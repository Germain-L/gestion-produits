# Gestion Produits Helm Chart

This Helm chart deploys the Gestion Produits application on a Kubernetes cluster.

## Prerequisites

- Kubernetes 1.16+
- Helm 3.0+
- PV provisioner support in the underlying infrastructure (for persistent volumes)
- Ingress controller installed (e.g., Traefik)
- cert-manager installed (for TLS certificates)

## Installing the Chart

To install the chart with the release name `my-release`:

```bash
helm install my-release ./charts
```

The command deploys the application on the Kubernetes cluster with the default configuration.

## Uninstalling the Chart

To uninstall/delete the `my-release` deployment:

```bash
helm uninstall my-release
```

## Configuration

The following table lists the configurable parameters of the chart and their default values.

| Parameter                              | Description                                        | Default                                       |
|----------------------------------------|----------------------------------------------------|-----------------------------------------------|
| `namespace`                            | Namespace to deploy resources                      | `gestion-produits`                            |
| `app.image.repository`                 | Application image repository                       | `registry.germainleignel.com/library/gestion-produits` |
| `app.image.tag`                        | Application image tag                              | `latest`                                      |
| `app.image.pullPolicy`                 | Application image pull policy                      | `Always`                                      |
| `app.resources.limits.memory`          | Application memory limit                           | `128Mi`                                       |
| `app.resources.limits.cpu`             | Application CPU limit                              | `500m`                                        |
| `app.resources.requests.memory`        | Application memory request                         | `64Mi`                                        |
| `app.resources.requests.cpu`           | Application CPU request                            | `250m`                                        |
| `appMigrations.image.repository`       | Migrations image repository                        | `registry.germainleignel.com/library/gestion-produits-migrations` |
| `appMigrations.image.tag`              | Migrations image tag                               | `latest`                                      |
| `appUploads.image.repository`          | Uploads image repository                           | `registry.germainleignel.com/library/gestion-produits-uploads` |
| `appUploads.image.tag`                 | Uploads image tag                                  | `latest`                                      |
| `db.image.repository`                  | Database image repository                          | `mysql`                                       |
| `db.image.tag`                         | Database image tag                                 | `8.0`                                         |
| `db.resources.limits.memory`           | Database memory limit                              | `512Mi`                                       |
| `db.resources.limits.cpu`              | Database CPU limit                                 | `1000m`                                       |
| `db.resources.requests.memory`         | Database memory request                            | `256Mi`                                       |
| `db.resources.requests.cpu`            | Database CPU request                               | `500m`                                        |
| `db.rootPassword`                      | MySQL root password                                | `root`                                        |
| `db.database`                          | MySQL database name                                | `gestion_produits`                            |
| `db.rootHost`                          | MySQL root host                                    | `%`                                           |
| `persistence.storageClass`             | StorageClass for PVCs                              | `longhorn`                                    |
| `persistence.db.size`                  | Size of the database PVC                           | `5Gi`                                         |
| `persistence.uploads.size`             | Size of the uploads PVC                            | `2Gi`                                         |
| `ingress.enabled`                      | Enable ingress                                     | `true`                                        |
| `ingress.className`                    | Ingress class name                                 | `traefik`                                     |
| `ingress.annotations`                  | Ingress annotations                                | See values.yaml                               |
| `ingress.hosts`                        | Ingress hosts                                      | See values.yaml                               |
| `ingress.tls`                          | Ingress TLS configuration                          | See values.yaml                               |
| `certificate.enabled`                  | Enable certificate                                 | `true`                                        |
| `certificate.issuerRef.name`           | Certificate issuer name                            | `letsencrypt-prod`                            |
| `certificate.issuerRef.kind`           | Certificate issuer kind                            | `ClusterIssuer`                               |
| `certificate.secretName`               | TLS secret name                                    | `gestion-produits-tls`                        |
| `certificate.dnsNames`                 | Certificate DNS names                              | See values.yaml                               |

## Customizing the Installation

You can specify each parameter using the `--set key=value[,key=value]` argument to `helm install`. For example:

```bash
helm install my-release \
  --set db.rootPassword=mysecretpassword \
  --set persistence.storageClass=my-storage-class \
  ./charts
```

Alternatively, a YAML file that specifies the values for the parameters can be provided while installing the chart. For example:

```bash
helm install my-release -f my-values.yaml ./charts
```

## Persistence

The chart persists data using Kubernetes Persistent Volumes. The following Persistent Volume Claims are created:

- `{release-name}-db-pvc`: Stores the MySQL database data
- `{release-name}-uploads-pvc`: Stores uploaded files

Make sure your Kubernetes cluster has a default StorageClass defined or specify a StorageClass in the `values.yaml` file.

## Upgrading the Chart

To upgrade the chart with a new version or configuration:

```bash
helm upgrade my-release ./charts
```

## Uninstalling the Chart

To uninstall/delete the `my-release` deployment:

```bash
helm uninstall my-release
```

This command removes all the Kubernetes components associated with the chart and deletes the release.

**Note**: The Persistent Volume Claims (PVCs) are not deleted by default. To delete them, run:

```bash
kubectl delete pvc -l app.kubernetes.io/instance=my-release
```

## Troubleshooting

If the application is not accessible, check the following:

1. Verify that all pods are running:

   ```bash
   kubectl get pods -n gestion-produits
   ```

2. Check the logs of a specific pod:

   ```bash
   kubectl logs <pod-name> -n gestion-produits
   ```

3. Check the status of the ingress:

   ```bash
   kubectl get ingress -n gestion-produits
   ```

4. If using cert-manager, check the status of the certificate:

   ```bash
   kubectl get certificate -n gestion-produits
   kubectl describe certificate <certificate-name> -n gestion-produits
   ```

## License

This chart is licensed under the MIT License.
