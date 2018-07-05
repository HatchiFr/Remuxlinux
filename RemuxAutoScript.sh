#!/bin/bash
#### Description: Auto Remux Script for Bluray
#### Written by: Hatchi - on 03-2017

REMUXPATH="/home/hatchi/test/"

function usage
{
	echo -e " One or more arguments are missing"
	echo -e " $0 --type (episodes, movie, debug) --time (20, 30, 40, 50 or 60 for episodes and movie for movie) --folder (Full Path of the Bluray Folder)"
	exit 0
}

function checkdata
{
	if [ ! -d "$BLURAYPATH" ]
		then
			echo -e "The path of the Bluray is incorrect"
			exit 0
	fi
}

function cleanblurayname
{
	CLEANBLURAYNAME="$(echo "$BLURAYNAME" | tr '[:space:]' '.')"
	CLEANBLURAYNAME="$(echo "$CLEANBLURAYNAME" | sed s'/[.]$//')"
	CLEANBLURAYNAME="$(echo "$CLEANBLURAYNAME" | tr -d '(')"
	CLEANBLURAYNAME="$(echo "$CLEANBLURAYNAME" | tr -d ')')"
}

#Remove duplicated episodes (Fuc**** playlist creator)
function deduplication
{
	SIZE="$(echo "$BDINFO" |  sed '/Disc Size/d' |  grep -oP '(([0-9]{2}|[0-9]{1}),[0-9]{3},[0-9]{3},[0-9]{3})' | sed -n 'G; s/\n/&&/; /^\([ -~]*\n\).*\n\1/d; s/\n//; h; P')"
	for n in $SIZE
		do
		DEDUPLINE="$(echo "$BDINFO" | grep  $n | head -n1)"
		DEDUPBDINFO="$DEDUPBDINFO\n$DEDUPLINE"
	done
	BDINFO="$(echo -e "$DEDUPBDINFO" | uniq)"
}

#Check number of arguments
if [ "$#" -ne 6 ]
    then
	    usage
fi

#Check arguments
if [ "$2" != "episodes" ] && [ "$2" != "movie" ] && [ "$2" != "debug" ] 
    then
    	echo -e "Bad argument for attribute type"
    exit 0
fi

if [ "$4" != "20" ] && [ "$4" != "30" ] && [ "$4" != "40" ] && [ "$4" != "50" ] && [ "$4" != "60" ] && [ "$4" != "movie" ] 
    then
    	echo -e "Bad argument for attribute time"
    exit 0
fi

#MOVIE
if [ "$2" = "movie" ]
	then
	BDINFO="$(docker run --rm -v "$6":"$6" hatchi/bdinfocli "$6" /tmp/)"
	BLURAYPATH="$(echo "$BDINFO" | grep -oP '(\/[A-z0-9,.;&_ \-\[\]\(\)\{\}]*)+(\/BDMV)')"
	BLURAYNAME="$(echo "$BDINFO" | grep -oP '(\()+([A-z0-9,.;&_ \-\[\]\(\)\{\}]*)+(\))')"

	#Check if the BlurayPath is good
	checkdata
	#Clear the BLURAYNAME (remove () and space)
	cleanblurayname
	PLAYLISTPATH="$BLURAYPATH/PLAYLIST/"
	
	#Extract Movie specific data
	DATA="$(echo "$BDINFO" | grep -oP '([0-9]{1})[ ]+([0-9]{5}.MPLS)[ ]+([0][1-3]:[0-9]{2}:[0-9]{2})')"
	MPLSFILE="$(echo "$DATA" | grep -oP '([0-9]{5}.MPLS)')"
	echo "$MPLSFILE"
	
	#Create TAB and REMUX
	i=1
	for x in $MPLSFILE
	do
		#For DEBUG
		#TAB_MPLS[$i]=$x
		#Stock location
		TAB_LOCATION[$i]="$(find "$PLAYLISTPATH" -iname "$x")"
		i=$((i + 1))
	done

	mkdir -p "$REMUXPATH"/"$CLEANBLURAYNAME"

	#Remux just the first MPLS that correpsond to movie
	mkvmerge -o "$REMUXPATH/$CLEANBLURAYNAME/$CLEANBLURAYNAME.mkv" "${TAB_LOCATION[1]}"
fi

#EPISODES
if [ "$2" = "episodes" ]
	then

	if [ "$4" = "20" ]
		then
		REGHEX='([0-9]{1})[ ]+([0-9]{5}.MPLS)[ ]+([0]{2}:([1][6-9]|[2][0-7]):[0-9]{2})'
	elif [ "$4" = "30" ]
		then
		REGHEX='([0-9]{1})[ ]+([0-9]{5}.MPLS)[ ]+([0]{2}:([2][7-9]|[3][0-6]):[0-9]{2})'
	elif [ "$4" = "40" ]
		then
		REGHEX='([0-9]{1})[ ]+([0-9]{5}.MPLS)[ ]+([0]{2}:([3][6-9]|[4][0-8]):[0-9]{2})'
	elif [ "$4" = "50" ] || [ "$4" = "60" ]
		then
		REGHEX='([0-9]{1})[ ]+([0-9]{5}.MPLS)[ ]+(([0]{2}:([4][7-9]|[5][0-9]):[0-9]{2})|([0][1]:([0-3][0-9]:[0-9]{2})))'
	else
		echo "Bad argument for attribute time"
    	exit 0
	fi

	BDINFO="$(docker run --rm -v "$6":"$6" hatchi/bdinfocli "$6" /tmp/)"
	BLURAYPATH="$(echo "$BDINFO" | grep -oP '(\/[A-z0-9,.;&_ \-\[\]\(\)\{\}]*)+(\/BDMV)')"
	BLURAYNAME="$(echo "$BDINFO" | grep -oP '(\()+([A-z0-9,.;&_ \-\[\]\(\)\{\}]*)+(\))')"

	#Check if the BlurayPath is good
	checkdata
	#Clear the BLURAYNAME (remove () and space)
	cleanblurayname
	PLAYLISTPATH="$BLURAYPATH/PLAYLIST/"
	
	deduplication

	#Extract Episodes specific time
	DATA="$(echo "$BDINFO" | grep -oP "$REGHEX")"

	#Extract MPLSFILES
	MPLSFILE="$(echo "$DATA" | grep -oP '([0-9]{5}.MPLS)')"

	mkdir -p "$REMUXPATH"/"$CLEANBLURAYNAME"

	#Create TAB and REMUX
	i=1
	for x in $MPLSFILE
	do
		#For DEBUG
		#TAB_MPLS[$i]=$x
		#Stock location
		TAB_LOCATION[$i]="$(find "$PLAYLISTPATH" -iname "$x")"
		mkvmerge -o "$REMUXPATH/$CLEANBLURAYNAME/$CLEANBLURAYNAME.E$i.mkv" "${TAB_LOCATION[$i]}"
		i=$((i + 1))
	done
fi

if [ "$2" = "debug" ]
	then

	if [ "$4" = "20" ]
		then
		REGHEX='([0-9]{1})[ ]+([0-9]{5}.MPLS)[ ]+([0]{2}:([1][6-9]|[2][0-7]):[0-9]{2})'
	elif [ "$4" = "30" ]
		then
		REGHEX='([0-9]{1})[ ]+([0-9]{5}.MPLS)[ ]+([0]{2}:([2][7-9]|[3][0-6]):[0-9]{2})'
	elif [ "$4" = "40" ]
		then
		REGHEX='([0-9]{1})[ ]+([0-9]{5}.MPLS)[ ]+([0]{2}:([3][6-9]|[4][0-8]):[0-9]{2})'
	elif [ "$4" = "50" ] || [ "$4" = "60" ]
		then
		REGHEX='([0-9]{1})[ ]+([0-9]{5}.MPLS)[ ]+(([0]{2}:([4][7-9]|[5][0-9]):[0-9]{2})|([0][1]:([0-3][0-9]:[0-9]{2})))'
	else
		echo "Bad argument for attribute time"
    	exit 0
	fi

	BDINFO="$(docker run --rm -v "$6":"$6" hatchi/bdinfocli "$6" /tmp/)"
	BLURAYPATH="$(echo "$BDINFO" | grep -oP '(\/[A-z0-9,.;&_ \-\[\]\(\)\{\}]*)+(\/BDMV)')"
	BLURAYNAME="$(echo "$BDINFO" | grep -oP '(\()+([A-z0-9,.;&_ \-\[\]\(\)\{\}]*)+(\))')"

	#Check if the BlurayPath is good
	checkdata
	#Clear the BLURAYNAME (remove () and space)
	cleanblurayname
	PLAYLISTPATH="$BLURAYPATH/PLAYLIST/"
	
	deduplication

	#Extract Episodes specific time
	DATA="$(echo "$BDINFO" | grep -oP "$REGHEX")"
	echo "BDINFO :"
	echo "$BDINFO"
	echo ""
	echo "SELECTED TIME : $4"
	echo ""
	echo "SELECTED MPLS FILES WITH REGHEX :"
	echo ""
	echo "$DATA"
	echo ""
	
fi

exit 0