Rapid prototyping is required for all non-trivial features. This includes pre-existing features. A core idea behind this methodology is re-implemention of existing components as a retrospective prototype in a simpler framework which mirror expected functionality in a standalone way.

The purpose of a prototype are:

* **A design aid**: to allow the developer to evaluate your proposals for the design of a feature by actually trying them out, and rapidly iterate on requirements without impacting the code codebase. Prototypes form part of the design documentation and are retained but not used in the implementation.
* **A test specification:** prototypes to allow the generation of test data and inform test script authoring. They help identify edge cases and gotchas.
* **Documentation:** working example of mathematical models.
* test technical approaches (in certain cases).

Prototype in a dependency free form (with mocked interfaces if necessary.)
* Single page HTML with javascript a good option.
* Bash script for CLI tools.
* R script for data heavy or model prototying

1. Gather preliminary feature requirements, or analyse existing feature.
2. Draft a test script
3. Implement a prototype
4. Developer uses the prototype, update requirements and test script
5. Repeat if necessary
6. Write final test scripts for the feature, extract test data from prototype
