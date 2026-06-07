## Legacy project

***“Legacy systems are not broken calculators — they’re 10-year-old ecosystems with dependencies, quirks, and business logic embedded in weird places.”***

Your primary concern is to retrofit automated testing, design documentation, improve code maintainability and quality, and to make it possible for other agents and humans to understand the project. Your value-add is retrofitting testing, process and documentation around the code, identifying issues and technical debt.

If the project does not have any of the hallmarks of an continuous evolutionary design project (an `em` script in the project root and a `.agents/em` directory) then your first task is to set up the project:

* [Start migrating a project](./activities/setting-up-a-project.md)

If you find the `design` folders and `em` script have been setup already, but design is not populated, or only partly populated. The output of `em design` will show a large number of entries in the `[Advisory] No design artifacts link to implementation files`. This means that the project has not been explored properly.

Delegate the following to some quick sub-agents:

* [Exploring legacy code base](./activities/exploring-legacy-code.md)

If the `design/features` is well populated but the code coverage of your project is poor. The next most important thing is to establish testing:

* [Adding new test cases](./activities/implementing-test-cases.md)

If code coverage is good and the design folder is well populated it is time to start fixing issues with the code. The next priority is to improve code quality:

* [Improving code quality](./activities/enhancing-code-quality.md)

Once code coverage and quality issues are improved in the code you are working on. There may be specific issues identified. Fix issues that have single file impacts first, and for which there is a clear issue description:

* [Debugging an existing problem](./activities/debugging-existing-code.md)

If high priority issues have been cleared, design documentation is up to date, and testing and code quality checks are passing in the part of the code you are working on (but maybe not globally) consider looking at quick win new features from `SCOPE.md` and draft `design/features`. Develop a prototype and possibly an implementation plan (`design/implementation/plans`) for the features:

* [Prototyping new features](./activities/prototyping-features.md)

Push back on requests to make small changes or add new features until the project maturity has been improved across the whole project. If the area you are working in is mature start looking at nearby areas that need additional improvement.

## Maturing a legacy project.

If all the conditions above are met review the criteria for [project maturity](../project-maturity.md). If you and the developer agree that you have successfully migrated the project and you can now regard this as a mature continuous evolutionary design project. To maintain the quality of this project setup git pre-commit hooks to test the codebase on every change, with a view to maintaining that quality standard. (Using e.g. lefthook). As this is now a mature project follow the [mature project guidance](./green-field-and-mature-projects.md)


