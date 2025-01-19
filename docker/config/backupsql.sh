#!/bin/bash

# Configuration
BACKUP_DIR="/backup/database"
MYSQL_USER="your_user"
MYSQL_PASSWORD="your_password"
DATABASE="your_database"
RETENTION_DAYS=30
DATE=$(date +%Y%m%d_%H%M%S)

# Create backup directory if it doesn't exist
mkdir -p $BACKUP_DIR

# Perform backup
docker exec database mysqldump -u$MYSQL_USER -p$MYSQL_PASSWORD $DATABASE | gzip > "$BACKUP_DIR/backup_$DATE.sql.gz"

# Remove backups older than retention period
find $BACKUP_DIR -name "backup_*.sql.gz" -mtime +$RETENTION_DAYS -delete

# Log the backup
echo "Backup completed: backup_$DATE.sql.gz" >> "$BACKUP_DIR/backup.log"

# Check if backup was successful
if [ $? -eq 0 ]; then
    echo "Backup successful: backup_$DATE.sql.gz"
else
    echo "Backup failed!"
    exit 1
fi