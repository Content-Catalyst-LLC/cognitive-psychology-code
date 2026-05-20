package main

import (
	"encoding/csv"
	"fmt"
	"log"
	"os"
	"strconv"
)

var required = []string{
	"participant","expertise_level","condition","domain","session","task_id","practice_hours",
	"deliberate_practice_quality","feedback_quality","task_difficulty","cognitive_load",
	"working_memory_demand","chunking_score","pattern_recognition_score","strategy_quality",
	"transfer_score","adaptive_flexibility","accuracy","error_rate","response_time_ms",
	"automaticity_score","retention_score",
}

func main() {
	if len(os.Args) < 2 { log.Fatal("Usage: go run go/validator.go data/skill_acquisition_trials.csv") }
	f, err := os.Open(os.Args[1]); if err != nil { log.Fatal(err) }
	defer f.Close()
	rows, err := csv.NewReader(f).ReadAll(); if err != nil { log.Fatal(err) }
	if len(rows) < 2 { log.Fatal("CSV must contain header and at least one row") }
	idx := map[string]int{}
	for i, h := range rows[0] { idx[h] = i }
	for _, col := range required {
		if _, ok := idx[col]; !ok { log.Fatalf("Missing column: %s", col) }
	}
	errors := 0
	for n, row := range rows[1:] {
		line := n + 2
		check(row, idx, "deliberate_practice_quality", 0, 10, line, &errors)
		check(row, idx, "feedback_quality", 0, 10, line, &errors)
		check(row, idx, "task_difficulty", 0, 10, line, &errors)
		check(row, idx, "cognitive_load", 0, 10, line, &errors)
		check(row, idx, "working_memory_demand", 0, 10, line, &errors)
		check(row, idx, "chunking_score", 0, 10, line, &errors)
		check(row, idx, "pattern_recognition_score", 0, 10, line, &errors)
		check(row, idx, "strategy_quality", 0, 10, line, &errors)
		check(row, idx, "transfer_score", 0, 100, line, &errors)
		check(row, idx, "adaptive_flexibility", 0, 10, line, &errors)
		check(row, idx, "accuracy", 0, 1, line, &errors)
		check(row, idx, "error_rate", 0, 1, line, &errors)
		check(row, idx, "response_time_ms", 150, 1000000, line, &errors)
		check(row, idx, "automaticity_score", 0, 10, line, &errors)
		check(row, idx, "retention_score", 0, 100, line, &errors)
	}
	fmt.Printf("Validated %s\nRows checked: %d\nValidation errors: %d\n", os.Args[1], len(rows)-1, errors)
	if errors > 0 { os.Exit(2) }
}

func check(row []string, idx map[string]int, col string, min float64, max float64, line int, errors *int) {
	v, err := strconv.ParseFloat(row[idx[col]], 64)
	if err != nil || v < min || v > max {
		fmt.Printf("Line %d: %s out of range [%.1f, %.1f]\n", line, col, min, max)
		*errors++
	}
}
