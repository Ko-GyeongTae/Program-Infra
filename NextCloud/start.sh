#!/bin/bash
echo "Make Directory for nextcloud"

sudo mkdir -p /mnt/storage1/nextcloud/nextcloud
sudo mkdir -p /mnt/storage1/nextcloud/apps
sudo mkdir -p /mnt/storage1/nextcloud/config
sudo mkdir -p /mnt/storage1/nextcloud/data
sudo mkdir -p /mnt/storage1/nextcloud/theme

echo "Read Environment"
export $(xargs < .env)

echo "Set Database"
docker exec mysql mysql -uroot -p$MYSQL_PASSWORD -e "CREATE DATABASE $CLOUD_DATABASE;"
docker exec mysql mysql -uroot -p$MYSQL_PASSWORD -e "CREATE USER '$CLOUD_USERNAME'@'%' IDENTIFIED BY '$CLOUD_PASSWORD';"
docker exec mysql mysql -uroot -p$MYSQL_PASSWORD -e "GRANT ALL PRIVILEGES ON $CLOUD_USERNAME.* TO '$CLOUD_USERNAME'@'%';"
docker exec mysql mysql -uroot -p$MYSQL_PASSWORD -e "FLUSH PRIVILEGES;"

echo "Create Container"
docker-compose up -d