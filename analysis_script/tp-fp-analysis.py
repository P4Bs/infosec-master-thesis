#!/usr/bin/env python3
"""
Analyze CSV with columns: file, cwe, mode, status, warnings_raw, vuln_detected.
Each file appears exactly twice (one BAD, one GOOD). So total files = total entries / 2.
Classify each row and report counts.
"""

import csv
import sys
import argparse

def main():
    parser = argparse.ArgumentParser(description="Analyze vulnerability detection results.")
    parser.add_argument("csv_file", nargs="?", help="Path to the CSV file. If omitted, read from stdin.")
    args = parser.parse_args()

    # Determine input source
    if args.csv_file:
        f = open(args.csv_file, "r", encoding="utf-8")
    else:
        f = sys.stdin

    reader = csv.DictReader(f)

    # Initialize counters
    total_rows = 0
    false_negatives = 0
    true_positives = 0
    true_negatives = 0
    false_positives = 0

    for row in reader:
        total_rows += 1
        mode = row.get("mode", "").strip().upper()
        vuln = row.get("vuln_detected", "").strip().lower()

        # Classify based on mode and vuln_detected
        if mode == "BAD" and vuln == "false":
            false_negatives += 1
        elif mode == "BAD" and vuln == "true":
            true_positives += 1
        elif mode == "GOOD" and vuln == "false":
            true_negatives += 1
        elif mode == "GOOD" and vuln == "true":
            false_positives += 1
        else:
            sys.stderr.write(f"Warning: unexpected values (mode={mode}, vuln_detected={vuln}) at row {total_rows}\n")

    if args.csv_file:
        f.close()

    # Each file appears exactly twice, so total files = total_rows / 2
    total_files = total_rows // 2

    # Print results
    print(f"Total files: {total_files}")
    print(f"Total entries: {total_rows}")
    print(f"False positives: {false_positives}")
    print(f"False negatives: {false_negatives}")
    print(f"True negatives: {true_negatives}")
    print(f"True positives: {true_positives}")

if __name__ == "__main__":
    main()
