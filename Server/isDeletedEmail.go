package main

import (
	"context"
	"encoding/json"
	"fmt"
	"net/http"
)

func isDeletedEmail(w http.ResponseWriter, r *http.Request) {
	r.ParseForm()
	email := r.Form.Get("email")

	isValid :=
		isValidString(email, 3, 320)
	if !isValid {
		fmt.Fprintln(w, "Invalid")
		return
	}

	var isDeletedEmail bool
	err := pool.QueryRow(context.Background(), "select count(user_id) = 1 from account where lower(email) = lower($1) and deleted_at is not null limit 1;", email).Scan(&isDeletedEmail)
	handleError(err)

	mapper := map[string]interface{}{
		"isDeletedEmail": isDeletedEmail,
	}
	json, err := json.Marshal(mapper)
	handleError(err)

	w.Header().Set("Content-Type", "application/json")
	w.Write(json)
}
