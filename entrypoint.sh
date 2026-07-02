#!/bin/bash

# Ensure config.json points to the correct MySQL host (not the old external container)
if [ -f /app/data/config.json ]; then
    sed -i 's/"host": "test-mysql8"/"host": "BillSumExt-mysql"/g' /app/data/config.json
    sed -i 's/"container_name": "test-mysql8"/"container_name": "BillSumExt-mysql"/g' /app/data/config.json
fi

# Wait for MySQL to be fully ready (ping is not enough — it succeeds before init scripts complete)
echo "Waiting for MySQL at $MYSQL_HOST:$MYSQL_PORT..."
for i in $(seq 1 120); do
    if mysql -h"$MYSQL_HOST" -P"$MYSQL_PORT" -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" -e "SELECT COUNT(*) FROM information_schema.SCHEMATA WHERE SCHEMA_NAME='sum_all'" --silent 2>/dev/null | grep -q '[0-9]'; then
        echo "MySQL is ready (sum_all database found)."
        break
    fi
    if [ "$i" -eq 120 ]; then
        echo "WARNING: MySQL not ready after 120 retries, continuing anyway..."
    else
        echo "Waiting... ($i/120)"
        sleep 2
    fi
done

# Generate self-signed SSL cert and config if missing
SSL_DIR=/etc/nginx/ssl
SSL_CONF=/etc/nginx/conf.d/ssl.conf
if [ ! -f "$SSL_DIR/cert.pem" ] || [ ! -f "$SSL_DIR/key.pem" ]; then
    echo "Generating self-signed SSL certificate..."
    mkdir -p "$SSL_DIR"
    if openssl req -x509 -nodes -days 3650 -newkey rsa:2048 \
        -keyout "$SSL_DIR/key.pem" \
        -out "$SSL_DIR/cert.pem" \
        -subj "/CN=BillSumExt-app" 2>/dev/null; then
        echo "SSL certificate generated."
    else
        echo "WARNING: SSL certificate generation failed. HTTPS will be disabled."
    fi
fi

# Create SSL nginx config if cert exists
if [ -f "$SSL_DIR/cert.pem" ] && [ -f "$SSL_DIR/key.pem" ]; then
    cat > "$SSL_CONF" << 'EOF'
server {
    listen 443 ssl;
    server_name _;

    ssl_certificate     /etc/nginx/ssl/cert.pem;
    ssl_certificate_key /etc/nginx/ssl/key.pem;
    ssl_protocols       TLSv1.2 TLSv1.3;
    ssl_ciphers         HIGH:!aNULL:!MD5;

    root /usr/share/nginx/html;
    index index.html;

    location / {
        try_files $uri $uri/ /index.html;
    }

    location /api/ {
        proxy_pass http://127.0.0.1:8000/api/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_read_timeout 7200s;
    }
}
EOF
    echo "SSL nginx config created."
else
    rm -f "$SSL_CONF"
    echo "SSL not available. HTTPS disabled."
fi

# Validate and start nginx
nginx -t 2>/dev/null || {
    echo "WARNING: nginx config invalid. Removing SSL config and retrying..."
    rm -f "$SSL_CONF"
    nginx -t 2>/dev/null || echo "WARNING: still invalid, attempting to start nginx anyway..."
}

nginx
echo "Nginx started. Starting Uvicorn..."
exec uvicorn app.main:app --host 127.0.0.1 --port 8000
