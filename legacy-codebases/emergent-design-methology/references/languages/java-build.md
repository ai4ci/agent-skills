This is the preferred set of tools to support agentic java code generation. Modern java packages may use `gradle` or `mvn`, select as appropriate for the project, in a green field project choose `mvn`.

mvnd (Maven Daemon): If relevant use `mvnd` instead of `mvn`. It keeps a background daemon warm in the runtime environment, cutting compilation times down from seconds to milliseconds.

---
## Validation tools (Java):

### 
- `Spotless` with `Palantir Java Format` can be invoked from the CLI or build tools to clean up text format logic.
- `Checkstyle` - Mature, highly customisable syntax linter. Unlike code formatters, it explicitly checks semantic layout, structural indentation, and enforces strict variable naming conventions.
- [SpotBugs](https://spotbugs.github.io/) (`spotbugs -textui -xml -output spotbugs.xml build/classes`): The modern successor to FindBugs. It runs at bytecode level to flag deep structural issues (like null pointer risks or unclosed streams) and outputs deterministic XML summaries.
### Strict Type-Checking
- javac (`mvnd clean compile` / `mvn compile` / `./gradlew compileJava`): Native compiler execution. Fails the build immediately on mismatched type assertions or illegal signatures.
### Testing & Assertion
- Maven projects use `Surefire` (`mvnd test`) with optional JSON/XML report flags (`-Dformat=json`).
- JUnit 5 CLI Launcher (`java -jar junit-platform-console-launcher.jar --reports-dir=build/test-reports`): Running tests through heavy build wrappers is slow. Launching the JUnit Console Launcher directly isolates unit testing. It dumps standard XML test reports that your automation script can quickly parse to flag failing assertions.
- Gradle projects use native test tasks (`./gradlew test`).
### Dependency & Vulnerability Scans
- OWASP Dependency-Check (`mvnd org.owasp:dependency-check-maven:check` or `./gradlew dependencyCheckAnalyze`): Scans project third-party `.jar` files for known CVE records.
- Dead/Unused dependencies: (Maven Dependency Plugin) via `mvn dependency:analyze` - Flags declared packages that are unused in code, or implicitly used packages that are missing from declarations.
### Automated Refactoring & Dependency Upgrades
- OpenRewrite Maven Plugin (`mvnd rewrite:run`): This is arguably the most powerful tool for an agent working on legacy code. Instead of manually rewriting code to upgrade syntax use OpenRewrite to safely execute pre-tested recipes (e.g., migrating from Java 8 to 11, or converting JUnit 4 tests to JUnit 5 architecture).
### Code coverage
- JaCoCo (`mvnd jacoco:report` or `./gradlew jacocoTestReport`): Standard code coverage generator. Emits metrics in structured XML, HTML, and CSV data profiles.
### Documentation consistency
- `Checkstyle (JavadocMethod rule)` & `Javadoc`: Configured inside the build tool to strictly cross-reference Javadoc string metadata (like `@param`, `@return`, `@throws`) directly against live method parameters, breaking the build if they drift out of sync.
### Code duplication
- PMD CPD : `mvnd pmd:cpd-check` or `./gradlew cpdCheck` - Scans internal directories for duplicate Java token sequences.
- [jscpd](https://github.com/kucherenko/jscpd) : `bunx jscpd /path/to/source` or `bunx jscpd --pattern "src/**/*.java"`
### Profiling
- JDK Flight Recorder (JFR): Built natively into the modern Java runtime. Zero-overhead production profiling. Executed on a standard run: `java -XX:StartFlightRecording=duration=60s,filename=profile.jfr -jar app.jar`.  Analyse with `jfr view <view-name> recording.jfr` or `jcmd <pid> JFR.view <view-name>` for live processes. Three view categories: **JVM** (`gc-configuration`, `heap-configuration`), **Environment** (`cpu-load`, `system-processes`), **Application** (`allocation-by-thread`, `memory-leaks-by-class`). Prioritize diagnostic views: `gc-pause-phases`, `native-memory-committed`, `thread-cpu-load`, `exception-count`, `object-statistics`. Use `jfr summary` for quick overview; `jfr print --json` for machine-readable event extraction.


---
## Project Setup (Java):

Here is the complete summary of all dependencies and configuration files required to enable strict Java compilation linting, synchronized Javadoc validation, Spotless formatting, and Markdown documentation generation using Maven or Gradle.
### 1. Dependency Installation

Java builds embed plugins directly inside the main workspace configuration tree rather than requiring global system node layers.
#### For Maven projects (`pom.xml` configurations):

Add the central tool chains to your `<plugins>` array:

```xml
<plugins>
    <!-- Spotless Formatter Plugin -->
    <plugin>
        <groupId>com.diffplug.spotless</groupId>
        <artifactId>spotless-maven-plugin</artifactId>
        <version>2.43.0</version>
        <configuration>
            <java>
	            <palantirJavaFormat>
					<version>2.90.0</version>
					<style>PALANTIR</style>
					<formatJavadoc>true</formatJavadoc>
				</palantirJavaFormat>
				<!-- Alternative when project has an eclipse formatter xml. -->
				<!-- <eclipse>
					<version>4.26</version>
					<file>${project.basedir}/eclipse-formatter.xml</file>
				</eclipse> -->
			</java>
        </configuration>
    </plugin>
    <!-- Checkstyle Validation Plugin -->
    <plugin>
        <groupId>org.apache.maven.plugins</groupId>
        <artifactId>maven-checkstyle-plugin</artifactId>
        <version>3.3.1</version>
        <configuration>
            <configLocation>checkstyle.xml</configLocation>
            <consoleOutput>true</consoleOutput>
            <failsOnError>true</failsOnError>
        </configuration>
    </plugin>
    <plugin>
		<groupId>com.github.spotbugs</groupId>
		<artifactId>spotbugs-maven-plugin</artifactId>
		<version>4.9.8.0</version>
	</plugin>
</plugins>
```

#### For Gradle projects (`build.gradle` configurations):

```groovy
plugins {
    id 'java'
    id 'com.diffplug.spotless' version '6.25.0'
    id 'checkstyle'
}

spotless {
    java {
        googleJavaFormat('1.22.0').aosp()
    }
}

checkstyle {
    toolVersion = '10.15.0'
    configFile = file('checkstyle.xml')
}
```

---

### 2. Configuration Files

#### `checkstyle.xml`

This file configures Checkstyle to parses code methods and throws severe compilation errors if a developer alters a parameter but forgets to update the matching `@param` block inside the Javadoc.

```xml
<?xml version="1.0"?>
<!DOCTYPE module PUBLIC "-//Checkstyle//DTD Checkstyle Configuration 1.3//EN" "https://checkstyle.org">
<module name="Checker">
    <property name="severity" value="error"/>
    <module name="TreeWalker">
        <!-- Strictly checks Javadoc against live methods -->
        <module name="JavadocMethod">
            <property name="accessModifiers" value="public, protected, package, private"/>
            <property name="validateThrows" value="true"/>
        </module>
        <!-- Ensures all parameters match names exactly -->
        <module name="MissingDeprecated"/>
        <module name="NonEmptyAtclauseDescription"/>
    </module>
</module>
```

## `spotless.eclipseformat.ignore`

A single source of truth configuration to bypass files from Spotless validation routines (acts exactly like `.prettierignore`). Place it in the root folder.

```text
# Ignore build artifact zones
target/
build/
.gradle/
bin/
docs/
```

---

## 3. Running the Ecosystem Commands

- `mvn checkstyle:check` — Validates Java Javadoc syntax and enforces naming schemes.
- `mvn spotless:apply` — Instantly reformats Java files to the strict format baseline.
- `mvn spotless:check --file`  — Scans files for structural format compliance.
- `mvn spotbugs:spotbugs`  — Scans files for common errors.
- `mvn javadoc:javadoc` — Compiles complete Javadoc files out to your `/target/site/apidocs` repository.

---

## Git Workflow Integration (Java expansion)

Update your root `lefthook.yml` file to dynamically target and process Java source code modifications right next to your existing TypeScript procedures:

```yaml
pre-commit:
  commands:
    # Task 1: Check and fix code formatting
    format-java:
      glob: "*.java"
      run: mvn spotless:apply && git add {staged_files}

    # Task 2: Validate code logic and check documentation sync
    lint-java:
      glob: "*.java"
      run: mvn checkstyle:check
```

---


## Automated Upgrade & Migration

- OpenRewrite CLI (`rewrite run`): A highly capable tool for large-scale automated refactoring. If your agent needs to upgrade legacy code (e.g., updating Java 8 syntax to modern Java 21 features or migrating structural APIs), OpenRewrite applies recipes programmatically via the command line.

## 5. 

---
