package main

import (
	"context"
	"encoding/json"
	"fmt"
	"net/http"
)

func requestNewUsername(w http.ResponseWriter, r *http.Request) {
	r.ParseForm()
	token := r.Form.Get("token")
	newUsername := r.Form.Get("newUsername")
	reason := r.Form.Get("reason")
	comments := r.Form.Get("comments")
	mustReplace := r.Form.Get("mustReplace")
	myId := getMyId(token)

	isValid :=
		isAuthenticated(myId) &&
			isValidUsername(newUsername) &&
			isValidInt(reason, 0, 2) &&
			isValidString(comments, 0, 1000) &&
			isValidBool(mustReplace)
	if !isValid {
		fmt.Fprintln(w, "Invalid")
		return
	}

	if isExtantUsername(newUsername) {
		mapper := map[string]interface{}{
			"isExtantUsername": true,
		}
		json, err := json.Marshal(mapper)
		handleError(err)

		w.Header().Set("Content-Type", "application/json")
		w.Write(json)
		return
	}

	if !toBool(mustReplace) {
		var isExtantRequest bool
		err := pool.QueryRow(context.Background(), "select count(username_change_request_id) = 1 from username_change_request where user_id = $1 and reviewed_at is null limit 1;", myId).Scan(&isExtantRequest)
		handleError(err)

		if isExtantRequest {
			mapper := map[string]interface{}{
				"isExtantRequest": isExtantRequest,
			}
			json, err := json.Marshal(mapper)
			handleError(err)

			w.Header().Set("Content-Type", "application/json")
			w.Write(json)
			return
		}
	}

	if toBool(mustReplace) {
		_, err := pool.Exec(context.Background(), "delete from username_change_request where user_id = $1 and reviewed_at is null;", myId)
		handleError(err)
	}

	var username string
	err := pool.QueryRow(context.Background(), "select username from account where user_id = $1 limit 1;", myId).Scan(&username)
	handleError(err)

	_, err = pool.Exec(context.Background(), "insert into username_change_request (user_id, username, new_username, reason, comments) values ($1, $2, $3, $4, $5);", myId, username, newUsername, reason, comments)
	handleError(err)
}
