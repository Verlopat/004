#!/bin/bash
echo "event,timestamp,old_img,new_img" > results/injection_log.csv

IMG_SEQ=("nginx:1.25-alpine" "nginx:1.24-alpine" "nginx:1.23-alpine" "busybox:1.35-glibc" "alpine:3.18")
for i in {0..9}; do
  NEW_IMG=${IMG_SEQ[$((i%5))]}
  TS=$(date -u +%s)
  OLD_IMG=$(kubectl get deploy nginx-vendor1 -n vendor1 -o jsonpath='{.spec.template.spec.containers[0].image}')
  kubectl -n vendor1 set image deploy/nginx-vendor1 nginx=$NEW_IMG
  echo "event_$i,$TS,$OLD_IMG,$NEW_IMG" >> results/injection_log.csv
  echo "INJECTION $i: $OLD_IMG → $NEW_IMG ($(date))"
  sleep 900  # 15min
done
echo "10 injections complete!"
