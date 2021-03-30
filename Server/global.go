package main

import (
	"context"
	"fmt"
	"os"
	"regexp"
	"strconv"
	"strings"
	"time"

	firebase "firebase.google.com/go/v4"
	"firebase.google.com/go/v4/auth"
	"firebase.google.com/go/v4/messaging"
	"github.com/jackc/pgx/v4/pgxpool"
)

var pool *pgxpool.Pool
var app *firebase.App
var client *auth.Client
var channelMapper map[chan string]string
var uuidNil string = "00000000-0000-0000-0000-000000000000"

func init() {
	host := "my-db-4.cuu0ug5si1zb.us-west-2.rds.amazonaws.com"
	port := 5432
	user := "harry"
	password := os.Getenv("DBPASSWORD")
	dbname := "csbuddies"
	psql := fmt.Sprintf("host=%s port=%d user=%s password=%s dbname=%s sslmode=disable", host, port, user, password, dbname)

	// Do not use ":=" since it create 2 new local variables.
	var err error
	pool, err = pgxpool.Connect(context.Background(), psql)
	handleError(err)

	app, err = firebase.NewApp(context.Background(), nil)
	handleError(err)

	client, err = app.Auth(context.Background())
	handleError(err)

	channelMapper = make(map[chan string]string)
}

func toBool(input string) bool {
	return input == "true"
}

func toInt(input string) int {
	integer, err := strconv.Atoi(input)
	handleError(err)

	return integer
}

func toFloat(input string) float64 {
	float, err := strconv.ParseFloat(input, 64)
	handleError(err)

	return float
}

func toTime(input string) time.Time {
	layoutIso := "2006-01-02 15:04:05.000"
	timestamp, err := time.Parse(layoutIso, input)
	handleError(err)

	return timestamp
}

func isValidBool(input string) bool {
	return input == "true" || input == "false"
}

func isValidInt(input string, minValue int, maxValue int) bool {
	return minValue <= toInt(input) && toInt(input) <= maxValue
}

func isValidFloat(input string, minValue float64, maxValue float64) bool {
	return minValue <= toFloat(input) && toFloat(input) <= maxValue
}

func isValidString(input string, minLength int, maxLength int) bool {
	// Use len([]rune(string)) instead of len(string)
	// because the latter returns the number of bytes, not characters.
	// For example, emojis and characters like "£" have 2 or more bytes.
	return minLength <= len([]rune(input)) && len([]rune(input)) <= maxLength
}

func isValidDate(input string) bool {
	layoutIso := "2006-01-02"
	date, err := time.Parse(layoutIso, input)
	handleError(err)

	now := time.Now()
	return date.Before(now) || date.Equal(now)
}

func isValidTime(input string) bool {
	layoutIso := "2006-01-02 15:04:05.000"
	timestamp, err := time.Parse(layoutIso, input)
	handleError(err)

	now := time.Now()
	return timestamp.Before(now) || timestamp.Equal(now)
}

func isValidInterests(input string) bool {
	if input == "" {
		return true
	}

	noFirstOrLast := input[1 : len(input)-1]
	interests := strings.Split(noFirstOrLast, "&&")
	return isValidString(input, 2, 1000) && len(interests) <= 10
}

func isValidUsername(input string) bool {
	hasValidChars, err := regexp.MatchString("^[A-Za-z0-9 ]*$", input)
	handleError(err)

	return isValidString(input, 6, 20) &&
		string([]rune(input)[0]) != " " &&
		string([]rune(input)[len(input)-1]) != " " &&
		!strings.Contains(input, "  ") &&
		hasValidChars
}

func isAdmin(buddyId string) bool {
	var isAdmin bool
	err := pool.QueryRow(context.Background(), "select count(user_id) = 1 from account where user_id = $1 and became_admin_at is not null limit 1;", buddyId).Scan(&isAdmin)
	handleError(err)
	return isAdmin
}

func isExtantUserId(userId string) bool {
	var isExtantUserId bool
	err := pool.QueryRow(context.Background(), "select count(user_id) = 1 from account where user_id = $1 limit 1;", userId).Scan(&isExtantUserId)
	handleError(err)
	return isExtantUserId
}

func isExtantUsername(username string) bool {
	var isExtantUsername bool
	err := pool.QueryRow(context.Background(), "select count(user_id) = 1 from account where username = $1 limit 1;", username).Scan(&isExtantUsername)
	handleError(err)
	return isExtantUsername
}

func isExtantByteId(byteId string) bool {
	var isExtantByteId bool
	err := pool.QueryRow(context.Background(), "select count(byte_id) = 1 from byte where byte_id = $1 limit 1;", byteId).Scan(&isExtantByteId)
	handleError(err)
	return isExtantByteId
}

func isExtantCommentId(commentId string) bool {
	var isExtantCommentId bool
	err := pool.QueryRow(context.Background(), "select count(comment_id) = 1 from comment where comment_id = $1 limit 1;", commentId).Scan(&isExtantCommentId)
	handleError(err)
	return isExtantCommentId
}

func isExtantByteCommentId(byteId string, commentId string) bool {
	var isExtantByteCommentId bool
	err := pool.QueryRow(context.Background(), "select count(comment_id) = 1 from comment where byte_id = $1 and comment_id = $2 limit 1;", byteId, commentId).Scan(&isExtantByteCommentId)
	handleError(err)
	return isExtantByteCommentId
}

func getMyId(token string) string {
	if token == "" {
		return uuidNil
	}

	verifiedIdToken, err := client.VerifyIDToken(context.Background(), token)
	handleError(err)

	uid := verifiedIdToken.UID
	claims, err := client.GetUser(context.Background(), uid)
	handleError(err)

	return claims.CustomClaims["userId"].(string)
}

func isAuthenticated(myId string, isSignIn ...bool) bool {
	var isAuthenticated bool
	if len(isSignIn) == 1 && isSignIn[0] {
		err := pool.QueryRow(context.Background(), "select count(user_id) = 1 from account where user_id = $1 and deleted_at is null limit 1;", myId).Scan(&isAuthenticated)
		handleError(err)
	} else {
		err := pool.QueryRow(context.Background(), "select count(user_id) = 1 from account where user_id = $1 and disabled_at is null and deleted_at is null limit 1;", myId).Scan(&isAuthenticated)
		handleError(err)
	}

	if isAuthenticated {
		_, err := pool.Exec(context.Background(), "update account set last_visited_at = current_timestamp where user_id = $1;", myId)
		handleError(err)
	}

	return isAuthenticated
}

func getByteLikesReceived(myId string) int {
	query := `
	select count(byte_like.byte_like_id)
    from   byte_like
           left join byte
                  on byte.byte_id = byte_like.byte_id
           left join account
                  on account.user_id = byte.user_id
    where  account.user_id = $1
           and byte_like.is_liked = true
	limit  1;`

	var byteLikesReceived int
	err := pool.QueryRow(context.Background(), query, myId).Scan(&byteLikesReceived)
	handleError(err)

	return byteLikesReceived
}

func getCommentLikesReceived(myId string) int {
	query := `
	select count(comment_like.comment_like_id)
    from   comment_like
           left join comment
                  on comment.comment_id = comment_like.comment_id
           left join account
                  on account.user_id = comment.user_id
    where  account.user_id = $1
           and comment_like.is_liked = true
    limit  1;`

	var commentLikesReceived int
	err := pool.QueryRow(context.Background(), query, myId).Scan(&commentLikesReceived)
	handleError(err)

	return commentLikesReceived
}

func sendChannel(buddyId string) {
	_, err := pool.Exec(context.Background(), "update account set last_outdated_at = current_timestamp where user_id = $1;", buddyId)
	handleError(err)

	for channel := range channelMapper {
		if channelMapper[channel] == buddyId {
			select {
			case channel <- buddyId:
			default:
			}
		}
	}
}

func sendNotification(notificationType string, myId string, buddyId string, content string) {
	if myId == buddyId {
		return
	}

	var username string
	var isBanned bool

	err := pool.QueryRow(context.Background(), "select username, banned_at is not null from account where user_id = $1 limit 1;", myId).Scan(&username, &isBanned)
	handleError(err)

	var notificationName, title string

	switch notificationType {
	case "byte like":
		notificationName = "likes"
		title = fmt.Sprintf("%s liked your byte.", username)
	case "comment like":
		notificationName = "likes"
		title = fmt.Sprintf("%s liked your comment.", username)
	case "byte comment":
		notificationName = "comments"
		title = fmt.Sprintf("%s commented on your byte.", username)
	case "comment reply":
		notificationName = "comments"
		title = fmt.Sprintf("%s replied to your comment.", username)
	case "message":
		notificationName = "messages"
		title = username
	}

	_, err = pool.Exec(context.Background(), "update account set badges = badges + 1 where user_id = $1;", buddyId)
	handleError(err)

	var fcmToken string
	var badges int
	var hasNotification bool
	var isBuddyBanned bool

	err = pool.QueryRow(context.Background(), fmt.Sprintf("select fcm_token, badges, notify_%s, banned_at is not null from account where user_id = $1 limit 1", notificationName), buddyId).Scan(&fcmToken, &badges, &hasNotification, &isBuddyBanned)
	handleError(err)

	var isBlocked bool
	err = pool.QueryRow(context.Background(), "select count(block_id) = 1 from block where user_id = $1 and buddy_id = $2 limit 1;", buddyId, myId).Scan(&isBlocked)
	handleError(err)

	if fcmToken == "" || !hasNotification || isBanned || isBuddyBanned || isBlocked {
		return
	}

	data := map[string]string{
		"myId": myId,
		"type": notificationType,
	}

	notification := &messaging.Notification{
		Title: title,
		Body:  content,
	}

	badgesPointer := int(badges)
	aps := &messaging.Aps{
		Badge: &badgesPointer,
		Sound: "default",
	}
	apnsPayload := &messaging.APNSPayload{
		Aps: aps,
	}
	apnsConfig := &messaging.APNSConfig{
		Payload: apnsPayload,
	}

	message := &messaging.Message{
		Data:         data,
		Notification: notification,
		Token:        fcmToken,
		APNS:         apnsConfig,
	}

	app, err := firebase.NewApp(context.Background(), nil)
	handleError(err)

	client, err := app.Messaging(context.Background())
	handleError(err)

	_, err = client.Send(context.Background(), message)
	handleError(err)
}

func handleError(err error) {
	if err != nil {
		panic(err)
	}
}
