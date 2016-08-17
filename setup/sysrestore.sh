#!/bin/bash

set +v 

if [ ! -d sysrestore.z ]; then
	mkdir sysrestore.z
fi

if [ ! -f sysrestore.conf ]; then
	echo "No sysrestore.conf"
	exit 1
fi

if [ "$1" = "create" ]; then


	while read line
	do
 	 if [ "$line" = "" ]; then
			continue
		fi
		SAVEFILE=${line////__}
 	 cp -v -p $line "sysrestore.z/${SAVEFILE}"
	done < sysrestore.conf

elif [ "$1" = "restore" ]; then

	pushd sysrestore.z
  for file in __*
  do
    SAVEFILE=${file//__//}
		if [ -f "$SAVEFILE" ]; then
			echo "Backing up $SAVEFILE"
			cp -v -p "$SAVEFILE" "${SAVEFILE}.orig"
			sleep 1
		fi
		echo "Installing $SAVEFILE" 
    cp -v -p "$file" "$SAVEFILE"
	done

else
	echo "$0 [create or restore]"
	exit 1
fi

exit 0
