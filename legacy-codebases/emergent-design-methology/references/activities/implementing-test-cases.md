
Implement continuous integration and testing

Legacy environments don’t always have robust pipelines — but they must be able to:

- Run unit and integration tests
- Validate AI-generated PRs
- Automate rollback if something breaks

### Test structure

- Setup: Put the unit under test (UUT) or the overall test system in the state needed to run the test.
- Execution: Trigger/drive the UUT to perform the target behavior and capture all output, such as return values and output parameters. This step is usually very simple.
- Validation: Ensure the results of the test are correct. These results may include explicit outputs captured during execution or state changes in the UUT.
- Cleanup: Restore the UUT or the overall test system to the pre-test state. This restoration permits another test to execute immediately after this one. In some cases, in order to preserve the information for possible test failure analysis, the cleanup should be starting the test just before the test's setup run.

### Individual best practices

- separate common set-up and tear-down logic into test support services utilized by the appropriate test cases, to keep each `test oracle` focused on only the results necessary to validate its test
- design time-related tests to allow tolerance for execution in non-real time operating systems. The common practice of allowing a 5-10 percent margin for late execution reduces the potential number of false negatives in test execution.
- treat test code with the same respect as production code. Test code must work correctly for both positive and negative cases, last a long time, and be readable and maintainable.

### Practices to avoid, or "anti-patterns"

- Having test cases depend on system state manipulated from previously executed test cases (i.e., you should always start a unit test from a known and pre-configured state).
- Dependencies between test cases. A test suite where test cases are dependent upon each other is brittle and complex. Execution order should not be presumed. Basic refactoring of the initial test cases or structure of the UUT causes a spiral of increasingly pervasive impacts in associated tests.
- Interdependent tests. Interdependent tests can cause cascading false negatives. A failure in an early test case breaks a later test case even if no actual fault exists in the UUT, increasing defect analysis and debug efforts.
- Testing precise execution, timing or performance.
- Building "all-knowing oracles". An oracle that inspects more than necessary is more expensive and brittle over time. This very common error is dangerous because it causes a subtle but pervasive time sink across the complex project.
- Testing implementation details.
- Slow running tests.
