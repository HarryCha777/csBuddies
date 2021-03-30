package main

import (
	"context"
	"fmt"
	"net/http"
)

func updateNotifications(w http.ResponseWriter, r *http.Request) {
	r.ParseForm()
	token := r.Form.Get("token")
	notifyLikes := r.Form.Get("notifyLikes")
	notifyComments := r.Form.Get("notifyComments")
	notifyMessages := r.Form.Get("notifyMessages")
	myId := getMyId(token)

	isValid :=
		isAuthenticated(myId) &&
			isValidBool(notifyLikes) &&
			isValidBool(notifyComments) &&
			isValidBool(notifyMessages)
	if !isValid {
		fmt.Fprintln(w, "Invalid")
		return
	}

	_, err := pool.Exec(context.Background(), "update account set notify_likes = $1, notify_comments = $2, notify_messages = $3 where user_id = $4;", notifyLikes, notifyComments, notifyMessages, myId)
	handleError(err)
}
