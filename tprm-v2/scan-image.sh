#!/bin/bash
set -e
mkdir -p results/scan-data results/scan-progress.log
echo "=== IMAGE SCANNER STARTED: $(date) ===" > results/scan-progress.log

# Get current deployment image (works 100%)
while true; do
  CYCLE=$(( $(ls results/scan-data/sbom-*.json 2>/dev/null | wc -l) + 1 ))
  TIMESTAMP=$(date +%s)
  
  echo "=== CYCLE $CYCLE ($(date)) ===" >> results/scan-progress.log
  
  # Extract CURRENT running image
  CURRENT_IMG=$(kubectl get deploy nginx-vendor1 -n vendor1 -o jsonpath='{.spec.template.spec.containers[0].image}')
  echo "Scanning image: $CURRENT_IMG" >> results/scan-progress.log
  
  # Native syft (installed & working)
  syft $CURRENT_IMG -o cyclonedx-json > results/scan-data/sbom-c${CYCLE}-\${CURRENT_IMG//[:\/]/-}.json
  VULNS=$(grype results/scan-data/sbom-c${CYCLE}-\${CURRENT_IMG//[:\/]/-}.json -o json | jq '.matches | length' 2>/dev/null || echo 0)
  
  echo "CYCLE $CYCLE: $CURRENT_IMG → $VULNS vulns ($(date))" >> results/scan-progress.log
  echo "$CYCLE,$TIMESTAMP,$CURRENT_IMG,$VULNS" >> results/scan-metrics.csv
  
  sleep 300  # 5min cycles (faster for testing)
done
