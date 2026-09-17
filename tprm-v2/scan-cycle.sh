#!/bin/bash
mkdir -p results/scan-data
echo "Starting 30-cycle scan at $(date)" > results/scan-log.txt

for CYCLE in {1..30}; do
  echo "=== CYCLE $CYCLE ($(date)) ===" >> results/scan-log.txt
  POD=$(kubectl get pod -n vendor1 -l app=nginx-v1 -o jsonpath='{.items[0].metadata.name}')
  syft packages pod:$POD -n vendor1 -o cyclonedx-json > results/scan-data/sbom-vendor1-c${CYCLE}.json 2>> results/scan-log.txt
  grype sbom:results/scan-data/sbom-vendor1-c${CYCLE}.json -o json > results/scan-data/grype-vendor1-c${CYCLE}.json 2>> results/scan-log.txt
  VULNS=$(jq '.matches | length' results/scan-data/grype-vendor1-c${CYCLE}.json 2>/dev/null || echo 0)
  echo "Cycle $CYCLE: $VULNS vulns" >> results/scan-log.txt
  sleep 900
done
