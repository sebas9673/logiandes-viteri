#!/usr/bin/env bash
# Script usado en Tarea 2. Se ejecuta desde el propio balanceador.
# La hora registrada es UTC; documentar eventos de falla con el mismo reloj.
set -u
printf 'timestamp_utc,http_code,backend,latency_s\n' > "$HOME/ha-evidence.csv"
for i in $(seq 1 240); do
  r=$(curl -s --max-time 3 -w '|%{http_code}|%{time_total}' http://127.0.0.1/ || true)
  x="${r%|*}"
  status="${x##*|}"
  latency="${r##*|}"
  case "$r" in
    *'APP A'*) backend='APP_A' ;;
    *'APP B'*) backend='APP_B' ;;
    *) backend='NONE' ;;
  esac
  printf '%s,%s,%s,%s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)" "$status" "$backend" "$latency" >> "$HOME/ha-evidence.csv"
  sleep 1
done
