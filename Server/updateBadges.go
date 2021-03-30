package main

import (
	"context"
	"fmt"
	"net/http"
)

func updateBadges(w http.ResponseWriter, r *http.Request) {
	r.ParseForm()
	token := r.Form.Get("token")
	badges := r.Form.Get("badges")
	myId := getMyId(token)

	isValid :=
		isAuthenticated(myId) &&
			isValidInt(badges, 0, 30000)
	if !isValid {
		fmt.Fprintln(w, "Invalid")
		return
	}

	_, err := pool.Exec(context.Background(), "update account set badges = $1 where user_id = $2;", badges, myId)
	handleError(err)
}
