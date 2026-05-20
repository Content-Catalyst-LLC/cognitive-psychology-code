package main

import (
	"encoding/csv"
	"fmt"
	"log"
	"os"
	"strconv"
)

var requiredColumns = []string{
	"participant", "modality", "condition", "trial", "stimulus_id",
	"cue_delay_ms", "stimulus_duration_ms", "array_size", "cue_validity",
	"mask_present", "trace_strength", "salience", "attentional_priority",
	"report_score", "correct", "selection_probability", "wm_transfer",
	"rt_ms", "confidence", "perceptual_continuity",
}

func main() {
	if len(os.Args) < 2 {
		log.Fatal("Usage: go run go/validator.go data/sensory_memory_trials.csv")
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

	modalityCounts := map[string]int{}
	conditionCounts := map[string]int{}
	errors := 0

	for rowNum, row := range rows[1:] {
		line := rowNum + 2
		modalityCounts[row[index["modality"]]]++
		conditionCounts[row[index["condition"]]]++

		checkRange(row, index, "cue_delay_ms", 0, 1000000, line, &errors)
		checkRange(row, index, "stimulus_duration_ms", 1, 1000000, line, &errors)
		checkRange(row, index, "array_size", 1, 1000000, line, &errors)
		checkRange(row, index, "cue_validity", 0, 1, line, &errors)
		checkRange(row, index, "trace_strength", 0, 1, line, &errors)
		checkRange(row, index, "salience", 0, 10, line, &errors)
		checkRange(row, index, "attentional_priority", 0, 10, line, &errors)
		checkRange(row, index, "report_score", 0, 1000000, line, &errors)
		checkRange(row, index, "selection_probability", 0, 1, line, &errors)
		checkRange(row, index, "rt_ms", 100, 1000000, line, &errors)
		checkRange(row, index, "confidence", 0, 10, line, &errors)
		checkRange(row, index, "perceptual_continuity", 0, 10, line, &errors)

		checkBinary(row, index, "mask_present", line, &errors)
		checkBinary(row, index, "correct", line, &errors)
		checkBinary(row, index, "wm_transfer", line, &errors)
	}

	fmt.Printf("Validated file: %s\n", path)
	fmt.Printf("Rows checked: %d\n", len(rows)-1)
	fmt.Printf("Validation errors: %d\n", errors)
	fmt.Println("Modality counts:")
	for modality, count := range modalityCounts {
		fmt.Printf("  %s: %d\n", modality, count)
	}
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
