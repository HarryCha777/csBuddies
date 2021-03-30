package main

import (
	"context"
	"fmt"
	"net/http"
)

func signIn(w http.ResponseWriter, r *http.Request) {
	r.ParseForm()
	token := r.Form.Get("token")
	fcmToken := r.Form.Get("fcmToken")
	myId := getMyId(token)

	isValid :=
		isAuthenticated(myId, true) &&
			isValidString(fcmToken, 0, 1000)
	if !isValid {
		fmt.Fprintln(w, "Invalid")
		return
	}

	_, err := pool.Exec(context.Background(), "update account set fcm_token = $1, last_signed_in_at = current_timestamp, disabled_at = null where user_id = $2;", fcmToken, myId)
	handleError(err)
}
