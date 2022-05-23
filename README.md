# delete-cloudformation-stack-gh-action

Providers github action to delete CFN stack

- [Features](#features)
- [How to use](#how-to-use)

## Features

- 23-05-2022: Delete CFN stack.

## How to use

Example:

```yaml
jobs:
  cfn-delete:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
        with:
          fetch-depth: 0
          token: ${{ secrets.CICD_GITHUB_REPOSITORY_TOKEN }}
      - uses: ohpensource/delete-cloudformation-stack-gh-action@lanz/2307
        name: terraform apply
        with:
          region: "eu-west-1"
          access-key: $COR_AWS_ACCESS_KEY_ID
          secret-key: $COR_AWS_SECRET_ACCESS_KEY
          account: "88..."
          role-name: "dev-cicd-automation"
          stack-name: "my-stack-name"
```
