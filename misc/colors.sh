#!/bin/bash
c_txtblk='\e[0;30m' # Black - Regular
c_txtred='\e[0;31m' # Red
c_txtgrn='\e[0;32m' # Green
c_txtylw='\e[0;33m' # Yellow
c_txtblu='\e[0;34m' # Blue
c_txtpur='\e[0;35m' # Purple
c_txtcyn='\e[0;36m' # Cyan
c_txtwht='\e[0;37m' # White
c_bldblk='\e[1;30m' # Black - Bold
c_bldred='\e[1;31m' # Red
c_bldgrn='\e[1;32m' # Green
c_bldylw='\e[1;33m' # Yellow
c_bldblu='\e[1;34m' # Blue
c_bldpur='\e[1;35m' # Purple
c_bldcyn='\e[1;36m' # Cyan
c_bldwht='\e[1;37m' # White
c_unkblk='\e[4;30m' # Black - Underline
c_undred='\e[4;31m' # Red
c_undgrn='\e[4;32m' # Green
c_undylw='\e[4;33m' # Yellow
c_undblu='\e[4;34m' # Blue
c_undpur='\e[4;35m' # Purple
c_undcyn='\e[4;36m' # Cyan
c_undwht='\e[4;37m' # White
c_bakblk='\e[40m'   # Black - Background
c_bakred='\e[41m'   # Red
c_bakgrn='\e[42m'   # Green
c_bakylw='\e[43m'   # Yellow
c_bakblu='\e[44m'   # Blue
c_bakpur='\e[45m'   # Purple
c_bakcyn='\e[46m'   # Cyan
c_bakwht='\e[47m'   # White

for k in txt bld und bak
do
	for v in blk red grn ylw blue pur cyn wht
	do
		COLOR=$(eval echo $`echo c_$k$v`)
		echo -ne "$COLOR $k$v"
	done
	echo ""
done


echo -ne "\e[00m"


		i=1
		echo
		for v in {000..255}
		do
		 	let 'i=i+1'
			if [ $i -gt 30 ]; then
				echo ""
				i=1
			fi
			echo -ne "\e[38;5;${v}m $v"
		done

