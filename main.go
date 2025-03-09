package main

import (
	"log"
	"os"
)

func main() {
	if err := NewCli().Run(os.Args); err != nil {
		log.Fatal(err)
	}
}
