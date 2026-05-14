# Continuar el upgrade del operador (RHEL / Linux)

Este commit deja el trabajo **hasta el chart 1.1.2, CRDs de workers, watches, RBAC y samples**. Se **revirtieron** los cambios del `Makefile` pensados para Windows (MINGW, zip de kustomize, `.exe` de operator-sdk): en RHEL/Linux el `Makefile` vuelve al flujo estándar con `tar.gz` y binarios `linux_amd64`.

## Ya hecho en el repo

- Helm chart principal `helm-charts/jhipster-online/` alineado con upstream **1.1.2** (sin templates de Deployments/Services de workers en el chart principal; los workers van por CR aparte).
- Tres charts: `helm-charts/jhipster8-worker/`, `helm-charts/pyhipster-worker/`, `helm-charts/mcp-worker/`.
- `watches.yaml` con los cuatro kinds.
- CRDs en `config/crd/bases/` (main + tres workers) y `config/crd/kustomization.yaml`.
- Samples en `config/samples/` (convención: **mismo `metadata.name`** en `JhipsterOnline` y en los tres workers, p. ej. `demo`, y `instanceBaseName` en workers = ese nombre).
- RBAC actualizado (`config/rbac/role.yaml`, editor/viewer).
- `Makefile`: `VERSION ?= 1.1.2`, `IMAGE_TAG_BASE ?= quay.io/maximilianopizarro/jhipster-online-operator` (sin lógica Windows).
- `config/manager/kustomization.yaml`: `newTag: v1.1.2`.
- `PROJECT`: recursos API de los workers.

## Pendiente al abrir Cursor en RHEL

1. **`make bundle`** (requiere `operator-sdk` y `kustomize` descargables en Linux; en Windows no hay binario oficial de operator-sdk para la misma versión).
   ```bash
   make bundle IMG=quay.io/maximilianopizarro/jhipster-online-operator:v1.1.2 VERSION=1.1.2
   ```
2. **CSV / bundle**: actualizar `bundle/manifests/jhipster-online-operator.clusterserviceversion.yaml` (versión **1.1.2**, `replaces` **v0.1.0**, cuatro CRDs owned con `description`, `alm-examples` con los cuatro CRs, `minKubeVersion: 1.25.0`, anotación `support`, imágenes del manager a **v1.1.2**, reglas RBAC del CSV para `jhipster8workers`, `pyhipsterworkers`, `mcpworkers`).
3. **OpenShift**: `com.redhat.openshift.versions: "v4.12"` en `bundle/metadata/annotations.yaml` y `LABEL` equivalente en `bundle.Dockerfile`.
4. **GitHub Actions**: CI (helm lint, yamllint, `operator-sdk bundle validate`) y release (build/push a Quay con `QUAY_USERNAME` / `QUAY_PASSWORD`).
5. **FBC**: plantillas / `ci.yaml` para `community-operators-prod` según el plan.
6. **README**: v1.1.2, badge de CI, enlace LICENSE correcto, quitar fences sobrantes; documentar la convención del nombre compartido entre CRs.

## Archivos empaquetados (.tgz) bajo `helm-charts/jhipster-online/charts/`

Si no quieres versionarlos en git (peso / duplicado del repo Helm), añádelos a `.gitignore` y deja solo el chart “source”.

## Verificación rápida en RHEL

```bash
helm lint helm-charts/jhipster-online helm-charts/jhipster8-worker helm-charts/pyhipster-worker helm-charts/mcp-worker
```
