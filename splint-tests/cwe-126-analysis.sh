#!/bin/bash

SUITE_DIR="/home/p4bs/splint_analysis/juliet-analysis/juliet-test-suite-c/testcases/CWE126_Buffer_Overread"
SUPPORT_DIR="/home/p4bs/splint_analysis/juliet-analysis/juliet-test-suite-c/testcasesupport"
TIMESTAMP=$(date +%Y%m%d%H%M%S)
LOG_BASE="/home/p4bs/splint_analysis/juliet-test-suite-c/debug/logs/CWE126_Buffer_Overread/${TIMESTAMP}"
OUTPUT_CSV_DIR="/home/p4bs/splint_analysis/juliet-analysis/juliet-test-suite-c/output-csv/CWE126_Buffer_Overread"
OUTPUT_CSV="${OUTPUT_CSV_DIR}/${TIMESTAMP}.csv"
SPLINT_FLAGS="-I${SUPPORT_DIR} +posixlib +strict +checks +memchecks +bounds +boundsread +boundswrite +null +nullterminated +mustfreefresh -namechecks"

# CREATE GOOD AND BAD TEST CASE LOGS
mkdir -p "${OUTPUT_CSV_DIR}"
mkdir -p "${LOGS_BASE}/bad" "${LOGS_BASE}/good"

echo "file,cwe,mode,status,warnings_raw,vuln_detected" > "$OUTPUT_CSV"

# COUNT TOTAL FILES (EXCLUDING w32)
total=$(find "$SUITE_DIR" -name "*.c" ! -path "*w32*" | wc -l)
current=0

echo "Analysing test cases... (Total amount: $total)"

find "$SUITE_DIR" -name "*.c" ! -path "*w32*" | while read file; do
    current=$((current + 1))
    percent=$((current * 100 / total))

    # SHOW TOTAL PROGRESS
    printf "\rProcessing %d of %d (%d%%) - %s" "$current" "$total" "$percent" "$(basename "$file")"

    rel_path="${file#${SUITE_DIR}/}"
    cwe_dir=$(dirname "$file" | sed 's#.*/##')
    filename=$(basename "$file")

    # LOG FILES
    bad_log="${LOG_BASE}/bad/${rel_path}.txt"
    good_log="${LOG_BASE}/good/${rel_path}.txt"

    # CREATE DIRECTORIES IF THEY DO NOT EXIST
    mkdir -p "$(dirname "$bad_log")"
    mkdir -p "$(dirname "$good_log")"

    # BAD clause of test case
    bad_output_raw=$(splint $SPLINT_FLAGS -DOMITGOOD "$file" 2>&1 | grep -v "^Splint " | tr -d '\r')
    echo "$bad_output_raw" > "$bad_log"
    # bad_count=$(echo "$bad_output_raw" | grep -c "warning")
    bad_keyw=$(echo "$bad_output_raw" | grep -m1 -E -i 'out-of-bounds|possible out-of-bounds' || echo "")
    bad_keyw=$(echo "$bad_keyw" | sed 's/"/""/g')
    if [ -z "$bad_keyw" ]; then
        vuln_detected_bad="false"
    else
        vuln_detected_bad="true"
    fi

    echo "${filename},${cwe_dir},BAD,analyzed,\"${bad_log}\",\"${vuln_detected_bad}\"" >> "$OUTPUT_CSV"

    # GOOD clause of test case
    good_output_raw=$(splint $SPLINT_FLAGS -DOMITBAD "$file" 2>&1 | grep -v "^Splint " | tr -d '\r')
    echo "$good_output_raw" > "$good_log"
    # good_count=$(echo "$good_output_raw" | grep -c "warning")
    good_keyw=$(echo "$good_output_raw" | grep -m1 -E -i "out-of-bounds|possible out-of-bounds" || echo "")
    good_keyw=$(echo "$good_keyw" | sed 's/"/""/g')
    if [ -z "$bad_keyw" ]; then
        vuln_detected_good="false"
    else
        vuln_detected_good="true"
    fi

    echo "${filename},${cwe_dir},GOOD,analyzed,\"${good_log}\",\"${vuln_detected_good}\"" >> "$OUTPUT_CSV"
done

# Finalizado
printf "\nAnalysis completed. Check the results at %s\n" "$OUTPUT_CSV"
