package main

import (
	"context"
	"fmt"
	"net/http"
)

func updateFcmToken(w http.ResponseWriter, r *http.Request) {
	r.ParseForm()
	token := r.Form.Get("token")
	fcmToken := r.Form.Get("fcmToken")
	myId := getMyId(token)

	isValid :=
		isAuthenticated(myId) &&
			isValidString(fcmToken, 0, 1000)
	if !isValid {
		fmt.Fprintln(w, "Invalid")
		return
	}

	_, err := pool.Exec(context.Background(), "update account set fcm_token = $1 where user_id = $2;", fcmToken, myId)
	handleError(err)
}
