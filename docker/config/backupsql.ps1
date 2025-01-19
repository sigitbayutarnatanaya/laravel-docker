# Configuration
$BACKUP_DIR = "C:\backup\database"
$MYSQL_USER = "your_user"
$MYSQL_PASSWORD = "your_password"
$DATABASE = "your_database"
$RETENTION_DAYS = 30
$DATE = Get-Date -Format "yyyyMMdd_HHmmss"

# Create backup directory if it doesn't exist
if (-not (Test-Path -Path $BACKUP_DIR)) {
    New-Item -ItemType Directory -Path $BACKUP_DIR | Out-Null
}

# Define backup filename
$BACKUP_FILE = Join-Path $BACKUP_DIR "backup_$DATE.sql.gz"
$LOG_FILE = Join-Path $BACKUP_DIR "backup.log"

try {
    # Perform backup using docker
    $result = docker exec database mysqldump "-u$MYSQL_USER" "-p$MYSQL_PASSWORD" $DATABASE | 
        & "C:\Program Files\7-Zip\7z.exe" a -si -tgzip "$BACKUP_FILE"

    # Log the backup
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "[$timestamp] Backup completed: backup_$DATE.sql.gz" | Add-Content -Path $LOG_FILE

    # Remove old backups
    Get-ChildItem -Path $BACKUP_DIR -Filter "backup_*.sql.gz" | 
        Where-Object { $_.LastWriteTime -lt (Get-Date).AddDays(-$RETENTION_DAYS) } | 
        Remove-Item -Force

    Write-Host "Backup successful: backup_$DATE.sql.gz" -ForegroundColor Green
}
catch {
    Write-Host "Backup failed! Error: $_" -ForegroundColor Red
    exit 1
}

# Must already installed 7-Zip on windows platform
# And be sure permission for execution running script enabled