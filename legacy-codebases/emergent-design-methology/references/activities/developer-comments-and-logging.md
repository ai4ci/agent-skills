You are adding or changing production code, which may be legacy code or new code, or documenting code as part of an exploration.

Emergent design projects must be easy to understand for new AI agents and human developers alike and must be easy to debug non-interactively through logging.

To help extract comments and track provenance emergent design comments shoudl be prefixed with `EM:`. e.g. `// EM: this is an emergent design java comment`. `EM` comments can be extracted from source files with `cat srcfile | grep "EM:"`. 

Follow these standards:

- [ ] Between 10-25% of active production code should be developer focused `EM` comments
- [ ] `EM` comments describe the algorithm and control flow of the program
- [ ] `EM:IMPLEMENTS` comments provide a link back to design documentation, e.g. `// EM:IMPLEMENTS: design/features/feat-001-prints-hello-world.md`
- [ ] Trace level (or debug) logging which includes current variables wherever runtime errors are likely.