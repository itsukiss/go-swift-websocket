package main

import (
	"./protos"
	"flag"
	"github.com/golang/protobuf/proto"
	"github.com/golang/protobuf/ptypes/any"
	"github.com/gorilla/websocket"
	"log"
	"net/http"
)

var addr = flag.String("addr", "localhost:8080", "http service address")

var upgrader = websocket.Upgrader{} // use default options

func echo(w http.ResponseWriter, r *http.Request) {
	c, err := upgrader.Upgrade(w, r, nil)
	if err != nil {
		log.Print("upgrade:", err)
		return
	}
	defer c.Close()
	for {
		_, message, err := c.ReadMessage()
		if err != nil {
			log.Println("read:", err)
			break
		}
		log.Printf("recv: %s", message)
		c.WriteMessage(websocket.BinaryMessage, getSerializeData())
		if err != nil {
			log.Println("write:", err)
			break
		}
	}
}

func getSerializeData() (res []byte) {
	test := &example.User{
		Id:   33,
		Name: "laughing_cat",
	}
	buff, err := proto.Marshal(test)
	if err != nil {
		log.Print("marshal error")
		return
	}
	metaData := &example.MetaData{
		Data: &any.Any{
			TypeUrl: "tapple.com/protobuf/" + proto.MessageName(test),
			Value:   buff,
		},
	}

	buff2, err2 := proto.Marshal(metaData)
	if err2 != nil {
		log.Print("marshal error")
		return
	}

	log.Print("serialize success: ", buff2)
	return buff2
}

/*
func getDeserializeData() {
	// Deserialize
	parsedTest := &example.User{}
	err = proto.Unmarshal(buff, parsedTest)

	if err != nil {
		log.Print("deserialize error: ", err)
	}
	log.Print("deserialized id :", parsedTest.Id)
	log.Print("deserialized name: ", parsedTest.Name)
}
*/

func main() {
	flag.Parse()
	log.SetFlags(0)
	http.HandleFunc("/echo", echo)
	log.Fatal(http.ListenAndServe(*addr, nil))
}
