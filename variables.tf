variable "aws_region" {
  type    = string
  default = "us-east-2"
}

variable "owner" {
  type    = string
  default = "owner"
#  default = format("%s",data.external.whatismyip.result,"whoiamuser")

}

variable "amiowner" {
  type    = list(string)
  default = ["099720109477"]
}

variable "spotprice" {
  type    = string
  default = "0.03"
}


variable "amitype" {
  type    = string
  default = "t3a.medium"
}

variable "volsize" {
  type    = number
  default = 50
}

variable "deployname" {
  type    = string
  default = "dockerhost"
}