echo Start rabbitMQ

mkdir -p rabbitmq/etc
mkdir -p rabbitmq/data
mkdir -p rabbitmq/logs

echo Start Docker-Compose

docker-compose --env-file .env up -d