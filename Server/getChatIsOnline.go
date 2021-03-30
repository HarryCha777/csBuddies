package main

import (
	"context"
	"encoding/json"
	"fmt"
	"net/http"
	"time"
)

func getChatIsOnline(w http.ResponseWriter, r *http.Request) {
	r.ParseForm()
	token := r.Form.Get("token")
	myId := getMyId(token)

	isValid :=
		isAuthenticated(myId)
	if !isValid {
		fmt.Fprintln(w, "Invalid")
		return
	}

	query := `
	select account.user_id,
           account.last_visited_at
    from   account
           left join message
                  on account.user_id = message.buddy_id
    where  message.user_id = $1
    group  by account.user_id;`

	rows, err := pool.Query(context.Background(), query, myId)
	handleError(err)
	defer rows.Close()

	mapper := map[int]interface{}{}
	for rows.Next() {
		var buddyId string
		var lastVisitedAt time.Time

		err = rows.Scan(&buddyId, &lastVisitedAt)
		handleError(err)

		newMapper := map[string]interface{}{
			"buddyId":       buddyId,
			"lastVisitedAt": lastVisitedAt,
		}
		mapper[len(mapper)] = newMapper
	}
	handleError(rows.Err())

	json, err := json.Marshal(mapper)
	handleError(err)

	w.Header().Set("Content-Type", "application/json")
	w.Write(json)
}
