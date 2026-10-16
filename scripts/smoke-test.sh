#!usr/bin/env bash

# Owner: Pratik Pokhrel
# Date Created: 2026/10/06
# Last Date Modified: 2026/10/06
# Description: checks the Sync-Right stack is actually healthy


set -euo pipefail

NS="${1:-syncright}"
HOST="${2:?Usage: ./smoke-test.sh [namespace] <ingress-host[:port]>}"
FAIL=0

echo "== Pods in $NS =="
if ! kubectl get pods -n "$NS" --no-headers | awk '{print $3}' | grep -qv Running; then
  echo " [OK] all pods Running"
else
  echo " [FAIL] a pod is not Running"; kubectl get pods -n "$NS"; FAIL=1
fi

echo "== Backend health via ingress =="
if curl -sk --max-time 5 "https://${HOST}/api/health" | grep -q '"success":true'; then
  echo " [OK] backend healthy"
else
  echo " [FAIL] backend health check failed"; FAIL=1
fi

tcp() {
  kubectl exec -n "$NS" deploy/backend -- node -e \
    "require('net').connect($2,'$1').on('connect',()=>process.exit(0)).on('error',()=>process.exit(1))" &>/dev/null
}
echo "== Backend to datastores =="
if tcp mongo 27017; then echo " [OK] MongoDB reachable"; else echo " [FAIL] MongoDB unreachable"; FAIL=1; fi
if tcp redis 6379; then echo " [OK] Redis reachable"; else echo " [FAIL] Redis unreachable"; FAIL=1; fi

echo
[ "$FAIL" -eq 0 ] && echo "Smoke test passed." || { echo "Smoke test failed, see above."; exit 1; }
