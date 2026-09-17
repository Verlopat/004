#!/bin/bash
mkdir -p results/scan-data
echo "=== IMAGE SCANNER v2 STARTED: $(date) ===" | tee -a results/scan-progress.log

while true; do
  CYCLE=$(( $(ls results/scan-data/sbom-*.json 2>/dev/null | wc -l) + 1 ))
  TIMESTAMP=$(date +%s)
  
  echo "=== CYCLE $CYCLE ($(date)) ===" | tee -a results/scan-progress.log
  
  CURRENT_IMG=$(kubectl get deploy nginx-vendor1 -n vendor1 -o jsonpath='{.spec.template.spec.containers[0].image}')
  echo "Scanning: $CURRENT_IMG" | tee -a results/scan-progress.log
  
  FILENAME="sbom-c${CYCLE}-${CURRENT_IMG//[:\/]/-}.json"
  syft "$CURRENT_IMG" -o cyclonedx-json > "results/scan-data/$FILENAME"
  
  GRYPE_FILE="grype-c${CYCLE}-${CURRENT_IMG//[:\/]/-}.json"
  grype "results/scan-data/$FILENAME" -o json > "results/scan-data/$GRYPE_FILE"
  
  VULNS=$(jq '.matches | length' "results/scan-data/$GRYPE_FILE" 2>/dev/null || echo 0)
  FIXED=$(jq '.matches[] | select(.status == "fixed") | length' "results/scan-data/$GRYPE_FILE" 2>/dev/null || echo 0)
  
  echo "CYCLE $CYCLE: $VULNS total ($FIXED fixed)" | tee -a results/scan-progress.log
  echo "$CYCLE,$TIMESTAMP,$CURRENT_IMG,$VULNS,$FIXED" >> results/scan-metrics.csv
  
  sleep 300
done
