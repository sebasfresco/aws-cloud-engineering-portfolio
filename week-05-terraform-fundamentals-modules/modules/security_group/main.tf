# ------------------------------------------------------------------
# Security Group
# Generic security group module. Ingress rules are passed in as a variable
# (dynamic block) so callers define what traffic to allow. Egress allows all
# outbound — standard default; restrict only if compliance requires it.
# ------------------------------------------------------------------
resource "aws_security_group" "this" {
  name        = "${var.name}-sg"
  description = var.description
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = var.ingress_rules
    content {
      description = ingress.value.description
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.name}-sg"
  }
}
