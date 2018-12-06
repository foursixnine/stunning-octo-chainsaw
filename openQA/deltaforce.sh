#!/bin/bash
set -x

OSAUTOINST="https://github.com/os-autoinst/os-autoinst"
OPENQA="https://github.com/os-autoinst/openQA"

get_git_hash() {
    zypper info $1 | grep Version | sed -E 's=.*\.([[:alnum:]]+)-.*=\1=g'
}

PROJECT='os-autoinst'
git clone "${OSAUTOINST}.git" || true
cd $PROJECT
HASH=`get_git_hash $PROJECT`
echo `git shortlog $1..$HASH | grep Merge | sed 's=^.*#\(.*\) from.*='$OSAUTOINST'/pull/\1=g' | xargs -I {} nokogiri -e 'puts " * {} - " + $_.xpath("//title").text.split("·")[0]' {} |tee ../output.txt`

cd ..

PROJECT='openQA'
git clone "${OPENQA}.git" || true
cd $PROJECT
HASH=`get_git_hash $PROJECT`
echo $(git shortlog $2..$HASH | grep Merge | sed 's=^.*#\(.*\) from.*='$OPENQA'/pull/\1=g' | xargs -I {} nokogiri -e 'puts " * {} - " + $_.xpath("//title").text.split("·")[0]' {} |tee -a ../output.txt)
cd ..
