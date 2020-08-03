#! /bin/bash
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
printf "%dK\n" $(ulimit -s) | numfmt --from=iec --to=none
ulimit -s
ulimit -s 9999999
echo 'new stack size and arg max:'
ulimit -s
getconf ARG_MAX
echo 'limit for number of processes:'
ulimit -u
echo 'limit for number of open files:'
ulimit -n 
echo 'number of current threads/processes:'
ls -1d /proc/*/task/* | wc -l
echo 'number of open files:'
lsof | wc -l
#cd /home/travis/build/timbarsotti/pgi_lex
git config http.postBuffer 524288000
git config --global pack.windowMemory "100m"
git config --global pack.packSizeLimit "100m"
git config --global pack.threads "1"
#the effectively usable space: (you can pass X number of bytes to any shell command...)
echo $(( $(getconf ARG_MAX) - $(env | wc -c) ))
expr `getconf ARG_MAX` - `env|wc -c` - `env|wc -l` \* 4 - 2048

# Run a git diff for the incremental build depending on checked-out branch (if-statement per branch)
#lex branch:
if [ "$BRANCH" == "LEX" ]; then
  #create tracking branch
  #removed to shorten output in travis: echo 'Your current branches: '
  #removed to shorten output in travis: echo
  for branch in $(git branch -r|grep -v HEAD); do
    #removed to shorten output in travis: echo $branch
    git checkout -qf ${branch#origin/}
  done;
  echo
  git checkout LEX
  # Copy the files from a git diff into the deploy directory
  export CHANGED_FILES=$(git diff --name-only master force-app/)
  sudo cp --parents $(git diff --name-only master force-app/) $DEPLOYDIR;
  # Show which files will be deployed in the Travis build job log
  echo
  echo 'There are changed files detected'
  echo
  #removed to shorten output in travis:
  #for FILE in $CHANGED_FILES; do
    #echo ../$FILE
  #done;
  #echo
fi;
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
 
  export CHANGED_FILES=$(git diff --name-only LEX force-app/)
  #for f in $CHANGED_FILES; do
    #sudo cp --parents $f $DEPLOYDIR;
  #done;
  sudo cp -l 99999 --parents $(git diff --name-only LEX force-app/) $DEPLOYDIR;
 
  echo
  echo 'There are changed files detected'
  echo
  #removed to shorten output in travis:
  #for FILE in $CHANGED_FILES; do
    #echo ../$FILE
  #done;
  #echo
fi;
 
# List each changed file from the git diff command
 # For any changed class or trigger file, it's associated meta data file is copied to the deploy directory (and vice versa)
for FILE in $DEPLOYDIR; do
  #removed to shorten output in travis: echo ' ';
  #removed to shorten output in travis: echo "Found changed file:`echo ' '$FILE`";
  # NOTE - naming convention used for <className>Test.cls files: "Test":
  if [[ $FILE == *Test.cls ]]; then
    find $classPath -samefile "$FILE-meta.xml" -maxdepth1 -exec sudo cp --parents "{}" $DEPLOYDIR +
    #find $classPath -samefile "$FILE-meta.xml" -maxdepth1 -exec /bin/cp --parents {} $DEPLOYDIR +
    #PAGE_SIZE*MAX_ARG_PAGES-sizeof(void *) / sizeof(void *)
    #find $classPath -samefile "$FILE-meta.xml" -exec sudo cp --parents -t $DEPLOYDIR {} +
    #sudo cp --parents "$(find $classPath -samefile "$FILE-meta.xml")"* $DEPLOYDIR;
    #removed to shorten output in travis: echo 'Copying class file to diff folder for deployment...';
    #removed to shorten output in travis: echo 'Class files that will be deployed:';
    #removed to shorten output in travis: ls $userPath$diffPath/classes;
  fi;
done;
#for FILE in $CHANGED_FILES; do
 # if [[ $FILE == *Test.cls-meta.xml ]]; then
  #  export FILE2=${FILE%.cls-meta.xml};
   # find $classPath -samefile "$FILE2.cls" -maxdepth1 | parallel sudo cp --parents "{}" $DEPLOYDIR
    #find $classPath -samefile "$FILE2.cls" -exec sudo cp --parents -t $DEPLOYDIR {} +
    #sudo cp --parents "$(find $classPath -samefile "$FILE2.cls")"* $DEPLOYDIR;
    #removed to shorten output in travis: echo 'Copying class meta file to diff folder for deployment...';
    #removed to shorten output in travis: echo 'Class files that will be deployed:';
    #removed to shorten output in travis: ls $userPath$diffPath/classes;
#done;
#for FILE in $CHANGED_FILES; do 
  #if [[ $FILE == *.cls ]]; then
    #find $classPath -samefile "$FILE2.cls" -print0 | xargs -0 sudo cp --parents {} $DEPLOYDIR \;
    #find $classPath -samefile "$FILE2.cls" -exec sudo cp --parents -t $DEPLOYDIR {} +
    #sudo cp --parents "$(find $classPath -samefile "$FILE2.cls")"* $DEPLOYDIR;
    #removed to shorten output in travis: echo 'Copying class file to diff folder for deployment...';
    #removed to shorten output in travis: echo 'Class files that will be deployed:';
    #removed to shorten output in travis: ls $userPath$diffPath/classes;
 
  #elif [[ $FILE == *.cls-meta.xml ]]; then
    #export FILE2=${FILE%.cls-meta.xml};
    #find $classPath -samefile "$FILE2.cls" | xargs -0 sudo cp --parents {} $DEPLOYDIR
    #find $classPath -samefile "$FILE2.cls" -exec sudo cp --parents -t $DEPLOYDIR {} +
    #sudo cp --parents "$(find $classPath -samefile "$FILE2.cls")"* $DEPLOYDIR;
    #removed to shorten output in travis: echo 'Copying class meta file to diff folder for deployment...';
    #removed to shorten output in travis: echo 'Class files that will be deployed:';
    #removed to shorten output in travis: ls $userPath$diffPath/classes;
 
  #elif [[ $FILE == *.trigger ]]; then
    #find $triggerPath -samefile "$FILE-meta.xml" | xargs -0 sudo cp --parents {} $DEPLOYDIR
    #find $triggerPath -samefile "$FILE-meta.xml" -exec sudo cp --parents -t $DEPLOYDIR {} +
    #sudo cp --parents "$(find $triggerPath -samefile "$FILE-meta.xml")"* $DEPLOYDIR;
    #removed to shorten output in travis: echo 'Copying trigger file to diff folder for deployment...';
    #removed to shorten output in travis: echo 'Trigger files that will be deployed:';
    #removed to shorten output in travis: ls $userPath$diffPath/triggers;
    
  #elif [[ $FILE == *.trigger-meta.xml ]]; then
    #export FILE3=${FILE%.trigger-meta.xml};
    #find $triggerPath -samefile "$FILE3.trigger" | xargs -0 sudo cp --parents {} $DEPLOYDIR
    #find $triggerPath -samefile "$FILE3.trigger" -exec sudo cp --parents -t $DEPLOYDIR {} +
    #sudo cp --parents "$(find $triggerPath -samefile "$FILE3.trigger")"* $DEPLOYDIR;
    #removed to shorten output in travis: echo 'Copying trigger meta file to diff folder for deployment...';
    #removed to shorten output in travis: echo 'Trigger files that will be deployed:';
    #removed to shorten output in travis: ls $userPath$diffPath/triggers;
  #fi;
#done;
#echo 'All changed files have been copied to their destination directories.'
#echo
 
# Make temporary folder for our <className>Test.cls files that will be parsed
#sudo mkdir -p /Users/jackbarsotti/pgi_lex/force-app/main/default/unparsedTests
#export unparsedTestsDir=/Users/jackbarsotti/pgi_lex/force-app/main/default/unparsedTests
# Search the local "classes" folder for <className>Test.cls files
#export classTests=$(find $classPath -name "*Test.cls")
# Parse the <className>Test.cls filenames to remove each file's path and ".cls" ending, result: <className>Test
# Exports as a string that will be called in the deploy command in script phase IF branch is dev or qa
#export parsedList=''
#for testfiles in $classTests; do
 # sudo cp "$testfiles"* $unparsedTestsDir;
  ##export parsed=$(find $unparsedTestsDir -name "*Test.cls");
  #export parsed=${parsed##*/};
  #export parsed=${parsed%.cls*};
  #export parsedList="${parsedList}${parsed},";
#done;
 
# Finally, go back to the HEAD from the before_script phase
#echo 'Running: git checkout $build_head'
#git checkout $build_head
 
# Automatically authenticate against current branch's corresponding SalesForce org
# Create deployment variable for "sfdx:force:source:deploy RunSpecifiedTests -r <variable>" (see script phase below)
# Only validate, not deploy, when a pull request is being created
 # When a pull request is MERGED, deploy it
#if [ "$BRANCH" == "LEX" ]; then
 # echo $SFDX_AUTH_URL_LEX>authtravisci.txt;
  #if [ "$TRAVIS_EVENT_TYPE" == "pull_request" ]; then
   # export TESTLEVEL="RunSpecifiedTests -r $parsedList -c";
  #else
   # export TESTLEVEL="RunSpecifiedTests -r $parsedList";
  #fi;
#fi;
 
#if [ "$BRANCH" == "master" ]; then
 # echo $SFDX_AUTH_URL_DEV>authtravisci.txt;
  #if [ "$TRAVIS_EVENT_TYPE" == "pull_request" ]; then
  #  export TESTLEVEL="RunSpecifiedTests -r $parsedList -c";
 # else
  #  export TESTLEVEL="RunSpecifiedTests -r $parsedList";
  #fi;
#fi;

# Store our auth-url for our targetEnvironment alias for deployment
#sfdx force:auth:sfdxurl:store -f authtravisci.txt -a targetEnvironment
 
# Create error message to account for potential deployment failure
#export deployErrorMsg='There was an issue deploying. Check ORG deployment status page for details'

# Run apex tests and deploy apex classes/triggers
#sfdx force:org:display -u targetEnvironment
#echo 'skipping deployment'
#sfdx force:source:deploy -w 10 -p $DEPLOYDIR -l $TESTLEVEL -u targetEnvironment
#echo
 
# Failure message if deployment fails
#if [ TRAVIS_TEST_RESULT != 0 ]; then
  #echo $deployErrorMsg;
  #echo
#fi;
