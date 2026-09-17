#!/bin/bash
mkdir -p results/scan-data
echo "Starting 30-cycle scan at $(date)" > results/scan-log.txt

for CYCLE in {1..30}; do
  echo "=== CYCLE $CYCLE ($(date)) ===" >> results/scan-log.txt
  
  # Scan vendor1 (target)
  POD=$(kubectl get pod -n vendor1 -l app=nginx-v1 -o jsonpath='{.items[0].metadata.name}')
  syft packages pod:$POD -n vendor1 -o cyclonedx-json > results/scan-data/sbom-vendor1-c${CYCLE}.json 2>> results/scan-log.txt
  grype sbom:results/scan-data/sbom-vendor1-c${CYCLE}.json -o json > results/scan-data/grype-vendor1-c${CYCLE}.json 2>> results/scan-log.txt
  
  echo "Cycle $CYCLE complete: $(wc -l results/scan-data/grype-vendor1-c${CYCLE}.json) vulns" >> results/scan-log.txt
  sleep 900  # 15min
done
echo "30 cycles complete: $(date)" >> results/scan-log.txt
