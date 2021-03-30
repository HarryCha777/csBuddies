package main

import (
	"context"
	"encoding/json"
	"fmt"
	"net/http"
	"time"
)

func getBlockedBuddies(w http.ResponseWriter, r *http.Request) {
	r.ParseForm()
	token := r.Form.Get("token")
	bottomBlockedAt := r.Form.Get("bottomBlockedAt")
	myId := getMyId(token)

	isValid :=
		isAuthenticated(myId) &&
			isValidTime(bottomBlockedAt)
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
	       block.blocked_at
	from   block
	       left join account
	              on block.buddy_id = account.user_id
	where  account.deleted_at is null
	       and block.user_id = $1
	       and block.blocked_at < $2
	order  by block.blocked_at desc
	limit  20;`

	rows, err := pool.Query(context.Background(), query, myId, bottomBlockedAt)
	handleError(err)
	defer rows.Close()

	mapper := map[int]interface{}{}
	newBottomBlockedAt := toTime(bottomBlockedAt)

	for rows.Next() {
		var buddyId string
		var username string
		var gender int
		var birthday time.Time
		var country int
		var intro string
		var lastVisitedAt time.Time
		var blockedAt time.Time

		err = rows.Scan(&buddyId, &username, &gender, &birthday, &country, &intro, &lastVisitedAt, &blockedAt)
		handleError(err)

		newBottomBlockedAt = blockedAt

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
		"bottomBlockedAt": newBottomBlockedAt,
	}
	mapper[len(mapper)] = newMapper

	json, err := json.Marshal(mapper)
	handleError(err)

	w.Header().Set("Content-Type", "application/json")
	w.Write(json)
}
