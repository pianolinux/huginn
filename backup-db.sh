#! /bin/bash
# add this to cron
#
#   0 12 * * * $HOME/huginn/backup-db.sh huginn
#
# to restore:
#   gunzip XXX.db.gz
#   docker-compose exec db pg_restore -U postgres -Fc -d huginn /backup/2018-04-29.db

YMD=$(date "+%Y-%m-%d")
SCRIPTPATH="$( cd "$(dirname "$0")" ; pwd -P )"
cd $SCRIPTPATH

# directory to save backups in
CONTAINER_BACKUP_DIR="/backup"
LOCAL_BACKUP_DIR="./backup"

# make database backup
export COMPOSE_INTERACTIVE_NO_CLI=1
docker-compose exec -T db pg_dump -U postgres -Fc -d $1 -f "$CONTAINER_BACKUP_DIR/$YMD.db"
docker-compose exec -T db chown 1000:1000 "$CONTAINER_BACKUP_DIR/$YMD.db"

# delete backup files older than 7 days
OLD=$(find $LOCAL_BACKUP_DIR -type f -mtime +7)
if [ -n "$OLD" ] ; then
        echo deleting old backup files: $OLD
        echo $OLD | xargs rm -rfv
fi
