# Security

This repository is a local sample for a portfolio. It is not a hosted service. The application code is the official Spring Petclinic sample. The container and the checks were added around it.

Report a problem in this repository to elyesaekici9@gmail.com.

## What the running demo does

The Compose service publishes port 8080 on `127.0.0.1` only. The process runs as uid `10001` (`petclinic`) with a login shell disabled, and Compose sets `no-new-privileges`.

`src/main/resources/application.properties` sets `management.endpoints.web.exposure.include=*`. The upstream file says that is for development and testing. This demo exposes every actuator endpoint.

`docker-compose.yml` is not the application. It starts optional MySQL and PostgreSQL with the demo password `petclinic` and an empty MySQL root password. Do not expose that file beyond a local machine.

## Checks recorded locally

Commands were run on this machine on 1 November 2026.

Tests, in `maven:3.9.9-eclipse-temurin-17`, with `PostgresIntegrationTests` excluded:

`Tests run: 79, Failures: 0, Errors: 0, Skipped: 2`

The two skips are `MySqlIntegrationTests`. Testcontainers did not see a Docker socket inside that container. `PostgresIntegrationTests` did not run because of the filter.

Semgrep `p/java` and `p/security-audit` on the git-tracked tree, excluding `target/` and `.git`: 97 rules, 103 files, 0 findings.

Trivy image scan of `petclinic:local`, severity high and critical:

- Ubuntu 22.04 packages in the runtime image: 0
- `app.jar`: 12 (6 critical, 6 high)

All 12 are in upstream libraries brought in by Spring Boot 4.1.0. They were not patched in this repository. The application still builds the Boot version it was released with.

| Library | Installed | Finding | Severity |
|---|---|---|---|
| `tomcat-embed-core` | 11.0.22 | CVE-2026-65182, CVE-2026-65637, CVE-2026-65905, CVE-2026-68525 | Critical |
| `spring-webmvc` | 7.0.8 | CVE-2026-47884, CVE-2026-47890 | Critical |
| `postgresql` | 42.7.11 | CVE-2026-54291 | High |
| `jackson-core` | 3.1.4 | CVE-2026-89407, CVE-2026-89425 | High |
| `jackson-databind` | bundled in `app.jar` | CVE-2026-68497, CVE-2026-91776, CVE-2026-91777 | High |

A filesystem scan that asked Maven Central for dependency metadata received HTTP 429 and a 30-minute block. An offline retry of `pom.xml` could not resolve child versions, so its count of 0 does not describe the libraries inside the jar. The image scan above is the dependency result. GitHub Actions runs the filesystem scan with `--offline-scan` for the same reason.

Semgrep and Trivy are configured to print results. A finding in an upstream dependency does not by itself fail the workflow. A failing test does.
