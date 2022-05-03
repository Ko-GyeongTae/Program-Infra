# Download node_exporter file
curl -LO https://github.com/prometheus/node_exporter/releases/download/v1.0.1/node_exporter-1.0.1.linux-amd64.tar.gz
tar -xvf node_exporter-1.0.1.linux-amd64.tar.gz
sudo mv node_exporter-1.0.1.linux-amd64/node_exporter /usr/local/bin/

# Register service
sudo echo -e "[Unit]
Description=Node Exporter
After=network.target

[Service]
User=node_exporter
Group=node_exporter
Type=simple
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=multi-user.target" >> /etc/systemd/system/node_exporter.service

# Start node_exporter
sudo useradd -M -r -s /bin/false node_exporter

sudo systemctl daemon-reload
sudo systemctl start node_exporter
sudo systemctl status node_exporter
sudo systemctl enable node_exporter

# Set Prometheus
sudo mkdir -p /data/docker/prometheus/

sudo echo -e "global:
  scrape_interval:     15s # Set the scrape interval to every 15 seconds. Default is every 1 minute.
scrape_configs:
  - job_name: 'prometheus'
    static_configs:
    - targets: ['localhost:9090']

  - job_name: 'node_exporter'
    static_configs:
      - targets: ['localhost:9100', 'localhost:9100']" >> /data/docker/prometheus/prometheus.yml

mkdir prometheus
cd prometheus

# Docker Set
# docker v19 부터 volume 명령 사용가능
docker volume create --name=prometheus_data
docker volume create --name=grafana_data
docker volume ls

# ps 에 user 가 숫자로 나오는 것 수정
sudo useradd -M -r -s /bin/false grafana
# export GRA_UID=`id -u grafana`
# export GRA_GID=`id -g grafana`

# Write Docker Compose
touch docker-compose.yml

echo -e "version: '3.7'

volumes:
  prometheus_data:
    external: true
  grafana_data:
    external: true

services:
  prometheus:
    image: prom/prometheus
    container_name: prometheus
    network_mode: host
    volumes:
      - /data/docker/prometheus/prometheus.yml:/etc/prometheus/prometheus.yml
      - prometheus_data:/prometheus
    ports:
      - 9090:9090
    restart: always

  grafana:
    image: grafana/grafana
    container_name: grafana
    network_mode: host
    environment:
      - GF_SECURITY_ADMIN_USER=${USER}
      - GF_SECURITY_ADMIN_PASSWORD=${PASSWORD}
      - GF_USERS_ALLOW_SIGN_UP=false
    depends_on:
      - prometheus
    user: "${GRA_UID}:${GRA_GID}"
    ports:
      - 3000:3000
    volumes:
      - grafana_data:/var/lib/grafana
    restart: always
" >> docker-compose.yml

GRA_UID=`id -u grafana` GRA_GID=`id -g grafana` docker-compose --env-file .env up -d 

docker container logs prometheus
docker container logs grafana

# docker-compose stop
# docker-compose start
# docker-compose down