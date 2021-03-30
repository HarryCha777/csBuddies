package main

import (
	"context"
	"encoding/json"
	"fmt"
	"net/http"

	firebase "firebase.google.com/go/v4"
)

func addUser(w http.ResponseWriter, r *http.Request) {
	r.ParseForm()
	token := r.Form.Get("token")
	username := r.Form.Get("username")
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
	fcmToken := r.Form.Get("fcmToken")

	isValid :=
		isValidUsername(username) &&
			isValidString(smallImage, 1, 30000) &&
			isValidString(bigImage, 1, 300000) &&
			isValidInt(gender, 0, 3) &&
			isValidDate(birthday) &&
			isValidInt(country, 0, 196) &&
			isValidInterests(interests) &&
			isValidString(otherInterests, 0, 100) &&
			isValidString(intro, 1, 256) &&
			isValidString(github, 0, 39) &&
			isValidString(linkedin, 0, 100) &&
			isValidString(fcmToken, 0, 1000)
	if !isValid {
		fmt.Fprintln(w, "Invalid")
		return
	}

	if isExtantUsername(username) {
		mapper := map[string]interface{}{
			"isExtantUsername": true,
		}
		json, err := json.Marshal(mapper)
		handleError(err)

		w.Header().Set("Content-Type", "application/json")
		w.Write(json)
		return
	}

	app, err := firebase.NewApp(context.Background(), nil)
	handleError(err)

	auth, err := app.Auth(context.Background())
	handleError(err)

	verifiedIdToken, err := auth.VerifyIDToken(context.Background(), token)
	handleError(err)

	uid := verifiedIdToken.UID
	claims, err := auth.GetUser(context.Background(), uid)
	handleError(err)

	if !claims.EmailVerified {
		fmt.Fprintln(w, "Invalid")
		return
	}

	email := claims.Email

	var isExtantEmail bool
	err = pool.QueryRow(context.Background(), "select count(user_id) = 1 from account where lower(email) = lower($1) limit 1;", email).Scan(&isExtantEmail)
	handleError(err)

	if isExtantEmail {
		fmt.Fprintln(w, "Invalid")
		return
	}

	var myId string
	err = pool.QueryRow(context.Background(), "insert into account (email, username, small_image, big_image, gender, birthday, country, interests, other_interests, intro, github, linkedin, fcm_token) values (lower($1), $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13) returning user_id;", email, username, smallImage, bigImage, gender, birthday, country, interests, otherInterests, intro, github, linkedin, fcmToken).Scan(&myId)
	handleError(err)

	customClaims := map[string]interface{}{
		"userId": myId,
	}
	err = auth.SetCustomUserClaims(context.Background(), uid, customClaims)
	handleError(err)

	mapper := map[string]interface{}{
		"myId": myId,
	}
	json, err := json.Marshal(mapper)
	handleError(err)

	w.Header().Set("Content-Type", "application/json")
	w.Write(json)
}
