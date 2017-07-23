data "ignition_config" "node_ignition" {
  files = [
    "${data.ignition_file.appzip.id}",
  ]

  systemd = [
    "${data.ignition_systemd_unit.docker.id}",
    "${data.ignition_systemd_unit.app.id}",
  ]
}

data "ignition_systemd_unit" "docker" {
  name   = "docker.service"
  enable = true
}

data "ignition_file" "appzip" {
  path       = "/opt/ro-demo/ro-demo.zip"
  mode       = 0666
  filesystem = "root"

  content {
    mime    = "application/octet-stream"
    content = "${file(data.archive_file.appzip.output_path)}"
  }
}

data "archive_file" "appzip" {
  type = "zip"

  output_path = "./.terraform/app.zip"

  source {
    filename = "app.py"
    content  = "${file("${path.module}/app/app.py")}"
  }

  source {
    filename = "Dockerfile"
    content  = "${file("${path.module}/app/Dockerfile")}"
  }

  source {
    filename = "docker-compose.yaml"
    content  = "${file("${path.module}/app/docker-compose.yaml")}"
  }
}

data "ignition_systemd_unit" "app" {
  name    = "ro-demo.service"
  enable  = true
  content = <<EOF
[Unit]
Description=Demo app setup
After=docker.service
[Service]
WorkingDirectory=/opt/ro-demo/
ExecStart=/usr/bin/bash -ec 'cd /opt/ro-demo; unzip ro-demo.zip; \
docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \
  -v /opt/ro-demo:/app \
  docker/compose:1.14.0 \
  --project-directory /app \
  --file /app/docker-compose.yaml \
  up'
[Install]
WantedBy=multi-user.target
EOF
}
