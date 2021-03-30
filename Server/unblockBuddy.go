package main

import (
	"context"
	"fmt"
	"net/http"
)

func unblockBuddy(w http.ResponseWriter, r *http.Request) {
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

	_, err := pool.Exec(context.Background(), "delete from block where user_id = $1 and buddy_id = $2;", myId, buddyId)
	handleError(err)
}
