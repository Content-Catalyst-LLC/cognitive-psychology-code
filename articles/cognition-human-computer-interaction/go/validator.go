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
	"interface_condition",
	"task_id",
	"trial",
	"task_difficulty",
	"perceptual_load",
	"attentional_demand",
	"working_memory_load",
	"cognitive_load",
	"alignment_score",
	"trust_score",
	"automation_reliance",
	"accessibility_friction",
	"success",
	"response_time_ms",
	"error_count",
	"warning_detected",
}

func main() {
	if len(os.Args) < 2 {
		log.Fatal("Usage: go run go/validator.go data/hci_trials.csv")
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

		condition := row[index["interface_condition"]]
		conditionCounts[condition]++

		checkRange(row, index, "task_difficulty", 0, 10, line, &errors)
		checkRange(row, index, "perceptual_load", 0, 10, line, &errors)
		checkRange(row, index, "attentional_demand", 0, 10, line, &errors)
		checkRange(row, index, "working_memory_load", 0, 10, line, &errors)
		checkRange(row, index, "cognitive_load", 0, 10, line, &errors)
		checkRange(row, index, "alignment_score", 0, 10, line, &errors)
		checkRange(row, index, "trust_score", 0, 10, line, &errors)
		checkRange(row, index, "automation_reliance", 0, 10, line, &errors)
		checkRange(row, index, "accessibility_friction", 0, 10, line, &errors)
		checkRange(row, index, "response_time_ms", 150, 1000000, line, &errors)
		checkNonNegativeInteger(row, index, "error_count", line, &errors)
		checkBinary(row, index, "success", line, &errors)
		checkBinary(row, index, "warning_detected", line, &errors)
	}

	fmt.Printf("Validated file: %s\n", path)
	fmt.Printf("Rows checked: %d\n", len(rows)-1)
	fmt.Printf("Validation errors: %d\n", errors)
	fmt.Println("Interface condition counts:")
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
