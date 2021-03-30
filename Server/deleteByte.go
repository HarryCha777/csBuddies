package main

import (
	"context"
	"encoding/json"
	"fmt"
	"net/http"
)

func deleteByte(w http.ResponseWriter, r *http.Request) {
	r.ParseForm()
	token := r.Form.Get("token")
	byteId := r.Form.Get("byteId")
	myId := getMyId(token)

	isValid :=
		isAuthenticated(myId) &&
			isExtantByteId(byteId)
	if !isValid {
		fmt.Fprintln(w, "Invalid")
		return
	}

	var userId string
	err := pool.QueryRow(context.Background(), "select user_id from byte where byte_id = $1 limit 1;", byteId).Scan(&userId)
	handleError(err)

	if myId != userId {
		fmt.Fprintln(w, "Invalid")
		return
	}

	var hasAlreadyDeleted bool
	err = pool.QueryRow(context.Background(), "select count(byte_id) = 0 from byte where deleted_at is null and byte_id = $1 limit 1;", byteId).Scan(&hasAlreadyDeleted)
	handleError(err)

	if !hasAlreadyDeleted {
		_, err := pool.Exec(context.Background(), "update byte set deleted_at = current_timestamp where byte_id = $1;", byteId)
		handleError(err)
	}

	mapper := map[string]interface{}{
		"hasAlreadyDeleted": hasAlreadyDeleted,
	}
	json, err := json.Marshal(mapper)
	handleError(err)

	w.Header().Set("Content-Type", "application/json")
	w.Write(json)
}
