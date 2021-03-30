package main

import (
	"context"
	"encoding/json"
	"fmt"
	"net/http"
	"time"
)

func syncUser(w http.ResponseWriter, r *http.Request) {
	r.ParseForm()
	token := r.Form.Get("token")
	myId := getMyId(token)

	isValid :=
		isAuthenticated(myId)
	if !isValid {
		fmt.Fprintln(w, "Invalid")
		return
	}

	var lastOutdatedAt time.Time
	var lastSyncedAt time.Time
	var isAdmin bool
	var isClientOutdated bool
	var isBanned bool

	err := pool.QueryRow(context.Background(), "select last_outdated_at, last_synced_at, became_admin_at is not null, client_outdated_at is not null, banned_at is not null from account where user_id = $1 limit 1;", myId).Scan(&lastOutdatedAt, &lastSyncedAt, &isAdmin, &isClientOutdated, &isBanned)
	handleError(err)

	_, err = pool.Exec(context.Background(), "update account set last_synced_at = current_timestamp where user_id = $1;", myId)
	handleError(err)

	if lastSyncedAt.After(lastOutdatedAt) || isBanned {
		mapper := map[string]interface{}{
			"isAdmin":          isAdmin,
			"isClientOutdated": isClientOutdated,
			"hasInteraction":   false,
		}
		json, err := json.Marshal(mapper)
		handleError(err)

		w.Header().Set("Content-Type", "application/json")
		w.Write(json)
		return
	}

	byteLikesReceived := getByteLikesReceived(myId)
	commentLikesReceived := getCommentLikesReceived(myId)

	query := `
	select byte_like.byte_like_id,
           byte.byte_id,
           account.user_id,
           account.username,
           account.last_visited_at,
           byte.content,
           byte_like.last_updated_at
    from   byte_like
           left join byte
                  on byte_like.byte_id = byte.byte_id
           left join account
                  on byte_like.user_id = account.user_id
           left join block
                  on block.user_id = byte.user_id
    where  byte.user_id = $1
           and not byte.user_id = byte_like.user_id
           and not coalesce(block.buddy_id, uuid_nil()) = account.user_id
           and account.banned_at is null
           and byte_like.is_liked = true
           and byte_like.last_updated_at > $2;`

	rows, err := pool.Query(context.Background(), query, myId, lastSyncedAt)
	handleError(err)
	defer rows.Close()

	var byteLikes []map[string]interface{}
	for rows.Next() {
		var notificationId string
		var byteId string
		var buddyId string
		var buddyUsername string
		var lastVisitedAt time.Time
		var content string
		var notifiedAt time.Time

		err = rows.Scan(&notificationId, &byteId, &buddyId, &buddyUsername, &lastVisitedAt, &content, &notifiedAt)
		handleError(err)

		mapper := map[string]interface{}{
			"notificationId": notificationId,
			"byteId":         byteId,
			"buddyId":        buddyId,
			"buddyUsername":  buddyUsername,
			"lastVisitedAt":  lastVisitedAt,
			"content":        content,
			"notifiedAt":     notifiedAt,
		}
		byteLikes = append(byteLikes, mapper)
	}
	handleError(rows.Err())

	query = `
	select comment_like.comment_like_id,
           comment.byte_id,
           account.user_id,
           account.username,
           account.last_visited_at,
           comment.content,
           comment_like.last_updated_at
    from   comment_like
           left join comment
                  on comment_like.comment_id = comment.comment_id
           left join account
                  on comment_like.user_id = account.user_id
           left join block
                  on block.user_id = comment.user_id
    where  comment.user_id = $1
           and not comment.user_id = comment_like.user_id
           and not coalesce(block.buddy_id, uuid_nil()) = account.user_id
           and account.banned_at is null
           and comment_like.is_liked = true
           and comment_like.last_updated_at > $2;`

	rows, err = pool.Query(context.Background(), query, myId, lastSyncedAt)
	handleError(err)
	defer rows.Close()

	var commentLikes []map[string]interface{}
	for rows.Next() {
		var notificationId string
		var byteId string
		var buddyId string
		var buddyUsername string
		var lastVisitedAt time.Time
		var content string
		var notifiedAt time.Time

		err = rows.Scan(&notificationId, &byteId, &buddyId, &buddyUsername, &lastVisitedAt, &content, &notifiedAt)
		handleError(err)

		mapper := map[string]interface{}{
			"notificationId": notificationId,
			"byteId":         byteId,
			"buddyId":        buddyId,
			"buddyUsername":  buddyUsername,
			"lastVisitedAt":  lastVisitedAt,
			"content":        content,
			"notifiedAt":     notifiedAt,
		}
		commentLikes = append(commentLikes, mapper)
	}
	handleError(rows.Err())

	query = `
	select comment.comment_id,
           byte.byte_id,
           account.user_id,
           account.username,
           account.last_visited_at,
           comment.content,
           comment.posted_at
    from   byte
           left join comment
                  on comment.byte_id = byte.byte_id
           left join account
                  on account.user_id = comment.user_id
           left join block
                  on block.user_id = byte.user_id
    where  byte.user_id = $1
           and not byte.user_id = comment.user_id
           and not coalesce(block.buddy_id, uuid_nil()) = account.user_id
           and account.banned_at is null
           and comment.parent_comment_id = uuid_nil()
           and comment.deleted_at is null
    	   and comment.posted_at > $2;`

	rows, err = pool.Query(context.Background(), query, myId, lastSyncedAt)
	handleError(err)
	defer rows.Close()

	var comments []map[string]interface{}
	for rows.Next() {
		var notificationId string
		var byteId string
		var buddyId string
		var buddyUsername string
		var lastVisitedAt time.Time
		var content string
		var notifiedAt time.Time

		err = rows.Scan(&notificationId, &byteId, &buddyId, &buddyUsername, &lastVisitedAt, &content, &notifiedAt)
		handleError(err)

		mapper := map[string]interface{}{
			"notificationId": notificationId,
			"byteId":         byteId,
			"buddyId":        buddyId,
			"buddyUsername":  buddyUsername,
			"lastVisitedAt":  lastVisitedAt,
			"content":        content,
			"notifiedAt":     notifiedAt,
		}
		comments = append(comments, mapper)
	}
	handleError(rows.Err())

	query = `
	select comment.comment_id,
           comment.byte_id,
           account.user_id,
           account.username,
           account.last_visited_at,
           comment.content,
           comment.posted_at
    from   comment
           left join account
                  on account.user_id = comment.user_id
           left join comment as parent_comment
                  on parent_comment.comment_id = comment.parent_comment_id
           left join block
                  on block.user_id = parent_comment.user_id
    where  parent_comment.user_id = $1
           and not comment.user_id = parent_comment.user_id
           and not coalesce(block.buddy_id, uuid_nil()) = account.user_id
           and account.banned_at is null
           and comment.parent_comment_id != uuid_nil()
           and comment.deleted_at is null
           and comment.posted_at > $2;`

	rows, err = pool.Query(context.Background(), query, myId, lastSyncedAt)
	handleError(err)
	defer rows.Close()

	var replies []map[string]interface{}
	for rows.Next() {
		var notificationId string
		var byteId string
		var buddyId string
		var buddyUsername string
		var lastVisitedAt time.Time
		var content string
		var notifiedAt time.Time

		err = rows.Scan(&notificationId, &byteId, &buddyId, &buddyUsername, &lastVisitedAt, &content, &notifiedAt)
		handleError(err)

		mapper := map[string]interface{}{
			"notificationId": notificationId,
			"byteId":         byteId,
			"buddyId":        buddyId,
			"buddyUsername":  buddyUsername,
			"lastVisitedAt":  lastVisitedAt,
			"content":        content,
			"notifiedAt":     notifiedAt,
		}
		replies = append(replies, mapper)
	}
	handleError(rows.Err())

	query = `
	select message.message_id,
           account.user_id,
           account.username,
           message.content,
           message.sent_at
    from   message
           left join account
                  on account.user_id = message.user_id
           left join block
                  on block.user_id = message.buddy_id
    where  message.buddy_id = $1
           and not coalesce(block.buddy_id, uuid_nil()) = account.user_id
           and account.banned_at is null
           and message.sent_at > $2;`

	rows, err = pool.Query(context.Background(), query, myId, lastSyncedAt)
	handleError(err)
	defer rows.Close()

	var messages []map[string]interface{}
	for rows.Next() {
		var messageId string
		var buddyId string
		var buddyUsername string
		var content string
		var sentAt time.Time

		err = rows.Scan(&messageId, &buddyId, &buddyUsername, &content, &sentAt)
		handleError(err)

		mapper := map[string]interface{}{
			"messageId":     messageId,
			"buddyId":       buddyId,
			"buddyUsername": buddyUsername,
			"content":       content,
			"sentAt":        sentAt,
		}
		messages = append(messages, mapper)
	}
	handleError(rows.Err())

	// myMessages is unnecessary unless deleted chat history must be restored by setting lastSyncedAt to the past.
	var myMessages []map[string]interface{}
	if lastSyncedAt.String()[:10] == "2000-01-01" {
		query = `
	    select message.message_id,
               account.user_id,
               account.username,
               message.content,
               message.sent_at
        from   message
               left join account
                      on account.user_id = message.buddy_id
        where  message.user_id = $1
               and message.sent_at > $2;`

		rows, err = pool.Query(context.Background(), query, myId, lastSyncedAt)
		handleError(err)
		defer rows.Close()

		for rows.Next() {
			var messageId string
			var buddyId string
			var buddyUsername string
			var content string
			var sentAt time.Time

			err = rows.Scan(&messageId, &buddyId, &buddyUsername, &content, &sentAt)
			handleError(err)

			mapper := map[string]interface{}{
				"messageId":     messageId,
				"buddyId":       buddyId,
				"buddyUsername": buddyUsername,
				"content":       content,
				"sentAt":        sentAt,
			}
			myMessages = append(myMessages, mapper)
		}
		handleError(rows.Err())
	}

	rows, err = pool.Query(context.Background(), "select user_id, last_read_at from read_receipt where buddy_id = $1 and last_read_at > $2;", myId, lastSyncedAt)
	handleError(err)
	defer rows.Close()

	var readReceipts []map[string]interface{}
	for rows.Next() {
		var buddyId string
		var lastReadAt time.Time

		err = rows.Scan(&buddyId, &lastReadAt)
		handleError(err)

		mapper := map[string]interface{}{
			"buddyId":    buddyId,
			"lastReadAt": lastReadAt,
		}
		readReceipts = append(readReceipts, mapper)
	}
	handleError(rows.Err())

	mapper := map[string]interface{}{
		"isAdmin":              isAdmin,
		"isClientOutdated":     isClientOutdated,
		"hasInteraction":       true,
		"byteLikesReceived":    byteLikesReceived,
		"commentLikesReceived": commentLikesReceived,
		"byteLikes":            byteLikes,
		"commentLikes":         commentLikes,
		"comments":             comments,
		"replies":              replies,
		"messages":             messages,
		"myMessages":           myMessages,
		"readReceipts":         readReceipts,
	}
	json, err := json.Marshal(mapper)
	handleError(err)

	w.Header().Set("Content-Type", "application/json")
	w.Write(json)
}
