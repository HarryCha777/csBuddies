package main

import (
	"context"
	"encoding/json"
	"fmt"
	"net/http"
)

func addByte(w http.ResponseWriter, r *http.Request) {
	r.ParseForm()
	token := r.Form.Get("token")
	content := r.Form.Get("content")
	myId := getMyId(token)

	isValid :=
		isAuthenticated(myId) &&
			isValidString(content, 1, 256)
	if !isValid {
		fmt.Fprintln(w, "Invalid")
		return
	}

	var dailyBytes int
	err := pool.QueryRow(context.Background(), "select count(byte_id) from byte where user_id = $1 and date(posted_at) = current_date limit 1;", myId).Scan(&dailyBytes)
	handleError(err)

	if dailyBytes >= 50 {
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

	var byteId string
	err = pool.QueryRow(context.Background(), "insert into byte (user_id, content) values ($1, $2) returning byte_id;", myId, content).Scan(&byteId)
	handleError(err)

	mapper := map[string]interface{}{
		"byteId": byteId,
	}
	json, err := json.Marshal(mapper)
	handleError(err)

	w.Header().Set("Content-Type", "application/json")
	w.Write(json)
}
