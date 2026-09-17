#!/bin/bash
# TPRM Continuous Monitoring Framework v1.0
while true; do
  TS=$(date +%Y%m%d-%H%M%S)
  echo "=== [$TS] DPDPA Third-Party Risk Scan ==="
  
  # 1. SBOM Generation (vendor exchange simulation)
  for DEP in nginx-vulnerable nginx-secure; do
    POD=$(kubectl get pods -l app="$DEP" -o jsonpath='{.items[0].metadata.name}')
    IMAGE=$(kubectl get pod "$POD" -o jsonpath='{.spec.containers[0].image}')
    
    echo "Scanning $DEP ($IMAGE)..."
    syft "$IMAGE" -o json > "sbom-$DEP-$TS.json"
    
    # 2. Vulnerability Assessment  
    grype sbom:"sbom-$DEP-$TS.json" > "grype-$DEP-$TS.txt"
    
    # 3. DPDPA Triggers
    if grep -q "HIGH\|CRITICAL" "grype-$DEP-$TS.txt"; then
      echo "🚨 DPDPA AUDIT TRIGGER: $DEP - High risk detected!"
      # trigger_audit.sh "$DEP" "HIGH_VULN"
    fi
  done
  
  sleep 300  # 5min continuous cycle
done
