package main

import (
	"context"
	"encoding/json"
	"fmt"
	"net/http"
)

func likeByte(w http.ResponseWriter, r *http.Request) {
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

	var isOwnByte bool
	err := pool.QueryRow(context.Background(), "select count(byte_id) = 1 from byte where user_id = $1 and byte_id = $2 limit 1;", myId, byteId).Scan(&isOwnByte)
	handleError(err)

	if isOwnByte {
		fmt.Fprintln(w, "Invalid")
		return
	}

	var hasLikedBefore bool
	err = pool.QueryRow(context.Background(), "select count(byte_like_id) = 1 from byte_like where user_id = $1 and byte_id = $2 limit 1;", myId, byteId).Scan(&hasLikedBefore)
	handleError(err)

	var isLiked bool
	if hasLikedBefore {
		err = pool.QueryRow(context.Background(), "select is_liked from byte_like where user_id = $1 and byte_id = $2 limit 1;", myId, byteId).Scan(&isLiked)
		handleError(err)

		_, err := pool.Exec(context.Background(), "update byte_like set last_updated_at = current_timestamp, is_liked = true where user_id = $1 and byte_id = $2;", myId, byteId)
		handleError(err)
	} else {
		_, err := pool.Exec(context.Background(), "insert into byte_like (user_id, byte_id) values ($1, $2);", myId, byteId)
		handleError(err)
	}

	mapper := map[string]interface{}{
		"isLiked": isLiked,
	}
	json, err := json.Marshal(mapper)
	handleError(err)

	w.Header().Set("Content-Type", "application/json")
	w.Write(json)

	var buddyId string
	err = pool.QueryRow(context.Background(), "select user_id from byte where byte_id = $1 limit 1;", byteId).Scan(&buddyId)
	handleError(err)

	if !isLiked {
		sendChannel(buddyId)
	}

	if !hasLikedBefore {
		var content string
		err = pool.QueryRow(context.Background(), "select content from byte where byte_id = $1 limit 1;", byteId).Scan(&content)
		handleError(err)

		sendNotification("byte like", myId, buddyId, content)
	}
}
