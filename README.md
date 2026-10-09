# konnect-eu-ko-dp-shared-3

Terraform for the **ko-dp-shared-3** Konnect control plane — one of two CPs (see also
`konnect-eu-ko-dp-shared-2`), each backing its own Kong Operator-managed `DataPlane` on `shared-pve-1`.

## What it provisions
- Gateway control plane `ko-dp-shared-3` + data-plane client certificate
- **connection-details** — control-plane ID + endpoints, written to **OpenBao** and/or a **local file** (see toggles)

No developer portal and no team/role bindings here — unlike `konnect-eu-development`/`konnect-eu-production`,
this control plane isn't meant to be managed by hand; it exists to be referenced by the Kong Operator.

## Prerequisites
- `terraform`, network access to `eu.api.konghq.com` (and OpenBao if `write_to_openbao=true`)
- Secrets via env: `source ./export-secrets.sh` → sets `TF_VAR_KPAT` (Konnect PAT) and
  `TF_VAR_HCV_ROOT_TOKEN` (OpenBao token). **Never commit real values.**
- Root CA cert present at `../../../ansible/roles/tls/files/root-ca-cert.pem`

## Usage
```bash
source ./export-secrets.sh
terraform init
terraform plan
terraform apply
```

## Toggles (variables)
| Variable | Default | Effect |
|---|---|---|
| `write_to_openbao` | `true` | write connection-details to OpenBao `kv/konnect/konnect-eu-ko-dp-shared-3/connection-details` |
| `write_to_file` | `true` | write the same JSON to `connection-details.json` (git-ignored) |
| `local_output_file` | `connection-details.json` | local filename |

## Outputs & consumers
- `terraform output`: `control_plane_id`, `control_plane_endpoint`, `telemetry_endpoint`
- **Kong Operator** (gitops `kong-operator`, not yet configured) will reference `control_plane_id` via a
  `KonnectGatewayControlPlane` in `mirror` mode, and the endpoints via a `KonnectExtension` + `DataPlane`,
  reading all of it from the OpenBao `connection-details` secret through External Secrets Operator.
