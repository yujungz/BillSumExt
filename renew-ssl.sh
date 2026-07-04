#!/bin/bash
# BillSumExt — Let's Encrypt 证书手工续期(临时借用 80 端口)
#
# 用法：
#   sudo PORT80_SERVICE=caddy bash renew-ssl.sh
# PORT80_SERVICE = 占用 80 端口的 systemd 服务名；不传则自动检测。
#
# 流程：临时停 80 服务 → certbot renew → 立即启动归还 80 → reload nginx

set -e

PORT80_SERVICE="${PORT80_SERVICE:-}"

if [ -z "$PORT80_SERVICE" ]; then
  for svc in caddy nginx apache2 httpd traefik; do
    if systemctl is-active --quiet "$svc" 2>/dev/null; then
      PORT80_SERVICE="$svc"; break
    fi
  done
fi
if [ -z "$PORT80_SERVICE" ]; then
  echo "❌ 未识别占用 80 端口的服务。请运行: sudo PORT80_SERVICE=<服务名> bash renew-ssl.sh"
  exit 1
fi

echo "停用 $PORT80_SERVICE 以释放 80 端口..."
systemctl stop "$PORT80_SERVICE" || true
trap 'systemctl start "$PORT80_SERVICE" 2>/dev/null || true' EXIT

certbot renew

echo "归还 80 端口给 $PORT80_SERVICE..."
systemctl start "$PORT80_SERVICE" || true
trap - EXIT

nginx -s reload 2>/dev/null || systemctl reload nginx 2>/dev/null || true
echo "✅ 续期完成，80 端口已归还 $PORT80_SERVICE"
