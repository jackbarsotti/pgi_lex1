#! /bin/bash
# Exit on error:
#set -e
# Provide basic information about the current build type
echo
echo "Travis event type: $TRAVIS_EVENT_TYPE"
if [ "$TRAVIS_EVENT_TYPE" == "pull_request" ]; then
  echo "Travis pull request branch: $TRAVIS_PULL_REQUEST_BRANCH"
fi;
echo

# Install sfdx plugins and configure build with sfdx settings
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
 
# Create temporary diff folder to paste files into later for incremental deployment
 # This is the deploy directory (see below in before_script)
sudo mkdir -p /Users/timbarsotti/pgi_lex/force-app/main/default/diff
 
# Pull our local branches so they exist locally
# We are on a detached head, so we keep track of where Travis puts us
echo
echo 'Running: export build_head=$(git rev-parse HEAD)'
export build_head=$(git rev-parse HEAD)
echo "Build head: $build_head"
echo
 
# Overwrite remote.origin.fetch to fetch the remote branches (overrides Travis's --depth clone)
git config --replace-all remote.origin.fetch +refs/heads/*:refs/remotes/origin/*
echo 'Running: git fetch'
git fetch
 
# Create variables for frequently-referenced file paths and branches
export BRANCH=$TRAVIS_BRANCH
export branch=$TRAVIS_BRANCH
echo
echo "Travis branch: $TRAVIS_BRANCH"
echo
export userPath=/Users/timbarsotti/pgi_lex/force-app/main/default
export diffPath=/diff/force-app/main/default
# For a full build, deploy directory should be "- export DEPLOYDIR=force-app/main/default":
export DEPLOYDIR=/Users/timbarsotti/pgi_lex/force-app/main/default/diff
export classPath=force-app/main/default/classes
export triggerPath=force-app/main/default/triggers

#NEW:
git config core.preloadIndex false
git config --global diff.renameLimit 9999999
ulimit -s 9999999
echo 'new stack size and arg max:'
ulimit -s
getconf ARG_MAX
#cd /home/travis/build/timbarsotti/pgi_lex
git config http.postBuffer 524288000
git config --global pack.windowMemory "100m"
git config --global pack.packSizeLimit "100m"
git config --global pack.threads "1"
#the effectively usable space: (you can pass X number of bytes to any shell command...)
echo $(( $(getconf ARG_MAX) - $(env | wc -c) ))
expr `getconf ARG_MAX` - `env|wc -c` - `env|wc -l` \* 4 - 2048

#master branch
if [ "$BRANCH" == "master" ]; then
  #removed to shorten output in travis: echo 'Your current branches: '
  #removed to shorten output in travis: echo
  for branch in $(git branch -r|grep -v HEAD); do
    #removed to shorten output in travis: echo $branch
    git checkout -qf ${branch#origin/}
  done;
  echo
  git checkout master
 
  #export CHANGED_FILES=$(git diff --name-only LEX force-app/)
  #for f in $CHANGED_FILES; do
    #sudo cp --parents $f $DEPLOYDIR;
  #done;
  #sudo apt install strace
  #strace -f -v -s 99999999 -o strace.log git diff --name-only branch2 force-app/ | xargs sudo cp --parents -t "$DEPLOYDIRECTORY"
  #git diff --name-only branch2 force-app/ | xargs sudo cp --parents -t "$DEPLOYDIRECTORY"
  #strace -f -v -s 99999999 -o strace.log sudo cp --parents $(git diff --name-only LEX force-app/) $DEPLOYDIR
  pwd
  cd force-app/main/default/classes
  pwd
  sudo cp --parents $(git diff --name-only LEX $DEPLOYDIR;
  #sudo cp --parents $(git diff --name-only LEX force-app/) $DEPLOYDIR;
  #tar -cf - -C $CHANGED_FILES | tar xpf - -C /Users/timbarsotti/pgi_lex/force-app/main/default/diff
  echo
  echo 'There are changed files detected'
  echo
fi;

# List each changed file from the git diff command
 # For any changed class or trigger file, it's associated meta data file is copied to the deploy directory (and vice versa)
for FILE in $CHANGED_FILES; do
  if [[ $FILE == *Test.cls ]]; then
    #find $classPath -maxdepth1 -samefile "$FILE-meta.xml" -exec sudo cp --parents "{}" $DEPLOYDIR +
    find $classPath -samefile "$FILE-meta.xml" | xargs -n 1000 cp --parents {} $DEPLOYDIR
    find $classPath -samefile '$FILE-meta.xml' -exec cp -p {} $DEPLOYDIR \;
    #strace -f -v -s 99999999 -o strace.log find $classPath -samefile "$FILE-meta.xml" | xargs --max-args=1 cp --parents {} $DEPLOYDIR
    #find "$FILE-meta.xml" -name | xargs cp $DEPLOYDIR
    #sudo cp -uf --parents "$FILE-meta.xml" $DEPLOYDIR
    #find $classPath -name "$FILE-meta.xml"
    #find $classPath -samefile "$FILE-meta.xml" -maxdepth1 -exec /bin/cp --parents {} $DEPLOYDIR +
    #PAGE_SIZE*MAX_ARG_PAGES-sizeof(void *) / sizeof(void *)
    #find $classPath -samefile "$FILE-meta.xml" -exec sudo cp --parents -t $DEPLOYDIR {} +
    #sudo cp --parents "$(find $classPath -samefile "$FILE-meta.xml")"* $DEPLOYDIR;
  fi;
done;