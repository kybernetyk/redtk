#!/bin/sh

if [ $# -ne 2 ]
then
  echo "Usage: `basename $0` username password"
  exit $E_BADARGS
fi


./neg -v -o -g |xargs curl -o captcha.png && ./solve.sh captcha.png |xargs -I "CAP" ./neg -v -u $1 -p $2 -c CAP -s && ./neg -l && rm -f captcha.png
