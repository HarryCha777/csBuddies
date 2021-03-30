package main

import (
	"context"
	"encoding/json"
	"fmt"
	"net/http"
	"time"
)

func getByteLikes(w http.ResponseWriter, r *http.Request) {
	r.ParseForm()
	token := r.Form.Get("token")
	byteId := r.Form.Get("byteId")
	bottomLastUpdatedAt := r.Form.Get("bottomLastUpdatedAt")
	myId := getMyId(token)

	isValid :=
		(myId == uuidNil || isAuthenticated(myId)) &&
			isExtantByteId(byteId) &&
			isValidTime(bottomLastUpdatedAt)
	if !isValid {
		fmt.Fprintln(w, "Invalid")
		return
	}

	query := `
	select account.user_id,
           account.username,
           account.gender,
           account.birthday,
           account.country,
           account.intro,
           account.last_visited_at,
           byte_like.last_updated_at
    from   account
           left join byte_like
                  on account.user_id = byte_like.user_id
    where  ( account.banned_at is null
              or account.user_id = $1 )
           and account.deleted_at is null
           and byte_like.is_liked = true
           and byte_like.byte_id = $2
           and byte_like.last_updated_at < $3
    order  by byte_like.last_updated_at desc
    limit  20;`

	rows, err := pool.Query(context.Background(), query, myId, byteId, bottomLastUpdatedAt)
	handleError(err)
	defer rows.Close()

	mapper := map[int]interface{}{}
	newBottomLastUpdatedAt := toTime(bottomLastUpdatedAt)

	for rows.Next() {
		var buddyId string
		var username string
		var gender int
		var birthday time.Time
		var country int
		var intro string
		var lastVisitedAt time.Time
		var lastUpdatedAt time.Time

		err = rows.Scan(&buddyId, &username, &gender, &birthday, &country, &intro, &lastVisitedAt, &lastUpdatedAt)
		handleError(err)

		newBottomLastUpdatedAt = lastUpdatedAt

		newMapper := map[string]interface{}{
			"buddyId":       buddyId,
			"username":      username,
			"gender":        gender,
			"birthday":      birthday,
			"country":       country,
			"intro":         intro,
			"lastVisitedAt": lastVisitedAt,
		}
		mapper[len(mapper)] = newMapper
	}
	handleError(rows.Err())

	newMapper := map[string]interface{}{
		"bottomLastUpdatedAt": newBottomLastUpdatedAt,
	}
	mapper[len(mapper)] = newMapper

	json, err := json.Marshal(mapper)
	handleError(err)

	w.Header().Set("Content-Type", "application/json")
	w.Write(json)
}
