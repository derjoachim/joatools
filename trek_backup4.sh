#!/bin/bash
# Joachim van de Haterd, november/december 2006
# JH: Version 2 was written July 2007
# JH: Version 3 was written March 2011. The old disk has been replaced with a more modern container.
# JH: Version 3.5 was written April 2014. Some stuff is being backed up to and from my NAS as well.
# JH: Version 4 was written December 2015. Truecrypt has been replaced by tomb.

# Checks whether an external partition was mounted
# and rsyncs both /home and /etc subdirectories.

# See https://github.com/derjoachim/joatools for more information

# @TODO: 
# - Put all subdirectories to be excluded into an array. This makes the script more configurable.
# - Put all important variables into a config file

# @Param a) Disable automatic mounting / unmounting
# @Param d /dev/partition) Manual path to HDD device
# @Param h) Show a more helpful message and exit gracefully
# @Param n) Chicken mode: do not do anything. Only show what would be done if you had shown some guts. :)
# @Param u) Disable automatic unmounting. Keeps truecrypt volume mounted upon exit.

echo "--- Starting automatic backup script ---"
echo "--- Current date is `date` ---"

#Basename of the tomb container
basename="mycontainer"

# Standard variables, to be set with optional parameters 
rsyncopt="-av --delete"
rsyncoptnfs="-Orvzl --delete"

# the name of my tomb container. Dependent on distro. 
mydevice="/path/to/$basename.tomb"
mypic="/path/to/a/nice/picture.jpg"

# the name of the mount point
mymountpoint="/path/to/mountpoint/which/contains/$basename/"
automount=1
autounmount=1

while getopts ahd:nu opt
do
    case "$opt" in
		a) echo "--- Automatic mounting disabled ---";automount=0;;
    	h)  
		echo "a : disable automatic mounting and unmounting. Useful for further fiddling."
	  	echo "d /dev/yourdevice: manual device override."
	  	echo "h : print this help message."
		echo "n : uses the -n switch in the rsync command. This essentialy means 'do nothing' and it just shows what would be done if you hadn't chickened out."
		echo "u : disable automatic unmounting. Keeps a volume mounted after making a backup."
		exit 0;;
      	d) mydevice="$OPTARG";mykey="$OPTARG.key";;
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
	exit 1
fi


# Try to mount the encrypted HDD if desired
if [ $automount = "1" ]
then
	echo ""
	echo "-- Trying to mount the encrypted container--"
    tomb exhume $mypic > /tmp/$basename.tomb.key
	tomb open $mydevice -k /tmp/$basename.tomb.key
fi


if [ -d $mymountpoint ]; then
	echo ""
	echo "--- Container mounted ---"
	echo ""
	echo "--- Collecting current package list ---"
	yaourt -Qqet > ~/package_list_mosquito
	echo ""
	echo "--- removing plugin stuff ---"
	rm -rf ~/.adobe
	rm -rf ~/.macromedia
	echo ""
	echo "--- syncing home directories ---"
	
    rsync $rsyncopt --exclude '.dbus/' --exclude '.gvfs/' --exclude '.cache' --exclude 'Video/' --exclude 'Music/' --exclude 'backups/' --exclude '.local/share/Trash/' ~ $mymountpoint
	echo ""
	echo "--- syncing etc ---"
	sudo rsync $rsyncopt /etc $mymountpoint

	# Done! Now we gracefully unmount the encrypted container
	if [[ $automount = "1" && $autounmount = "1" ]]; then
		echo ""
		echo "-- Unmounting container --"
		tomb close $basename
        rm -f /tmp/$basename.tomb.key
	fi
fi

# 20140427 : Backup important documents to my NAS 
if [ -d /net/path/to/my/nas ]; then
	echo ""
	echo "-- Backing up important documents to configured NAS --"
	rsync $rsyncoptnfs ~/Documents/ /net/path/to/my/nas 
fi

echo ""
echo "-- Done --"
