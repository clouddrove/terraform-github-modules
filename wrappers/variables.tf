variable "items" {
  type        = any
  default     = {}
  description = "Baseline calls to make, keyed by an arbitrary label. Each value accepts any root module input; the key is used as the repository name when `name` is omitted."
}

variable "defaults" {
  type        = any
  default     = {}
  description = "Values applied to every entry in `items` that does not set them itself."
}
