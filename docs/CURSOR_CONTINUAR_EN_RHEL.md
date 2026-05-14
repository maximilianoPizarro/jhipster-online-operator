# Estado del upgrade del operador v1.1.2 (RHEL / Linux)

## Completado

- Helm chart principal `helm-charts/jhipster-online/` alineado con upstream **1.1.2**.
- Tres charts de workers: `jhipster8-worker/`, `pyhipster-worker/`, `mcp-worker/`.
- `watches.yaml` con los cuatro kinds.
- CRDs en `config/crd/bases/` (main + tres workers) y `config/crd/kustomization.yaml`.
- Samples en `config/samples/` con nombres unicos (`demo` para main, `demo-jhipster8-worker`, `demo-pyhipster-worker`, `demo-mcp-worker` para workers).
- RBAC actualizado (`config/rbac/role.yaml`): incluye `rbac.authorization.k8s.io` (roles/rolebindings) y `networking.k8s.io` (ingresses).
- `Makefile`: `VERSION=1.1.2`, `IMAGE_TAG_BASE` en Quay, `LOCALBIN` definido, `kube-rbac-proxy` actualizado a `quay.io/brancz/kube-rbac-proxy:v0.18.1`.
- `config/manager/manager.yaml`: imagen manager usa `controller:latest` (kustomize reemplaza).
- `make bundle` ejecutado con `operator-sdk v1.40.0`.
- CSV base y bundle actualizados a v1.1.2 con 4 CRDs owned, `alm-examples` completos, `replaces: v0.1.0`.
- Anotaciones OpenShift: `com.redhat.openshift.versions: "v4.12"` en bundle metadata y Dockerfile.
- GitHub Actions: `ci.yaml` (helm lint, yamllint, bundle validate) y `release.yaml` (build/push Quay).
- FBC: `catalog/jhipster-online-operator/` con `catalog.yaml` y `ci.yaml`.
- README actualizado a v1.1.2 con badge CI, 4 CRDs documentados, convencion de nombres, LICENSE link correcto.

## Probado en OpenShift

- Operator desplegado en cluster OpenShift 4.x con imagen interna.
- 4 CRs reconciliados: JhipsterOnline + 3 workers + MariaDB + Route.
- Workers requieren `metadata.name` distinto del CR principal (Helm release names deben ser unicos).
- El chart principal crea un RoleBinding con ClusterRole `edit`; el SA del operator necesita tener ese permiso (`openshift.grantEditRoleToServiceAccount: true` en values).

## Pendiente para produccion

- Publicar imagen operator `v1.1.2` a Quay (`podman push`).
- Publicar imagen bundle `v1.1.2` a Quay.
- Configurar secrets `QUAY_USERNAME`/`QUAY_PASSWORD` en GitHub Actions.
- Crear tag `v1.1.2` para disparar el workflow de release.
- PR a `community-operators-prod` con el FBC.
