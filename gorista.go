package main

import (
	"fmt"
	"github.com/gorilla/websocket"
	"net/http"
	"os"
)

var upgrader = websocket.Upgrader{
	ReadBufferSize:  512,
	WriteBufferSize: 512,
}

func websocketHandler(w http.ResponseWriter, r *http.Request) {
	conn, err := upgrader.Upgrade(w, r, nil)
	if err != nil {
		fmt.Println("Failed to upgrade socket to WebSocket. Exiting")
		return
	}
	for {
		messageType, p, err := conn.ReadMessage()
		if err != nil {
			return
		}

		/// Do something here

		err = conn.WriteMessage(messageType, p)
		if err != nil {
			return
		}
	}
}

func main() {
	http.HandleFunc("/websocket", websocketHandler)
	http.Handle("/", http.FileServer(http.Dir("public")))
	var port string = ":8080"
	if os.Getenv("PORT") != "" {
		port = ":" + os.Getenv("PORT")
	}
	fmt.Println("Starting up Gorista on port " + port)
	err := http.ListenAndServe(port, nil)
	if err != nil {
		panic("Error: " + err.Error())
	}
}
