#!/bin/sh
set -eu

server_dir=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
. "$server_dir/scripts/compose-command.sh"

services='auth realtime'
migration_overlays=compose.migrate.yaml
case " ${COMPOSE_OVERLAYS:-} " in
  *" compose.storage.yaml "*)
    services="$services storage"
    migration_overlays="$migration_overlays compose.storage-migrate.yaml"
    ;;
esac

compose up -d --no-recreate --wait $services
COMPOSE_OVERLAYS="${COMPOSE_OVERLAYS:+$COMPOSE_OVERLAYS }$migration_overlays" \
  compose run --rm --no-deps -T --name pomodoist-selfhost-migrate-manual migrate
