package main

import (
	"encoding/csv"
	"fmt"
	"log"
	"os"
	"strconv"
)

var requiredColumns = []string{
	"participant", "condition", "domain", "trial", "scenario_id",
	"objective_probability", "subjective_probability", "consequence_rating",
	"affect_rating", "dread_rating", "familiarity_rating", "controllability_rating",
	"trust_rating", "ambiguity_rating", "communication_clarity", "perceived_benefit",
	"perceived_risk", "choose_safe", "protective_action", "rt_ms", "confidence",
}

func main() {
	if len(os.Args) < 2 {
		log.Fatal("Usage: go run go/validator.go data/risk_perception_trials.csv")
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
	domainCounts := map[string]int{}
	errors := 0

	for rowNum, row := range rows[1:] {
		line := rowNum + 2
		conditionCounts[row[index["condition"]]]++
		domainCounts[row[index["domain"]]]++

		checkRange(row, index, "objective_probability", 0, 1, line, &errors)
		checkRange(row, index, "subjective_probability", 0, 1, line, &errors)
		checkRange(row, index, "consequence_rating", 0, 10, line, &errors)
		checkRange(row, index, "affect_rating", 0, 10, line, &errors)
		checkRange(row, index, "dread_rating", 0, 10, line, &errors)
		checkRange(row, index, "familiarity_rating", 0, 10, line, &errors)
		checkRange(row, index, "controllability_rating", 0, 10, line, &errors)
		checkRange(row, index, "trust_rating", 0, 10, line, &errors)
		checkRange(row, index, "ambiguity_rating", 0, 10, line, &errors)
		checkRange(row, index, "communication_clarity", 0, 10, line, &errors)
		checkRange(row, index, "perceived_benefit", 0, 10, line, &errors)
		checkRange(row, index, "perceived_risk", 0, 10, line, &errors)
		checkRange(row, index, "rt_ms", 150, 1000000, line, &errors)
		checkRange(row, index, "confidence", 0, 10, line, &errors)

		checkBinary(row, index, "choose_safe", line, &errors)
		checkBinary(row, index, "protective_action", line, &errors)
	}

	fmt.Printf("Validated file: %s\n", path)
	fmt.Printf("Rows checked: %d\n", len(rows)-1)
	fmt.Printf("Validation errors: %d\n", errors)
	fmt.Println("Condition counts:")
	for condition, count := range conditionCounts {
		fmt.Printf("  %s: %d\n", condition, count)
	}
	fmt.Println("Domain counts:")
	for domain, count := range domainCounts {
		fmt.Printf("  %s: %d\n", domain, count)
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
