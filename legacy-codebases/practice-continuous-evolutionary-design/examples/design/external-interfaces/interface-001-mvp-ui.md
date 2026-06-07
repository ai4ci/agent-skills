---
status: final
target-version: 0.3.0
tags: mvp
---
<!-- @required: status one of draft|final|deprecated -->
<!-- @required: target-version specified -->
<!-- @optional: tags containing comma separated list of tags. -->

Static prototype example

## Interfaces:

### 1) Help messages:

**input:**

```bash
greet --help
```

**output:**

```
usage: greet [-v] [-h] [name ...]

positional arguments:
  name            The name of the person to greet

options:
  -h, --help      Show this help message and exit.
  -V, --version   Print version information and exit.
```

### 2) Additional outputs ...

etc...

## Links:

* [HAS_FEATURE](../features/feat-001-prints-hello-world.md)
* [HAS_FEATURE](../features/feat-002-greets-user-by-name.md)
<!-- @required: A link to the features implemented -->
* [IMPLEMENTED_BY](/src/main/java/Greeter.java)
<!-- @required: A link to the implementation -->
* [HAS_TEST](/design/test-scripts/test-001-script-for-mvp.md)
