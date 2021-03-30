package main

import (
	"context"
	"encoding/json"
	"fmt"
	"net/http"
	"time"
)

func getBuddy(w http.ResponseWriter, r *http.Request) {
	r.ParseForm()
	buddyId := r.Form.Get("buddyId")

	isValid :=
		isExtantUserId(buddyId)
	if !isValid {
		fmt.Fprintln(w, "Invalid")
		return
	}

	var username string
	var isBanned, isDeleted bool

	err := pool.QueryRow(context.Background(), "select username, banned_at is not null, deleted_at is not null from account where user_id = $1 limit 1;", buddyId).Scan(&username, &isBanned, &isDeleted)
	handleError(err)

	if isBanned {
		mapper := map[string]interface{}{
			"username": username,
			"isBanned": true,
		}
		json, err := json.Marshal(mapper)
		handleError(err)

		w.Header().Set("Content-Type", "application/json")
		w.Write(json)
		return
	}

	if isDeleted {
		mapper := map[string]interface{}{
			"username":  username,
			"isDeleted": true,
		}
		json, err := json.Marshal(mapper)
		handleError(err)

		w.Header().Set("Content-Type", "application/json")
		w.Write(json)
		return
	}

	var bytesMade int
	err = pool.QueryRow(context.Background(), "select count(byte_id) from byte where deleted_at is null and user_id = $1 limit 1;", buddyId).Scan(&bytesMade)
	handleError(err)

	var commentsMade int
	err = pool.QueryRow(context.Background(), "select count(comment_id) from comment where deleted_at is null and user_id = $1 limit 1;", buddyId).Scan(&commentsMade)
	handleError(err)

	query := `
	select count(byte.user_id)
	from   byte
	       left join byte_like
	              on byte.byte_id = byte_like.byte_id
	where  byte.byte_id = byte_like.byte_id
	       and byte_like.is_liked = true
	       and byte.user_id = $1
	limit  1;`

	var byteLikesReceived int
	err = pool.QueryRow(context.Background(), query, buddyId).Scan(&byteLikesReceived)
	handleError(err)

	query = `
	select count(comment.user_id)
	from   comment
	       left join comment_like
	              on comment.comment_id = comment_like.comment_id
	where  comment.comment_id = comment_like.comment_id
	       and comment_like.is_liked = true
	       and comment.user_id = $1
	limit  1;`

	var commentLikesReceived int
	err = pool.QueryRow(context.Background(), query, buddyId).Scan(&commentLikesReceived)
	handleError(err)

	var byteLikesGiven int
	err = pool.QueryRow(context.Background(), "select count(user_id) from byte_like where is_liked = true and user_id = $1 limit 1;", buddyId).Scan(&byteLikesGiven)
	handleError(err)

	var commentLikesGiven int
	err = pool.QueryRow(context.Background(), "select count(user_id) from comment_like where is_liked = true and user_id = $1 limit 1;", buddyId).Scan(&commentLikesGiven)
	handleError(err)

	var gender int
	var birthday time.Time
	var country int
	var interests string
	var intro string
	var github string
	var linkedin string
	var lastVisitedAt time.Time
	var lastUpdatedAt time.Time
	var isAdmin bool

	err = pool.QueryRow(context.Background(), "select gender, birthday, country, interests, intro, github, linkedin, last_visited_at, last_updated_at, became_admin_at is not null from account where user_id = $1 limit 1;", buddyId).Scan(&gender, &birthday, &country, &interests, &intro, &github, &linkedin, &lastVisitedAt, &lastUpdatedAt, &isAdmin)
	handleError(err)

	mapper := map[string]interface{}{
		"username":             username,
		"gender":               gender,
		"birthday":             birthday,
		"country":              country,
		"interests":            interests,
		"intro":                intro,
		"github":               github,
		"linkedin":             linkedin,
		"lastVisitedAt":        lastVisitedAt,
		"lastUpdatedAt":        lastUpdatedAt,
		"isAdmin":              isAdmin,
		"bytesMade":            bytesMade,
		"commentsMade":         commentsMade,
		"byteLikesReceived":    byteLikesReceived,
		"commentLikesReceived": commentLikesReceived,
		"byteLikesGiven":       byteLikesGiven,
		"commentLikesGiven":    commentLikesGiven,
	}
	json, err := json.Marshal(mapper)
	handleError(err)

	w.Header().Set("Content-Type", "application/json")
	w.Write(json)
}
