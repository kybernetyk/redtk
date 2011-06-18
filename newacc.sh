#!/bin/sh

./neg -v -o -g |xargs curl -o captcha.png && ./solve.sh captcha.png |xargs -I "CAP" ./neg -v -u $1 -p $2 -c CAP -s && ./neg -l 
