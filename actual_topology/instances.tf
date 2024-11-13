data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

resource "aws_instance" "public" {
  count         = 2
  ami           = data.aws_ami.amazon_linux_2.id
  instance_type = var.instance_type
  subnet_id     = aws_subnet.public[count.index].id
  key_name      = "key"
  vpc_security_group_ids = [aws_security_group.public.id]

  tags = {
    Name = "Public-EC2-${count.index + 1}"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum update -y",
      "sudo amazon-linux-extras install nginx1 -y",
      "sudo systemctl start nginx",
      "sudo systemctl enable nginx",
      "sudo tee /etc/nginx/conf.d/reverse-proxy.conf << EOF",
      "server {",
      "    listen 80;",
      "    server_name _;",
      "    location / {",
      "        proxy_pass http://${aws_lb.internal.dns_name};",
      "        proxy_set_header Host \\$host;",
      "        proxy_set_header X-Real-IP \\$remote_addr;",
      "        proxy_set_header X-Forwarded-For \\$proxy_add_x_forwarded_for;",
      "        proxy_set_header X-Forwarded-Proto \\$scheme;",
      "        proxy_connect_timeout 300;",
      "        proxy_send_timeout 300;",
      "        proxy_read_timeout 300;",
      "        proxy_buffer_size 128k;",
      "        proxy_buffers 4 256k;",
      "        proxy_busy_buffers_size 256k;",
      "    }",
      "}",
      "EOF",
      "sudo nginx -t",
      "sudo systemctl reload nginx"
    ]

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file("./key.pem")
      host        = self.public_ip
    }
  }
}

resource "aws_instance" "private" {
  count         = 2
  ami           = data.aws_ami.amazon_linux_2.id
  instance_type = var.instance_type
  subnet_id     = aws_subnet.private[count.index].id
  vpc_security_group_ids = [aws_security_group.private.id]

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd
              systemctl start httpd
              systemctl enable httpd
              echo "<h1>well done King Memo</h1>" > /var/www/html/index.html
              # Add proper headers configuration
              echo "RequestHeader set X-Forwarded-Proto https" >> /etc/httpd/conf/httpd.conf
              echo "RequestHeader set X-Forwarded-Port 443" >> /etc/httpd/conf/httpd.conf
              systemctl restart httpd
              EOF

  tags = {
    Name = "Private-EC2-${count.index + 1}"
  }
}
