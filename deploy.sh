#! /bin/bash
set -e
#export SFDX_AUTOUPDATE_DISABLE=false
#export SFDX_USE_GENERIC_UNIX_KEYCHAIN=true
#export SFDX_DOMAIN_RETRY=300
#export SFDX_DISABLE_APP_HUB=true
#xport SFDX_LOG_LEVEL=DEBUG
#echo 'mkdir sfdx...'
#mkdir sfdx
#wget -qO- $URL | tar xJ -C sfdx --strip-components 1
#"./sfdx/install"
export PATH=./sfdx/$(pwd):$PATH
#sfdx --version
#sfdx plugins --core
sudo mkdir -p /Users/jackbarsotti/pgi_lex1/force-app/main/default/diff
export build_head=$(git rev-parse HEAD)
git config --replace-all remote.origin.fetch +refs/heads/*:refs/remotes/origin/*
echo
echo 'Running a git fetch...'
git fetch -q
export BRANCH=$TRAVIS_BRANCH
export branch=$TRAVIS_BRANCH
echo "Travis branch: $TRAVIS_BRANCH" 
echo
export userPath=/Users/timbarsotti/pgi_lex/force-app/main/default
export diffPath=/diff/force-app/main/default
export DEPLOYDIR=/Users/jackbarsotti/pgi_lex1/force-app/main/default/diff
export classPath=force-app/main/default/classes
export triggerPath=force-app/main/default/triggers

git config --global diff.renameLimit 9999999

if [ "$BRANCH" == "LEX" ]; then
  echo 'Preparing for an incremental deployment to org...'
  for branch in $(git branch -r|grep -v HEAD); do
    git checkout -qf ${branch#origin/}
  done;
  echo
  git checkout LEX
  echo
  echo 'Running a git diff...'
  git diff --name-only master force-app/ |
  while read -r file; do
    sudo cp --parents "$file" /Users/jackbarsotti/pgi_lex1/force-app/main/default/diff 2>/dev/null
    if [[ $file == *.cls ]]; then
      find force-app/main/default/classes -samefile "$file-meta.xml" -exec sudo cp --parents -t /Users/jackbarsotti/pgi_lex1/force-app/main/default/diff {} + 2>/dev/null
    elif [[ $file == *.cls-meta.xml ]]; then
      parsedfile=${file%.cls-meta.xml}
      find force-app/main/default/classes -samefile "$parsedfile.cls" -exec sudo cp --parents -t /Users/jackbarsotti/pgi_lex1/force-app/main/default/diff {} + 2>/dev/null
    elif [[ $file == *Test.cls ]]; then
      find force-app/main/default/classes -samefile "$file-meta.xml" -exec sudo cp --parents -t /Users/jackbarsotti/pgi_lex1/force-app/main/default/diff {} + 2>/dev/null
    elif [[ $file == *Test.cls-meta.xml ]]; then
      parsedfile=${file%.cls-meta.xml}
      find force-app/main/default/classes -samefile "$parsedfile.cls" -exec sudo cp --parents -t /Users/jackbarsotti/pgi_lex1/force-app/main/default/diff {} + 2>/dev/null
    elif [[ $file == *.trigger ]]; then
      find force-app/main/default/triggers -samefile "$file-meta.xml" -exec sudo cp --parents -t /Users/jackbarsotti/pgi_lex1/force-app/main/default/diff {} + 2>/dev/null
    elif [[ $file == *.trigger-meta.xml ]]; then
      parsedfile=${file%.trigger-meta.xml}
      find force-app/main/default/triggers -samefile "$parsedfile.trigger" -exec sudo cp --parents -t /Users/jackbarsotti/pgi_lex/force-app/main/default/diff {} + 2>/dev/null
    fi
  done
  echo 'Complete.'
  echo
  echo 'Deployment directory includes:'
  echo
  ls /Users/jackbarsotti/pgi_lex1/force-app/main/default/diff/force-app/main/default
  echo
  echo 'Class files to be deployed:'
  echo
  ls /Users/jackbarsotti/pgi_lex1/force-app/main/default/diff/force-app/main/default/classes
fi;