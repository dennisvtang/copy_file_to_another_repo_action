# Changes from original action
This github action differs from the [original action](https://github.com/dmnemec/copy_file_to_another_repo_action) in the last step. When pushing the commit it is done with `--force`. This was to fix an error I was having when running the action when the destination branch existed and had changes.

The error I encountered
```
error: failed to push some refs to REPO
hint: Updates were rejected because the remote contains work that you do not
hint: have locally. This is usually caused by another repository pushing to
hint: the same ref. If you want to integrate the remote changes, use
hint: 'git pull' before pushing again.
hint: See the 'Note about fast-forwards' in 'git push --help' for details.
```

# copy_file_to_another_repo_action
This GitHub Action copies a file from the current repository to a location in another repository

# Example Workflow
    name: Push File

    on: push

    jobs:
      copy-file:
        runs-on: ubuntu-latest
        steps:
        - name: Checkout
          uses: actions/checkout@v2

        - name: Pushes test file
          uses: dmnemec/copy_file_to_another_repo_action@main
          env:
            API_TOKEN_GITHUB: ${{ secrets.API_TOKEN_GITHUB }}
          with:
            source_file: |
              'test2.md'
              'test1.md'
              '/copy_folder'
              '/copy_files_in_folder/'
            destination_repo: 'dmnemec/release-test'
            destination_folder: 'test-dir'
            user_email: 'example@email.com'
            user_name: 'dmnemec'
            commit_message: 'A custom message for the commit'

# Variables
> This section is probably out of date, its best to reference the `action.yml` file directly.

The `API_TOKEN_GITHUB` needs to be set in the `Secrets` section of your repository options. You can retrieve the `API_TOKEN_GITHUB` [here](https://github.com/settings/tokens) (set the `repo` permissions).

* source_files: The file or directory to be moved. Uses the same syntax as the `rsync` command. Incude the path for any files not in the repositories root directory. Possible to specify multiple sources by separating them by spaces.
* destination_repo: The repository to place the file or directory in.
* destination_folder: [optional] The folder in the destination repository to place the file in, if not the root directory.
* user_email: The GitHub user email associated with the API token secret.
* user_name: The GitHub username associated with the API token secret.
* destination_branch: [optional] The branch of the source repo to update, if not "main" branch is used.
* destination_branch_create: [optional] A branch to be created with this commit, defaults to commiting in `destination_branch`
* commit_title: [optional] A custom commit title for the commit. Defaults to `Update from ${GITHUB_REPOSITORY}`
* commit_description: [optional] A custom commit description for the commit. Defaults to `Update from https://github.com/${GITHUB_REPOSITORY}/commit/${GITHUB_SHA}`
* use_rsync: [optional] Uses `rsync -avh` instead of `cp -R` to perform the base operation. Currently works as an experimental feature (due to lack of testing) but can speed up updates to large collections of files with many small changes by only syncing the changes and not copying the entire contents again. Please understand your use case before using this, and provide feedback as issues if needed.

# Behavior Notes
The action will create any destination paths if they don't exist. It will also overwrite existing files if they already exist in the locations being copied to. It will not delete the entire destination repository.
