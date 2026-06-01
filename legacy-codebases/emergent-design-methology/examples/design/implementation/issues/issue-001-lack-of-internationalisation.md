---
status: open
since-version: 0.0.1
target-version: 0.4.0
---
<!-- @required: status one of open|closed -->
<!-- @required: target-version specified -->
<!-- @optional: tags containing comma separated list of tags. -->

<!-- issues are a summary of functional issues which maybe will come from github -->

## Issue description:

Greeter class does not allow for non-English speakers. It should detect platform
language and respond in the correct language.

## Steps to reproduce:

1. Set locale to french
2. Call greeter function

## Expected behavour:

Outputs "bonjour le monde"

## Observed behaviour:

Outputs "hello world"

