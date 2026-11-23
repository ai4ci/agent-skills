Rapid prototyping is required for all non-trivial features. This includes pre-existing features where re-implemention of existing components as a "archaeological prototype" in a simpler standalone framework are the basis for test data to test existing code.

## The purposes of a prototype are:

1. **A design aid**: to allow the developer to evaluate your proposals for the design of a feature by actually trying them out, and rapidly iterate on requirements without impacting the code codebase. Prototypes form part of the design documentation and are retained but not used in the implementation.
2. **A test specification:** prototypes to allow the generation of test data and inform test script authoring. They help identify edge cases and gotchas.
3. **Documentation:** working example of mathematical models.
4. **A reference implementation:** A known working benchmark which can be tested against.
5. **Develop technical approaches:** Mock specific uses of a tool or utility to make sure it behaves in an expected way (in certain cases).
6. **Generate test data:** Prototypes can operate on test inputs and produce test outputs that can be combined as test data for automated testing.

**Prototypes are standalone** (with mocked interfaces if necessary.)

**DO NOT** try and recreate the functionality of the whole application in a prototype.

* Single page HTML with javascript is a good option for UI.
* Bash script for CLI tools.
* R markdown for data heavy or mathematical model prototying.
* The `design/prototypes` directory can include supporting libraries but make sure they are appropriately included in a `.gitignore` file.
* Test data

Steps:

1. Gather preliminary feature requirements, or analyse existing implementation code and document a draft set of features.
2. Develop an initial draft test script.
3. Implement a minimal prototype that implements the draft features.
4. Document design decisions and rationale in the prototype (as comments or ideally in R markdown).
5. Develop draft test inputs.
6. Developer uses the prototype, update feature description and test script.
7. Repeat steps 3-6 until requirements are clear and prototype is stable and test inputs are clear.
8. Write final test scripts for the feature, extract test outputs from prototype.
9. Combine test inputs and outputs into final test data and link to from from prototype ("CREATES_DATA")
10. Link prototype to feature(s) ("HAS_FEATURE") and vice versa ("HAS_PROTOTYPE")
11. Link test-scripts to feature(s) ("HAS_FEATURE") and vice versa ("HAS_TEST")

Make sure features, test scripts, prototypes have appropriate [design documentation](../design-documentation.md) links between them.
