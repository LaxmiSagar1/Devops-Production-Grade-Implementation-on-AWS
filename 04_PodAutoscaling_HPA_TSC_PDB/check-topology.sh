#!/bin/bash

echo "╔════════════════════════════════════════════════════════════════════════════╗"
echo "║              POD TOPOLOGY DISTRIBUTION REPORT                              ║"
echo "╚════════════════════════════════════════════════════════════════════════════╝"
echo ""

echo "📍 NODES AND THEIR ZONES:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
printf "%-40s %s\n" "NODE" "ZONE"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

kubectl get nodes \
  -o custom-columns='NAME:.metadata.name,ZONE:.metadata.labels.topology\.kubernetes\.io/zone' \
  --no-headers |
  sort |
  awk '{printf "%-40s %s\n", $1, $2}'

echo ""

echo "🚀 PODS DISTRIBUTION BY APPLICATION:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
printf "%-12s %-40s %-40s %s\n" "APP" "POD" "NODE" "ZONE"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

kubectl get pods -o json |
jq -r '
  .items[] |
  {
    app: (.metadata.labels["app.kubernetes.io/name"] // "unknown"),
    pod: .metadata.name,
    node: (.spec.nodeName // "NotScheduled")
  } |
  [.app, .pod, .node] |
  @tsv
' |
 tr -d '\r' | while IFS=$'\t' read -r app pod node; do

    if [ "$node" = "NotScheduled" ]; then
        zone="NotScheduled"
    else
        zone=$(kubectl get node "$node" \
          -o jsonpath='{.metadata.labels.topology\.kubernetes\.io/zone}')
    fi

    printf "%-12s %-40s %-40s %s\n" \
      "$app" "$pod" "$node" "$zone"

done | sort

echo ""

echo "📊 ZONE DISTRIBUTION SUMMARY:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

APPS=$(kubectl get pods \
  -o jsonpath='{range .items[*]}{.metadata.labels.app\.kubernetes\.io/name}{"\n"}{end}' |
  sort -u)

for app in $APPS; do

    echo ""
    echo "📦 $app:"

    for zone in us-east-1a us-east-1b us-east-1c; do

        count=$(kubectl get pods \
          -l "app.kubernetes.io/name=$app" \
          -o json |
          jq -r --arg zone "$zone" '

            .items[] |
            select(.spec.nodeName != null) |
            .spec.nodeName

          ' | tr -d '\r' |
          while read -r node; do

              kubectl get node "$node" \
                -o jsonpath='{.metadata.labels.topology\.kubernetes\.io/zone}'
              echo

          done |
          grep -c "^${zone}$"
        )

        if [ "$count" -gt 0 ]; then
            printf "  %-15s %-2d pods ✅\n" "$zone:" "$count"
        else
            printf "  %-15s %-2d pods ⚠️  (no pods in this zone)\n" "$zone:" "$count"
        fi

    done
done

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ Topology spread analysis complete!"
echo ""
echo "💡 INTERPRETATION GUIDE:"
echo "  ✅ = Pods present in this zone (good for HA)"
echo "  ⚠️  = No pods in this zone (may want to investigate)"
echo ""