#!/bin/bash
# BillSumExt — 宿主机 Nginx 反向代理 + Let's Encrypt SSL 一键配置脚本
# 在远程服务器上以 root 运行： bash setup-ssl.sh
#
# 完成后访问：https://shadow.burncloud.com（正式证书，地址栏显示锁🔒）

set -e

DOMAIN="shadow.burncloud.com"
EMAIL="13695956@qq.com"

echo "============================================"
echo " BillSumExt — SSL 反向代理配置"
echo "============================================"
echo ""

# ── 1. 检查 Docker 容器是否在运行 ──
if ! docker ps --format '{{.Names}}' | grep -q 'BillSumExt-app'; then
  echo "❌ BillSumExt-app 容器未运行，请先执行 docker-compose up -d --build"
  exit 1
fi
echo "✅ BillSumExt-app 容器运行中"

# ── 2. 安装 Nginx（如未安装） ──
if ! command -v nginx &>/dev/null; then
  echo "📦 安装 Nginx..."
  apt-get update && apt-get install -y nginx
fi
echo "✅ Nginx 已安装"

# ── 3. 安装 certbot ──
if ! command -v certbot &>/dev/null; then
  echo "📦 安装 certbot..."
  apt-get install -y certbot python3-certbot-nginx
fi
echo "✅ certbot 已安装"

# ── 4. 停止容器内的 Nginx（释放 80 端口给 certbot） ──
echo "⏸️ 暂停容器内的 Nginx（释放端口）..."
docker exec BillSumExt-app nginx -s stop 2>/dev/null || true

# ── 5. 创建临时 Nginx 配置用于证书验证 ──
cat > /etc/nginx/sites-available/billsumext-http << 'EOF'
server {
    listen 80;
    server_name shadow.burncloud.com;
    root /var/www/html;
}
EOF
ln -sf /etc/nginx/sites-available/billsumext-http /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default
nginx -t && systemctl reload nginx || nginx

# ── 6. 申请 Let's Encrypt 证书 ──
echo "🔐 申请 Let's Encrypt 证书..."
certbot --nginx -d "$DOMAIN" --email "$EMAIL" --agree-tos --non-interactive --redirect 2>&1 || {
  echo "⚠️ certbot nginx 模式失败，尝试 standalone 模式..."
  systemctl stop nginx
  certbot certonly --standalone -d "$DOMAIN" --email "$EMAIL" --agree-tos --non-interactive 2>&1
  systemctl start nginx
}

# ── 7. 如果证书申请成功 ──
if [ -f "/etc/letsencrypt/live/$DOMAIN/fullchain.pem" ]; then
  echo "✅ 证书获取成功！"

  # 创建正式的反向代理配置
  cat > /etc/nginx/sites-available/billsumext << 'EOF'
server {
    listen 80;
    server_name shadow.burncloud.com;
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name shadow.burncloud.com;

    ssl_certificate     /etc/letsencrypt/live/shadow.burncloud.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/shadow.burncloud.com/privkey.pem;
    ssl_protocols       TLSv1.2 TLSv1.3;
    ssl_ciphers         HIGH:!aNULL:!MD5;

    client_max_body_size 100m;

    location / {
        proxy_pass http://127.0.0.1:8091;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_read_timeout 7200s;
    }
}
EOF

  rm -f /etc/nginx/sites-enabled/billsumext-http
  ln -sf /etc/nginx/sites-available/billsumext /etc/nginx/sites-enabled/
  nginx -t && systemctl reload nginx
  echo ""
  echo "============================================"
  echo " 🎉 配置完成！"
  echo ""
  echo " 访问地址：https://shadow.burncloud.com"
  echo " （地址栏显示锁🔒，正式证书）"
  echo ""
  echo " 原来的 http://localhost:8091 仍可访问"
  echo "============================================"
else
  echo "❌ 证书获取失败"
  echo "请检查域名 shadow.burncloud.com 是否解析到本服务器 IP"
fi

# ── 8. 恢复容器内的 Nginx ──
docker exec BillSumExt-app nginx 2>/dev/null || true

# ── 9. 配置自动续期 ──
echo "0 3 * * * root certbot renew --quiet && systemctl reload nginx" > /etc/cron.d/certbot-renew
echo "✅ 自动续期已配置（每天凌晨 3 点检查）"
