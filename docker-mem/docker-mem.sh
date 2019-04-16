#!/bin/bash
dockers=`/usr/bin/docker stats --no-stream --format "table {{.Name}}\t{{.Container}}\t{{.CPUPerc}}\t{{.MemPerc}}" | sort -k 4 -h | sed 's/%//g' | awk -F " " '{if( $4 > 95) print $1}'`
containers=($dockers)
echo $containers
echo ".........................................."
echo "Restarting Containers....................."
for container in "${containers[@]}"; do `docker restart $container`; done