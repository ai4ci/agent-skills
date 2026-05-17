Depending on the language you should use a suite of code quality tools:

* Bash: [[bash-build]]
* Java: [[java-build]]
* Python: [[python-build]]
* R: [[r-build]]
* SQL: [[sql-build]]
* Typescript: [[typescript-build]]
* Polyglot: [[polyglot-build]]

### Establish a baseline


### Iteratively improve quality

* There often a very large number of code quality issues and prioritising ones to fix may be difficult. 
* There are likely low cost, low value quick wins in terms of ensuring all function parameters and return values are documented.
* Establish with the developer where the major pain points are in terms of bugs or desired improvements, and focus in-code commenting, retrospective prototyping, logging and improving test coverage for these areas of code. 
* Make a small number of fixes and repeat.
* Document the "why" behind technical debt (sometimes it exists for good reasons)
* 

### Maintaining quality (longer term)

As you get each aspect of code quality under control, for example no undocumented method parameters, setup git pre-commit hooks to test the codebase on every change, with a view to maintaining that quality standard.

```bash
curl -1sLf 'https://dl.cloudsmith.io/public/evilmartians/lefthook/setup.deb.sh' | sudo -E bash
sudo apt install lefthook
```

