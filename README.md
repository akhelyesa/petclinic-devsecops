# Petclinic DevSecOps

A local DevSecOps portfolio project around the official [Spring Petclinic](https://github.com/spring-projects/spring-petclinic) sample. The application is unchanged Spring Boot 4.1 code on Java 17. This repository adds a non-root container, a localhost-only Compose file, and the same three checks locally and in GitHub Actions: tests, Semgrep, and Trivy.

No cloud account, Jenkins, or paid scanner is required. The `k8s/` manifests are upstream files and are not part of this setup.

The sample is licensed under the [Apache License 2.0](LICENSE.txt).

## Run the application

From this directory:

```powershell
docker compose -p petclinic -f compose.yaml up --build
```

Open http://127.0.0.1:8080/. The published port is bound to loopback only. The process inside the container is the unprivileged user `petclinic` (uid 10001), and Compose sets `no-new-privileges`. The application uses its default in-memory H2 database.

Stop it with Ctrl+C, then:

```powershell
docker compose -p petclinic -f compose.yaml down
```

`docker-compose.yml` is the upstream file for optional MySQL and PostgreSQL. It is not started by the command above. Use it only when you want those databases:

```powershell
docker compose -f docker-compose.yml up
```

## Tests

`PostgresIntegrationTests` starts PostgreSQL through Docker Compose, so it stays out of the normal test run. The MySQL tests use Testcontainers and skip when the Maven container has no Docker socket.

```powershell
docker run --rm -v "${PWD}:/app" -w /app maven:3.9.9-eclipse-temurin-17 mvn -B test "-Dtest=!PostgresIntegrationTests"
```

The image build uses the same Maven image and skips tests there. Tests run as this separate check.

## Checks

GitHub Actions workflow: [DevSecOps](.github/workflows/devsecops.yml).

| Job | What it does |
|---|---|
| Test | `mvn -B test "-Dtest=!PostgresIntegrationTests"` on Temurin 17 |
| Semgrep | Java and security-audit rules on the source tree |
| Trivy | High and critical findings in the repository and in the built image |

The test job fails the workflow when a test fails. Semgrep and Trivy print their results. A match in an upstream dependency does not by itself fail the workflow. What those scans reported, and the demo settings that are not production-safe, is in [SECURITY.md](SECURITY.md).
