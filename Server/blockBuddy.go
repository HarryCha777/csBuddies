package main

import (
	"context"
	"encoding/json"
	"fmt"
	"net/http"
)

func blockBuddy(w http.ResponseWriter, r *http.Request) {
	r.ParseForm()
	token := r.Form.Get("token")
	buddyId := r.Form.Get("buddyId")
	myId := getMyId(token)

	isValid :=
		isAuthenticated(myId) &&
			isExtantUserId(buddyId)
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

	var isBlocked bool
	err := pool.QueryRow(context.Background(), "select count(block_id) = 1 from block where user_id = $1 and buddy_id = $2 limit 1;", myId, buddyId).Scan(&isBlocked)
	handleError(err)

	if !isBlocked {
		_, err := pool.Exec(context.Background(), "insert into block (user_id, buddy_id) values ($1, $2);", myId, buddyId)
		handleError(err)
	}
}
