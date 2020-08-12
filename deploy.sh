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
sudo mkdir -p /Users/jackbarsotti/pgi_lex1/force-app/main/default/diff

# Pull our local branches so they exist locally
# We are on a detached head, so we keep track of where Travis puts us
export build_head=$(git rev-parse HEAD)

# Overwrite remote.origin.fetch to fetch the remote branches (overrides Travis's --depth clone)
git config --replace-all remote.origin.fetch +refs/heads/*:refs/remotes/origin/*
echo
echo 'Running a git fetch...'
git fetch -q
echo 'Remote: Enumerating, counting, compressing objects...'
echo 'Fetching remote branches from github...'
echo 'Done.'

# Create variables for frequently-referenced file paths and branches
export BRANCH=$TRAVIS_BRANCH
export branch=$TRAVIS_BRANCH
echo "Travis branch: $TRAVIS_BRANCH" 
echo
export userPath=/Users/jackbarsotti/pgi_lex1/force-app/main/default
export diffPath=/diff/force-app/main/default
export DEPLOYDIR=/Users/jackbarsotti/pgi_lex1/force-app/main/default/diff
export classPath=force-app/main/default/classes
export triggerPath=force-app/main/default/triggers

# Ensure that "inexact rename detection" error isn't skipped due to too many files
git config --global diff.renameLimit 9999999

# Run a git diff for the incremental build depending on checked-out branch (if-statement per branch)
# LEX branch:
if [ "$BRANCH" == "LEX" ]; then
  #create tracking branch
  echo 'Preparing for an incremental deployment to org...'
  for branch in $(git branch -r|grep -v HEAD); do
    git checkout -qf ${branch#origin/}
  done;
  echo
  git checkout LEX
  echo
  echo 'Running a git diff, please wait...'
  git diff --name-only master force-app/ |
  while read -r file; do
    # Copy the files from git diff into the deploy directory
    sudo cp --parents "$file" $DEPLOYDIR 2>/dev/null
    # For any changed class or trigger file, it's associated meta data file is copied to the deploy directory (and vice versa):
    if [[ $file == *.cls ]]; then
      find $classPath -samefile "$file-meta.xml" -exec sudo cp --parents -t $DEPLOYDIR {} + 2>/dev/null
    elif [[ $file == *.cls-meta.xml ]]; then
      parsedfile=${file%.cls-meta.xml}
      find $classPath -samefile "$parsedfile.cls" -exec sudo cp --parents -t $DEPLOYDIR {} + 2>/dev/null
    elif [[ $file == *Test.cls ]]; then
      find $classPath -samefile "$file-meta.xml" -exec sudo cp --parents -t $DEPLOYDIR {} + 2>/dev/null
    elif [[ $file == *Test.cls-meta.xml ]]; then
      parsedfile=${file%.cls-meta.xml}
      find $classPath -samefile "$parsedfile.cls" -exec sudo cp --parents -t $DEPLOYDIR {} + 2>/dev/null
    elif [[ $file == *.trigger ]]; then
      find $triggerPath -samefile "$file-meta.xml" -exec sudo cp --parents -t $DEPLOYDIR {} + 2>/dev/null
    elif [[ $file == *.trigger-meta.xml ]]; then
      parsedfile=${file%.trigger-meta.xml}
      find $triggerPath -samefile "$parsedfile.trigger" -exec sudo cp --parents -t /Users/jackbarsotti/pgi_lex/force-app/main/default/diff {} + 2>/dev/null
    fi
  done
  echo 'Complete.'
  echo
  echo 'Deployment directory includes:'
  echo
  ls $DEPLOYDIR/force-app/main/default
  echo
  echo 'Class files to be deployed:'
  echo
  ls $DEPLOYDIR/force-app/main/default/classes
fi;

# Make temporary folder for our <className>Test.cls files that will be parsed
sudo mkdir -p /Users/jackbarsotti/pgi_lex1/force-app/main/default/unparsedTests
export unparsedTestsDir=/Users/jackbarsotti/pgi_lex1/force-app/main/default/unparsedTests
# Search the local "classes" folder for <className>Test.cls files
export classTests=$(find $classPath -name "*Test.cls")
# Parse the <className>Test.cls filenames to remove each file's path and ".cls" ending, result: <className>Test
# Exports as a string that will be called in the deploy command in script phase IF branch is dev or qa
export parsedList=''
for testfiles in $classTests; do
  sudo cp "$testfiles"* $unparsedTestsDir;
  export parsed=$(find $unparsedTestsDir -name "*Test.cls");
  export parsed=${parsed##*/};
  export parsed=${parsed%.cls*};
  export parsedList="${parsedList}${parsed},";
done; 

# Finally, go back to the HEAD from earlier
git config advice.detachedHead false
echo 
echo 'Running: git checkout $build_head'
git checkout $build_head

# Automatically authenticate against current branch's corresponding SalesForce org
# Create deployment variable for "sfdx:force:source:deploy RunSpecifiedTests -r <variable>" (see script phase below)
# Only validate, not deploy, when a pull request is being created
  # When a pull request is MERGED, deploy it
if [ "$BRANCH" == "LEX" ]; then
  #echo $SFDXAUTHURLLEX>authtravisci.txt;
  if [ "$TRAVIS_EVENT_TYPE" == "pull_request" ]; then
    export TESTLEVEL="RunSpecifiedTests -r $parsedList -c";
  else
    export TESTLEVEL="RunSpecifiedTests -r $parsedList";
  fi;
fi;

# Store our auth-url for our targetEnvironment alias for deployment
#sfdx force:auth:sfdxurl:store -f authtravisci.txt -a targetEnvironment

# Create error message to account for potential deployment failure
export deployErrorMsg='There was an issue deploying. Check ORG deployment status page for details.'

# Run apex tests and deploy apex classes/triggers
#sfdx force:org:display -u targetEnvironment
#sfdx force:source:deploy -w 10 -p $DEPLOYDIR -l $TESTLEVEL -u targetEnvironment
echo
echo 'Build complete. Check ORG deployment status page for details.' 