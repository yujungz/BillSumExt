#!/bin/bash
# BillSumExt — Let's Encrypt 证书申请（临时借用 80 端口）
#
# 80/443 都被其他服务/容器占用，本方案不碰宿主机 80/443：
#   - 仅申请证书时临时停掉占用 80 的服务供 certbot 验证，用完归还
#   - HTTPS 由 BillSumExt 容器内 nginx 提供（通过已映射的 8090 端口）
#   - 证书挂载进容器，entrypoint 自动选用
#
# 用法：
#   sudo PORT80_SERVICE=caddy bash setup-ssl.sh
# PORT80_SERVICE = 占用 80 端口的 systemd 服务名；不传则自动检测。
# 完成后访问 https://shadow.burncloud.com:8090

set -e

DOMAIN="shadow.burncloud.com"
EMAIL="13695956@qq.com"
PORT80_SERVICE="${PORT80_SERVICE:-}"
CERT_DIR="/etc/letsencrypt/live/$DOMAIN"

echo "============================================"
echo " BillSumExt — 证书申请(临时借用 80)"
echo " 完成后 HTTPS 由容器提供: https://$DOMAIN:8090"
echo "============================================"

# 1. 检测占用 80 的服务
if [ -z "$PORT80_SERVICE" ]; then
  for svc in caddy nginx apache2 httpd traefik; do
    if systemctl is-active --quiet "$svc" 2>/dev/null; then
      PORT80_SERVICE="$svc"; break
    fi
  done
fi
if [ -z "$PORT80_SERVICE" ]; then
  echo "❌ 未识别占用 80 端口的服务。"
  echo "   用 'ss -tlnp | grep :80' 查看后执行:"
  echo "   sudo PORT80_SERVICE=<服务名> bash setup-ssl.sh"
  exit 1
fi
echo "✅ 80 端口服务: $PORT80_SERVICE (仅申请时临时停用)"

# 2. 安装 certbot
command -v certbot >/dev/null || { apt-get update && apt-get install -y certbot; }

# 3. 申请证书(已存在则跳过，避免无谓停服)
if [ -f "$CERT_DIR/fullchain.pem" ]; then
  echo "✅ 证书已存在，跳过申请"
else
  echo "🔐 临时停用 $PORT80_SERVICE 以释放 80 端口供 certbot 验证..."
  systemctl stop "$PORT80_SERVICE" || true
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

# 4. 重启容器以加载挂载的正式证书
echo "🔄 重启 BillSumExt-app 以加载证书..."
docker restart BillSumExt-app 2>/dev/null || docker-compose restart billsumext-app 2>/dev/null || true

echo ""
echo "============================================"
echo " 🎉 完成！访问 https://$DOMAIN:8090"
echo ""
echo " 手工续期(临时借用 80)："
echo "   sudo PORT80_SERVICE=$PORT80_SERVICE bash renew-ssl.sh"
echo "============================================"
