You've been asked to improve the testing of a legacy project or implement continuous integration and testing. You may be retrofitting tests to existing production code.

## Before starting

- [ ] Make sure there is a clear point to revert to if everything goes wrong (git commit, or new branch)
- [ ] Check for existing syntax & formatting and type checking and code duplication issues
- [ ] Check existing documentation consistency
- [ ] Clarify with the developer if the production code is working as expected before you start, or whether there are .

## Step 1: identify test subject

If you haven't been given specific instructions what to generate testing for follow the [establish high priority](./establish-priorities.md) guide.

## Step 2: Document feature (if not already)

* Feature under test must have a corresponding `design/feature` entry.
* Insert design documentation links from design feature to production code ("IMPLEMENTED_BY") if they do not already exist.

## Step 3: Consider archaeological prototype or interface specification

* You should be planning to [implement a prototype](./prototyping-features.md) under most circumstances.

* Skip prototyping only if we have an obvious set of test data we can use AND the functionality under test is trivial.

## Step 4: Generate test data.

* Use the prototype to generate a thorough set of test inputs
* create a design documentation link to this test data from the prototype ("CREATES_DATA").
* Alternatively generate the test data from scratch if no prototype.
* If the function is externally facing then test data should test missing and anomalous inputs as well as expected behaviour.

## Step 5: Write test script

* Describe the step by step process of the test.
* Create a design documentation link from the test script to the feature under test ("USES_DATA"), and to the test data used.

## Step 6: Implement test script as designed

* Write the test code
* Create design documentation link to the test-script ("IMPLEMENTS") and test data.
* Based test code on the test script and not the production code.

## Step 7:

* Run the tests; inspect failures and validate if the failure is a bug in the test, test script or data, before assuming it is a defect in the production code.
* Fix issues in the test, test script or data and repeat **UP TO 3 TIMES** before seeking help from the developer.
* Raise an issue for defects in production code, and create a design document link ("REPRODUCES") between test code and issue.
* Failing tests are a possible outcome.
* **DO NOT** fix genunine issues in production code at this stage.

## After completion

- [ ] Check there are no new syntax & formatting, and type checking, and code duplication issues
- [ ] Use the [change analysis script](../../scripts/analyse-change.R) to identify design documentation that needs changing
- [ ] Update user guides and skills to match change
- [ ] Bump version numbers
- [ ] Commit changes

## General principles:

### Test structure

- Setup: Puting the overall test system in the state needed to run the test, is often a common problem accross test. Create and maintain "test utilities" for common setup and teardown tasks.
- Unit test: keep each test focused on only the results necessary to validate its test
- Validation: Ensure the results of the test are correct. These results may include explicit outputs captured during execution or state changes in the UUT.
- design time-related tests to allow tolerance for execution in non-real time operating systems, allow a 5-10 percent margin for late execution to reduces the potential number of false negatives in test execution.
- treat test code with the same respect as production code. Test code must work correctly for both positive and negative cases, last a long time, and be readable and maintainable.

### Practices to avoid, or "anti-patterns"

- Having test cases depend on system state manipulated from previously executed test cases (i.e., you should always start a unit test from a known and pre-configured state).
- Dependencies between test cases. A test suite where test cases are dependent upon each other is brittle and complex. Execution order should not be presumed. Basic refactoring of the initial test cases or structure of the UUT causes a spiral of increasingly pervasive impacts in associated tests.
- Interdependent tests. Interdependent tests can cause cascading false negatives. A failure in an early test case breaks a later test case even if no actual fault exists in the UUT, increasing defect analysis and debug efforts.
- Testing precise execution, timing or performance.
- Building "all-knowing oracles". An oracle that inspects more than necessary is more expensive and brittle over time. This very common error is dangerous because it causes a subtle but pervasive time sink across the complex project.
- Testing implementation details.
- Slow running tests.
