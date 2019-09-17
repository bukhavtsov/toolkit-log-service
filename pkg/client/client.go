package client

import (
	"context"
	"fmt"
	"time"

	"google.golang.org/grpc"

	pb "github.com/bukhavtsov/toolkit-log-service/pkg/pb"
	"github.com/sirupsen/logrus"
)

// Client is the gRPC client that send messages to server.
type Client struct {
	gRPCEndpoint string
	log          *logrus.Logger
}

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

	for i := 0; ; i++ {
		msg := fmt.Sprintf("msg#%d ", i)
		req := &pb.SendMessagesRequest{Msg: msg}
		err = stream.Send(req)
		if err != nil {
			return err
		}
		time.Sleep(time.Second * 5)
	}
}
