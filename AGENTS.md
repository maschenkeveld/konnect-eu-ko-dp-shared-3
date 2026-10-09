# AGENTS.md

Terraform stack for the **ko-dp-shared-3** (Kong Operator) Konnect control plane. See [README.md](README.md).
One of two sibling stacks - see also `../konnect-eu-ko-dp-shared-2`.

## Rules
- **Always `terraform plan` before `apply`** — this mutates live Konnect (control plane) and OpenBao.
- **Never commit** `TF_VAR_KPAT` / `TF_VAR_HCV_ROOT_TOKEN` values, `terraform.tfstate*`, or `connection-details.json` (git-ignored).
- Secrets come from env (`source ./export-secrets.sh`), never hardcoded in `*.tf`.
- Providers are pinned (`kong/konnect`, `hashicorp/vault`→OpenBao, `hashicorp/local`); run `terraform init -upgrade` after changing them.
- No developer portal here, unlike `konnect-eu-development`/`konnect-eu-production` - this control plane exists
  solely to be mirrored into the cluster via the Kong Operator's `KonnectGatewayControlPlane` (mirror mode), not
  to serve APIOps/portal traffic.

## Shape
`main.tf` builds a `locals.connection_details` map (CP id + endpoints), then writes it to OpenBao
(`write_to_openbao`) and/or a local file (`write_to_file`), both default `true`. The `control_plane_id` field is
the one addition versus the development/production stacks - the Kong Operator's CRD references an externally
created control plane by raw ID (`spec.mirror.konnect.id`) rather than creating its own.
