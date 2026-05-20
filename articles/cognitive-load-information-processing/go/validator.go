package main

import (
	"encoding/csv"
	"fmt"
	"log"
	"os"
	"strconv"
)

var requiredColumns = []string{
	"participant", "condition", "domain", "trial", "task_id", "expertise_level",
	"intrinsic_load", "extraneous_load", "germane_load", "element_interactivity",
	"prior_knowledge", "working_memory_capacity", "design_quality", "split_attention",
	"redundancy", "subjective_effort", "mental_demand", "temporal_demand", "frustration",
	"performance_accuracy", "correct", "rt_ms", "error_rate", "transfer_score",
	"learning_gain", "mental_efficiency", "confidence",
}

func main() {
	if len(os.Args) < 2 {
		log.Fatal("Usage: go run go/validator.go data/cognitive_load_trials.csv")
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
	expertiseCounts := map[string]int{}
	errors := 0

	for rowNum, row := range rows[1:] {
		line := rowNum + 2
		conditionCounts[row[index["condition"]]]++
		expertiseCounts[row[index["expertise_level"]]]++

		checkRange(row, index, "intrinsic_load", 0, 10, line, &errors)
		checkRange(row, index, "extraneous_load", 0, 10, line, &errors)
		checkRange(row, index, "germane_load", 0, 10, line, &errors)
		checkRange(row, index, "element_interactivity", 0, 10, line, &errors)
		checkRange(row, index, "prior_knowledge", 0, 10, line, &errors)
		checkRange(row, index, "working_memory_capacity", 0, 10, line, &errors)
		checkRange(row, index, "design_quality", 0, 10, line, &errors)
		checkRange(row, index, "split_attention", 0, 10, line, &errors)
		checkRange(row, index, "redundancy", 0, 10, line, &errors)
		checkRange(row, index, "subjective_effort", 0, 10, line, &errors)
		checkRange(row, index, "mental_demand", 0, 10, line, &errors)
		checkRange(row, index, "temporal_demand", 0, 10, line, &errors)
		checkRange(row, index, "frustration", 0, 10, line, &errors)
		checkRange(row, index, "performance_accuracy", 0, 1, line, &errors)
		checkRange(row, index, "rt_ms", 150, 1000000, line, &errors)
		checkRange(row, index, "error_rate", 0, 1, line, &errors)
		checkRange(row, index, "transfer_score", 0, 100, line, &errors)
		checkRange(row, index, "learning_gain", 0, 100, line, &errors)
		checkRange(row, index, "confidence", 0, 10, line, &errors)
		checkBinary(row, index, "correct", line, &errors)
	}

	fmt.Printf("Validated file: %s\n", path)
	fmt.Printf("Rows checked: %d\n", len(rows)-1)
	fmt.Printf("Validation errors: %d\n", errors)
	fmt.Println("Condition counts:")
	for condition, count := range conditionCounts {
		fmt.Printf("  %s: %d\n", condition, count)
	}
	fmt.Println("Expertise counts:")
	for expertise, count := range expertiseCounts {
		fmt.Printf("  %s: %d\n", expertise, count)
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
