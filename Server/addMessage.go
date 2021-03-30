package main

import (
	"context"
	"encoding/json"
	"fmt"
	"net/http"
)

func addMessage(w http.ResponseWriter, r *http.Request) {
	r.ParseForm()
	token := r.Form.Get("token")
	buddyId := r.Form.Get("buddyId")
	content := r.Form.Get("content")
	myId := getMyId(token)

	isValid :=
		isAuthenticated(myId) &&
			isExtantUserId(buddyId) &&
			isValidString(content, 1, 256)
	if !isValid {
		fmt.Fprintln(w, "Invalid")
		return
	}

	var dailyChatBuddies int
	err := pool.QueryRow(context.Background(), "select count(buddy_id) from (select distinct buddy_id from message where user_id = $1 and date(sent_at) = current_date) as message;", myId).Scan(&dailyChatBuddies)
	handleError(err)

	if dailyChatBuddies >= 50 {
		mapper := map[string]interface{}{
			"dailyLimit": 50,
			"isTooMany":  true,
		}
		json, err := json.Marshal(mapper)
		handleError(err)

		w.Header().Set("Content-Type", "application/json")
		w.Write(json)
		return
	}

	var messageId string
	err = pool.QueryRow(context.Background(), "insert into message (user_id, buddy_id, content) values ($1, $2, $3) returning message_id;", myId, buddyId, content).Scan(&messageId)
	handleError(err)

	mapper := map[string]interface{}{
		"messageId": messageId,
	}
	json, err := json.Marshal(mapper)
	handleError(err)

	w.Header().Set("Content-Type", "application/json")
	w.Write(json)

	sendChannel(buddyId)
	sendNotification("message", myId, buddyId, content)
}
