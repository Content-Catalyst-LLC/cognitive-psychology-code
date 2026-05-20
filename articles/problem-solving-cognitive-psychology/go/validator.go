package main

import (
	"encoding/csv"
	"fmt"
	"log"
	"os"
	"strconv"
)

var requiredColumns = []string{
	"participant",
	"condition",
	"problem_id",
	"trial",
	"problem_difficulty",
	"representation_quality",
	"goal_clarity",
	"constraint_load",
	"wm_load",
	"strategy_type",
	"metacognitive_monitoring",
	"strategy_switch_count",
	"switched_strategy",
	"insight_event",
	"solution_accuracy",
	"solution_quality",
	"error_count",
	"confidence",
	"response_time_ms",
}

func main() {
	if len(os.Args) < 2 {
		log.Fatal("Usage: go run go/validator.go data/problem_solving_trials.csv")
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
	errors := 0

	for rowNum, row := range rows[1:] {
		line := rowNum + 2
		condition := row[index["condition"]]
		conditionCounts[condition]++

		checkRange(row, index, "problem_difficulty", 0, 10, line, &errors)
		checkRange(row, index, "representation_quality", 0, 10, line, &errors)
		checkRange(row, index, "goal_clarity", 0, 10, line, &errors)
		checkRange(row, index, "constraint_load", 0, 10, line, &errors)
		checkRange(row, index, "wm_load", 0, 10, line, &errors)
		checkRange(row, index, "metacognitive_monitoring", 0, 10, line, &errors)
		checkRange(row, index, "solution_quality", 0, 100, line, &errors)
		checkRange(row, index, "confidence", 0, 10, line, &errors)
		checkRange(row, index, "response_time_ms", 150, 1000000, line, &errors)

		checkNonNegativeInteger(row, index, "strategy_switch_count", line, &errors)
		checkNonNegativeInteger(row, index, "error_count", line, &errors)
		checkBinary(row, index, "switched_strategy", line, &errors)
		checkBinary(row, index, "insight_event", line, &errors)
		checkBinary(row, index, "solution_accuracy", line, &errors)
	}

	fmt.Printf("Validated file: %s\n", path)
	fmt.Printf("Rows checked: %d\n", len(rows)-1)
	fmt.Printf("Validation errors: %d\n", errors)
	fmt.Println("Condition counts:")
	for condition, count := range conditionCounts {
		fmt.Printf("  %s: %d\n", condition, count)
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

func checkNonNegativeInteger(row []string, index map[string]int, col string, line int, errors *int) {
	value, err := strconv.Atoi(row[index[col]])
	if err != nil {
		fmt.Printf("Line %d: %s is not an integer: %s\n", line, col, row[index[col]])
		*errors = *errors + 1
		return
	}
	if value < 0 {
		fmt.Printf("Line %d: %s must be non-negative, got %d\n", line, col, value)
		*errors = *errors + 1
	}
}
