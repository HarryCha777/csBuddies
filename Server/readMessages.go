package main

import (
	"context"
	"fmt"
	"net/http"
)

func readMessages(w http.ResponseWriter, r *http.Request) {
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

	var hasReadReceipt bool
	err := pool.QueryRow(context.Background(), "select count(read_receipt_id) = 1 from read_receipt where user_id = $1 and buddy_id = $2 limit 1;", myId, buddyId).Scan(&hasReadReceipt)
	handleError(err)

	if !hasReadReceipt {
		_, err := pool.Exec(context.Background(), "insert into read_receipt (user_id, buddy_id) values ($1, $2);", myId, buddyId)
		handleError(err)
	} else {
		_, err := pool.Exec(context.Background(), "update read_receipt set last_read_at = current_timestamp where user_id = $1 and buddy_id = $2;", myId, buddyId)
		handleError(err)
	}

	sendChannel(buddyId)
}
