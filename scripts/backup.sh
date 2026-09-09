#!/usr/bin/env bash
set -eo pipefail

CONTAINER_NAME="local_postgres"
DB_USER="postgres"
DB_NAME="booking_db"
BACKUP_DIR="$(dirname "$0")/../backups"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_FILE="${BACKUP_DIR}/backup_${TIMESTAMP}.sql.gz"

mkdir -p "${BACKUP_DIR}"

echo "Starting database extraction from container: ${CONTAINER_NAME}..."

docker exec -t "${CONTAINER_NAME}" pg_dump -U "${DB_USER}" -d "${DB_NAME}" --clean --if-exists | gzip > "${BACKUP_FILE}"

echo "Backup successful! Output saved to: ${BACKUP_FILE}"
