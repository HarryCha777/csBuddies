package main

import (
	"context"
	"encoding/json"
	"fmt"
	"net/http"
)

func getImage(w http.ResponseWriter, r *http.Request) {
	r.ParseForm()
	userId := r.Form.Get("userId")
	size := r.Form.Get("size")

	isValid :=
		isExtantUserId(userId) &&
			(size == "small" || size == "big")
	if !isValid {
		fmt.Fprintln(w, "Invalid")
		return
	}

	var image string
	err := pool.QueryRow(context.Background(), "select "+size+"_image from account where user_id = $1 limit 1;", userId).Scan(&image)
	handleError(err)

	mapper := map[string]interface{}{
		"image": image,
	}
	json, err := json.Marshal(mapper)
	handleError(err)

	w.Header().Set("Content-Type", "application/json")
	w.Write(json)
}
