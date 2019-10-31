resource "kubernetes_config_map" "vault-conf" {
  metadata {
    name = "vault-conf"
    namespace = "${var.namespace}"
  }

  data = {
    "config.hcl" = <<EOH

      PUT YOUR STORAGE CONFIGS HERE
        
      listener "tcp" {
        address          = "0.0.0.0:8200"
        tls_disable      = "true"
      }

      ui = true
      log_level = "Info"

    EOH
  }
}
resource "kubernetes_cluster_role_binding" "vault-cluster-role-binding" {
  metadata {
    name = "vault-server-binding"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "vault-role"
  }

  subject {
    kind      = "ServiceAccount"
    name      = "vault-service-account"
    namespace = "${var.namespace}"
  }
}

resource "kubernetes_service_account" "vault-service-account" {
   metadata {
    name = "vault-service-account"
  }
}

resource "kubernetes_service" "vault-service" {
  metadata {
    name = "vault-service"
    namespace = "${var.namespace}"
  }

  spec {
    selector = {
      app = "${var.appLabel}"
    }

    port {
      name = "http"
      protocol = "TCP"
      port = "${var.containerHttpPort}"
    }
    port {
      name = "cluster"
      protocol = "TCP"
      port = "${var.containerClusterPort}"
    }

    type = "${var.serviceType}"
  }
}

resource "kubernetes_stateful_set" "vault-statefulset" {
  metadata {
    name = "vault"
    namespace = "${var.namespace}"
    labels = {
      app = "${var.appLabel}"
    }
  }

  spec {
    service_name = "vault-service"
    pod_management_policy = "Parallel"
    replicas = "${var.numberOfReplicas}"
    update_strategy {
      type = "OnDelete"
    }

    selector {
      match_labels = {
        app = "${var.appLabel}"
      }
    }

    template {
      metadata {
          labels = {
              app = "${var.appLabel}"
          }
      }

      spec {
        service_account_name = "vault-service-account"
        termination_grace_period_seconds = 10

        security_context {
          run_as_non_root = true
          run_as_group = 1000
          run_as_user = 100
          fs_group = 1000
        }

        volume {
          name = "config"
          config_map {
            name = "vault-conf"
          }
        }

        container {
          name = "vault"
          security_context {
            capabilities {
              add = ["IPC_LOCK"]
            }
          }

          image = "${var.image}"
          image_pull_policy = "Always"
          args = ["server"]


          port {
            name = "http"
            protocol = "TCP"
            container_port = "${var.containerHttpPort}"
          }
          port {
            name = "cluster"
            protocol = "TCP"
            container_port = "${var.containerClusterPort}"
          }

          volume_mount {
            name       = "config"
            mount_path = "/vault/config/config.hcl"
            sub_path = "config.hcl"
          }

          readiness_probe {
            http_get {
              path = "/v1/sys/health?standbyok=true"
              port = 8200
              scheme = "HTTP"
            }

            initial_delay_seconds = 5
            period_seconds = 5
          }
        }
      }
    }
  }
}
