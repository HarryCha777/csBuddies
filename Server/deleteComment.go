package main

import (
	"context"
	"encoding/json"
	"fmt"
	"net/http"
)

func deleteComment(w http.ResponseWriter, r *http.Request) {
	r.ParseForm()
	token := r.Form.Get("token")
	commentId := r.Form.Get("commentId")
	myId := getMyId(token)

	isValid :=
		isAuthenticated(myId) &&
			isExtantCommentId(commentId)
	if !isValid {
		fmt.Fprintln(w, "Invalid")
		return
	}

	var userId string
	err := pool.QueryRow(context.Background(), "select user_id from comment where comment_id = $1 limit 1;", commentId).Scan(&userId)
	handleError(err)

	if myId != userId {
		fmt.Fprintln(w, "Invalid")
		return
	}

	var hasAlreadyDeleted bool
	err = pool.QueryRow(context.Background(), "select count(comment_id) = 0 from comment where deleted_at is null and comment_id = $1 limit 1;", commentId).Scan(&hasAlreadyDeleted)
	handleError(err)

	if !hasAlreadyDeleted {
		_, err := pool.Exec(context.Background(), "update comment set deleted_at = current_timestamp where comment_id = $1;", commentId)
		handleError(err)
	}

	mapper := map[string]interface{}{
		"hasAlreadyDeleted": hasAlreadyDeleted,
	}
	json, err := json.Marshal(mapper)
	handleError(err)

	w.Header().Set("Content-Type", "application/json")
	w.Write(json)
}
