#!/bin/bash


#su postgres
for i in `seq 1 100000`;
        do
                echo $i
		psql -h 192.168.2.230 -p 5432 -U postgres facetone -c "insert into hapgsql values ($i,'$i')"
       #         echo "insert into test values ('$i','abc$i');"
		sleep 10 
        done

