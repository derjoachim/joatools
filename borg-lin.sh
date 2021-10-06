#!/usr/bin/env bash

# Loosely based on https://nuxx.net/files/backupscripts/borgbackup.sh.txt

set -eu

source ~/.borg-lin

# Example command
# borg create --stats /run/media/joachim/lin/borg/phantom::{hostname}-{now:%Y-%m-%dT%H:%M:%S.%f} ~/Documents ~/.config ~/src ~/Downloads


# Initialize the backup; not needed for routine work.
# $BORG_EXEC init --encryption=repokey-blake2

echo "Beginning borg create"
# Do the backup.
$BORG_EXEC					\
	create 					\
	--stats					\
	--progress				\
	--exclude-from $BORG_EXCLUDE_FILE	\
	::{hostname}-{now:%Y-%m-%dT%H:%M:%S}	\
	~ 					

echo "Running borg create"

echo "Completed borg create"

echo "Beginning borg prune"

# Clean up the old backups.
$BORG_EXEC					\
	prune					\
	--stats					\
	--list					\
	--keep-daily=7				\
	--keep-weekly=4				\
	--keep-monthly=1			

echo "Running borg prune"

echo "Completed borg prune"

echo "Backup Complete"
