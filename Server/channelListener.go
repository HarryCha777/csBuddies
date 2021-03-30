package main

import (
	"net/http"
	"time"

	"github.com/gorilla/websocket"
)

func channelListener(w http.ResponseWriter, r *http.Request) {
	r.ParseForm()
	token := r.Form.Get("token")
	myId := getMyId(token)

	var upgrader = websocket.Upgrader{
		ReadBufferSize:  1024,
		WriteBufferSize: 1024,
	}

	isValid :=
		isAuthenticated(myId)
	upgrader.CheckOrigin = func(r *http.Request) bool {
		return isValid
	}

	ws, err := upgrader.Upgrade(w, r, nil)
	handleError(err)

	ws.SetReadLimit(512)

	err = ws.WriteMessage(1, []byte("sync"))
	handleError(err)

	channel := make(chan string, 5)
	channelMapper[channel] = myId

	go func() {
		for {
			ws.SetReadDeadline(time.Now().Add(63 * time.Second))
			_, _, err := ws.ReadMessage()
			if err != nil {
				ws.Close()
				delete(channelMapper, channel)
				close(channel)
				return
			}
		}
	}()

	for {
		<-channel

		err := ws.WriteMessage(1, []byte("sync"))
		if err != nil {
			return
		}
	}
}
