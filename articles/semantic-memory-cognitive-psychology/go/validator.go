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
	"trial",
	"cue_concept",
	"target_concept",
	"category",
	"relation_type",
	"semantic_distance",
	"category_typicality",
	"feature_overlap",
	"associative_strength",
	"concept_familiarity",
	"concreteness",
	"schema_consistency",
	"fact_true",
	"false_association",
	"verification_accuracy",
	"category_strength",
	"confidence",
	"response_time_ms",
}

func main() {
	if len(os.Args) < 2 {
		log.Fatal("Usage: go run go/validator.go data/semantic_memory_trials.csv")
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

		checkRange(row, index, "semantic_distance", 0, 10, line, &errors)
		checkRange(row, index, "category_typicality", 0, 10, line, &errors)
		checkRange(row, index, "feature_overlap", 0, 10, line, &errors)
		checkRange(row, index, "associative_strength", 0, 10, line, &errors)
		checkRange(row, index, "concept_familiarity", 0, 10, line, &errors)
		checkRange(row, index, "concreteness", 0, 10, line, &errors)
		checkRange(row, index, "schema_consistency", 0, 10, line, &errors)
		checkRange(row, index, "category_strength", 0, 10, line, &errors)
		checkRange(row, index, "confidence", 0, 10, line, &errors)
		checkRange(row, index, "response_time_ms", 150, 1000000, line, &errors)

		checkBinary(row, index, "fact_true", line, &errors)
		checkBinary(row, index, "false_association", line, &errors)
		checkBinary(row, index, "verification_accuracy", line, &errors)
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
