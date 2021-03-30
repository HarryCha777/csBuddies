package main

import (
	"context"
	"encoding/json"
	"fmt"
	"net/http"
	"strings"
	"time"
)

func getTabBuddies(w http.ResponseWriter, r *http.Request) {
	r.ParseForm()
	token := r.Form.Get("token")
	gender := r.Form.Get("gender")
	minAge := r.Form.Get("minAge")
	maxAge := r.Form.Get("maxAge")
	country := r.Form.Get("country")
	sort := r.Form.Get("sort")
	interests := r.Form.Get("interests")
	bottomLastVisitedAt := r.Form.Get("bottomLastVisitedAt")
	bottomSignedUpAt := r.Form.Get("bottomSignedUpAt")
	myId := getMyId(token)

	isValid :=
		(myId == uuidNil || isAuthenticated(myId)) &&
			isValidInt(gender, -1, 2) &&
			isValidInt(minAge, 13, 130) &&
			isValidInt(maxAge, toInt(minAge), 130) &&
			isValidInt(country, -1, 196) &&
			isValidInterests(interests) &&
			isValidInt(sort, 0, 1) &&
			isValidTime(bottomLastVisitedAt) &&
			isValidTime(bottomSignedUpAt)
	if !isValid {
		fmt.Fprintln(w, "Invalid")
		return
	}

	query := `
	select user_id,
           username,
           gender,
           birthday,
           country,
           intro,
           last_visited_at,
           signed_up_at
    from   account
    where  not user_id = $1
           and banned_at is null
           and disabled_at is null
           and deleted_at is null `

	var params []interface{}
	params = append(params, myId)

	if gender != "-1" {
		query += fmt.Sprintf("and gender = $%d ", len(params)+1)
		params = append(params, gender)
	}

	if minAge != "13" || maxAge != "130" {
		minDate := time.Now().AddDate(-toInt(maxAge)-1, 0, 0)
		maxDate := time.Now().AddDate(-toInt(minAge), 0, 0)

		query += fmt.Sprintf("and birthday between $%d and $%d ", len(params)+1, len(params)+2)
		params = append(params, minDate, maxDate)
	}

	if country != "-1" {
		query += fmt.Sprintf("and country = $%d ", len(params)+1)
		params = append(params, country)
	}

	if interests != "" {
		query += "and (false "

		noFirstOrLast := interests[1 : len(interests)-1]
		interests := strings.Split(noFirstOrLast, "&&")

		for _, interest := range interests {
			query += fmt.Sprintf("or interests like '%%' || '&' || $%d || '&' || '%%' ", len(params)+1)
			params = append(params, interest)
		}

		query += ") "
	}

	if sort == "0" {
		// Hide new users who made their accounts up to 1 day ago
		// in order to prevent new users from cluttering active users sort and prevent mass spam of new user account.
		//query += "and last_visited_at < ? and signed_up_at < current_date - interval '1 days' order by last_visited_at desc limit 20;";
		query += fmt.Sprintf("and last_visited_at < $%d order by last_visited_at desc limit 20;", len(params)+1)
		params = append(params, bottomLastVisitedAt)
	} else {
		query += fmt.Sprintf("and signed_up_at < $%d order by signed_up_at desc limit 20;", len(params)+1)
		params = append(params, bottomSignedUpAt)
	}

	rows, err := pool.Query(context.Background(), query, params...)
	handleError(err)
	defer rows.Close()

	mapper := map[int]interface{}{}
	newBottomLastVisitedAt := toTime(bottomLastVisitedAt)
	newBottomSignedUpAt := toTime(bottomSignedUpAt)

	for rows.Next() {
		var buddyId string
		var username string
		var gender int
		var birthday time.Time
		var country int
		var intro string
		var lastVisitedAt time.Time
		var signedUpAt time.Time

		err = rows.Scan(&buddyId, &username, &gender, &birthday, &country, &intro, &lastVisitedAt, &signedUpAt)
		handleError(err)

		newBottomLastVisitedAt = lastVisitedAt
		newBottomSignedUpAt = signedUpAt

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
		"bottomLastVisitedAt": newBottomLastVisitedAt,
		"bottomSignedUpAt":    newBottomSignedUpAt,
	}
	mapper[len(mapper)] = newMapper

	json, err := json.Marshal(mapper)
	handleError(err)

	w.Header().Set("Content-Type", "application/json")
	w.Write(json)
}
