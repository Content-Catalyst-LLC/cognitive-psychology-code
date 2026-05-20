package main

import (
	"encoding/csv"
	"fmt"
	"log"
	"os"
	"strconv"
)

var requiredColumns = []string{
	"participant", "condition", "domain", "trial", "scenario_id", "heuristic_type",
	"anchor_value", "adjustment", "recall_ease", "representativeness", "base_rate",
	"base_rate_use", "recognition_strength", "fluency", "affective_valence",
	"cue_validity", "cue_count", "information_cost", "time_pressure", "cognitive_load",
	"strategy_complexity", "subjective_effort", "judged_probability", "true_probability",
	"estimate", "true_value", "choice_binary", "correct", "rt_ms", "confidence",
	"calibration_error", "bias_magnitude", "adaptive_fit",
}

func main() {
	if len(os.Args) < 2 {
		log.Fatal("Usage: go run go/validator.go data/heuristics_trials.csv")
	}

	path := os.Args[1]
	file, err := os.Open(path)
	if err != nil {
		log.Fatal(err)
	}
	defer file.Close()

	reader := csv.NewReader(file)
	reader.FieldsPerRecord = -1
	rows, err := reader.ReadAll()
	if err != nil {
		log.Fatal(err)
	}
	if len(rows) < 2 {
		log.Fatal("CSV must contain a header and at least one data row")
	}

	header := rows[0]
	index := map[string]int{}
	for i, col := range header {
		index[col] = i
	}

	missing := []string{}
	for _, col := range requiredColumns {
		if _, ok := index[col]; !ok {
			missing = append(missing, col)
		}
	}
	if len(missing) > 0 {
		log.Fatalf("Missing required columns: %v", missing)
	}

	conditionCounts := map[string]int{}
	heuristicCounts := map[string]int{}
	errors := 0

	for rowNum, row := range rows[1:] {
		line := rowNum + 2
		conditionCounts[row[index["condition"]]]++
		heuristicCounts[row[index["heuristic_type"]]]++

		checkRange(row, index, "anchor_value", 0, 100, line, &errors)
		checkRange(row, index, "recall_ease", 0, 10, line, &errors)
		checkRange(row, index, "representativeness", 0, 10, line, &errors)
		checkRange(row, index, "base_rate", 0, 1, line, &errors)
		checkRange(row, index, "base_rate_use", 0, 1, line, &errors)
		checkRange(row, index, "recognition_strength", 0, 10, line, &errors)
		checkRange(row, index, "fluency", 0, 10, line, &errors)
		checkRange(row, index, "affective_valence", -5, 5, line, &errors)
		checkRange(row, index, "cue_validity", 0, 1, line, &errors)
		checkRange(row, index, "cue_count", 1, 1000000, line, &errors)
		checkRange(row, index, "information_cost", 0, 10, line, &errors)
		checkRange(row, index, "time_pressure", 0, 10, line, &errors)
		checkRange(row, index, "cognitive_load", 0, 10, line, &errors)
		checkRange(row, index, "strategy_complexity", 0, 10, line, &errors)
		checkRange(row, index, "subjective_effort", 0, 10, line, &errors)
		checkRange(row, index, "judged_probability", 0, 1, line, &errors)
		checkRange(row, index, "true_probability", 0, 1, line, &errors)
		checkRange(row, index, "estimate", 0, 100, line, &errors)
		checkRange(row, index, "true_value", 0, 100, line, &errors)
		checkRange(row, index, "rt_ms", 150, 1000000, line, &errors)
		checkRange(row, index, "confidence", 0, 10, line, &errors)
		checkRange(row, index, "calibration_error", 0, 1, line, &errors)
		checkRange(row, index, "bias_magnitude", 0, 1000000, line, &errors)
		checkRange(row, index, "adaptive_fit", -1, 1, line, &errors)
		checkBinary(row, index, "choice_binary", line, &errors)
		checkBinary(row, index, "correct", line, &errors)
	}

	fmt.Printf("Validated file: %s\n", path)
	fmt.Printf("Rows checked: %d\n", len(rows)-1)
	fmt.Printf("Validation errors: %d\n", errors)
	fmt.Println("Condition counts:")
	for condition, count := range conditionCounts {
		fmt.Printf("  %s: %d\n", condition, count)
	}
	fmt.Println("Heuristic counts:")
	for heuristic, count := range heuristicCounts {
		fmt.Printf("  %s: %d\n", heuristic, count)
	}

	if errors > 0 {
		os.Exit(2)
	}
}

func checkRange(row []string, index map[string]int, col string, min float64, max float64, line int, errors *int) {
	value, err := strconv.ParseFloat(row[index[col]], 64)
	if err != nil {
		fmt.Printf("Line %d: %s is not numeric: %s\n", line, col, row[index[col]])
		*errors = *errors + 1
		return
	}
	if value < min || value > max {
		fmt.Printf("Line %d: %s out of range [%.1f, %.1f]: %.3f\n", line, col, min, max, value)
		*errors = *errors + 1
	}
}

func checkBinary(row []string, index map[string]int, col string, line int, errors *int) {
	value := row[index[col]]
	if value != "0" && value != "1" {
		fmt.Printf("Line %d: %s must be 0 or 1, got %s\n", line, col, value)
		*errors = *errors + 1
	}
}
