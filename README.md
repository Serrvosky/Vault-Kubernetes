<p align="center"><img src="https://pic4.zhimg.com/v2-2fb11209ef72bb2dfa625c9a690c526e_1200x500.jpg" alt="Vault Logo"></p>

## Vault in Kubernetes.

Vault is a secrets manager, developed by Hashicorp. This repository, it's for people like me, who wants to deploy a Vault cluster in Kubernetes, but don't want to follow use Hashicorp's approach (using Helm).
For this implementation, I suppose that you already have an operational Kubernetes cluster, kubectl command line knowlegde and practise with Terraform. This implementation tries to "transpose" Helm chart template from Hashicorp repository, to Terraform.

If you don't know how to use Terraform, a very good Infrastruture as Code tool, please check Hashicorp's page with all the documentation that you need to know. - [Start using Terraform for your Kubernetes deploys](https://www.terraform.io/)


### main.tf file
In this file you can find the following Kubernetes resources:
- ConfigMap (vault-conf) - used to create the configuration file to Vault
- Cluster Role Binding (vault-server-binding)
- Service Account (vault-service-account)
- Service (vault-service) - Used to expose Vault deployment
- Statefulset (vault)


In this file, you must change the content of config.hcl file (in the config map), specially storage config.

For example, if you want to storage your secrets in filesystem add:

```
storage "file" {
  path = "/mnt/vault/data"
}
```

and uncomment this lines in the statefulset template:

```
volume_mount {
  name       = "vault-data"
  mount_path = "mnt/vault/data"
}
...

volume_claim_template {
  metadata {
    name = "vault-data"
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "${var.dataStorageSize}"
      }
    }
  }
}
```

I choose using a Statefulset approach, to have persistent volumes and don't loose any critical data between redeploys, when using filesystem storage approach.


### vars.tf file

In this file you can find some variables to improve your deployment. Each of them have a comment.

### Contributing

Please, be free to contributing and improve this repository.
