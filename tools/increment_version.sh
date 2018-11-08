#!/bin/bash -eu

[ "$#" -ne "1" ] && echo "usage: $0 <current version>" && exit 1

GITHUB_BRANCH=deploy

DIR=$(cd `dirname $0` && echo `git rev-parse --show-toplevel`)
NEW_VERSION=$(echo $1 | awk 'BEGIN { FS="." } { $3++; } { printf "%d.%d.%d\n", $1, $2, $3 }')-SNAPSHOT

cd $DIR

git config --global user.email "travis@travis-ci.org"
git config --global user.name "Travis CI"

# make sure no stale stuff before checkout
git reset --hard

# setup origin
git remote set-url origin https://${GITHUB_TOKEN}@github.com/${TRAVIS_REPO_SLUG}.git
git fetch 

# verify same commit as branch
A=$(git rev-parse --verify HEAD)
B=$(git rev-parse --verify origin/$GITHUB_BRANCH)

echo "Comparing $A to $B on $GITHUB_BRANCH"
if [ "$A" != "$B" ]; then exit 0; fi

# checkout branch
git checkout $GITHUB_BRANCH

# increment version
echo changing version to $NEW_VERSION
mvn org.eclipse.tycho:tycho-versions-plugin:set-version -DnewVersion=$NEW_VERSION -Dtycho.mode=maven

# push changes to branch
git commit -a --message "Next version: $NEW_VERSION" > /dev/null 2>&1
git push origin --quiet 