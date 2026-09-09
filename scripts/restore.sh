#!/usr/bin/env bash
set -eo pipefail

CONTAINER_NAME="local_postgres"
DB_USER="postgres"
DB_NAME="booking_db"
BACKUP_DIR="$(dirname "$0")/../backups"

LATEST_BACKUP=$(ls -t "${BACKUP_DIR}"/backup_*.sql.gz 2>/devnull | head -n 1)

if [ -z "${LATEST_BACKUP}" ]; then
  echo "Error: No dump archive found in ${BACKUP_DIR}."
  exit 1
fi

echo "Restoring database state from: ${LATEST_BACKUP}..."

gunzip -c "${LATEST_BACKUP}" | docker exec -i "${CONTAINER_NAME}" psql -U "${DB_USER}" -d "${DB_NAME}"

echo "Restore successfully completed!"
