---
status: final
target-version: 0.3.0
tags: mvp
---
<!-- @required: status one of draft|final|deprecated -->
<!-- @required: target-version specified -->
<!-- @optional: tags containing comma separated list of tags. -->
<!-- N.b.  good titles might be expressed in the form "{action} {result} {object}" -->

## Description

Send a personalised greeting so the user knows we care.

<!-- N.b. This is too small to be a real feature but just as an example -->

The MVP feature of this project enables us to have an example to test. The description would provide an example of how it was to be used and what benefits it creates. This could, for example, be specified as a set of user stories.

## Success Criteria

Not so easy to describe in this trivial example.

## Links


<!-- @required: prerequisite or impacted features which are linked to from features must exist -->
* [HAS_TEST](../test-scripts/test-001-script-for-mvp.md)
<!-- @required: when a feature has a final status it must link to one or more test-scripts -->
* [HAS_PROTOTYPE](../prototypes/prototype-001-mvp.Rmd)
<!-- @optional: features link to one or more prototypes (which must exist) -->
* [HAS_INTERFACE](../external-interfaces/interface-001-mvp-ui.md) - the MVP user interface
<!-- @optional: features link to one or more external interfaces (which must exist)  -->
* [IMPLEMENTED_BY](/src/main/java/Greeter.java)
<!-- @required: A link to the implementation -->

<!-- @optional: features link to replacements when superseded -->
<!-- * [REPLACED_BY](./feat-005-new-user-greetings.md) -->
<!-- N.B. link above doesn't exist -->

<!-- @optional: any other snake case names are extracted but ignored -->
* [DEPENDS_ON](./feat-001-prints-hello-world.md) - the hello world feature is needed before we can greet someone
