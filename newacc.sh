#!/bin/sh

if [ $# -ne 2 ]
then
  echo "Usage: `basename $0` username password"
  exit $E_BADARGS
fi

rm -f .cap
rm -f captcha.png

./redtk -v -o -g >.cap || exit 12
cat .cap | xargs curl -o captcha.png || exit 13
rm -f .cap
./solve.sh captcha.png >.cap || exit 14
cat .cap | xargs -I "CAP" ./redtk -v -u $1 -p $2 -c CAP -s || exit 15
./redtk -l && rm -f captcha.png .cap
