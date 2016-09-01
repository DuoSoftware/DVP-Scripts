#!/bin/bash
#
## redis backup script
## usage
## redis-backup.sh port backup.dir

port=${1:-6379}
backup_dir=${2:-"/data/backup/redis"}

cli="/usr/bin/redis-cli -p $port"
rdb="/var/lib/redis/dump.rdb"

test -f $rdb || {
  echo "[$port] No RDB Found" ; exit 1
}
test -d $backup_dir || {
  echo "[$port] Create backup directory $backup_dir" && mkdir -p $backup_dir
}

# perform a bgsave before copy
echo bgsave | $cli
echo "[$port] waiting for 30 seconds..."
sleep 60
try=5
while [ $try -gt 0 ] ; do
  ## redis-cli output dos format line feed '\r\n', remove '\r'
  bg=$(echo 'info Persistence' | $cli | awk -F: '/rdb_bgsave_in_progress/{sub(/\r/, "", $0); print $2}')
  ok=$(echo 'info Persistence' | $cli | awk -F: '/rdb_last_bgsave_status/{sub(/\r/, "", $0); print $2}')
  if [[ "$bg" = "0" ]] && [[ "$ok" = "ok" ]] ; then
    dst="$backup_dir/$port-dump.$(date +%Y%m%d%H%M).rdb"
    cp $rdb $dst
    if [ $? = 0 ] ; then
      echo "[$port] redis rdb $rdb copied to $dst."

      # delete rdb created 3 days ago
      cd $backup_dir
      find . \( -name "$port-dump*" \) -mtime +3 -exec rm -f {} \;
      exit 0
    else 
      echo "[$port] >> Failed to copy $rdb to $dst!"
    fi
  fi
  try=$((try - 1))
  echo "[$port] redis maybe busy, waiting and retry in 5s..."
  sleep 5
done
exit 1
