#!/bin/bash

set -e
set -x

if [ -z "$INPUT_SOURCE_FILES" ]
then
  echo "Source file must be defined"
  return 1
fi

if [ -z "$INPUT_GIT_SERVER" ]
then
  INPUT_GIT_SERVER="github.com"
fi

if [ -z "$INPUT_DESTINATION_BRANCH" ]
then
  INPUT_DESTINATION_BRANCH=main
fi
OUTPUT_BRANCH="$INPUT_DESTINATION_BRANCH"

CLONE_DIR=$(mktemp -d)

echo "Cloning destination git repository"
git config --global user.email "$INPUT_USER_EMAIL"
git config --global user.name "$INPUT_USER_NAME"
# fix issue with fatal: detected dubious ownership in repository
git config --global --add safe.directory '*'
git clone --single-branch --branch $INPUT_DESTINATION_BRANCH "https://x-access-token:$API_TOKEN_GITHUB@$INPUT_GIT_SERVER/$INPUT_DESTINATION_REPO.git" "$CLONE_DIR"

if [ -n "$INPUT_RENAME" ]
then
  echo "Setting new filename: ${INPUT_RENAME}"
  DEST_COPY="$CLONE_DIR/$INPUT_DESTINATION_FOLDER/$INPUT_RENAME"
else
  DEST_COPY="$CLONE_DIR/$INPUT_DESTINATION_FOLDER"
fi

echo "Copying contents to git repo"
mkdir -p "$CLONE_DIR"/"$INPUT_DESTINATION_FOLDER"
if [ -z "$INPUT_USE_RSYNC" ]
then
  cp -R "$INPUT_SOURCE_FILES" "$DEST_COPY"
else
  echo "rsync mode detected"
  for value in $INPUT_SOURCE_FILES; do
    rsync -avrh "$value" "$DEST_COPY"
  done
fi

cd "$CLONE_DIR"

if [ -n "$INPUT_DESTINATION_BRANCH_CREATE" ]
then
  echo "Creating new branch: ${INPUT_DESTINATION_BRANCH_CREATE}"
  git checkout -b "$INPUT_DESTINATION_BRANCH_CREATE"
  OUTPUT_BRANCH="$INPUT_DESTINATION_BRANCH_CREATE"
fi

if [ -z "$INPUT_COMMIT_MESSAGE" ]
then
  INPUT_COMMIT_MESSAGE="Update from https://$INPUT_GIT_SERVER/${GITHUB_REPOSITORY}/commit/${GITHUB_SHA}"
fi

echo "Adding git commit"
git add .
if git status | grep -q "Changes to be committed"
then
  git commit --message "$INPUT_COMMIT_MESSAGE"

  if [ -n "$INPUT_USE_FORCE" ]
  then
    echo "Pushing git commit with --force"
    git push --force -u origin HEAD:"$OUTPUT_BRANCH"
  else
    echo "Pushing git commit"
    git push -u origin HEAD:"$OUTPUT_BRANCH"
  fi

else
  echo "No changes detected"
fi
