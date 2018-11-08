#!/bin/bash -eu

[ "$#" -ne "1" ] && echo "usage: $0 <current version>" && exit 1

SITE_GITHUB_BRANCH=develop

DIR=$(cd `dirname $0` && echo `git rev-parse --show-toplevel`)
NEW_VERSION=$(echo $1 | awk 'BEGIN { FS=":" } { $3++;  if ($3 > 99) { $3=0; $2++; if ($2 > 99) { $2=0; $1++ } } } { printf "%02d:%02d:%02d\n", $1, $2, $3 }')-SNAPSHOT

cd $DIR

git config --global user.email "travis@travis-ci.org"
git config --global user.name "Travis CI"

git reset --hard
git checkout develop

mvn org.eclipse.tycho:tycho-versions-plugin:set-version -DnewVersion=$NEW_VERSION -Dtycho.mode=maven

git commit -a --message "Next version: $NEW_VERSION"

git remote set-url origin  https://travis:${GITHUB_TOKEN}@github.com/${TRAVIS_REPO_SLUG}.git 
#> /dev/null 2>&1
git push origin
#--quiet --set-upstream origin-pages gh-pages 