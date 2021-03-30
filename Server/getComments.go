package main

import (
	"context"
	"encoding/json"
	"fmt"
	"net/http"
	"time"
)

func getComments(w http.ResponseWriter, r *http.Request) {
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
	select comment.comment_id,
           comment.byte_id,
           coalesce(parent_account.user_id, uuid_nil()),
           coalesce(parent_account.username, ''),
           comment.content,
           coalesce(all_comment_like.likes, 0),
           case
             when my_comment_like.comment_like_id is null then false
             else true
           end,
           comment.posted_at
    from   comment
           left join (select comment_id,
                             count(comment_like_id) as likes
                      from   comment_like
                      where  is_liked = true
                      group  by comment_id) as all_comment_like
                  on all_comment_like.comment_id = comment.comment_id
           left join comment_like as my_comment_like
                  on my_comment_like.comment_id = comment.comment_id
                     and my_comment_like.is_liked = true
                     and my_comment_like.user_id = $1
           left join comment as parent_comment
                  on parent_comment.comment_id = comment.parent_comment_id
           left join account as parent_account
                  on parent_account.user_id = parent_comment.user_id
    where  comment.deleted_at is null
           and comment.user_id = $2
           and comment.posted_at < $3
    order  by comment.posted_at desc
    limit  20;`

	rows, err := pool.Query(context.Background(), query, myId, userId, bottomPostedAt)
	handleError(err)
	defer rows.Close()

	mapper := map[int]interface{}{}
	newBottomPostedAt := toTime(bottomPostedAt)

	for rows.Next() {
		var commentId string
		var byteId string
		var parentUserId string
		var parentUsername string
		var content string
		var likes int
		var isLiked bool
		var postedAt time.Time

		err = rows.Scan(&commentId, &byteId, &parentUserId, &parentUsername, &content, &likes, &isLiked, &postedAt)
		handleError(err)

		newBottomPostedAt = postedAt

		newMapper := map[string]interface{}{
			"commentId":      commentId,
			"byteId":         byteId,
			"parentUserId":   parentUserId,
			"parentUsername": parentUsername,
			"content":        content,
			"likes":          likes,
			"isLiked":        isLiked,
			"postedAt":       postedAt,
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
