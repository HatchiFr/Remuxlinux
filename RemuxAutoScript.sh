#!/bin/bash
#### Description: Auto Remux Script for Bluray
#### CSV file must use : as separator
#### Written by: Hatchi - on 03-2017

REMUXPATH="/home/hatchi/test/"

function usage
{
	echo -e " One or more arguments are missing"
	echo -e " $0 --type (episodes, movie) --time (20 or 40 for episodes and movie for movie) --folder (Full Path of the Bluray Folder)"
	exit 0
}

function checkdata
{
	if [ ! -d "$BLURAYPATH" ]
		then
			echo -e "The path or the Bluray is incorrect"
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

#Check number of arguments
if [ "$#" -ne 6 ]
    then
	    usage
fi

#Check arguments
if [ "$2" != "episodes" ] && [ "$2" != "movie" ] 
    then
    	echo -e "Bad argument for attribute type"
    exit 0
fi

if [ "$4" != "20" ] && [ "$4" != "40" ] && [ "$4" != "movie" ] 
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

#EPISODES 20 Min
if [ "$2" = "episodes" ] && [ "$4" = "20" ]
	then
	BDINFO="$(docker run --rm -v "$6":"$6" hatchi/bdinfocli "$6" /tmp/)"
	BLURAYPATH="$(echo "$BDINFO" | grep -oP '(\/[A-z0-9,.;&_ \-\[\]\(\)\{\}]*)+(\/BDMV)')"
	BLURAYNAME="$(echo "$BDINFO" | grep -oP '(\()+([A-z0-9,.;&_ \-\[\]\(\)\{\}]*)+(\))')"

	#Check if the BlurayPath is good
	checkdata
	#Clear the BLURAYNAME (remove () and space)
	cleanblurayname
	PLAYLISTPATH="$BLURAYPATH/PLAYLIST/"
	
	#Extract Episodes of 20min specific data
	DATA="$(echo "$BDINFO" | grep -oP '([0-9]{1})[ ]+([0-9]{5}.MPLS)[ ]+([0]{2}:([1][9]|[2][0-5]):[0-9]{2})')"

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

#EPISODES 40 Min
if [ "$2" = "episodes" ] && [ "$4" = "40" ]
	then
	BDINFO="$(docker run --rm -v "$6":"$6" hatchi/bdinfocli "$6" /tmp/)"
	BLURAYPATH="$(echo "$BDINFO" | grep -oP '(\/[A-z0-9,.;&_ \-\[\]\(\)\{\}]*)+(\/BDMV)')"
	BLURAYNAME="$(echo "$BDINFO" | grep -oP '(\()+([A-z0-9,.;&_ \-\[\]\(\)\{\}]*)+(\))')"

	#Check if the BlurayPath is good
	checkdata
	#Clear the BLURAYNAME (remove () and space)
	cleanblurayname
	PLAYLISTPATH="$BLURAYPATH/PLAYLIST/"
	
	#Extract Episodes of 40min specific data
	DATA="$(echo "$BDINFO" | grep -oP '([0-9]{1})[ ]+([0-9]{5}.MPLS)[ ]+([0]{2}:([3][8-9]|[4][0-5]):[0-9]{2})')"

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

exit 0