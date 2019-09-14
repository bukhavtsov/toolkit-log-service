package svc

import (
	"io"
	"log"

	pb "github.com/bukhavtsov/toolkit-log-service/pkg/pb"
)

const (
	// version is the current version of the service
	version = "0.0.1"
)

// Implementation of the ToolkitLogService server interface
type server struct{}

// NewServer returns an instance of the server interface
func NewServer() (*server, error) {
	return &server{}, nil
}

func SendMessages(stream pb.ToolkitLogService_SendMessagesServer) error {
	for {
		req, err := stream.Recv()
		if err == io.EOF {
			return nil
		}
		if err != nil {
			return err
		}
		log.Println(req.Msg)
	}
}

// SendMessages send stream of messages from client to server
func (s server) SendMessages(stream pb.ToolkitLogService_SendMessagesServer) error {
	log.Println("client has been connected")
	err := SendMessages(stream)
	log.Println("client has been disconnected")
	return err
}
