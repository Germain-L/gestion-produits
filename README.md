# Gestion Produits Helm Chart

Ce dépôt contient le TP de déploiement Kubernetes et Helm pour l'application **Gestion Produits**.

## 1. Description
Chart Helm permettant de déployer :
- Une application PHP (gestion produits)
- Une base de données MySQL
- Un Ingress TLS (Traefik + Cert-Manager)
- Un mécanisme d'autoscaling (KEDA)
- Un dashboard Grafana

## 2. Prérequis
- Kubernetes ≥ 1.21
- Helm ≥ 3.0
- StorageClass (ex. longhorn)
- Cert-Manager (ClusterIssuer `letsencrypt-prod`)
- Traefik Ingress Controller
- KEDA
- Prometheus & Grafana (pour autoscaling et dashboard)

## 3. Installation
```bash
# Créer le namespace
kubectl create namespace gestion-produits

# Installer le chart
helm install gestion-produits ./charts \
  --namespace gestion-produits \
  -f values.yaml
```

## 4. Structure du chart
```
charts/
├── Chart.yaml              # métadonnées du chart
├── values.yaml             # valeurs par défaut configurables
└── templates/              # manifests Kubernetes
    ├── app-deployment.yaml
    ├── app-service.yaml
    ├── app-ingress.yaml
    ├── app-scaledobject.yaml
    ├── app-pvc.yaml
    ├── db-deployment.yaml
    ├── db-service.yaml
    ├── db-pvc.yaml
    ├── mysql-configmap.yaml
    ├── grafana-dashboard-configmap.yaml
    └── _helpers.tpl
```

## 5. Principales configurations (values.yaml)
- **namespace** : namespace Kubernetes
- **app.image** : repository, tag, pullPolicy
- **app.resources** : limite et requête CPU/mémoire
- **app.healthcheck** : liveness, readiness, startup probes
- **db.image** : MySQL image et version
- **db.configuration** : options MySQL (`my.cnf`)
- **persistence** : volumes pour MySQL et uploads
- **ingress** : hôtes, annotations TLS, classe
- **certificate** : issuerRef et secret TLS
- **keda.scaling** : min/max replicas, CPU et Prometheus scaler
- **grafana.dashboard** : ConfigMap du dashboard JSON

## 6. Templates clés
- **app-deployment.yaml** : Deployment PHP + init containers si besoin
- **app-service.yaml** : Service ClusterIP
- **app-ingress.yaml** : Ressource Ingress Traefik avec TLS
- **app-scaledobject.yaml** : ScaledObject KEDA (CPU + custom Prometheus)
- **db-deployment.yaml** : Deployment MySQL
- **db-pvc.yaml** : PersistentVolumeClaim pour MySQL
- **mysql-configmap.yaml** : ConfigMap pour options MySQL
- **grafana-dashboard-configmap.yaml** : ConfigMap contenant le dashboard JSON

## 7. Accès
- Application : https://gestion-produits-masset.germainleignel.com
- Base de données : Credentials dans `values.yaml` (rootPassword)

## 8. Mise à jour et nettoyage
```bash
# Mettre à jour
helm upgrade gestion-produits ./charts -n gestion-produits -f values.yaml

# Supprimer
helm uninstall gestion-produits -n gestion-produits
kubectl delete namespace gestion-produits