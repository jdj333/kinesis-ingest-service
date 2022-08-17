
resource "helm_release" "metric-server" {
  count      = var.create_metrics ? 1 : 0
  repository = "https://charts.bitnami.com/bitnami"
  name = "metrics-server"
  chart      = "metrics-server"
  namespace  = var.namespace

  set {
    name  = "rbac.create"
    value = "true"
  }
  set {
    name  = "apiService.create"
    value = "true"
  }
  set {
    name = "replicas"
    value = "2"
  }  
  set {
    name="extraArgs[0]"
    value="--kubelet-use-node-status-port"
  }
  set {
    name="extraArgs[1]"
    value="--kubelet-preferred-address-types=InternalIP\\,ExternalIP\\,Hostname"
  }
  set {
    name="extraArgs[2]"
    value="--cert-dir=/tmp"
  }
  set {
    name="extraArgs[3]"
    value="--metric-resolution=15s"
  }

}
