resource "aws_lb" "external" {
  name               = "external-public-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.public.id]
  subnets           = aws_subnet.public[*].id
}

resource "aws_lb_target_group" "external" {
  name     = "external-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id
}

resource "aws_lb_listener" "external" {
  load_balancer_arn = aws_lb.external.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.external.arn
  }
}

resource "aws_lb_target_group_attachment" "external" {
  count            = 2
  target_group_arn = aws_lb_target_group.external.arn
  target_id        = aws_instance.public[count.index].id
  port             = 80
}

resource "aws_lb" "internal" {
  name               = "private-internal-lb"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [aws_security_group.internal_alb.id]
  subnets           = aws_subnet.private[*].id
}

resource "aws_lb_target_group" "internal" {
  name     = "internal-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id
}

resource "aws_lb_listener" "internal" {
  load_balancer_arn = aws_lb.internal.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.internal.arn
  }
}

resource "aws_lb_target_group_attachment" "internal" {
  count            = 2
  target_group_arn = aws_lb_target_group.internal.arn
  target_id        = aws_instance.private[count.index].id
  port             = 80
}
