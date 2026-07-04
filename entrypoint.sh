#!/bin/bash

# Ensure config.json points to the correct MySQL host (not the old external container)
if [ -f /app/data/config.json ]; then
    sed -i 's/"host": "test-mysql8"/"host": "BillSumExt-mysql"/g' /app/data/config.json
    sed -i 's/"container_name": "test-mysql8"/"container_name": "BillSumExt-mysql"/g' /app/data/config.json
fi

# Pick SSL certificate: prefer mounted Let's Encrypt cert, fall back to self-signed
SSL_DIR=/etc/nginx/ssl
SSL_CONF=/etc/nginx/conf.d/ssl.conf
SSL_CERT=""
SSL_KEY=""

if [ -n "$SSL_DOMAIN" ] && [ -f "/etc/letsencrypt/live/$SSL_DOMAIN/fullchain.pem" ] && [ -f "/etc/letsencrypt/live/$SSL_DOMAIN/privkey.pem" ]; then
    SSL_CERT="/etc/letsencrypt/live/$SSL_DOMAIN/fullchain.pem"
    SSL_KEY="/etc/letsencrypt/live/$SSL_DOMAIN/privkey.pem"
    echo "Using Let's Encrypt certificate for $SSL_DOMAIN"
else
    if [ ! -f "$SSL_DIR/cert.pem" ] || [ ! -f "$SSL_DIR/key.pem" ]; then
        echo "Generating self-signed SSL certificate..."
        mkdir -p "$SSL_DIR"
        if openssl req -x509 -nodes -days 3650 -newkey rsa:2048 \
            -keyout "$SSL_DIR/key.pem" \
            -out "$SSL_DIR/cert.pem" \
            -subj "/CN=BillSumExt-app" 2>/dev/null; then
            echo "Self-signed certificate generated."
        else
            echo "WARNING: SSL certificate generation failed."
        fi
    fi
    if [ -f "$SSL_DIR/cert.pem" ] && [ -f "$SSL_DIR/key.pem" ]; then
        SSL_CERT="$SSL_DIR/cert.pem"
        SSL_KEY="$SSL_DIR/key.pem"
        echo "Using self-signed certificate."
    fi
fi

# Create SSL nginx config if a certificate is available
if [ -n "$SSL_CERT" ] && [ -n "$SSL_KEY" ]; then
    cat > "$SSL_CONF" << EOF
server {
    listen 443 ssl;
    server_name _;

    ssl_certificate     $SSL_CERT;
    ssl_certificate_key $SSL_KEY;
    ssl_protocols       TLSv1.2 TLSv1.3;
    ssl_ciphers         HIGH:!aNULL:!MD5;

    root /usr/share/nginx/html;
    index index.html;

    location / {
        try_files \$uri \$uri/ /index.html;
    }

    location /api/ {
        proxy_pass http://127.0.0.1:8000/api/;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
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
