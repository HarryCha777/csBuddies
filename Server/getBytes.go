package main

import (
	"context"
	"encoding/json"
	"fmt"
	"net/http"
	"time"
)

func getBytes(w http.ResponseWriter, r *http.Request) {
	r.ParseForm()
	token := r.Form.Get("token")
	userId := r.Form.Get("userId")
	bottomPostedAt := r.Form.Get("bottomPostedAt")
	myId := getMyId(token)

	isValid :=
		(myId == uuidNil || isAuthenticated(myId)) &&
			isExtantUserId(userId) &&
			isValidTime(bottomPostedAt)
	if !isValid {
		fmt.Fprintln(w, "Invalid")
		return
	}

	query := `
	select byte.byte_id,
           byte.content,
           coalesce(all_byte_like.likes, 0),
           coalesce(comment.comments, 0),
           case
             when my_byte_like.byte_like_id is null then false
             else true
           end,
           byte.posted_at
    from   byte
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
    where  byte.deleted_at is null
           and byte.user_id = $2
           and byte.posted_at < $3
    order  by byte.posted_at desc
    limit  20;`

	rows, err := pool.Query(context.Background(), query, myId, userId, bottomPostedAt)
	handleError(err)
	defer rows.Close()

	mapper := map[int]interface{}{}
	newBottomPostedAt := toTime(bottomPostedAt)

	for rows.Next() {
		var byteId string
		var content string
		var likes int
		var comments int
		var isLiked bool
		var postedAt time.Time

		err = rows.Scan(&byteId, &content, &likes, &comments, &isLiked, &postedAt)
		handleError(err)

		newBottomPostedAt = postedAt

		newMapper := map[string]interface{}{
			"byteId":   byteId,
			"content":  content,
			"likes":    likes,
			"comments": comments,
			"isLiked":  isLiked,
			"postedAt": postedAt,
		}
		mapper[len(mapper)] = newMapper
	}
	handleError(rows.Err())

	newMapper := map[string]interface{}{
		"bottomPostedAt": newBottomPostedAt,
	}
	mapper[len(mapper)] = newMapper

	json, err := json.Marshal(mapper)
	handleError(err)

	w.Header().Set("Content-Type", "application/json")
	w.Write(json)
}
