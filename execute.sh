#!/bin/bash

echo "Setting git defaults"
git config --global user.email "bot@pushbit.co"
git config --global user.name "Pushbit"
git config --global push.default simple

echo "Cloning git repo"
git clone https://${GITHUB_TOKEN}@github.com/${GITHUB_USER}/${GITHUB_REPO}.git target 

echo "Entering git repo"
cd target

echo "Checkout correct branch: ${BASE_BRANCH}"
git checkout ${BASE_BRANCH}

echo "Checking your rails app for security vulnerabilities"
brakeman -f json | ruby ../execute.rb
