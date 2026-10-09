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
