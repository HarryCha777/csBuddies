package main

import (
	"context"
	"fmt"
	"net/http"
)

func signOut(w http.ResponseWriter, r *http.Request) {
	r.ParseForm()
	token := r.Form.Get("token")
	myId := getMyId(token)

	isValid :=
		isAuthenticated(myId)
	if !isValid {
		fmt.Fprintln(w, "Invalid")
		return
	}

	_, err := pool.Exec(context.Background(), "update account set fcm_token = '', last_signed_out_at = current_timestamp where user_id = $1;", myId)
	handleError(err)
}
