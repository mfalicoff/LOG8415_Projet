# As we don't want to go through the very involving setup of configuring
# our own VPC for this lab, we use the default one provided by AWS.
data "aws_vpc" "cluster-default" {
  default = true
}
