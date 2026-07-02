#!/bin/bash

# Ensure config.json points to the correct MySQL host (not the old external container)
if [ -f /app/data/config.json ]; then
    sed -i 's/"host": "test-mysql8"/"host": "BillSumExt-mysql"/g' /app/data/config.json
    sed -i 's/"container_name": "test-mysql8"/"container_name": "BillSumExt-mysql"/g' /app/data/config.json
fi

# Wait for MySQL to be ready
echo "Waiting for MySQL at $MYSQL_HOST:$MYSQL_PORT..."
for i in $(seq 1 60); do
    if mysqladmin ping -h"$MYSQL_HOST" -P"$MYSQL_PORT" -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" --silent 2>/dev/null; then
        echo "MySQL is ready."
        break
    fi
    echo "Waiting... ($i/60)"
    sleep 2
done

# Generate self-signed SSL cert if missing
SSL_DIR=/etc/nginx/ssl
if [ ! -f "$SSL_DIR/cert.pem" ] || [ ! -f "$SSL_DIR/key.pem" ]; then
    mkdir -p "$SSL_DIR"
    openssl req -x509 -nodes -days 3650 -newkey rsa:2048 \
        -keyout "$SSL_DIR/key.pem" \
        -out "$SSL_DIR/cert.pem" \
        -subj "/CN=BillSumExt-app" 2>/dev/null
fi

nginx
exec uvicorn app.main:app --host 127.0.0.1 --port 8000
