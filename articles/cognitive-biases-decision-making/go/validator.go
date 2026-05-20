package main

import (
	"encoding/csv"
	"fmt"
	"log"
	"os"
	"strconv"
)

var requiredColumns = []string{
	"participant", "condition", "domain", "trial", "scenario_id", "bias_type",
	"frame", "gain_loss", "anchor_value", "base_rate", "representativeness",
	"evidence_valence", "confirmation_congruence", "prior_belief", "confidence_rating",
	"actual_accuracy", "calibration_error", "overconfidence", "probability", "payoff",
	"loss_aversion_lambda", "probability_weight", "subjective_value", "chose_risky",
	"choice_binary", "correct", "response_time_ms", "cognitive_load", "time_pressure",
	"debiasing_condition", "decision_quality", "institutional_review_flag",
}

func main() {
	if len(os.Args) < 2 {
		log.Fatal("Usage: go run go/validator.go data/cognitive_bias_trials.csv")
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
	biasCounts := map[string]int{}
	errors := 0

	for rowNum, row := range rows[1:] {
		line := rowNum + 2
		conditionCounts[row[index["condition"]]]++
		biasCounts[row[index["bias_type"]]]++

		checkRange(row, index, "anchor_value", 0, 100, line, &errors)
		checkRange(row, index, "base_rate", 0, 1, line, &errors)
		checkRange(row, index, "representativeness", 0, 10, line, &errors)
		checkRange(row, index, "evidence_valence", -5, 5, line, &errors)
		checkRange(row, index, "confirmation_congruence", 0, 1, line, &errors)
		checkRange(row, index, "prior_belief", 0, 1, line, &errors)
		checkRange(row, index, "confidence_rating", 0, 1, line, &errors)
		checkRange(row, index, "actual_accuracy", 0, 1, line, &errors)
		checkRange(row, index, "calibration_error", 0, 1, line, &errors)
		checkRange(row, index, "overconfidence", -1, 1, line, &errors)
		checkRange(row, index, "probability", 0, 1, line, &errors)
		checkRange(row, index, "loss_aversion_lambda", 0, 100, line, &errors)
		checkRange(row, index, "probability_weight", 0, 1, line, &errors)
		checkRange(row, index, "response_time_ms", 150, 1000000, line, &errors)
		checkRange(row, index, "cognitive_load", 0, 10, line, &errors)
		checkRange(row, index, "time_pressure", 0, 10, line, &errors)
		checkRange(row, index, "decision_quality", 0, 1, line, &errors)

		checkBinary(row, index, "chose_risky", line, &errors)
		checkBinary(row, index, "choice_binary", line, &errors)
		checkBinary(row, index, "correct", line, &errors)
		checkBinary(row, index, "institutional_review_flag", line, &errors)
	}

	fmt.Printf("Validated file: %s\n", path)
	fmt.Printf("Rows checked: %d\n", len(rows)-1)
	fmt.Printf("Validation errors: %d\n", errors)
	fmt.Println("Condition counts:")
	for condition, count := range conditionCounts {
		fmt.Printf("  %s: %d\n", condition, count)
	}
	fmt.Println("Bias-type counts:")
	for bias, count := range biasCounts {
		fmt.Printf("  %s: %d\n", bias, count)
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
