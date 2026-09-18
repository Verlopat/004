# TPRM — Kubernetes Image Security Scanning Lab

This repository is a proof-of-concept lab for scanning container images used by Kubernetes workloads. It combines local **kind** clusters, Kubernetes manifests, Syft-generated SBOMs, Grype vulnerability reports, shell-based scan automation, and a Python statistics processor to compare vulnerable and hardened NGINX image variants.

> **Status:** Experimental / lab repository. It contains captured scan outputs, process-ID files, and logs alongside the scripts and manifests. Review and adapt the commands before using them in a production environment.

## What the repository contains

| Area | Files | Purpose |
| --- | --- | --- |
| Local Kubernetes setup | `kind-config.yaml`, `kind-simple.yaml`, `kind-tprm.yaml`, `tprm-v2/kind-multi-cloud.yaml` | Defines kind cluster configurations, including multi-node variants. |
| Workload samples | `workloads.yaml`, `workloads-simple.yaml` | Deploys NGINX-based workload examples intended for scanning experiments. |
| Scan automation | `tpr-framework.sh`, `tprm-v2/scan-image.sh`, `tprm-v2/scan-image-v2.sh`, `tprm-v2/scan-cycle.sh` | Runs image scanning and periodic scan workflows. |
| Kubernetes injection | `tprm-v2/inject-controller.sh` | Applies or injects the controller used by the experiment. |
| Results processing | `stats-processor.py` | Processes scan/result data to produce summary statistics. |
| Security artifacts | `sbom-*.json`, `grype-*.txt`, `grype-nginx.json` | Saved SBOM and vulnerability-scan outputs for NGINX image variants. |
| Run-state artifacts | `*.pid`, `tpr-results.log`, `tprm-v2/results/` | Process identifiers and generated log/result material from prior runs. |

## Workflow

The intended workflow is:

1. Create a local Kubernetes cluster with one of the kind configuration files.
2. Apply an NGINX workload manifest.
3. Run an image-scanning script against the workload’s container image.
4. Generate or inspect SBOM and Grype vulnerability outputs.
5. Process the resulting data with the Python utility and retain the results for comparison.

The checked-in artifacts distinguish `nginx-secure` and `nginx-vulnerable` images, enabling a side-by-side scan comparison.

## Prerequisites

Install and configure the following command-line tools before running the scripts:

- Docker, to build, pull, and run container images.
- kind, to create a local Kubernetes cluster running in Docker.
- kubectl, to apply manifests and inspect Kubernetes workloads.
- Syft, to generate software bills of materials (SBOMs).
- Grype, to scan images or SBOMs for known vulnerabilities.
- Python 3, to run `stats-processor.py`.
- Bash and common Unix command-line tools.

Confirm that Docker is running and that `kubectl` is configured to use the kind context created for this lab.

## Quick start

The exact configuration to use depends on the experiment you want to run. A typical local sequence is:

```bash
# Create a local kind cluster
kind create cluster --config kind-config.yaml

# Deploy the example workload
kubectl apply -f workloads.yaml

# Inspect deployed pods and their images
kubectl get pods -A
kubectl get pods -A -o jsonpath='{range .items[*]}{.metadata.namespace}{"/"}{.metadata.name}{"  "}{range .spec.containers[*]}{.image}{"\n"}{end}{end}'

# Run the repository scan workflow
bash tpr-framework.sh
```

The scripts may assume particular local paths, image names, namespaces, or installed versions of Syft and Grype. Inspect each script before execution and adjust those assumptions for your machine.

## Scanning images manually

The repository includes scan scripts, but the underlying workflow can also be run directly. For example:

```bash
# Create an SBOM for an image
syft nginx:latest -o json > sbom-nginx.json

# Scan the image or its SBOM with Grype
grype nginx:latest -o json > grype-nginx.json
grype sbom:sbom-nginx.json -o table > grype-nginx.txt
```

Use explicit image tags or immutable digests rather than `latest` when you need reproducible results.

## Results and analysis

- `sbom-nginx-vulnerable-*.json` and `sbom-nginx-secure-*.json` are saved SBOM snapshots.
- `grype-nginx-vulnerable-*.txt` and `grype-nginx-secure-*.txt` are human-readable vulnerability reports.
- `grype-nginx.json` is a JSON-formatted Grype output suitable for programmatic processing.
- `stats-processor.py` is the repository’s Python entry point for turning collected result data into statistics.

To run the processor, use Python 3 and supply the inputs expected by its implementation:

```bash
python3 stats-processor.py
```

## Repository layout

```text
.
├── kind-*.yaml                 # kind cluster definitions
├── workloads*.yaml             # Kubernetes NGINX workload examples
├── tpr-framework.sh            # Top-level framework script
├── stats-processor.py          # Result/statistics processing
├── tprm-v2/
│   ├── inject-controller.sh    # Controller injection helper
│   ├── scan-image*.sh          # Image-scanning helpers
│   ├── scan-cycle.sh           # Repeated scan workflow
│   └── results/                # Scan results
├── sbom-*.json                 # Saved Syft SBOMs
├── grype-*.txt                 # Saved table-format Grype reports
├── grype-nginx.json            # Saved JSON-format Grype report
└── tpr-results.log             # Prior run log
```

## Security notes

- Treat the included reports as point-in-time results. Vulnerability databases, image tags, and package contents change over time, so rerun scans before making security decisions.
- An SBOM records discovered components; it does not by itself establish that a vulnerability is exploitable.
- A vulnerability scan should feed into triage: confirm the image digest, affected package, reachable code path, compensating controls, and availability of a fix.
- Do not commit secrets, kubeconfig files, access tokens, or production scan data. The repository currently includes runtime artifacts such as PID and log files; consider adding ignore rules for future runs.

## Suggested improvements

1. Add pinned tool versions and a `requirements.txt` or equivalent environment specification.
2. Make script inputs configurable rather than relying on local paths or implicit defaults.
3. Document expected cluster names, namespaces, image tags, and output locations.
4. Add CI to regenerate SBOMs and scan reports on a schedule.
5. Store normalized scan summaries rather than duplicate timestamped output files where possible.
6. Remove transient PID/log files from source control and add them to `.gitignore`.
7. Add licenses and contribution guidance before broader reuse.

## License

No license file is currently included. Add an explicit license before distributing or accepting external contributions.
