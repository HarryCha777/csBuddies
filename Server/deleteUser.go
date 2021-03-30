package main

import (
	"context"
	"fmt"
	"net/http"
)

func deleteUser(w http.ResponseWriter, r *http.Request) {
	r.ParseForm()
	token := r.Form.Get("token")
	reason := r.Form.Get("reason")
	comments := r.Form.Get("comments")
	myId := getMyId(token)

	isValid :=
		isAuthenticated(myId) &&
			isValidInt(reason, 0, 6) &&
			isValidString(comments, 0, 1000)
	if !isValid {
		fmt.Fprintln(w, "Invalid")
		return
	}

	var isDeleted bool
	err := pool.QueryRow(context.Background(), "select count(user_id) = 1 from account where user_id = $1 and deleted_at is not null limit 1;", myId).Scan(&isDeleted)
	handleError(err)

	if !isDeleted {
		_, err := pool.Exec(context.Background(), "update account set fcm_token = '', last_signed_out_at = current_timestamp, deleted_at = current_timestamp, deletion_reason = $1, deletion_comments = $2 where user_id = $3;", reason, comments, myId)
		handleError(err)
	}
}
