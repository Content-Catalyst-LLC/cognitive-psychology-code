package main

import (
	"encoding/csv"
	"fmt"
	"log"
	"os"
	"strconv"
)

var requiredColumns = []string{
	"participant", "condition", "domain", "trial", "task_type", "modality", "load",
	"serial_position", "distractor_level", "interference", "attentional_control",
	"updating_demand", "storage_demand", "processing_demand", "chunking_support",
	"rehearsal_opportunity", "cognitive_load", "span_score", "updating_score",
	"capacity_estimate", "overload_probability", "dual_task_cost", "correct",
	"accuracy", "response_time_ms", "confidence", "learning_support", "interface_complexity",
}

func main() {
	if len(os.Args) < 2 {
		log.Fatal("Usage: go run go/validator.go data/working_memory_trials.csv")
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
	taskCounts := map[string]int{}
	errors := 0

	for rowNum, row := range rows[1:] {
		line := rowNum + 2
		conditionCounts[row[index["condition"]]]++
		taskCounts[row[index["task_type"]]]++

		checkRange(row, index, "load", 1, 1000000, line, &errors)
		checkRange(row, index, "serial_position", 1, 1000000, line, &errors)
		checkRange(row, index, "distractor_level", 0, 10, line, &errors)
		checkRange(row, index, "interference", 0, 10, line, &errors)
		checkRange(row, index, "attentional_control", 0, 10, line, &errors)
		checkRange(row, index, "updating_demand", 0, 10, line, &errors)
		checkRange(row, index, "storage_demand", 0, 10, line, &errors)
		checkRange(row, index, "processing_demand", 0, 10, line, &errors)
		checkRange(row, index, "chunking_support", 0, 10, line, &errors)
		checkRange(row, index, "rehearsal_opportunity", 0, 10, line, &errors)
		checkRange(row, index, "cognitive_load", 0, 10, line, &errors)
		checkRange(row, index, "span_score", 0, 1000000, line, &errors)
		checkRange(row, index, "updating_score", 0, 1, line, &errors)
		checkRange(row, index, "capacity_estimate", 0, 1000000, line, &errors)
		checkRange(row, index, "overload_probability", 0, 1, line, &errors)
		checkRange(row, index, "dual_task_cost", 0, 1, line, &errors)
		checkRange(row, index, "accuracy", 0, 1, line, &errors)
		checkRange(row, index, "response_time_ms", 150, 1000000, line, &errors)
		checkRange(row, index, "confidence", 0, 1, line, &errors)
		checkRange(row, index, "learning_support", 0, 10, line, &errors)
		checkRange(row, index, "interface_complexity", 0, 10, line, &errors)
		checkBinary(row, index, "correct", line, &errors)
	}

	fmt.Printf("Validated file: %s\n", path)
	fmt.Printf("Rows checked: %d\n", len(rows)-1)
	fmt.Printf("Validation errors: %d\n", errors)
	fmt.Println("Condition counts:")
	for condition, count := range conditionCounts {
		fmt.Printf("  %s: %d\n", condition, count)
	}
	fmt.Println("Task-type counts:")
	for task, count := range taskCounts {
		fmt.Printf("  %s: %d\n", task, count)
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
