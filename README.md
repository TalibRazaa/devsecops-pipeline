# DevSecOps CI/CD Pipeline

A Flask app deployed through a security-gated CI/CD pipeline: every commit is
scanned for secrets and known vulnerabilities before it's allowed to build or
deploy.

## Architecture

```
commit → Gitleaks (secrets) → Docker build → Trivy (CVE scan) → deploy gate → AWS EC2
                                                  |
                                          Prometheus + Grafana (monitoring)
```

## Stack

- **App**: Flask + Gunicorn, runs as non-root in container
- **CI/CD**: GitHub Actions
- **Security scanning**: Gitleaks (secret detection), Trivy (container CVE scanning)
- **Infra**: Terraform (AWS EC2, least-privilege security group)
- **Monitoring**: Prometheus + Grafana

## Run locally

```bash
docker compose up --build
curl http://localhost:5000/health
```

## Run the security scans locally (before pushing)

```bash
# Secret scan
docker run -v $(pwd):/repo zricethezav/gitleaks:latest detect --source=/repo --verbose

# Vulnerability scan
docker build -t devsecops-app .
docker run --rm -v /var/run/docker.sock:/var/run/docker.sock aquasec/trivy image devsecops-app
```

## Deploy infrastructure

```bash
cd terraform
terraform init
terraform apply -var="my_ip_cidr=YOUR.IP.HERE/32"
```

## Incident walkthrough (documented failure → fix)

> Fill this in once you've run the pipeline: e.g. "Committed a fake AWS key to
> test Gitleaks — pipeline failed at the secret-scan stage before it ever
> reached build, preventing the leak from reaching the image." This section is
> what turns the project into an interview story, not just a repo.

## Why this project

Built to demonstrate a security-first approach to CI/CD: scanning shifts left
(before build, not after deploy), infrastructure is defined as code, and
failures are caught and documented rather than hidden.
