# Gestion Produits Helm Chart

Ce dépôt contient le TP de déploiement Kubernetes et Helm pour l'application **Gestion Produits**, incluant des outils de test de charge pour KEDA.

## 1. Description
Chart Helm permettant de déployer :
- Une application PHP (gestion produits)
- Une base de données MySQL
- Un Ingress TLS (Traefik + Cert-Manager)
- Un mécanisme d'autoscaling (KEDA)
- Un dashboard Grafana

## 2. Endpoints de test KEDA

### Test de charge CPU
```
GET /stress-test/cpu?iterations=1000000
```

Paramètres :
- `iterations` : Nombre d'itérations de calcul (défaut: 1,000,000)

Exemple de test avec curl :
```bash
# Test léger (100k itérations)
curl "https://gestion-produits-masset.germainleignel.com/stress-test/cpu?iterations=100000"

# Test intensif (10M itérations)
curl "https://gestion-produits-masset.germainleignel.com/stress-test/cpu?iterations=10000000"
```

### Test de charge mémoire
```
GET /stress-test/memory?mb=10&duration=5
```

Paramètres :
- `mb` : Mémoire à allouer en Mo (max: 4096, défaut: 10)
- `duration` : Durée en secondes pendant laquelle maintenir l'allocation (défaut: 5)

Exemple de test avec curl :
```bash
# Allouer 100MB pendant 10 secondes
curl "https://gestion-produits-masset.germainleignel.com/stress-test/memory?mb=100&duration=10"

# Allouer 1GB pendant 30 secondes (attention : très intensif)
curl "https://gestion-produits-masset.germainleignel.com/stress-test/memory?mb=1024&duration=30"
```

### Vérification du statut
```
GET /stress-test/status
```

Retourne des informations sur le serveur et la configuration PHP actuelle.

## 3. Prérequis
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

## 8. Tests de charge automatisés

### Scénario de test avec k6

Installer k6 :
```bash
# Sur Linux
sudo gpg -k && sudo gpg --no-default-keyring --keyring /usr/share/keyrings/k6-archive-keyring.gpg --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys C5AD17C747E3415A3642D57D77C6C491D6AC1D69
echo "deb [signed-by=/usr/share/keyrings/k6-archive-keyring.gpg] https://dl.k6.io/deb stable main" | sudo tee /etc/apt/sources.list.d/k6.list
sudo apt-get update
sudo apt-get install k6
```

Exemple de script de test (`stress-test.js`) :
```javascript
import http from 'k6/http';
import { sleep } from 'k6';

export const options = {
  vus: 10,
  duration: '30s',
  thresholds: {
    http_req_failed: ['rate<0.01'],
    http_req_duration: ['p(95)<500'],
  },
};

export default function () {
  // Test CPU
  const cpuResponse = http.get('https://gestion-produits-masset.germainleignel.com/stress-test/cpu?iterations=500000');
  console.log(`CPU Test - ${cpuResponse.body}`);
  
  // Test mémoire
  const memoryResponse = http.get('https://gestion-produits-masset.germainleignel.com/stress-test/memory?mb=50&duration=2');
  console.log(`Memory Test - ${memoryResponse.body}`);
  
  sleep(1);
}
```

Lancer le test :
```bash
k6 run stress-test.js
```

## 9. Mise à jour et nettoyage
```bash
# Mettre à jour
helm upgrade gestion-produits ./charts -n gestion-produits -f values.yaml

# Supprimer
helm uninstall gestion-produits -n gestion-produits
kubectl delete namespace gestion-produits