package main

import (
	"context"
	"encoding/json"
	"fmt"
	"net/http"
	"time"
)

func getLikedBytes(w http.ResponseWriter, r *http.Request) {
	r.ParseForm()
	token := r.Form.Get("token")
	userId := r.Form.Get("userId")
	bottomLastUpdatedAt := r.Form.Get("bottomLastUpdatedAt")
	myId := getMyId(token)

	isValid :=
		(myId == uuidNil || isAuthenticated(myId)) &&
			isExtantUserId(userId) &&
			isValidTime(bottomLastUpdatedAt)
	if !isValid {
		fmt.Fprintln(w, "Invalid")
		return
	}

	query := `
	select byte.byte_id,
           account.user_id,
           account.username,
           account.last_visited_at,
           byte.content,
           coalesce(all_byte_like.likes, 0),
           coalesce(comment.comments, 0),
           case
             when my_byte_like.byte_like_id is null then false
             else true
           end,
           byte.posted_at,
           user_byte_like.last_updated_at
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
           left join byte_like as user_byte_like
                  on user_byte_like.byte_id = byte.byte_id
                     and user_byte_like.is_liked = true
                     and user_byte_like.user_id = $2
    where  byte.deleted_at is null
           and user_byte_like.last_updated_at < $3
    order  by user_byte_like.last_updated_at desc
    limit  20;`

	rows, err := pool.Query(context.Background(), query, myId, userId, bottomLastUpdatedAt)
	handleError(err)
	defer rows.Close()

	mapper := map[int]interface{}{}
	newBottomLastUpdatedAt := toTime(bottomLastUpdatedAt)

	for rows.Next() {
		var byteId string
		var userId string
		var username string
		var lastVisitedAt time.Time
		var content string
		var likes int
		var comments int
		var isLiked bool
		var postedAt time.Time
		var lastUpdatedAt time.Time

		err = rows.Scan(&byteId, &userId, &username, &lastVisitedAt, &content, &likes, &comments, &isLiked, &postedAt, &lastUpdatedAt)
		handleError(err)

		newBottomLastUpdatedAt = lastUpdatedAt

		newMapper := map[string]interface{}{
			"byteId":        byteId,
			"userId":        userId,
			"username":      username,
			"lastVisitedAt": lastVisitedAt,
			"content":       content,
			"likes":         likes,
			"comments":      comments,
			"isLiked":       isLiked,
			"postedAt":      postedAt,
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
