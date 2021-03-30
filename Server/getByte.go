package main

import (
	"context"
	"encoding/json"
	"fmt"
	"net/http"
	"time"
)

func getByte(w http.ResponseWriter, r *http.Request) {
	r.ParseForm()
	token := r.Form.Get("token")
	byteId := r.Form.Get("byteId")
	myId := getMyId(token)

	isValid :=
		(myId == uuidNil || isAuthenticated(myId)) &&
			isExtantByteId(byteId)
	if !isValid {
		fmt.Fprintln(w, "Invalid")
		return
	}

	var isDeleted bool
	err := pool.QueryRow(context.Background(), "select deleted_at is not null from byte where byte_id = $1 limit 1;", byteId).Scan(&isDeleted)
	handleError(err)

	if isDeleted {
		mapper := map[string]interface{}{
			"isDeleted": true,
		}
		json, err := json.Marshal(mapper)
		handleError(err)

		w.Header().Set("Content-Type", "application/json")
		w.Write(json)
		return
	}

	query := `
	select account.user_id,
           account.username,
           account.last_visited_at,
           byte.content,
           coalesce(all_byte_like.likes, 0),
           coalesce(comment.comments, 0),
           case
             when my_byte_like.byte_like_id is null then false
             else true
           end,
           byte.posted_at
    from   byte
           left join account
                  on account.user_id = byte.user_id
           left join (select byte_id,
                             count(comment_id) as comments
                      from   comment
                      where  deleted_at is null
                      group  by byte_id) as comment
                  on comment.byte_id = byte.byte_id
           left join (select byte_id,
                             count(byte_like_id) as likes
                      from   byte_like
                      where  is_liked = true
                      group  by byte_id) as all_byte_like
                  on all_byte_like.byte_id = byte.byte_id
           left join byte_like as my_byte_like
                  on my_byte_like.byte_id = byte.byte_id
                     and my_byte_like.is_liked = true
                     and my_byte_like.user_id = $1
    where  byte.byte_id = $2;`

	var userId string
	var username string
	var lastVisitedAt time.Time
	var content string
	var likes int
	var comments int
	var isLiked bool
	var postedAt time.Time

	err = pool.QueryRow(context.Background(), query, myId, byteId).Scan(&userId, &username, &lastVisitedAt, &content, &likes, &comments, &isLiked, &postedAt)
	handleError(err)

	mapper := map[string]interface{}{
		"userId":        userId,
		"username":      username,
		"lastVisitedAt": lastVisitedAt,
		"content":       content,
		"likes":         likes,
		"comments":      comments,
		"isLiked":       isLiked,
		"postedAt":      postedAt,
	}
	json, err := json.Marshal(mapper)
	handleError(err)

	w.Header().Set("Content-Type", "application/json")
	w.Write(json)
}
