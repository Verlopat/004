# TPRM — Kubernetes Image Security Scanning Lab

Experimental lab for scanning Kubernetes container images with local `kind` clusters, Syft SBOM generation, Grype vulnerability scanning, and result processing.

## Workflow

1. Create a local cluster with `kind-*.yaml`.
2. Deploy `workloads.yaml` or `workloads-simple.yaml`.
3. Run `tpr-framework.sh` or the workflows under `tprm-v2/`.
4. Generate and inspect SBOM and Grype outputs.
5. Process results with `stats-processor.py`.

```bash
kind create cluster --config kind-config.yaml
kubectl apply -f workloads.yaml
bash tpr-framework.sh
python3 stats-processor.py
```

Required tools include Docker, kind, kubectl, Bash, Syft, Grype, and Python 3. Review every script for local image, namespace, and path assumptions before running it.

## Key files

- `kind-*.yaml` — local cluster definitions.
- `workloads*.yaml` — NGINX workload examples.
- `tpr-framework.sh` — top-level scan workflow.
- `tprm-v2/` — controller, recurring scan, and result workflows.
- `sbom-*.json`, `grype-*.txt`, `grype-nginx.json` — captured scan artifacts.
- `stats-processor.py` — statistics/report processing.

The committed reports are point-in-time artifacts; rerun scans before making security decisions. Do not use the scripts against production or unauthorized clusters.

## License

No license file is currently included.
