package main

import (
	"context"
	"encoding/json"
	"fmt"
	"net/http"
)

func reportBuddy(w http.ResponseWriter, r *http.Request) {
	r.ParseForm()
	token := r.Form.Get("token")
	buddyId := r.Form.Get("buddyId")
	reason := r.Form.Get("reason")
	comments := r.Form.Get("comments")
	mustReplace := r.Form.Get("mustReplace")
	myId := getMyId(token)

	isValid :=
		isAuthenticated(myId) &&
			isExtantUserId(buddyId) &&
			isValidInt(reason, 0, 6) &&
			isValidString(comments, 0, 1000) &&
			isValidBool(mustReplace)
	if !isValid {
		fmt.Fprintln(w, "Invalid")
		return
	}

	if isAdmin(buddyId) {
		mapper := map[string]interface{}{
			"isAdmin": true,
		}
		json, err := json.Marshal(mapper)
		handleError(err)

		w.Header().Set("Content-Type", "application/json")
		w.Write(json)
		return
	}

	if !toBool(mustReplace) {
		var isExtantReport bool
		err := pool.QueryRow(context.Background(), "select count(report_id) = 1 from report where user_id = $1 and buddy_id = $2 and reviewed_at is null limit 1;", myId, buddyId).Scan(&isExtantReport)
		handleError(err)

		if isExtantReport {
			mapper := map[string]interface{}{
				"isExtantReport": isExtantReport,
			}
			json, err := json.Marshal(mapper)
			handleError(err)

			w.Header().Set("Content-Type", "application/json")
			w.Write(json)
			return
		}
	}

	if toBool(mustReplace) {
		_, err := pool.Exec(context.Background(), "delete from report where user_id = $1 and buddy_id = $2 and reviewed_at is null;", myId, buddyId)
		handleError(err)
	}

	_, err := pool.Exec(context.Background(), "insert into report (user_id, buddy_id, reason, comments) values ($1, $2, $3, $4);", myId, buddyId, reason, comments)
	handleError(err)
}
