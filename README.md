# JHipster Online Operator

[![CI](https://github.com/maximilianoPizarro/jhipster-online-operator/actions/workflows/ci.yaml/badge.svg)](https://github.com/maximilianoPizarro/jhipster-online-operator/actions/workflows/ci.yaml)
[![Docker Pulls](https://img.shields.io/docker/pulls/jhipster/jhipster-online.svg)](https://hub.docker.com/r/jhipster/jhipster-online/)
[![Open in Developer Sandbox](https://img.shields.io/static/v1?label=Open%20in&message=Developer%20Sandbox&logo=eclipseche&color=FDB940&labelColor=525C86)](https://workspaces.openshift.com/#https://github.com/redhat-developer-demos/jhipster-online)
[![ArtifactHub](https://img.shields.io/endpoint?url=https://artifacthub.io/badge/repository/jhipster-online)](https://artifacthub.io/packages/helm/jhipster-online/jhipster-online)

This repository hosts the **JHipster Online Operator v1.1.2**, designed to deploy JHipster Online on Red Hat OpenShift and Kubernetes environments.

JHipster Online provides a web interface for generating JHipster projects using JDL (JHipster Domain Language) models and pushing the code directly into a GitHub repository.

## Custom Resources

The operator manages **four** Custom Resource kinds. All worker CRs must share the same `metadata.name` as the main `JhipsterOnline` CR so service discovery is wired automatically.

| Kind | Purpose |
|------|---------|
| **JhipsterOnline** | Main application (Quarkus/Spring Boot), MariaDB, Route |
| **Jhipster8Worker** | HTTP worker for generator-jhipster 8.x stacks |
| **PyhipsterWorker** | HTTP worker for PyHipster generation |
| **McpWorker** | HTTP worker for MCP-based code generation |

### Included versions

* **JHipster 8.8.0** -- Spring Boot 3.4.1 projects
* **generator-jhipster-quarkus 3.4.0** -- Quarkus 3.11.1 projects
* **JDL Studio** -- web-based JDL editor

## Getting Started

### Prerequisites

* OpenShift >= 4.12 or Kubernetes >= 1.25 cluster with **cluster-admin**
* `oc` or `kubectl` configured to connect to the cluster
* `podman` (or `docker`)
* `operator-sdk` v1.40.0 (optional, for development)

### Installation

Deploy the operator using the OLM bundle:

```bash
operator-sdk run bundle quay.io/maximilianopizarro/jhipster-online-operator-bundle:v1.1.2
```

Or with podman:

```bash
podman run --rm -it \
  -v "$HOME/.kube/config:/root/.kube/config:ro" \
  -e KUBECONFIG=/root/.kube/config \
  quay.io/operator-framework/operator-sdk:v1.40.0 \
  run bundle quay.io/maximilianopizarro/jhipster-online-operator-bundle:v1.1.2
```

### Usage

Create the main application and its workers. Note the shared `metadata.name: demo`:

```yaml
apiVersion: maximilianopizarro.github.io/v1alpha1
kind: JhipsterOnline
metadata:
  name: demo
spec:
  replicaCount: 1
  image:
    repository: quay.io/maximilianopizarro/jhipster-online
    tag: "2.41.1-quarkus"
    pullPolicy: Always
  env:
    APPLICATION_GITHUB_CLIENT-ID: "YOUR_GITHUB_CLIENT_ID"
    APPLICATION_GITHUB_CLIENT-SECRET: "YOUR_GITHUB_CLIENT_SECRET"
    APPLICATION_GITHUB_HOST: https://github.com
    APPLICATION_JHIPSTER-CMD_CMD: jhipster-quarkus
    SPRING_DATASOURCE_URL: jdbc:mariadb://mariadb:3306/jhipsteronline
    SPRING_DATASOURCE_USERNAME: jhipster
    SPRING_DATASOURCE_PASSWORD: jhipster
  service:
    type: ClusterIP
    port: 8080
  route:
    enabled: true
  mariadb:
    enabled: true
  jhipster8Worker:
    enabled: true
    port: 8081
    timeoutSeconds: 600
  pyhipsterWorker:
    enabled: true
    port: 8082
    timeoutSeconds: 600
  mcpWorker:
    enabled: true
    port: 8083
    timeoutSeconds: 120
---
apiVersion: maximilianopizarro.github.io/v1alpha1
kind: Jhipster8Worker
metadata:
  name: demo
spec:
  enabled: true
  instanceBaseName: demo
  replicas: 1
  port: 8081
  timeoutSeconds: 600
  image:
    repository: quay.io/maximilianopizarro/jhipster-online-jhipster8-worker
    tag: "2.41.1-jhipster8-worker"
    pullPolicy: IfNotPresent
  service:
    type: ClusterIP
---
apiVersion: maximilianopizarro.github.io/v1alpha1
kind: PyhipsterWorker
metadata:
  name: demo
spec:
  enabled: true
  instanceBaseName: demo
  replicas: 1
  port: 8082
  timeoutSeconds: 600
  image:
    repository: quay.io/maximilianopizarro/jhipster-online-pyhipster-worker
    tag: "2.41.1-pyhipster-worker"
    pullPolicy: IfNotPresent
  service:
    type: ClusterIP
---
apiVersion: maximilianopizarro.github.io/v1alpha1
kind: McpWorker
metadata:
  name: demo
spec:
  enabled: true
  instanceBaseName: demo
  replicas: 1
  port: 8083
  timeoutSeconds: 120
  image:
    repository: quay.io/maximilianopizarro/jhipster-online-mcp-worker
    tag: "2.41.1-mcp-worker"
    pullPolicy: IfNotPresent
  service:
    type: ClusterIP
```

Apply them:

```bash
kubectl apply -f your-jhipsteronline-instance.yaml
```

### Configuration

The `JhipsterOnline` custom resource supports various configuration options:

| Parameter | Description | Default |
|:----------|:------------|:--------|
| `replicaCount` | Number of replicas | `1` |
| `image.repository` | Container image repository | `quay.io/maximilianopizarro/jhipster-online` |
| `image.tag` | Container image tag | `2.41.1-quarkus` |
| `image.pullPolicy` | Image pull policy | `IfNotPresent` |
| `imagePullSecrets` | Secrets for private registries | `[]` |
| `service.type` | Kubernetes Service type | `ClusterIP` |
| `service.port` | Service port | `8080` |
| `route.enabled` | Enable OpenShift Route | `true` |
| `ingress.enabled` | Enable Ingress | `false` |
| `mariadb.enabled` | Deploy MariaDB alongside | `true` |
| `jhipster8Worker.enabled` | Enable JHipster 8 worker flags on main pod | `true` |
| `pyhipsterWorker.enabled` | Enable PyHipster worker flags on main pod | `true` |
| `mcpWorker.enabled` | Enable MCP worker flags on main pod | `true` |
| `env` | Environment variables (GitHub OAuth, datasource, etc.) | `{}` |
| `resources` | CPU/memory requests and limits | `{}` |
| `nodeSelector` | Node labels for pod assignment | `{}` |
| `tolerations` | Tolerations for node taints | `[]` |
| `affinity` | Affinity rules | `{}` |
| `livenessProbe` | Liveness probe config | `httpGet /jdl-studio/ :8080` |
| `readinessProbe` | Readiness probe config | `httpGet /jdl-studio/ :8080` |

## Contributing

Contributions are welcome! If you find a bug or have a feature request, please open an issue or submit a pull request.

## License

This project is licensed under the Apache 2.0 License - see the [LICENSE](LICENSE) file for details.
