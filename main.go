package main

import (
	"log"
	"sync"
	"xyz/mantevian/lemmings/server"

	"github.com/joho/godotenv"
)

func main() {
	err := godotenv.Load()
	if err != nil {
		log.Fatal("Error loading .env file")
		return
	}

	var wg sync.WaitGroup

	wg.Add(1)
	go func() {
		defer wg.Done()
		server.StartHttpServer()
	}()

	wg.Add(1)
	go func() {
		defer wg.Done()
		server.StartPostgresConnection()
	}()

	wg.Wait()
}
