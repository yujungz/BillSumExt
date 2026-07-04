#!/bin/bash
# BillSumExt — HTTPS(443) 反向代理 + Let's Encrypt 证书
#
# 适用场景：80 端口已被其他服务长期占用。
# 本脚本宿主机 nginx 只监听 443 → 127.0.0.1:8091，不占用 80。
# 仅在申请证书时临时停掉占用 80 的服务供 certbot 验证，完成后立即归还。
#
# 用法：
#   sudo PORT80_SERVICE=caddy bash setup-ssl.sh
# PORT80_SERVICE = 占用 80 端口的 systemd 服务名(caddy / nginx / apache2 ...)
# 不传则自动尝试检测。

set -e

DOMAIN="shadow.burncloud.com"
EMAIL="13695956@qq.com"
APP_PORT=8091                       # BillSumExt 容器对外 HTTP 端口
PORT80_SERVICE="${PORT80_SERVICE:-}"
CERT_DIR="/etc/letsencrypt/live/$DOMAIN"

echo "============================================"
echo " BillSumExt — HTTPS(443) 配置"
echo "============================================"

# 1. 检查容器
if ! docker ps --format '{{.Names}}' | grep -q 'BillSumExt-app'; then
  echo "❌ BillSumExt-app 容器未运行，请先 docker-compose up -d --build"
  exit 1
fi
echo "✅ BillSumExt-app 运行中(容器端口 $APP_PORT)"

# 2. 安装 nginx + certbot
command -v nginx  >/dev/null || { apt-get update && apt-get install -y nginx; }
command -v certbot >/dev/null || apt-get install -y certbot
echo "✅ nginx + certbot 就绪"

# 3. 检测/确认占用 80 的服务
if [ -z "$PORT80_SERVICE" ]; then
  for svc in caddy nginx apache2 httpd traefik; do
    if systemctl is-active --quiet "$svc" 2>/dev/null; then
      PORT80_SERVICE="$svc"; break
    fi
  done
fi
if [ -z "$PORT80_SERVICE" ]; then
  echo "❌ 未识别占用 80 端口的服务。"
  echo "   请用 'ss -tlnp | grep :80' 查看占用 80 的进程，再执行："
  echo "   sudo PORT80_SERVICE=<服务名> bash setup-ssl.sh"
  exit 1
fi
echo "✅ 80 端口服务: $PORT80_SERVICE (仅申请证书时临时停用，用完归还)"

# 4. 申请证书(仅在不存在时；已存在则跳过，避免无谓停服)
if [ -f "$CERT_DIR/fullchain.pem" ]; then
  echo "✅ 证书已存在，跳过申请"
else
  echo "🔐 临时停用 $PORT80_SERVICE 以释放 80 端口供 certbot 验证..."
  systemctl stop "$PORT80_SERVICE" || true
  # 异常退出时也归还 80
  trap 'systemctl start "$PORT80_SERVICE" 2>/dev/null || true' EXIT

  set +e
  certbot certonly --standalone -d "$DOMAIN" --email "$EMAIL" --agree-tos --non-interactive 2>&1
  CERTBOT_EXIT=$?
  set -e

  echo "🔁 归还 80 端口给 $PORT80_SERVICE..."
  systemctl start "$PORT80_SERVICE" || true
  trap - EXIT

  if [ "$CERTBOT_EXIT" -ne 0 ] || [ ! -f "$CERT_DIR/fullchain.pem" ]; then
    echo "❌ 证书申请失败(exit $CERTBOT_EXIT)。请确认 $DOMAIN 已解析到本机且外网可达 80。"
    exit 1
  fi
  echo "✅ 证书获取成功"
fi

# 5. 配置 nginx：只监听 443 反代到容器，不配置 80(80 归原服务)
cat > /etc/nginx/sites-available/billsumext << EOF
server {
    listen 443 ssl http2;
    server_name $DOMAIN;

    ssl_certificate     $CERT_DIR/fullchain.pem;
    ssl_certificate_key $CERT_DIR/privkey.pem;
    ssl_protocols       TLSv1.2 TLSv1.3;
    ssl_ciphers         HIGH:!aNULL:!MD5;

    client_max_body_size 100m;

    location / {
        proxy_pass http://127.0.0.1:$APP_PORT;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_read_timeout 7200s;
    }
}
EOF
rm -f /etc/nginx/sites-enabled/default
ln -sf /etc/nginx/sites-available/billsumext /etc/nginx/sites-enabled/

# 6. 启动 nginx(若已在跑则 reload；确保不占 80)
nginx -t
if pgrep -x nginx >/dev/null 2>&1; then
  nginx -s reload
else
  systemctl restart nginx || nginx
fi
echo "✅ nginx 已启动(仅监听 443 → 127.0.0.1:$APP_PORT，不占用 80)"

echo ""
echo "============================================"
echo " 🎉 完成！访问 https://$DOMAIN"
echo ""
echo " 手工续期(临时借用 80)："
echo "   sudo PORT80_SERVICE=$PORT80_SERVICE bash renew-ssl.sh"
echo "============================================"
