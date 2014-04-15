#!/bin/bash
# Joachim van de Haterd, november/december 2006
# JH: Version 2 was written July 2007
# JH: Version 3 was written March 2011. The old disk has been replaced with a more modern container.
# Checks whether an external partition was mounted
# and rsyncs both /home and /etc subdirectories.

# TODO: Array van exclude-folders

# @Param d /dev/partition) Manual path to HDD device
# @Param h) Show a more helpful message and exit gracefully
# @Param n) Chicken mode: do not do anything. Only show what would be done if you had shown some guts. :)
# @Param 

echo "--- Starting automatic backup script ---"
echo "--- Current date is `date` ---"

# Standard variables, to be set with optional parameters 
#rsyncopt="-avz --delete --compress-level=9"
rsyncopt="-av --delete"
# Truecrypt needs this option because my kernel was not compiled with a certain option built-in
truecryptopts="-m=nokernelcrypto"
# the name of my truecrypt container
#mydevice="/media/lin/mosquito"
mydevice="/run/media/joachim/lin/mosquito"
# the name of the mount point
mymountpoint="/media/truecrypt1/"
automount=1
autounmount=1

# 20070726: better parameter handling
#  http://www.shelldorado.com/goodcoding/cmdargs.html
while getopts ahd:nu opt
do
    case "$opt" in
		a) echo "--- Automatic mounting disabled ---";automount=0;;
    	h)  
		echo "a : disable automatic mounting and unmounting. Useful for further fiddling."
	  	echo "d /dev/yourdevice: manual device override."
	  	echo "h : print this help message.";
		echo "n : uses the -n switch in the rsync command. This essentialy means 'do nothing' and it just shows what would be done if you hadn't chickened out.";	
		exit 1;;
      	d) mydevice="$OPTARG";;
	 	n) echo "--- Invoking dry-run mode. Chicken! *cluck* *cluck* ---";rsyncopt="-avzn --delete";;
		u) echo "--- Automatic unmounting disabled ---";autounmount=0;;
    	\?)		# unknown flag
      		echo >&2 "usage: $0 [-n] [-d /dev/yourdevice] [-h]";exit 1;;
	esac
done
shift `expr $OPTIND - 1`

# If the container is not found, 
if [ ! -f $mydevice ]; then
	echo ""
	echo "--- ERROR: unable to find file $mydevice. Exiting... ---"
	exit 0
fi

# Try to mount the encrypted HDD if desired
if [ $automount = "1" ]
then
	echo ""
	echo "-- Trying to mount truecrypt container--"
	truecrypt $truecryptopts $mydevice $mymountpoint
fi


if [ -d /media/truecrypt1/joachim ]; then
	echo ""
	echo "--- External truecrypt container mounted ---"
	# 20110301: Save a list of installed packages in ~user 
	echo ""
	echo "--- Collecting current package list ---"
	yaourt -Q > ~/package_list_mosquito
	echo ""
	echo "--- removing plugin stuff ---"
	rm -rf ~/.adobe
	rm -rf ~/.macromedia
	echo ""
	echo "--- syncing home directories ---"
    sudo rsync $rsyncopt --exclude '.gvfs/' --exclude 'Video/' --exclude 'Music/' --exclude 'backups/' --exclude '.local/share/Trash/' ~ $mymountpoint
	echo ""
	echo "--- syncing etc ---"
	sudo rsync $rsyncopt /etc $mymountpoint

	# Done! Now we gracefully unmount the encrypted truecrypt container
	if [ $automount = "1" ]
	then
		echo ""
		echo "-- Unmounting truecrypt container --"
		truecrypt -d $mydevice
		echo "-- Done --"
	fi
fi
