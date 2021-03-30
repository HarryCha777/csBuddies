package main

import (
	"context"
	"encoding/json"
	"fmt"
	"net/http"
)

func likeComment(w http.ResponseWriter, r *http.Request) {
	r.ParseForm()
	token := r.Form.Get("token")
	commentId := r.Form.Get("commentId")
	myId := getMyId(token)

	isValid :=
		isAuthenticated(myId) &&
			isExtantCommentId(commentId)
	if !isValid {
		fmt.Fprintln(w, "Invalid")
		return
	}

	var isOwnComment bool
	err := pool.QueryRow(context.Background(), "select count(comment_id) = 1 from comment where user_id = $1 and comment_id = $2 limit 1;", myId, commentId).Scan(&isOwnComment)
	handleError(err)

	if isOwnComment {
		fmt.Fprintln(w, "Invalid")
		return
	}

	var hasLikedBefore bool
	err = pool.QueryRow(context.Background(), "select count(comment_like_id) = 1 from comment_like where user_id = $1 and comment_id = $2 limit 1;", myId, commentId).Scan(&hasLikedBefore)
	handleError(err)

	var isLiked bool
	if hasLikedBefore {
		err = pool.QueryRow(context.Background(), "select is_liked from comment_like where user_id = $1 and comment_id = $2 limit 1;", myId, commentId).Scan(&isLiked)
		handleError(err)

		_, err := pool.Exec(context.Background(), "update comment_like set last_updated_at = current_timestamp, is_liked = true where user_id = $1 and comment_id = $2;", myId, commentId)
		handleError(err)
	} else {
		_, err := pool.Exec(context.Background(), "insert into comment_like (user_id, comment_id) values ($1, $2);", myId, commentId)
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
	err = pool.QueryRow(context.Background(), "select user_id from comment where comment_id = $1 limit 1;", commentId).Scan(&buddyId)
	handleError(err)

	if !isLiked {
		sendChannel(buddyId)
	}

	if !hasLikedBefore {
		var content string
		err = pool.QueryRow(context.Background(), "select content from comment where comment_id = $1 limit 1;", commentId).Scan(&content)
		handleError(err)

		sendNotification("comment like", myId, buddyId, content)
	}
}
