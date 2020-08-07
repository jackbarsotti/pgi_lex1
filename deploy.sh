#! /bin/bash
# Exit on error:
#set -e

export SFDX_AUTOUPDATE_DISABLE=false
export SFDX_USE_GENERIC_UNIX_KEYCHAIN=true
export SFDX_DOMAIN_RETRY=300
export SFDX_DISABLE_APP_HUB=true
export SFDX_LOG_LEVEL=DEBUG
echo 'mkdir sfdx...'
mkdir sfdx
wget -qO- $URL | tar xJ -C sfdx --strip-components 1
"./sfdx/install"
export PATH=./sfdx/$(pwd):$PATH
sfdx --version
sfdx plugins --core
sudo mkdir -p /Users/timbarsotti/pgi_lex/force-app/main/default/diff
echo
echo 'Running: export build_head=$(git rev-parse HEAD)'
export build_head=$(git rev-parse HEAD)
echo "Build head: $build_head"
echo
git config --replace-all remote.origin.fetch +refs/heads/*:refs/remotes/origin/*
echo 'Running: git fetch'
git fetch
export BRANCH=$TRAVIS_BRANCH
export branch=$TRAVIS_BRANCH
echo
echo "Travis branch: $TRAVIS_BRANCH"
echo
export userPath=/Users/timbarsotti/pgi_lex/force-app/main/default
export diffPath=/diff/force-app/main/default
export DEPLOYDIR=/Users/timbarsotti/pgi_lex/force-app/main/default/diff
export classPath=force-app/main/default/classes
export triggerPath=force-app/main/default/triggers

#config section:
git config core.preloadIndex false
git config --global diff.renameLimit 9999999
ulimit -s 9999999
getconf ARG_MAX
git config http.postBuffer 524288000
git config --global pack.windowMemory "100m"
git config --global pack.packSizeLimit "100m"
git config --global pack.threads "1"
echo $(( $(getconf ARG_MAX) - $(env | wc -c) ))
expr `getconf ARG_MAX` - `env|wc -c` - `env|wc -l` \* 4 - 2048

#sudo cp section
echo 'sudo cp section:'
if [ "$BRANCH" == "master" ]; then
  for branch in $(git branch -r|grep -v HEAD); do
    git checkout -qf ${branch#origin/}
  done;
  echo
  git checkout master
  #export CHANGED_FILES=$(git diff --name-only LEX force-app/)
  #export CHANGED_FILES=$(git diff --name-only LEX force-app/main/default/classes)
  #sudo cp --parents $(git diff --name-only LEX) $DEPLOYDIR;
  #sudo cp --parents $(git diff --name-only LEX force-app/) $DEPLOYDIR;

  # ls force-app/main/default, then loop through that, then go through each folder and subtype of file, git diff
  pwd
  ls force-app/main/default |
    while read f; do
      echo $f
      cd $f
      diff=$(git diff --name-only LEX)
      sudo cp --parents "$(diff)"* $DEPLOYDIR
      cd ..
    done; 

  #git diff --name-only LEX force-app/ |
    #while read f; do
      #sudo cp --parents "$(f)"* $DEPLOYDIR
    #done;
  echo
  echo 'Find command section:'
  echo
fi;

#find section
#for FILE in $CHANGED_FILES; do
  #if [[ $FILE == *Test.cls ]]; then
    ##find $classPath -samefile "$FILE-meta.xml" | xargs -n 1000 cp --parents {} $DEPLOYDIR
    ##sudo cp --parents "$(find $classPath -samefile "$FILE-meta.xml")"* $DEPLOYDIR;
  #fi;
#done;