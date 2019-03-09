#pg_backup.config - The main configuration file. This should be the only file which needs user modifications.
#pg_backup.sh - The normal backup script which will go through each database and save a gzipped and/or a custom format copy of the backup into a date-based directory.
#pg_backup_rotated.sh - The same as above except it will delete expired backups based on the configuration.
