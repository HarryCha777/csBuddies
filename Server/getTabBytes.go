package main

import (
	"context"
	"encoding/json"
	"fmt"
	"net/http"
	"time"
)

func getTabBytes(w http.ResponseWriter, r *http.Request) {
	r.ParseForm()
	token := r.Form.Get("token")
	sort := r.Form.Get("sort")
	bottomPostedAt := r.Form.Get("bottomPostedAt")
	bottomHotScore := r.Form.Get("bottomHotScore")
	myId := getMyId(token)

	isValid :=
		(myId == uuidNil || isAuthenticated(myId)) &&
			isValidInt(sort, 0, 1) &&
			isValidTime(bottomPostedAt) &&
			isValidFloat(bottomHotScore, 0, 30000)
	if !isValid {
		fmt.Fprintln(w, "Invalid")
		return
	}

	// 1606780800 is unix timestamp for 2020-12-01, and 86400 is number of seconds in a day.
	hotScoreSql := "round(cast(greatest(log(10, greatest(all_byte_like.likes, 1)), 1) + (extract(epoch from byte.posted_at) - 1606780800) / 86400 as numeric), 3)"

	query := fmt.Sprintf(`
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
		   %s
	from   byte
           left join account
                  on byte.user_id = account.user_id
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
    where  ( account.banned_at is null
              or account.user_id = $2 )
		   and byte.deleted_at is null `, hotScoreSql)

	var params []interface{}
	params = append(params, myId, myId)

	if sort == "0" {
		query += "and ((" + hotScoreSql + " = $3 and byte.posted_at < $4) or (" + hotScoreSql + " < $5)) order by " + hotScoreSql + " desc, byte.posted_at desc limit 20;"
		params = append(params, bottomHotScore, bottomPostedAt, bottomHotScore)
	} else {
		query += "and byte.posted_at < $3 order by byte.posted_at desc limit 20;"
		params = append(params, bottomPostedAt)
	}

	rows, err := pool.Query(context.Background(), query, params...)
	handleError(err)
	defer rows.Close()

	mapper := map[int]interface{}{}
	newBottomPostedAt := toTime(bottomPostedAt)
	newBottomHotScore := toFloat(bottomHotScore)

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
		var hotScore float64

		err = rows.Scan(&byteId, &userId, &username, &lastVisitedAt, &content, &likes, &comments, &isLiked, &postedAt, &hotScore)
		handleError(err)

		newBottomPostedAt = postedAt
		newBottomHotScore = hotScore

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
		"bottomPostedAt": newBottomPostedAt,
		"bottomHotScore": newBottomHotScore,
	}
	mapper[len(mapper)] = newMapper

	json, err := json.Marshal(mapper)
	handleError(err)

	w.Header().Set("Content-Type", "application/json")
	w.Write(json)
}
