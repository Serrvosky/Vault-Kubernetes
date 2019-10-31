variable namespace {
  description = "Namespace to deploy Vault"
  default     = "default"
}
variable appLabel {
  description = "App label to use as a selector"
  default     = "vault"
}
variable containerHttpPort {
  description = "HTTP Port"
  default     = "8200"
}
variable containerClusterPort {
  description = "Cluster Port"
  default     = "8201"
}
variable serviceType {
  description = "Service type to expose Vault"
  default     = "ClusterIP"
}
variable numberOfReplicas {
  description = "Number of Replicas"
  default     = "1"
}
variable image {
  description = "Container image and tag"
  default     = "vault:1.2.3"
}
variable dataStorageSize {
  description = "Size of disk for data in Vault"
  default     = "1Gi"
}
variable vault_request_cpu {
  description = "Kubernetes CPU Request for Vault pods"
  default     = "500m"
}
variable vault_request_memory {
  description = "Kubernetes Memory Request for Vault pods"
  default     = "256Mi"
}