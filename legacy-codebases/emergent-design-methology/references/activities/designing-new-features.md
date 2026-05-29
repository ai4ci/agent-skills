You are being asked to extend the functionality of the project (or create a minimal viable product). 

CRITICAL: You *MUST NOT* start writing production code without understanding the requirements and documenting them.

## Step 1 - summarise idea and decompose

* Summarise the idea the request and particularly the purpose: "We want feature XXX so that we can YYY".
* Re-read the scope / road map of the project (`design/SCOPE.md`) 
* Is the idea one feature or multiple features? Decompose where appropriate.
* Where in scope / road map does this fit (what is the version we are targeting, aka `target-version`)?
* Is this a new feature or updating an existing one.
* Document new feature titles in scope / road map.

## Step 2 - elaborate feature description

* Elaborate each new feature as a new file in `design/features` following the format of the [feature examples](../../examples/design/features/), with an initial draft `status`, and appropriate `target-version` field.
* Document success criteria for a feature.

## Step 3 - Optional: specify external interfaces

* Features may need new external interfaces or existing ones updated.
* Describe the updated external interfaces in `design/external-interfaces` following the format of the [external interfaces example](../../examples/design/external-interfaces/) with an initial draft `status`, and appropriate `target-version` field.

## Step 4 - prototype

* Follow the [build a prototype](./prototyping-features) guidance - with an initial draft `status`, and appropriate `target-version` field. This may be a very simple static file or a complex algorithm - start minimal and iterate.

## Step 5 - validate and iterate

* Review the new features, external interfaces, and prototypes with the developer. 
* Return to step 2 and incorporate feedback until design is approved.

## Step 6 - write test scripts

* Extract test data from the prototype 
* Write test scripts in `design/test-scripts` following the format of the [test scripts example](../../example/design/test-scripts/) with an initial draft `status`, and appropriate `target-version` field.

---

## Updating existing features

The process is the same but your initial draft of the features, external interfaces, prototypes, and test-scripts can be derived from the existing feature. The existing features and other design documents must be marked as superseded and linked to the new design docs using a `REPLACED_BY` link.
