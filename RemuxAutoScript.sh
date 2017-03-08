#!/bin/bash
REMUXPATH="/home/hatchi/test/"

function usage
{
	echo -e "[*] ["$(date "+%T")"] Il manque un ou plusieurs arguments"
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
	CLEANBLURAYNAME="$(echo "$BLURAYNAME" | tr '[[:space:]]' '.')"
	CLEANBLURAYNAME="$(echo "$CLEANBLURAYNAME" | sed s'/[.]$//')"
	CLEANBLURAYNAME="$(echo $CLEANBLURAYNAME | tr -d '(')"
	CLEANBLURAYNAME="$(echo $CLEANBLURAYNAME | tr -d ')')"
}

#Verification du type et le nombre d'argument en conséquence
if [ "$#" -ne 6 ]
    then
	    usage
fi

#Verification des arguments
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
	BLURAYPATH="$(echo $BDINFO | grep -oP '(\/[A-z0-9,.;&_ \-\[\]\(\)\{\}]*)+(\/BDMV)')"
	BLURAYNAME="$(echo $BDINFO | grep -oP '(\()+([A-z0-9,.;&_ \-\[\]\(\)\{\}]*)+(\))')"

	#Cheack if the BlurayPath is good
	checkdata
	#Clear the BLURAYNAME (remove () and space)
	cleanblurayname
	PLAYLISTPATH="$BLURAYPATH/PLAYLIST/"
	
	#Extract Movie specific data
	DATA="$(echo $BDINFO | grep -oP '([0-9]{1})[ ]+([0-9]{5}.MPLS)[ ]+([0][1-3]:[0-9]{2}:[0-9]{2})')"
	MPLSFILE="$(echo $DATA | grep -oP '([0-9]{5}.MPLS)')"
	echo $MPLSFILE
	
	LOCATION="$(find $PLAYLISTPATH -iname $MPLSFILE)"
	echo $LOCATION

	echo $CLEANBLURAYNAME
	#mkdir $REMUXPATH/$CLEANBLURAYNAME
fi

exit 0




i=0
	for x in $DATA
	do
		TAB_ALL[$i]=$x
		i=`expr $i + 1`
		echo $x
	done