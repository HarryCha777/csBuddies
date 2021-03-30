package main

import (
	"context"
	"fmt"
	"net/http"
)

func updateUser(w http.ResponseWriter, r *http.Request) {
	r.ParseForm()
	token := r.Form.Get("token")
	smallImage := r.Form.Get("smallImage")
	bigImage := r.Form.Get("bigImage")
	gender := r.Form.Get("gender")
	birthday := r.Form.Get("birthday")
	country := r.Form.Get("country")
	interests := r.Form.Get("interests")
	otherInterests := r.Form.Get("otherInterests")
	intro := r.Form.Get("intro")
	github := r.Form.Get("github")
	linkedin := r.Form.Get("linkedin")
	myId := getMyId(token)

	isValid :=
		isAuthenticated(myId) &&
			isValidString(smallImage, 1, 30000) &&
			isValidString(bigImage, 1, 300000) &&
			isValidInt(gender, 0, 3) &&
			isValidDate(birthday) &&
			isValidInt(country, 0, 196) &&
			isValidInterests(interests) &&
			isValidString(otherInterests, 0, 100) &&
			isValidString(intro, 1, 256) &&
			isValidString(github, 0, 39) &&
			isValidString(linkedin, 0, 100)
	if !isValid {
		fmt.Fprintln(w, "Invalid")
		return
	}

	_, err := pool.Exec(context.Background(), "update account set small_image = $1, big_image = $2, gender = $3, birthday = $4, country = $5, interests = $6, other_interests = $7, intro = $8, github = $9, linkedin = $10, last_updated_at = current_timestamp, last_visited_at = current_timestamp where user_id = $11;", smallImage, bigImage, gender, birthday, country, interests, otherInterests, intro, github, linkedin, myId)
	handleError(err)
}
