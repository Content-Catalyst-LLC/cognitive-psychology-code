package main

import "fmt"

func cognitiveLoadScore(intrinsic, extraneous, germane float64) float64 {
	return intrinsic + extraneous - germane
}

func main() {
	fmt.Printf("Toy cognitive-load score: %.2f\n", cognitiveLoadScore(0.7, 0.4, 0.2))
}
