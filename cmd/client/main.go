package main

import (
	"os"

	"github.com/bukhavtsov/toolkit-log-service/pkg/client"
	"github.com/sirupsen/logrus"
)

var (
	gRPCEndpoint = os.Getenv("GRPC_ADDR")
	log          *logrus.Logger
)

func init() {
	if gRPCEndpoint == "" {
		gRPCEndpoint = "localhost:8080"
	}

	log = logrus.New()
	log.SetFormatter(&logrus.TextFormatter{})
	log.SetOutput(os.Stdout)
}

func main() {
	c := client.NewClient(gRPCEndpoint, log)
	log.Printf("listening gRPC at %s", gRPCEndpoint)
	if err := c.RunClient(); err != nil {
		log.Fatal(err)
	}
}
