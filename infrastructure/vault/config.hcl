storage "raft" {
  path    = "/vault/data"
  node_id = "rag_vault_1"
}

listener "tcp" {
  address     = "0.0.0.0:8200"
  tls_cert_file = "/etc/vault/tls/tls.crt"
  tls_key_file  = "/etc/vault/tls/tls.key"
}

seal "awskms" {
  region     = "us-west-2"
  kms_key_id = "alias/agentic-rag-vault"
}

auto_auth {
  method "kubernetes" {
    mount_path = "auth/kubernetes"
    config = {
      role = "agentic-rag"
    }
  }
}

template_config {
  static_secret_render_interval = "5m"
}