#! /bin/bash
# Provide basic information about the current build type
echo
echo "Travis event type: $TRAVIS_EVENT_TYPE"
echo "Current branch: $TRAVIS_BRANCH"
echo
 
# Install sfdx plugins and configure build with sfdx settings
export SFDX_AUTOUPDATE_DISABLE=false
export SFDX_USE_GENERIC_UNIX_KEYCHAIN=true
export SFDX_DOMAIN_RETRY=300
export SFDX_DISABLE_APP_HUB=true
export SFDX_LOG_LEVEL=DEBUG
mkdir sfdx
wget -qO- $URL | tar xJ -C sfdx --strip-components 1
"./sfdx/install"
export PATH=./sfdx/$(pwd):$PATH
sfdx --version
sfdx plugins --core
 
# Authenticate against correct org
if [ "$TRAVIS_BRANCH" == "LEX" ]; then
  echo $SFDX_AUTH_URL_LEX>authtravisci.txt;
elif [ "$TRAVIS_BRANCH" == "masterbackup" ]; then
  echo $SFDX_AUTH_URL_DEV>authtravisci.txt;
fi;
 
# Set the target environment for force:source:retrieve command
sfdx force:auth:sfdxurl:store -f authtravisci.txt -a targetEnvironment

#NEW
git config remote.origin.fetch "+refs/heads/*:refs/remotes/origin/*"
git fetch -q
git stash
git checkout masterbackup

# Delete the contents of force-app folder before we paste source:retrieve contents into it
echo
rm -rf force-app/main/default/*
echo
echo 'The contents of the force-app directory have been removed.'
echo "Ready to retrieve org metadata to your $TRAVIS_BRANCH branch."
echo
 
# Create variables for frequently-referenced file paths
# Recreate "classes" and "triggers" folders for retrieved metadata files
export classPath=force-app/main/default/classes
export triggerPath=force-app/main/default/triggers
sudo mkdir -p /Users/jackbarsotti/pgi_lex1/$classPath
sudo mkdir -p /Users/jackbarsotti/pgi_lex1/$triggerPath
 
# Run a source:retrieve to rebuild the contents of the force-app folder (branch specific)
echo 'Retrieving files from Salesforce, please wait...'
echo '(one blank line will be echoed below for each 5 minutes that retrieval takes)'
function bell() {
  while true; do
    echo -e "\a"
    sleep 300
  done
}
bell &
retrieved_files=$(sudo sfdx force:source:retrieve -u targetEnvironment -x manifest/package.xml) |
while read -r file; do
echo
done
#exit $?

echo
echo "All retrieved metadata files have been added to the force-app directory on your $TRAVIS_BRANCH branch."
echo
echo "Now adding and committing these changes to your $TRAVIS_BRANCH branch..."

ls /Users/jackbarsotti/pgi_lex1/force-app/main/default
ls /Users/jackbarsotti/pgi_lex1/force-app/main/default/classes

# Add changes
git config --global user.email "travis@travis-ci.org"
git config --global user.name "Travis CI"
git add force-app/.

# Git commit -m "auto-build" changes
echo
echo 'Running: git commit -m "auto-build"'
git commit -q -m "auto-build"
echo "New commit made: $(git log -1 --oneline)" 
echo
echo "All metadata files have been retrieved, and the changes have been commited to your $TRAVIS_BRANCH branch."
echo 'Run "git pull" on your local machine to update your local branch with the new changes.'
echo
echo "Build complete!"
echo

# Run a git push 
git remote add origin-masterbackup https://${GH_TOKEN}@github.com/jackbarsotti/pgi_lex1.git > /dev/null 2>&1
#git push --quiet --set-upstream origin-masterbackup masterbackup