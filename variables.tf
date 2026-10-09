variable "KPAT" {
  type    = string
  default = ""
}

variable "HCV_ROOT_TOKEN" {
  type    = string
  default = ""
}

variable "write_to_openbao" {
  type        = bool
  default     = true
  description = "Write connection details to OpenBao."
}

variable "write_to_file" {
  type        = bool
  default     = true
  description = "Write the same connection details to a local JSON file."
}

variable "local_output_file" {
  type        = string
  default     = "connection-details.json"
  description = "Filename (relative to the stack) for the local details file."
}

variable "openbao_address" {
  type        = string
  default     = "https://openbao.example.com"
  description = "Address of the OpenBao (or Vault) server. Only used when write_to_openbao is true."
}

variable "root_ca_cert_path" {
  type        = string
  default     = "./root-ca-cert.pem"
  description = "Path to the root CA certificate (PEM) used as the data-plane client certificate."
}
