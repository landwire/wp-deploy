#!/bin/bash

# set workind dir and include env setup
cd "$(dirname "$0")"
source setup-bash.sh

# args
MSG=${1-'Deploy from Git'}
BRANCH=${2-'trunk'}

SRC_DIR=${BASEDIR}/git
DEST_DIR=${BASEDIR}/svn/$BRANCH
TRUNK=${BASEDIR}/svn/trunk

# make sure the destination dir exists
mkdir -p $DEST_DIR
svn add $DEST_DIR 2> /dev/null

# delete everything except .svn dirs
for file in $(find $DEST_DIR/* -not -name ".svn" -print); do
	rm -rf $file
done

# check if we need to checkout a branch
if git rev-parse --verify $BRANCH; then
	echo "Checking out the $BRANCH branch"
	git checkout $BRANCH
else
	echo "Checking out the main branch"
	git checkout main
fi

# copy everything over from git
rsync --recursive --exclude=".*" $SRC_DIR/* $DEST_DIR

# check .svnignore
for file in $(cat "$SRC_DIR/.svnignore" 2> /dev/null)
do
	rm -rf $DEST_DIR/$file
done

cd $DEST_DIR

# Transform the readme
if [ -f readme.md ]; then
	if [ -f readme.txt ]; then
		echo "Both readme.md and readme.txt found, leaving them alone."
	else
		echo "Moving readme.md to readme.txt and modifying Markdown."
		mv readme.md readme.txt
		# Use sed to
		# - eliminate all lines including and after
		#   line starting with '## Developer Information'
		# - delete all lines starting with an image
		# - eliminate <> around URLs
		# - transform headlines to WP == syntax
		sed -i '' \
		-e '/^## Developer Information/,$d' \
		-e '/\!\[/d' \
		-e 's/<\(http.*\)>/\1/' \
		-e 's/^# \(.*\)$/=== \1 ===/' \
		-e 's/^## \(.*\)$/== \1 ==/' \
		-e 's/^###* \(.*\)$/= \1 =/' \
		readme.txt
	fi
fi

# copy current version to trunk as well
echo "Copying to trunk"
rsync --recursive --exclude=".*" --delete $DEST_DIR/* $TRUNK

# check .svnignore
for file in $(cat "$SRC_DIR/.svnignore" 2> /dev/null)
do
	rm -rf $TRUNK/$file
done

cd $BASEDIR/svn

read -r -p "Count slowly to three and then press return to continue."

# svn add remove
echo "Checking svn stat"
svn stat | awk '/^\?/ {print $2}' | xargs svn add > /dev/null 2>&1
svn stat | awk '/^\!/ {print $2}' | xargs svn rm --force

svn stat

read -r -p "Commit to SVN? (y/n) " should_commit

if [ "$should_commit" = "y" ]; then
	svn ci -m "$MSG"
else
	echo "Commit Aborted!"
fi
