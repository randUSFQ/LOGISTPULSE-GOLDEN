#!/usr/bin/env bash
set -euo pipefail

BASE_URL="${1:-http://localhost:8080}"

echo "=========================================="
echo " LOGISTPULSE - Infrastructure Smoke Test"
echo "=========================================="
echo

echo "[1/6] Console"

curl -fsS "$BASE_URL/" | grep -q "LOGISTPULSE"

echo "OK - Console reachable"
echo


echo "[2/6] Inventory service"

curl -fsS \
  "$BASE_URL/health/inventory" \
  > /dev/null

echo "OK - Inventory API reachable"
echo


echo "[3/6] Logistics service"

curl -fsS \
  "$BASE_URL/health/logistics" \
  > /dev/null

echo "OK - Logistics API reachable"
echo


echo "[4/6] Operations service"

curl -fsS \
  "$BASE_URL/health/operations" \
  > /dev/null

echo "OK - Operations API reachable"
echo


echo "[5/6] Fulfillment service"

curl -fsS \
  "$BASE_URL/health/fulfillment" \
  > /dev/null

echo "OK - Fulfillment API reachable"
echo


echo "[6/6] Edge routing"

for service in inventory logistics operations fulfillment; do

  HTTP_CODE=$(curl -s \
    -o /dev/null \
    -w "%{http_code}" \
    "$BASE_URL/health/$service")

  if [ "$HTTP_CODE" != "200" ]; then
    echo "ERROR - $service returned HTTP $HTTP_CODE"
    exit 1
  fi

  echo "OK - $service -> HTTP $HTTP_CODE"

done


echo
echo "=========================================="
echo " LOGISTPULSE INFRASTRUCTURE SMOKE PASSED"
echo "=========================================="
echo
echo "NOTE:"
echo "This smoke test validates infrastructure,"
echo "service availability and edge routing."
echo
echo "Database/domain integration tests are"
echo "intentionally excluded from this stage."
