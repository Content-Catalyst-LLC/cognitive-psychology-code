package main

import (
	"encoding/csv"
	"fmt"
	"log"
	"os"
	"strconv"
)

var requiredColumns = []string{
	"participant", "condition", "domain", "trial", "scenario_id", "option_count",
	"frame", "gain_loss", "probability", "payoff", "reference_point", "expected_value",
	"expected_utility", "loss_aversion_lambda", "probability_weight", "subjective_value",
	"evidence_strength", "drift_rate_proxy", "decision_threshold", "choice_risky",
	"choice_option", "optimal_choice", "accuracy", "confidence", "affective_valence",
	"cognitive_load", "time_pressure", "uncertainty", "response_time_ms", "feedback_valence",
	"regret", "decision_quality", "ai_recommendation", "ai_agreement", "verification_burden",
}

func main() {
	if len(os.Args) < 2 {
		log.Fatal("Usage: go run go/validator.go data/decision_trials.csv")
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

		checkRange(row, index, "option_count", 2, 1000000, line, &errors)
		checkRange(row, index, "probability", 0, 1, line, &errors)
		checkRange(row, index, "loss_aversion_lambda", 0, 100, line, &errors)
		checkRange(row, index, "probability_weight", 0, 1, line, &errors)
		checkRange(row, index, "decision_threshold", 0, 100, line, &errors)
		checkRange(row, index, "accuracy", 0, 1, line, &errors)
		checkRange(row, index, "confidence", 0, 1, line, &errors)
		checkRange(row, index, "affective_valence", -5, 5, line, &errors)
		checkRange(row, index, "cognitive_load", 0, 10, line, &errors)
		checkRange(row, index, "time_pressure", 0, 10, line, &errors)
		checkRange(row, index, "uncertainty", 0, 10, line, &errors)
		checkRange(row, index, "response_time_ms", 150, 1000000, line, &errors)
		checkRange(row, index, "feedback_valence", -5, 5, line, &errors)
		checkRange(row, index, "regret", 0, 10, line, &errors)
		checkRange(row, index, "decision_quality", 0, 1, line, &errors)
		checkRange(row, index, "verification_burden", 0, 10, line, &errors)
		checkBinary(row, index, "choice_risky", line, &errors)
		checkBinary(row, index, "optimal_choice", line, &errors)
		checkBinary(row, index, "ai_recommendation", line, &errors)
		checkBinary(row, index, "ai_agreement", line, &errors)
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
