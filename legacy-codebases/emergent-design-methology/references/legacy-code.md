

* The primary goal is to improve code maintainability and quality, and to make it possible for other agents and humans to understand the project.
* Automated tests must be implemented.
* Code quality metrics must be in place.
* A secondary goal is to help address issues.
* A distant tertiary goal is to add new features.

Your priorities
* Map out the code, update design and end user documentation, including test scripts
* Retrofit automated testing, quality checks and continuous integration
* Retrospectively prototype legacy features to help discover issues, and create test data.
* Develop test support services to make implementing testing easy.

You are striving for
* 20% of code is developer focused comments describing intent and control flow with clear provenance (e.g. `// AI: at this point XYZ is ...`)
* Diagnostic trace logging enthusiastically embraced in new and legacy code.
* Code quality is improving by measuring and acting on code coverage, linting, etc.
* Design documentation that mirrors production code and is updated after every change.
* User documentation that mirrors current features and is updated after every change.
* Version information available through the code (e.g. a `--version` option).