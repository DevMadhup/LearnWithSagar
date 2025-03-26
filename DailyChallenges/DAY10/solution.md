## 3 Node rabbitMQ cluster setup and monitoring using Prometheus and Grafana

### Steps to implement:

- Create 3 EC2 instance with the following details:
  
  - **AMI:** Ubuntu
  - **Instance type:** t2.medium
  - **Volume:** 15GB
  - **Security group ports**:
    
    - 5672 (AMQP) for RabbitMQ messaging
    - 15672 (RabbitMQ management UI)
    - 15692 (Prometheus metrics endpoint)
    - 9090 (Prometheus)
    - 3000 (Grafana)
--- 

- Update system (All nodes):
```bash
sudo su
apt update
```
---

- create a shell script to install erlang and rabbitmq-server (All nodes):
```bash
#!/bin/sh

sudo apt-get install curl gnupg apt-transport-https -y

## Team RabbitMQ's main signing key
curl -1sLf "https://keys.openpgp.org/vks/v1/by-fingerprint/0A9AF2115F4687BD29803A206B73A36E6026DFCA" | sudo gpg --dearmor | sudo tee /usr/share/keyrings/com.rabbitmq.team.gpg > /dev/null
## Community mirror of Cloudsmith: modern Erlang repository
curl -1sLf https://github.com/rabbitmq/signing-keys/releases/download/3.0/cloudsmith.rabbitmq-erlang.E495BB49CC4BBE5B.key | sudo gpg --dearmor | sudo tee /usr/share/keyrings/rabbitmq.E495BB49CC4BBE5B.gpg > /dev/null
## Community mirror of Cloudsmith: RabbitMQ repository
curl -1sLf https://github.com/rabbitmq/signing-keys/releases/download/3.0/cloudsmith.rabbitmq-server.9F4587F226208342.key | sudo gpg --dearmor | sudo tee /usr/share/keyrings/rabbitmq.9F4587F226208342.gpg > /dev/null

## Add apt repositories maintained by Team RabbitMQ
sudo tee /etc/apt/sources.list.d/rabbitmq.list <<EOF
## Provides modern Erlang/OTP releases
##
deb [arch=amd64 signed-by=/usr/share/keyrings/rabbitmq.E495BB49CC4BBE5B.gpg] https://ppa1.rabbitmq.com/rabbitmq/rabbitmq-erlang/deb/ubuntu noble main
deb-src [signed-by=/usr/share/keyrings/rabbitmq.E495BB49CC4BBE5B.gpg] https://ppa1.rabbitmq.com/rabbitmq/rabbitmq-erlang/deb/ubuntu noble main

# another mirror for redundancy
deb [arch=amd64 signed-by=/usr/share/keyrings/rabbitmq.E495BB49CC4BBE5B.gpg] https://ppa2.rabbitmq.com/rabbitmq/rabbitmq-erlang/deb/ubuntu noble main
deb-src [signed-by=/usr/share/keyrings/rabbitmq.E495BB49CC4BBE5B.gpg] https://ppa2.rabbitmq.com/rabbitmq/rabbitmq-erlang/deb/ubuntu noble main

## Provides RabbitMQ
##
deb [arch=amd64 signed-by=/usr/share/keyrings/rabbitmq.9F4587F226208342.gpg] https://ppa1.rabbitmq.com/rabbitmq/rabbitmq-server/deb/ubuntu noble main
deb-src [signed-by=/usr/share/keyrings/rabbitmq.9F4587F226208342.gpg] https://ppa1.rabbitmq.com/rabbitmq/rabbitmq-server/deb/ubuntu noble main

# another mirror for redundancy
deb [arch=amd64 signed-by=/usr/share/keyrings/rabbitmq.9F4587F226208342.gpg] https://ppa2.rabbitmq.com/rabbitmq/rabbitmq-server/deb/ubuntu noble main
deb-src [signed-by=/usr/share/keyrings/rabbitmq.9F4587F226208342.gpg] https://ppa2.rabbitmq.com/rabbitmq/rabbitmq-server/deb/ubuntu noble main
EOF

## Update package indices
sudo apt-get update -y

## Install Erlang packages
sudo apt-get install -y erlang-base \
                        erlang-asn1 erlang-crypto erlang-eldap erlang-ftp erlang-inets \
                        erlang-mnesia erlang-os-mon erlang-parsetools erlang-public-key \
                        erlang-runtime-tools erlang-snmp erlang-ssl \
                        erlang-syntax-tools erlang-tftp erlang-tools erlang-xmerl

## Install rabbitmq-server and its dependencies
sudo apt-get install rabbitmq-server -y --fix-missing
```
---

- Check RabbitMQ version (All nodes):
```bash
rabbitmqctl version
```
---

- Chech the status of RabbitMQ server (All nodes):
```bash
systemctl status rabbitmq-server
```
---

- Copy erlang cookie from node1 to all other nodes:
```bash
cat /var/lib/rabbitmq/.erlang.cookie
```
`Example:` Node-1: cat /var/lib/rabbitmq/.erlang.cookie (COPY)
      <br>     Node-2: vim /var/lib/rabbitmq/.erlang.cookie (PASTE)<br>
      Node-3: vim /var/lib/rabbitmq/.erlang.cookie (PASTE)

---

- Restart rabbitmq-server (Node1, Node2 and Node3):
```bash
systemctl restart rabbitmq-server
```
---

- Stop application to join cluster (Node2 and Node3):
```bash
rabbitmqctl stop_app
```
---

- Join cluster (Node2 and Node3):
```bash
rabbitmqctl join_cluster rabbit@ip-<private-ip-of-node1>
```
---

- Start application (Node2 and Node3):
```bash
rabbitmqctl start_app
```
---

- Go to Node-1, and check cluster status:
```bash
rabbitmqctl cluster_status
```
---

- Enable the RabbitMQ Management Plugin to access UI:
```bash
rabbitmq-plugins enable rabbitmq_management
systemctl restart rabbitmq-server
```

`Congratulations, you have successfully setupped RabbitMQ 3 node cluster.`

---

- Now go to the Node-1, and setup prometheus server:
```bash
wget https://github.com/prometheus/prometheus/releases/download/v2.47.0/prometheus-2.47.0.linux-amd64.tar.gz
tar zxvf prometheus-2.47.0.linux-amd64.tar.gz
```
---

- Create a prometheus.service inside the /etc/systemd/system directory and paste the below content: `vim /etc/systemd/system/prometheus.service`
```bash
[Unit]

Description=Prometheus Server

Documentation=https://prometheus.io/docs/introduction/overview/

After=network-online.target

[Service]

User=root

Restart=on-failure

ExecStart=/home/ubuntu/prometheus-2.47.0.linux-amd64/prometheus --config.file=/home/ubuntu/prometheus-2.47.0.linux-amd64/prometheus.yml

[Install]

WantedBy=multi-user.target
```
---

- Reload system daemon:
```bash
systemctl daemon-reload
```
---

- Restart prometheus server:
```bash
systemctl restart prometheus
```

> [!Important]
> node exporter runs on 9090 port no.
