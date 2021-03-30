package main

import (
	"context"
	"encoding/json"
	"fmt"
	"net/http"
	"time"
)

func getUser(w http.ResponseWriter, r *http.Request) {
	r.ParseForm()
	token := r.Form.Get("token")
	myId := getMyId(token)

	isValid :=
		isAuthenticated(myId)
	if !isValid {
		fmt.Fprintln(w, "Invalid")
		return
	}

	_, err := pool.Exec(context.Background(), "update account set client_outdated_at = null where user_id = $1;", myId)
	handleError(err)

	var bytesMade int
	err = pool.QueryRow(context.Background(), "select count(byte_id) from byte where deleted_at is null and user_id = $1 limit 1;", myId).Scan(&bytesMade)
	handleError(err)

	var commentsMade int
	err = pool.QueryRow(context.Background(), "select count(comment_id) from comment where deleted_at is null and user_id = $1 limit 1;", myId).Scan(&commentsMade)
	handleError(err)

	byteLikesReceived := getByteLikesReceived(myId)
	commentLikesReceived := getCommentLikesReceived(myId)

	var byteLikesGiven int
	err = pool.QueryRow(context.Background(), "select count(byte_like_id) from byte_like where is_liked = true and user_id = $1 limit 1;", myId).Scan(&byteLikesGiven)
	handleError(err)

	var commentLikesGiven int
	err = pool.QueryRow(context.Background(), "select count(comment_like_id) from comment_like where is_liked = true and user_id = $1 limit 1;", myId).Scan(&commentLikesGiven)
	handleError(err)

	rows, err := pool.Query(context.Background(), "select buddy_id from block where user_id = $1;", myId)
	handleError(err)
	defer rows.Close()

	var blockedBuddyIds []map[string]interface{}
	for rows.Next() {
		var buddyId string

		err = rows.Scan(&buddyId)
		handleError(err)

		mapper := map[string]interface{}{
			"buddyId": buddyId,
		}
		blockedBuddyIds = append(blockedBuddyIds, mapper)
	}
	handleError(rows.Err())

	var username string
	var smallImage string
	var bigImage string
	var gender int
	var birthday time.Time
	var country int
	var interests string
	var otherInterests string
	var intro string
	var github string
	var linkedin string
	var notifyLikes bool
	var notifyComments bool
	var notifyMessages bool

	err = pool.QueryRow(context.Background(), "select username, small_image, big_image, gender, birthday, country, interests, other_interests, intro, github, linkedin, notify_likes, notify_comments, notify_messages from account where user_id = $1 limit 1;", myId).Scan(&username, &smallImage, &bigImage, &gender, &birthday, &country, &interests, &otherInterests, &intro, &github, &linkedin, &notifyLikes, &notifyComments, &notifyMessages)
	handleError(err)

	mapper := map[string]interface{}{
		"username":          username,
		"smallImage":        smallImage,
		"bigImage":          bigImage,
		"gender":            gender,
		"birthday":          birthday,
		"country":           country,
		"interests":         interests,
		"otherInterests":    otherInterests,
		"intro":             intro,
		"github":            github,
		"linkedin":          linkedin,
		"notifyLikes":       notifyLikes,
		"notifyComments":    notifyComments,
		"notifyMessages":    notifyMessages,
		"bytesMade":         bytesMade,
		"commentsMade":      commentsMade,
		"byteLikesReceived":    byteLikesReceived,
		"commentLikesReceived": commentLikesReceived,
		"byteLikesGiven":    byteLikesGiven,
		"commentLikesGiven": commentLikesGiven,
		"blockedBuddyIds":   blockedBuddyIds,
	}
	json, err := json.Marshal(mapper)
	handleError(err)

	w.Header().Set("Content-Type", "application/json")
	w.Write(json)
}
