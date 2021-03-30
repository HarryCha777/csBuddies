package main

import (
	"context"
	"encoding/json"
	"fmt"
	"net/http"
)

func addComment(w http.ResponseWriter, r *http.Request) {
	r.ParseForm()
	token := r.Form.Get("token")
	byteId := r.Form.Get("byteId")
	parentCommentId := r.Form.Get("parentCommentId")
	content := r.Form.Get("content")
	myId := getMyId(token)

	if parentCommentId == "" {
		parentCommentId = uuidNil
	}

	isValid :=
		isAuthenticated(myId) &&
			isValidString(content, 1, 256) &&
			isExtantByteId(byteId) &&
			(parentCommentId == uuidNil || isExtantByteCommentId(byteId, parentCommentId))
	if !isValid {
		fmt.Fprintln(w, "Invalid")
		return
	}

	var dailyComments int
	err := pool.QueryRow(context.Background(), "select count(comment_id) from comment where user_id = $1 and date(posted_at) = current_date limit 1;", myId).Scan(&dailyComments)
	handleError(err)

	if dailyComments >= 100 {
		mapper := map[string]interface{}{
			"dailyLimit": 100,
			"isTooMany":  true,
		}
		json, err := json.Marshal(mapper)
		handleError(err)

		w.Header().Set("Content-Type", "application/json")
		w.Write(json)
		return
	}

	var commentId string
	err = pool.QueryRow(context.Background(), "insert into comment (user_id, byte_id, parent_comment_id, content) values ($1, $2, $3, $4) returning comment_id;", myId, byteId, parentCommentId, content).Scan(&commentId)
	handleError(err)

	mapper := map[string]interface{}{
		"commentId": commentId,
	}
	json, err := json.Marshal(mapper)
	handleError(err)

	w.Header().Set("Content-Type", "application/json")
	w.Write(json)

	if parentCommentId == uuidNil {
		var buddyId string
		err := pool.QueryRow(context.Background(), "select user_id from byte where byte_id = $1 limit 1;", byteId).Scan(&buddyId)
		handleError(err)

		sendChannel(buddyId)
		sendNotification("byte comment", myId, buddyId, content)
	} else {
		var buddyId string
		err := pool.QueryRow(context.Background(), "select user_id from comment where comment_id = $1 limit 1;", parentCommentId).Scan(&buddyId)
		handleError(err)

		sendChannel(buddyId)
		sendNotification("comment reply", myId, buddyId, content)
	}
}
