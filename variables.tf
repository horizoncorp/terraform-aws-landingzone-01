variable "name" {}
variable "cidr" {}

variable "subnet" {
  type = map(object({
    az             = string
    private_cidr = list(string)
    public_cidr  = list(string)
  }))
  default = {}
}
