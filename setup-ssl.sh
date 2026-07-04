#!/bin/bash
# BillSumExt — 宿主机 Nginx 反向代理（端口 80/443）← 容器（端口 8091）
# 在远程服务器上以 root 运行： bash setup-ssl.sh
#
# 完成后：https://shadow.burncloud.com（正式证书🔒）
#          备用 http://shadow.burncloud.com:8091（原方式）

set -e

DOMAIN="shadow.burncloud.com"
EMAIL="13695956@qq.com"

echo "============================================"
echo " BillSumExt — SSL 反向代理配置"
echo "============================================"
echo ""

# ── 1. 检查容器 ──
if ! docker ps --format '{{.Names}}' | grep -q 'BillSumExt-app'; then
  echo "❌ BillSumExt-app 容器未运行"
  exit 1
fi
echo "✅ BillSumExt-app 运行中（端口 8091）"

# ── 2. 安装 Nginx + certbot ──
if ! command -v nginx &>/dev/null; then
  apt-get update && apt-get install -y nginx
fi
if ! command -v certbot &>/dev/null; then
  apt-get install -y certbot python3-certbot-nginx
fi
echo "✅ Nginx + certbot 已安装"

# ── 3. 重要：不要动容器内的 Nginx（容器 80 ↔ 宿主机 8091，无冲突） ──
echo "→ 容器内 Nginx 保持不变（端口 8091 服务正常）"

# ── 4. 配置宿主机 Nginx 作为反向代理（端口 80/443 → 127.0.0.1:8091） ──
cat > /etc/nginx/sites-available/billsumext << 'EOF'
server {
    listen 80;
    server_name shadow.burncloud.com;

    # Let's Encrypt ACME challenge (for manual renewal)
    location /.well-known/acme-challenge/ {
        root /var/www/html;
    }

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
mkdir -p /var/www/html
rm -f /etc/nginx/sites-enabled/default
ln -sf /etc/nginx/sites-available/billsumext /etc/nginx/sites-enabled/
nginx -t && systemctl enable nginx && systemctl restart nginx
echo "✅ 宿主机 Nginx 已启动（端口 80 → 127.0.0.1:8091）"

# 验证
sleep 2
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://127.0.0.1 2>/dev/null || echo "000")
if [ "$HTTP_CODE" = "200" ] || [ "$HTTP_CODE" = "302" ] || [ "$HTTP_CODE" = "301" ]; then
  echo "✅ http://$DOMAIN 代理正常"
else
  echo "⚠️ http://$DOMAIN 返回 $HTTP_CODE，可能还需调试"
fi

# ── 5. 申请 Let's Encrypt 证书（需要 80 端口外网可访问） ──
echo ""
echo "🔐 正在申请 Let's Encrypt 证书..."
echo "（请确保 $DOMAIN 已解析到本机，且 80 端口已开放）"
echo ""

set +e
# Stop nginx first so certbot can bind port 80 directly
nginx -s stop 2>/dev/null || systemctl stop nginx 2>/dev/null || true
certbot certonly --standalone -d "$DOMAIN" --email "$EMAIL" --agree-tos --non-interactive 2>&1
CERTBOT_EXIT=$?
# Restart nginx (will be reconfigured below)
nginx 2>/dev/null || systemctl restart nginx 2>/dev/null || true
set -e

if [ $CERTBOT_EXIT -eq 0 ] && [ -f "/etc/letsencrypt/live/$DOMAIN/fullchain.pem" ]; then
  echo "✅ 证书获取成功！"

  # certbot --nginx 已自动修改了配置，写入 HTTPS server block
  # 我们只需检查并确认配置正确
  if ! grep -q "listen 443 ssl" /etc/nginx/sites-available/billsumext; then
    # 如果 certbot 没有自动添加（有时 --nginx 模式会创建单独文件）
    cat > /etc/nginx/sites-available/billsumext << 'EOF'
server {
    listen 80;
    server_name shadow.burncloud.com;

    location /.well-known/acme-challenge/ {
        root /var/www/html;
    }

    location / {
        return 301 https://$server_name$request_uri;
    }
}

server {
    listen 443 ssl http2;
    server_name shadow.burncloud.com;

    ssl_certificate     /etc/letsencrypt/live/shadow.burncloud.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/shadow.burncloud.com/privkey.pem;
    ssl_protocols       TLSv1.2 TLSv1.3;
    ssl_ciphers         HIGH:!aNULL:!MD5;

    client_max_body_size 100m;

    location /.well-known/acme-challenge/ {
        root /var/www/html;
    }

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
  fi

  nginx -t && systemctl reload nginx
  echo ""
  echo "============================================"
  echo " 🎉 全部完成！"
  echo ""
  echo " 正式访问（推荐）：https://${DOMAIN} 🔒"
  echo " 备用访问：         http://${DOMAIN}:8091"
  echo " 手工续期：certbot renew --nginx"
else
  echo ""
  echo "============================================"
  echo " ⚠️ 证书获取失败（exit code: $CERTBOT_EXIT）"
  echo ""
  echo " 常见原因："
  echo "  1. 域名 $DOMAIN 未解析到本机 IP"
  echo "  2. 服务器 80 端口未开放（防火墙/安全组）"
  echo "  3. 证书申请频率超限"
  echo ""
  echo " HTTP 反向代理仍正常工作："
  echo "  → http://${DOMAIN}（自动跳转到 127.0.0.1:8091）"
  echo ""
  echo " 修复后重新运行：bash setup-ssl.sh"
  echo "============================================"
fi
