terraform {
  required_providers {
    konnect = {
      source  = "kong/konnect"
      version = "3.4.1"
    }

    vault = {
      source  = "hashicorp/vault"
      version = "3.0.0"
    }

    local = {
      source  = "hashicorp/local"
      version = "2.5.1"
    }
  }
}

provider "konnect" {
  personal_access_token = var.KPAT
  server_url            = "https://eu.api.konghq.com"
}

# OpenBao is API-compatible with Vault, so the hashicorp/vault provider is used against it.
provider "vault" {
  address = "https://openbao.shared.pve-home.schenkeveld.io"
  token   = var.HCV_ROOT_TOKEN
}

resource "konnect_gateway_control_plane" "ko_gateway_control_plane" {
  name          = "ko-dp-shared-3"
  cluster_type  = "CLUSTER_TYPE_CONTROL_PLANE"
  cloud_gateway = false
  auth_type     = "pki_client_certs"
  proxy_urls    = []
}

resource "konnect_gateway_data_plane_client_certificate" "ko_gatewaydataplaneclientcertificate" {
  cert             = file("../../../ansible/roles/tls/files/root-ca-cert.pem")
  control_plane_id = konnect_gateway_control_plane.ko_gateway_control_plane.id
}

output "control_plane_id" {
  value = konnect_gateway_control_plane.ko_gateway_control_plane.id
}

output "control_plane_endpoint" {
  value = konnect_gateway_control_plane.ko_gateway_control_plane.config.control_plane_endpoint
}

output "telemetry_endpoint" {
  value = konnect_gateway_control_plane.ko_gateway_control_plane.config.telemetry_endpoint
}

# Single source for the details, written to OpenBao and/or a local file below.
# control_plane_id is the one field the plain Helm-chart data-plane pattern
# (konnect-eu-development/-production) doesn't need but the Kong Operator does -
# its KonnectGatewayControlPlane CRD references an externally-created CP by raw
# ID via spec.mirror.konnect.id, rather than the operator creating its own.
locals {
  connection_details = {
    control_plane_id       = konnect_gateway_control_plane.ko_gateway_control_plane.id
    control_plane          = replace(konnect_gateway_control_plane.ko_gateway_control_plane.config.control_plane_endpoint, "https://", "")
    telemetry              = replace(konnect_gateway_control_plane.ko_gateway_control_plane.config.telemetry_endpoint, "https://", "")
    control_plane_endpoint = format("%s:443", replace(konnect_gateway_control_plane.ko_gateway_control_plane.config.control_plane_endpoint, "https://", ""))
    telemetry_endpoint     = format("%s:443", replace(konnect_gateway_control_plane.ko_gateway_control_plane.config.telemetry_endpoint, "https://", ""))
  }
}

# Write to OpenBao (for ESO + the Kong Operator config phase). Toggle with var.write_to_openbao.
resource "vault_generic_secret" "konnect_endpoints" {
  count     = var.write_to_openbao ? 1 : 0
  path      = "kv/konnect/konnect-eu-ko-dp-shared-3/connection-details"
  data_json = jsonencode(local.connection_details)
}

# Write the same details to a local JSON file. Toggle with var.write_to_file.
resource "local_file" "connection_details" {
  count    = var.write_to_file ? 1 : 0
  filename = "${path.module}/${var.local_output_file}"
  content  = jsonencode(local.connection_details)
}
