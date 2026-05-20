package main

import (
	"encoding/csv"
	"fmt"
	"log"
	"os"
	"strconv"
)

var required = []string{"participant","condition","domain","trial","item_id","memory_system","study_type","encoding_depth","retrieval_practice","spacing_interval","delay","retention_strength","cue_quality","interference","consolidation_support","source_context","misinformation_exposure","old_item","response_old","source_correct","correct","recall_accuracy","recognition_confidence","retrieval_fluency","response_time_ms","learning_transfer","forgetting_rate"}

func main() {
	if len(os.Args) < 2 { log.Fatal("Usage: go run go/validator.go data/memory_trials.csv") }
	f, err := os.Open(os.Args[1]); if err != nil { log.Fatal(err) }
	defer f.Close()
	rows, err := csv.NewReader(f).ReadAll(); if err != nil { log.Fatal(err) }
	if len(rows) < 2 { log.Fatal("CSV must contain header and rows") }
	idx := map[string]int{}
	for i, h := range rows[0] { idx[h] = i }
	for _, col := range required {
		if _, ok := idx[col]; !ok { log.Fatalf("Missing required column: %s", col) }
	}
	errors := 0
	conditions := map[string]int{}
	for r, row := range rows[1:] {
		line := r + 2
		conditions[row[idx["condition"]]]++
		checkRange(row, idx, "trial", 1, 1e9, line, &errors)
		checkRange(row, idx, "encoding_depth", 0, 10, line, &errors)
		checkRange(row, idx, "spacing_interval", 0, 1e9, line, &errors)
		checkRange(row, idx, "delay", 0, 1e9, line, &errors)
		checkRange(row, idx, "retention_strength", 0, 1e9, line, &errors)
		checkRange(row, idx, "cue_quality", 0, 10, line, &errors)
		checkRange(row, idx, "interference", 0, 10, line, &errors)
		checkRange(row, idx, "consolidation_support", 0, 10, line, &errors)
		checkRange(row, idx, "source_context", 0, 10, line, &errors)
		checkRange(row, idx, "recall_accuracy", 0, 1, line, &errors)
		checkRange(row, idx, "recognition_confidence", 0, 1, line, &errors)
		checkRange(row, idx, "retrieval_fluency", 0, 10, line, &errors)
		checkRange(row, idx, "response_time_ms", 150, 1e9, line, &errors)
		checkRange(row, idx, "learning_transfer", 0, 1, line, &errors)
		checkRange(row, idx, "forgetting_rate", 0, 1e9, line, &errors)
		for _, col := range []string{"retrieval_practice","misinformation_exposure","old_item","response_old","source_correct","correct"} {
			checkBinary(row, idx, col, line, &errors)
		}
	}
	fmt.Printf("Validated file: %s\nRows checked: %d\nValidation errors: %d\n", os.Args[1], len(rows)-1, errors)
	fmt.Println("Condition counts:")
	for k, v := range conditions { fmt.Printf("  %s: %d\n", k, v) }
	if errors > 0 { os.Exit(2) }
}

func checkRange(row []string, idx map[string]int, col string, min float64, max float64, line int, errors *int) {
	value, err := strconv.ParseFloat(row[idx[col]], 64)
	if err != nil || value < min || value > max {
		fmt.Printf("Line %d: %s out of range or nonnumeric: %s\n", line, col, row[idx[col]])
		*errors++
	}
}

func checkBinary(row []string, idx map[string]int, col string, line int, errors *int) {
	v := row[idx[col]]
	if v != "0" && v != "1" {
		fmt.Printf("Line %d: %s must be 0 or 1, got %s\n", line, col, v)
		*errors++
	}
}
