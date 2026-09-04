#!/usr/bin/env bash
set -euo pipefail

BASE_URL="${1:-http://localhost:8080}"

echo "=========================================="
echo " LOGISTPULSE - Domain Smoke Tests"
echo "=========================================="

echo "[1/6] Edge console"
curl -fsS "$BASE_URL/" | grep -q "LOGISTPULSE"
echo "OK - Console reachable"

echo "[2/6] Domain service health"

for service in inventory logistics operations fulfillment; do
  echo "Checking $service..."
  curl -fsS "$BASE_URL/health/$service" > /dev/null
  echo "OK - $service"
done

echo "[3/6] Inventory domain"

INVENTORY_RESPONSE=$(curl -fsS \
  "$BASE_URL/api/inventory/STORE-042")

echo "$INVENTORY_RESPONSE" | grep -q "Pollo"

echo "OK - Inventory API returned STORE-042 data"

echo "[4/6] Distribution domain"

DISTRIBUTION_RESPONSE=$(curl -fsS \
  "$BASE_URL/api/distribution/trucks")

echo "$DISTRIBUTION_RESPONSE" | grep -q "TRUCK-017"

echo "OK - Distribution API returned truck data"

echo "[5/6] Operations telemetry"

TELEMETRY_READY=false

for i in $(seq 1 20); do

  if curl -fsS \
    "$BASE_URL/api/operations/STORE-042/devices" \
    | grep -q "FREEZER"; then

    TELEMETRY_READY=true
    echo "OK - MQTT telemetry available"
    break

  fi

  echo "Waiting for telemetry... attempt $i/20"
  sleep 2

done

if [ "$TELEMETRY_READY" != "true" ]; then
  echo "ERROR - Telemetry did not become available"
  exit 1
fi

echo "[6/6] Fulfillment transaction"

ORDER_RESPONSE=$(curl -fsS \
  -X POST \
  -H "Content-Type: application/json" \
  -d '{
        "storeId":"STORE-042",
        "channel":"CI",
        "total":25.5
      }' \
  "$BASE_URL/api/fulfillment/orders")

echo "$ORDER_RESPONSE" | grep -q "ORD-"

echo "OK - Fulfillment order created"

echo
echo "=========================================="
echo " LOGISTPULSE SMOKE TEST PASSED"
echo "=========================================="
