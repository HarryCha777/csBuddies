package main

import (
	"context"
	"encoding/json"
	"fmt"
	"net/http"
	"time"
)

func getLikedComments(w http.ResponseWriter, r *http.Request) {
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
	select comment.comment_id,
           comment.byte_id,
           account.user_id,
           account.username,
           account.last_visited_at,
           coalesce(parent_account.user_id, uuid_nil()),
           coalesce(parent_account.username, ''),
           comment.content,
           coalesce(all_comment_like.likes, 0),
           case
             when my_comment_like.comment_like_id is null then false
             else true
           end,
           comment.posted_at,
           user_comment_like.last_updated_at
    from   comment
           left join account
                  on account.user_id = comment.user_id
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
           left join comment_like as user_comment_like
                  on user_comment_like.comment_id = comment.comment_id
                     and user_comment_like.is_liked = true
                     and user_comment_like.user_id = $2
           left join comment as parent_comment
                  on parent_comment.comment_id = comment.parent_comment_id
           left join account as parent_account
                  on parent_account.user_id = parent_comment.user_id
    where  comment.deleted_at is null
           and user_comment_like.last_updated_at < $3
    order  by user_comment_like.last_updated_at desc
    limit  20;`

	rows, err := pool.Query(context.Background(), query, myId, userId, bottomLastUpdatedAt)
	handleError(err)
	defer rows.Close()

	mapper := map[int]interface{}{}
	newBottomLastUpdatedAt := toTime(bottomLastUpdatedAt)

	for rows.Next() {
		var commentId string
		var byteId string
		var userId string
		var username string
		var lastVisitedAt time.Time
		var parentUserId string
		var parentUsername string
		var content string
		var likes int
		var isLiked bool
		var postedAt time.Time
		var lastUpdatedAt time.Time

		err = rows.Scan(&commentId, &byteId, &userId, &username, &lastVisitedAt, &parentUserId, &parentUsername, &content, &likes, &isLiked, &postedAt, &lastUpdatedAt)
		handleError(err)

		newBottomLastUpdatedAt = lastUpdatedAt

		newMapper := map[string]interface{}{
			"commentId":      commentId,
			"byteId":         byteId,
			"userId":         userId,
			"username":       username,
			"lastVisitedAt":  lastVisitedAt,
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
		"bottomLastUpdatedAt": newBottomLastUpdatedAt,
	}
	mapper[len(mapper)] = newMapper

	json, err := json.Marshal(mapper)
	handleError(err)

	w.Header().Set("Content-Type", "application/json")
	w.Write(json)
}
