#Remuxlinux

All you need is in that little script !

## Main features

* Make Remux for you without the need to know the good order for your episodes
* Easy to use it, scripted with love ;) 

##Description

* Everyone knows it is exhausting to make Remux manually for a whole season. 
* With my script and docker image you can automatically make the remux from the Blu-Ray, works for 20/40 min episodes and for movies.
* The result : Episodes are ordered accordingly with the Blu-Ray watching order (VOL 01 or DISC1) but aren't for the Global Season Order (E20 - E21...) that's your job ;).
* It use a docker container to escape the need of installing mono.
* Patched [BDInfoCLI-Lite](https://github.com/HatchiFr/BDInfoCLI) for easier use.
* RegHex are used to do that job !
* Full Path with no escape for space characters need double quote "".
* Example of use : ./RemuxAutoScript.sh --type movie --time movie --folder "/home/hatchi/BluRay/Pokemon The Movie(1998)/"
* Possible arguments --type episodes | movie  --time 20 | 40  movie  --folder "Full Path Of The Blu-ray Folder"
* Know Issues : BDInfo don't give you the possibility to check the presence of Bonus.

##Requirements

* Docker.
* MkvToolnix.
* Hands and Internet.

##Installation

* Download the Docker Image : docker pull hatchi/bdinfocli
* Download the script : wget https://raw.githubusercontent.com/HatchiFr/Remuxlinux/master/RemuxAutoScript.sh
* Give good authorization : chmod u+x RemuxAutoScript.sh
* Change the variable REMUXPATH in the script to your Remux storage specific path.

##ToDo

* Add Iso Support
* Check for duplicat m2ts call in playlist
* Eliminate Bonus