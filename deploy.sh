#! /bin/bash
# Exit on error:
#set -e

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
  #ls force-app/main/default |
    #while read f; do
      #sudo cp --parents $(git diff --name-only LEX force-app/main/default/$f) $DEPLOYDIR
    #done; 

  echo '---- git diff ----'
  git diff --name-only LEX force-app/ |
  awk 'NR <= 5
    { len += length($0)+1; c[NR%5] = $0 }
    END { print("...");
        for(i=4; i>=0; i--)
          print(c[(NR-i)%5]);
        print NR, len }'
  echo '---- end diff ----'
  #exit
  git diff --name-only LEX force-app/ |
  while read -r file; do
    sudo cp --parents "$file"  /Users/timbarsotti/pgi_lex/force-app/main/default/diff
    if [[ $file == *.cls ]]; then
      find force-app/main/default/classes -samefile "$file-meta.xml" -exec sudo cp --parents -t /Users/timbarsotti/pgi_lex/force-app/main/default/diff "{}" +
    fi
  done
  echo
  echo 'git diff folder contents:'
  ls /Users/timbarsotti/pgi_lex/force-app/main/default/diff
  ls /Users/timbarsotti/pgi_lex/force-app/main/default/diff/force-app
  ls /Users/timbarsotti/pgi_lex/force-app/main/default/diff/force-app/main
  ls /Users/timbarsotti/pgi_lex/force-app/main/default/diff/force-app/main/default
  echo
  ls /Users/timbarsotti/pgi_lex/force-app/main/default/diff/force-app/main/default/classes
fi;

#find section
#for FILE in $CHANGED_FILES; do
  #if [[ $FILE == *Test.cls ]]; then
    ##find $classPath -samefile "$FILE-meta.xml" | xargs -n 1000 cp --parents {} $DEPLOYDIR
    ##sudo cp --parents "$(find $classPath -samefile "$FILE-meta.xml")"* $DEPLOYDIR;
  #fi;
#done;