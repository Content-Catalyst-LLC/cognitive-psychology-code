package main

import (
	"encoding/csv"
	"fmt"
	"log"
	"os"
	"strconv"
)

var requiredColumns = []string{
	"participant", "condition", "domain", "trial", "stimulus_id", "modality",
	"stimulus_level", "signal_present", "response_yes", "correct", "sensory_evidence",
	"prior_expectation", "cue_quality", "attention_gain", "context_strength", "noise_level",
	"prediction_error", "perceptual_threshold", "confidence", "response_time_ms",
	"multisensory_congruence", "visual_search_set_size", "distractor_similarity",
	"perceptual_learning_block", "interface_salience",
}

func main() {
	if len(os.Args) < 2 {
		log.Fatal("Usage: go run go/validator.go data/perception_trials.csv")
	}

	path := os.Args[1]
	file, err := os.Open(path)
	if err != nil { log.Fatal(err) }
	defer file.Close()

	reader := csv.NewReader(file)
	reader.FieldsPerRecord = -1
	rows, err := reader.ReadAll()
	if err != nil { log.Fatal(err) }
	if len(rows) < 2 { log.Fatal("CSV must contain a header and at least one data row") }

	header := rows[0]
	index := map[string]int{}
	for i, col := range header { index[col] = i }

	missing := []string{}
	for _, col := range requiredColumns {
		if _, ok := index[col]; !ok { missing = append(missing, col) }
	}
	if len(missing) > 0 { log.Fatalf("Missing required columns: %v", missing) }

	conditionCounts := map[string]int{}
	modalityCounts := map[string]int{}
	errors := 0

	for rowNum, row := range rows[1:] {
		line := rowNum + 2
		conditionCounts[row[index["condition"]]]++
		modalityCounts[row[index["modality"]]]++

		checkRange(row, index, "trial", 1, 1000000, line, &errors)
		checkRange(row, index, "prior_expectation", 0, 10, line, &errors)
		checkRange(row, index, "cue_quality", 0, 10, line, &errors)
		checkRange(row, index, "attention_gain", 0, 10, line, &errors)
		checkRange(row, index, "context_strength", 0, 10, line, &errors)
		checkRange(row, index, "noise_level", 0, 10, line, &errors)
		checkRange(row, index, "prediction_error", 0, 1000000, line, &errors)
		checkRange(row, index, "confidence", 0, 1, line, &errors)
		checkRange(row, index, "response_time_ms", 150, 1000000, line, &errors)
		checkRange(row, index, "multisensory_congruence", 0, 1, line, &errors)
		checkRange(row, index, "visual_search_set_size", 1, 1000000, line, &errors)
		checkRange(row, index, "distractor_similarity", 0, 10, line, &errors)
		checkRange(row, index, "perceptual_learning_block", 1, 1000000, line, &errors)
		checkRange(row, index, "interface_salience", 0, 10, line, &errors)
		checkBinary(row, index, "signal_present", line, &errors)
		checkBinary(row, index, "response_yes", line, &errors)
		checkBinary(row, index, "correct", line, &errors)
	}

	fmt.Printf("Validated file: %s\n", path)
	fmt.Printf("Rows checked: %d\n", len(rows)-1)
	fmt.Printf("Validation errors: %d\n", errors)
	fmt.Println("Condition counts:")
	for condition, count := range conditionCounts { fmt.Printf("  %s: %d\n", condition, count) }
	fmt.Println("Modality counts:")
	for modality, count := range modalityCounts { fmt.Printf("  %s: %d\n", modality, count) }

	if errors > 0 { os.Exit(2) }
}

func checkRange(row []string, index map[string]int, col string, min float64, max float64, line int, errors *int) {
	value, err := strconv.ParseFloat(row[index[col]], 64)
	if err != nil {
		fmt.Printf("Line %d: %s is not numeric: %s\n", line, col, row[index[col]])
		*errors++
		return
	}
	if value < min || value > max {
		fmt.Printf("Line %d: %s out of range [%.1f, %.1f]: %.3f\n", line, col, min, max, value)
		*errors++
	}
}

func checkBinary(row []string, index map[string]int, col string, line int, errors *int) {
	value := row[index[col]]
	if value != "0" && value != "1" {
		fmt.Printf("Line %d: %s must be 0 or 1, got %s\n", line, col, value)
		*errors++
	}
}
