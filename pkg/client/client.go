package client

import (
	"context"
	"fmt"
	"os"

	"google.golang.org/grpc"

	pb "github.com/bukhavtsov/toolkit-log-service/pkg/pb"
	"github.com/sirupsen/logrus"
)

// Client is the gRPC client that send messages to server.
type Client struct {
	gRPCEndpoint string
	log          *logrus.Logger
}

//FIXME : replace listen to send!

// NewClient returns a new Client.
func NewClient(gRPCEndpoint string, log *logrus.Logger) *Client {
	return &Client{gRPCEndpoint: gRPCEndpoint, log: log}
}

// RunClient run the gRPC client that send messages to server.
func (c Client) RunClient() error {
	conn, err := grpc.Dial(c.gRPCEndpoint, grpc.WithInsecure())
	if err != nil {
		return err
	}

	client := pb.NewToolkitLogServiceClient(conn)
	stream, err := client.SendMessages(context.Background())

	for {
		c.log.Info("Enter your message:")
		var msg string
		_, err := fmt.Fscan(os.Stdin, &msg)
		if msg == "stop" {
			return nil
		}
		if err != nil {
			c.log.Warning(err)
		}
		req := &pb.SendMessagesRequest{Msg: msg}
		err = stream.Send(req)
		if err != nil {
			return err
		}
	}
}
