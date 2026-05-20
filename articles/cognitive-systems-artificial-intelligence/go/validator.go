package main

import (
	"encoding/csv"
	"fmt"
	"log"
	"os"
	"strconv"
)

var requiredColumns = []string{
	"agent_id",
	"architecture",
	"task_condition",
	"trial",
	"input_noise",
	"representation_quality",
	"working_memory_load",
	"retrieval_latency_ms",
	"uncertainty_level",
	"policy_entropy",
	"prediction_accuracy",
	"action_success",
	"explanation_score",
	"human_trust",
	"override_decision",
	"response_time_ms",
	"calibration_error",
}

func main() {
	if len(os.Args) < 2 {
		log.Fatal("Usage: go run go/validator.go data/cognitive_systems_trials.csv")
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

	architectureCounts := map[string]int{}
	errors := 0

	for rowNum, row := range rows[1:] {
		line := rowNum + 2

		architecture := row[index["architecture"]]
		architectureCounts[architecture]++

		checkRange(row, index, "input_noise", 0, 10, line, &errors)
		checkRange(row, index, "representation_quality", 0, 10, line, &errors)
		checkRange(row, index, "working_memory_load", 0, 10, line, &errors)
		checkRange(row, index, "retrieval_latency_ms", 1, 100000, line, &errors)
		checkRange(row, index, "uncertainty_level", 0, 10, line, &errors)
		checkRange(row, index, "policy_entropy", 0, 5, line, &errors)
		checkRange(row, index, "prediction_accuracy", 0, 1, line, &errors)
		checkRange(row, index, "explanation_score", 0, 10, line, &errors)
		checkRange(row, index, "human_trust", 0, 10, line, &errors)
		checkRange(row, index, "response_time_ms", 1, 100000, line, &errors)
		checkRange(row, index, "calibration_error", 0, 1, line, &errors)

		checkBinary(row, index, "action_success", line, &errors)
		checkBinary(row, index, "override_decision", line, &errors)
	}

	fmt.Printf("Validated file: %s\n", path)
	fmt.Printf("Rows checked: %d\n", len(rows)-1)
	fmt.Printf("Validation errors: %d\n", errors)
	fmt.Println("Architecture counts:")
	for architecture, count := range architectureCounts {
		fmt.Printf("  %s: %d\n", architecture, count)
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
