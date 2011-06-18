#!/bin/sh
# this script will solve a captcha by using the decaptcher service 
# more info: http://decaptcher.com/
#
# set _user and _pass accordingly.

if [ ! -e ".decaptcher" ]
then
	echo ".decaptcher file does not exist! create one containing 'username password'"
	exit
fi

# decaptcher.com credentials
_user=`awk <.decaptcher '{print $1}'`
_pass=`awk <.decaptcher '{print $2}'` 

echo $_user
echo $_pass

#curl -F "function=picture2" -F "username=$_user" -F "password=$_pass" -F "pict=@captcha.png" -F "pict_to=0" -F "pict_type=0" http://poster.decaptcher.com/ |awk 'BEGIN {FS="|"}; {print $6}'

