terraform {
  required_version = "> 0.10.8"
}

provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region     = "${var.aws_region}"
}

#
# =================== Manager =======================
#

resource "aws_instance" "Manager" {
  ami = "${var.aws_ami}"
//  instance_type = "r4.2xlarge" // 256 GB
  instance_type = "${var.instance_type}"
  key_name = "${var.aws_key_name}"
  security_groups = "${var.aws_security_groups}"

  tags {
    Name = "${var.name}"
  }

  # Provisioning

  connection {
    type = "ssh"
    user = "ubuntu"
    private_key = "${file(var.private_key_path)}"
    timeout = "5m"
  }

  provisioner "file" {
    source      = "${path.module}/daemon.json"
    destination = "/tmp/daemon.json"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mv /tmp/daemon.json /etc/docker/daemon.json",
      "sudo groupadd docker",
      "sudo usermod -aG docker $USER",
    ]
  }
  provisioner "remote-exec" {
    inline = [
      "sudo systemctl daemon-reload",
      "sudo systemctl stop docker",
      "sudo rm -rf /var/lib/docker",
      "sudo systemctl start docker",
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mkdir -p /data/zookeeper/data /data/zookeeper/datalog /data/mysql /data/mongo /data/kafka /data/endorsed /data/rulesprocessor-data /data/mongoinjector-data /data/transformbridge-data /data/k2m-data /data/prometheus /data/grafana /data/actionprocessor-data",
      "sudo mkdir -p /data/db /var/lib/mysql /datalog /usr/local/tomcat/endorsed /var/vizix/rulesProcessor /var/vizix/mongoIngestor /var/vizix",
      "sudo docker swarm init --advertise-addr ${aws_instance.Manager.private_ip} --listen-addr ${aws_instance.Manager.private_ip} > /tmp/joinCommand.txt",
      "sudo docker service create   --name=viz   --publish=8001:8080/tcp --constraint=node.role==manager --mount=type=bind,src=/var/run/docker.sock,dst=/var/run/docker.sock dockersamples/visualizer",
      "sudo grep 'join --token' /tmp/joinCommand.txt > /tmp/join.txt"
    ]
  }

  provisioner "file" {
    source      = "${path.module}/core.yml"
    destination = "/tmp/core.yml"
  }

  provisioner "file" {
    source      = "${path.module}/services.yml"
    destination = "/tmp/services.yml"
  }

  provisioner "file" {
    source      = "${path.module}/stream-apps.yml"
    destination = "/tmp/stream-apps.yml"
  }

  provisioner "file" {
    source      = "${path.module}/vizix-tools.yml"
    destination = "/tmp/vizix-tools.yml"
  }

  provisioner "file" {
    source      = "${path.module}/rulesprocessor.yml"
    destination = "/tmp/rulesprocessor.yml"
  }

  provisioner "file" {
    source      = "${path.module}/actionprocessor.yml"
    destination = "/tmp/actionprocessor.yml"
  }

  provisioner "file" {
    source      = "${path.module}/get_logs_by_container.py"
    destination = "/tmp/get_logs_by_container.py"
  }

  provisioner "file" {
    source      = "${path.module}/collectorMetrics.sh"
    destination = "/tmp/collectorMetrics.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo cp -rf /tmp/core.yml /home/ubuntu/vizix_repositories",
      "sudo cp -rf /tmp/services.yml /home/ubuntu/vizix_repositories",
      "sudo cp -rf /tmp/stream-apps.yml /home/ubuntu/vizix_repositories",
      "sudo cp -rf /tmp/vizix-tools.yml /home/ubuntu/vizix_repositories",
      "sudo cp -rf /tmp/rulesprocessor.yml /home/ubuntu/vizix_repositories",
      "sudo cp -rf /tmp/actionprocessor.yml /home/ubuntu/vizix_repositories",
      "sudo cp -rf /tmp/get_logs_by_container.py /home/ubuntu/vizix_repositories",
      "sudo cp -rf /tmp/collectorMetrics.sh /home/ubuntu/vizix_repositories",
      "sudo sh /home/ubuntu/vizix_repositories/collectorMetrics.sh"
    ]
  }
}

#
# =================== DataBase Server =======================
#

resource "aws_instance" "DataBase" {
  ami = "${var.aws_ami}"
//  instance_type = "r4.2xlarge" // 6x200 GB + 250 GB + 2x1024 GB
  instance_type = "${var.instance_type}"
  key_name = "${var.aws_key_name}"
  security_groups = "${var.aws_security_groups}"

  tags {
    Name = "${var.name}"
  }

  connection {
    type = "ssh"
    user = "ubuntu"
    private_key = "${file(var.private_key_path)}"
    timeout = "5m"
  }

  provisioner "file" {
    source      = "${path.module}/daemon.json"
    destination = "/tmp/daemon.json"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mv /tmp/daemon.json /etc/docker/daemon.json",
      "sudo groupadd docker",
      "sudo usermod -aG docker $USER",
    ]
  }
  provisioner "remote-exec" {
    inline = [
      "sudo systemctl daemon-reload",
      "sudo systemctl stop docker",
      "sudo rm -rf /var/lib/docker",
      "sudo systemctl start docker",
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mkdir -p /data/zookeeper/data /data/zookeeper/datalog /data/mysql /data/mongo /data/kafka /data/endorsed /data/rulesprocessor-data /data/mongoinjector-data /data/transformbridge-data /data/k2m-data /data/prometheus /data/grafana /data/actionprocessor-data",
      "sudo mkdir -p /data/db /var/lib/mysql /datalog /usr/local/tomcat/endorsed /var/vizix/rulesProcessor /var/vizix/mongoIngestor /var/vizix"
    ]
  }

  provisioner "file" {
    source      = "${path.module}/monitoring/monitoring.yml"
    destination = "/tmp/monitoring.yml"
  }

  provisioner "file" {
    source      = "${path.module}/monitoring/prometheus.yml"
    destination = "/tmp/prometheus.yml"
  }

  provisioner "file" {
    source      = "${path.module}/get_logs_by_container.py"
    destination = "/tmp/get_logs_by_container.py"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mkdir -p /home/ubuntu/vizix_repositories/monitoring/",
      "sudo cp -rf /tmp/prometheus.yml /home/ubuntu/vizix_repositories/monitoring/",
      "sudo cp -rf /tmp/monitoring.yml /home/ubuntu/vizix_repositories/monitoring/",
      "sudo cp -rf /tmp/get_logs_by_container.py /home/ubuntu/vizix_repositories",
      "sudo cp -rf /tmp/collectorMetrics.sh /home/ubuntu/vizix_repositories",
      "sudo sh /home/ubuntu/vizix_repositories/collectorMetrics.sh"
    ]
  }
}

#
# =================== Kafka Server =======================
#

resource "aws_instance" "Kafka" {
  ami = "${var.aws_ami}"
//  instance_type = "c5.2xlarge" // 250 GB
  instance_type = "${var.instance_type}"
  key_name = "${var.aws_key_name}"
  security_groups = "${var.aws_security_groups}"

  tags {
    Name = "${var.name}"
  }

  connection {
    type = "ssh"
    user = "ubuntu"
    private_key = "${file(var.private_key_path)}"
    timeout = "5m"
  }

  provisioner "file" {
    source      = "${path.module}/daemon.json"
    destination = "/tmp/daemon.json"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mv /tmp/daemon.json /etc/docker/daemon.json",
      "sudo groupadd docker",
      "sudo usermod -aG docker $USER",
    ]
  }
  provisioner "remote-exec" {
    inline = [
      "sudo systemctl daemon-reload",
      "sudo systemctl stop docker",
      "sudo rm -rf /var/lib/docker",
      "sudo systemctl start docker",
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mkdir -p /data/zookeeper/data /data/zookeeper/datalog /data/mysql /data/mongo /data/kafka /data/endorsed /data/rulesprocessor-data /data/mongoinjector-data /data/transformbridge-data /data/k2m-data /data/prometheus /data/grafana /data/actionprocessor-data",
      "sudo mkdir -p /data/db /var/lib/mysql /datalog /usr/local/tomcat/endorsed /var/vizix/rulesProcessor /var/vizix/mongoIngestor /var/vizix"
    ]
  }

  provisioner "file" {
    source      = "${path.module}/monitoring/monitoring.yml"
    destination = "/tmp/monitoring.yml"
  }

  provisioner "file" {
    source      = "${path.module}/monitoring/prometheus.yml"
    destination = "/tmp/prometheus.yml"
  }

  provisioner "file" {
    source      = "${path.module}/get_logs_by_container.py"
    destination = "/tmp/get_logs_by_container.py"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mkdir -p /home/ubuntu/vizix_repositories/monitoring/",
      "sudo cp -rf /tmp/prometheus.yml /home/ubuntu/vizix_repositories/monitoring/",
      "sudo cp -rf /tmp/monitoring.yml /home/ubuntu/vizix_repositories/monitoring/",
      "sudo cp -rf /tmp/get_logs_by_container.py /home/ubuntu/vizix_repositories",
      "sudo cp -rf /tmp/collectorMetrics.sh /home/ubuntu/vizix_repositories",
      "sudo sh /home/ubuntu/vizix_repositories/collectorMetrics.sh"
    ]
  }
}

#
# =================== Rulesprocessor Server(s) =======================
#

resource "aws_instance" "Rulesprocessor" {
  ami = "${var.aws_ami}"
//  instance_type = "c5.2xlarge" // 1024 GB
  instance_type = "${var.instance_type}"
  key_name = "${var.aws_key_name}"
  security_groups = "${var.aws_security_groups}"
//  Number of rulesprocessor to create
  count = "${var.aws_count_rulesprocessor}"

  tags {
    Name = "${var.name}"
  }

  connection {
    type = "ssh"
    user = "ubuntu"
    private_key = "${file(var.private_key_path)}"
    timeout = "5m"
  }

  provisioner "file" {
    source      = "${path.module}/daemon.json"
    destination = "/tmp/daemon.json"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mv /tmp/daemon.json /etc/docker/daemon.json",
      "sudo groupadd docker",
      "sudo usermod -aG docker $USER",
    ]
  }
  provisioner "remote-exec" {
    inline = [
      "sudo systemctl daemon-reload",
      "sudo systemctl stop docker",
      "sudo rm -rf /var/lib/docker",
      "sudo systemctl start docker",
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mkdir -p /data/zookeeper/data /data/zookeeper/datalog /data/mysql /data/mongo /data/kafka /data/endorsed /data/rulesprocessor-data /data/mongoinjector-data /data/transformbridge-data /data/k2m-data /data/prometheus /data/grafana /data/actionprocessor-data",
      "sudo mkdir -p /data/db /var/lib/mysql /datalog /usr/local/tomcat/endorsed /var/vizix/rulesProcessor /var/vizix/mongoIngestor /var/vizix"
    ]
  }

  provisioner "file" {
    source      = "${path.module}/monitoring/monitoring.yml"
    destination = "/tmp/monitoring.yml"
  }

  provisioner "file" {
    source      = "${path.module}/monitoring/prometheus.yml"
    destination = "/tmp/prometheus.yml"
  }

  provisioner "file" {
    source      = "${path.module}/get_logs_by_container.py"
    destination = "/tmp/get_logs_by_container.py"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mkdir -p /home/ubuntu/vizix_repositories/monitoring/",
      "sudo cp -rf /tmp/prometheus.yml /home/ubuntu/vizix_repositories/monitoring/",
      "sudo cp -rf /tmp/monitoring.yml /home/ubuntu/vizix_repositories/monitoring/",
      "sudo cp -rf /tmp/get_logs_by_container.py /home/ubuntu/vizix_repositories",
      "sudo cp -rf /tmp/collectorMetrics.sh /home/ubuntu/vizix_repositories",
      "sudo sh /home/ubuntu/vizix_repositories/collectorMetrics.sh"
    ]
  }
}

#
# =================== TransformBridge Server =======================
#

resource "aws_instance" "TransformBridge" {
  ami = "${var.aws_ami}"
//  instance_type = ""
  instance_type = "${var.instance_type}"
  key_name = "${var.aws_key_name}"
  security_groups = "${var.aws_security_groups}"

  tags {
    Name = "${var.name}"
  }

  connection {
    type = "ssh"
    user = "ubuntu"
    private_key = "${file(var.private_key_path)}"
    timeout = "5m"
  }

  provisioner "file" {
    source      = "${path.module}/daemon.json"
    destination = "/tmp/daemon.json"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mv /tmp/daemon.json /etc/docker/daemon.json",
      "sudo groupadd docker",
      "sudo usermod -aG docker $USER",
    ]
  }
  provisioner "remote-exec" {
    inline = [
      "sudo systemctl daemon-reload",
      "sudo systemctl stop docker",
      "sudo rm -rf /var/lib/docker",
      "sudo systemctl start docker",
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mkdir -p /data/zookeeper/data /data/zookeeper/datalog /data/mysql /data/mongo /data/kafka /data/endorsed /data/rulesprocessor-data /data/mongoinjector-data /data/transformbridge-data /data/k2m-data /data/prometheus /data/grafana /data/actionprocessor-data",
      "sudo mkdir -p /data/db /var/lib/mysql /datalog /usr/local/tomcat/endorsed /var/vizix/rulesProcessor /var/vizix/mongoIngestor /var/vizix"
    ]
  }

  provisioner "file" {
    source      = "${path.module}/monitoring/monitoring.yml"
    destination = "/tmp/monitoring.yml"
  }

  provisioner "file" {
    source      = "${path.module}/monitoring/prometheus.yml"
    destination = "/tmp/prometheus.yml"
  }

  provisioner "file" {
    source      = "${path.module}/get_logs_by_container.py"
    destination = "/tmp/get_logs_by_container.py"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mkdir -p /home/ubuntu/vizix_repositories/monitoring/",
      "sudo cp -rf /tmp/prometheus.yml /home/ubuntu/vizix_repositories/monitoring/",
      "sudo cp -rf /tmp/monitoring.yml /home/ubuntu/vizix_repositories/monitoring/",
      "sudo cp -rf /tmp/get_logs_by_container.py /home/ubuntu/vizix_repositories",
      "sudo cp -rf /tmp/collectorMetrics.sh /home/ubuntu/vizix_repositories",
      "sudo sh /home/ubuntu/vizix_repositories/collectorMetrics.sh"
    ]
  }
}

#
# =================== MongoInjector Server =======================
#

resource "aws_instance" "MongoInjector" {
  ami = "${var.aws_ami}"
  instance_type = "${var.instance_type}"
  key_name = "${var.aws_key_name}"
  security_groups = "${var.aws_security_groups}"

  tags {
    Name = "${var.name}"
  }

  connection {
    type = "ssh"
    user = "ubuntu"
    private_key = "${file(var.private_key_path)}"
    timeout = "5m"
  }

  provisioner "file" {
    source      = "${path.module}/daemon.json"
    destination = "/tmp/daemon.json"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mv /tmp/daemon.json /etc/docker/daemon.json",
      "sudo groupadd docker",
      "sudo usermod -aG docker $USER",
    ]
  }
  provisioner "remote-exec" {
    inline = [
      "sudo systemctl daemon-reload",
      "sudo systemctl stop docker",
      "sudo rm -rf /var/lib/docker",
      "sudo systemctl start docker",
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mkdir -p /data/zookeeper/data /data/zookeeper/datalog /data/mysql /data/mongo /data/kafka /data/endorsed /data/rulesprocessor-data /data/mongoinjector-data /data/transformbridge-data /data/k2m-data /data/prometheus /data/grafana /data/actionprocessor-data",
      "sudo mkdir -p /data/db /var/lib/mysql /datalog /usr/local/tomcat/endorsed /var/vizix/rulesProcessor /var/vizix/mongoIngestor /var/vizix"
    ]
  }

  provisioner "file" {
    source      = "${path.module}/monitoring/monitoring.yml"
    destination = "/tmp/monitoring.yml"
  }

  provisioner "file" {
    source      = "${path.module}/monitoring/prometheus.yml"
    destination = "/tmp/prometheus.yml"
  }

  provisioner "file" {
    source      = "${path.module}/get_logs_by_container.py"
    destination = "/tmp/get_logs_by_container.py"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mkdir -p /home/ubuntu/vizix_repositories/monitoring/",
      "sudo cp -rf /tmp/prometheus.yml /home/ubuntu/vizix_repositories/monitoring/",
      "sudo cp -rf /tmp/monitoring.yml /home/ubuntu/vizix_repositories/monitoring/",
      "sudo cp -rf /tmp/get_logs_by_container.py /home/ubuntu/vizix_repositories",
      "sudo cp -rf /tmp/collectorMetrics.sh /home/ubuntu/vizix_repositories",
      "sudo sh /home/ubuntu/vizix_repositories/collectorMetrics.sh"
    ]
  }
}


#
# =================== Client =======================
#

resource "aws_instance" "Client" {
  ami             = "ami-3955ae43" //client image
  instance_type   = "${var.instance_type}"
  key_name        = "${var.aws_key_name}"
  security_groups = "${var.aws_security_groups}"

  tags {
    Name = "${var.name}Client"
  }

  connection {
    type = "ssh"
    user = "ubuntu"
    private_key = "${file(var.private_key_path)}"
    timeout = "5m"
  }

  provisioner "file" {
    source      = "${path.module}/scripts/executeBridges.sh"
    destination = "/tmp/executeBridges.sh"
  }

  provisioner "file" {
    source      = "${path.module}/scripts/executeJmeter.sh"
    destination = "/tmp/executeJmeter.sh"
  }

  provisioner "file" {
    source      = "${path.module}/scripts/executeUI.sh"
    destination = "/tmp/executeUI.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo chmod 777 /tmp/executeBridges.sh /tmp/executeJmeter.sh /tmp/executeUI.sh",
      "sudo cp -rf /tmp/executeBridges.sh /home/ubuntu/vizix_repositories/",
      "sudo cp -rf /tmp/executeUI.sh /home/ubuntu/vizix_repositories/",
      "sudo cp -rf /tmp/executeJmeter.sh /home/ubuntu/vizix_repositories/"
    ]
  }
}


#
# =================== Output =======================
#

output "DataBase_private_IP" {
  value = "${aws_instance.DataBase.private_ip}"
}
output "DataBase_public_IP" {
  value = "${aws_instance.DataBase.public_ip}"
}
output "Kafka_private_IP" {
  value = "${aws_instance.Kafka.private_ip}"
}
output "Kafka_public_IP" {
  value = "${aws_instance.Kafka.public_ip}"
}
output "Rulesprocessor_private_IP" {
  value = "${aws_instance.Rulesprocessor.*.private_ip}"
}
output "Rulesprocessor_public_IP" {
  value = "${aws_instance.Rulesprocessor.*.public_ip}"
}
output "TransformBridge_private_IP" {
  value = "${aws_instance.TransformBridge.private_ip}"
}
output "TransformBridge_public_IP" {
  value = "${aws_instance.TransformBridge.public_ip}"
}
output "Manager_private_IP" {
  value = "${aws_instance.Manager.private_ip}"
}
output "Manager_public_IP" {
  value = "${aws_instance.Manager.public_ip}"
}
output "MongoInjector_private_IP" {
  value = "${aws_instance.MongoInjector.private_ip}"
}
output "MongoInjector_public_IP" {
  value = "${aws_instance.MongoInjector.public_ip}"
}
output "Client_private_IP" {
  value = "${aws_instance.Client.private_ip}"
}
output "Client_public_IP" {
  value = "${aws_instance.Client.public_ip}"
}
