#!/usr/bin/env bun
/**
 * lint-design.ts - Validate the design/ folder of an emergent design project.
 *
 * Processes markdown files using remark/unified and applies custom validation
 * rules to check structural conformance with the emergent design methodology.
 *
 * Usage:
 *   bun lint-design.ts <project-root>
 *
 * Exit codes:
 *   0  No errors found (warnings are OK)
 *   1  One or more errors found (or bad arguments)
 *
 * Prerequisites:
 *   bun add unified remark-parse unist-util-visit
 *   (or: cd scripts && bun install)
 *
 * Test:
 *   bun lint-design.ts /path/to/your/project
 */

import { parseArgs } from "node:util";
import { join, dirname, relative } from "node:path";
import { existsSync } from "node:fs";
import { unified } from "unified";
import remarkParse from "remark-parse";
import { visit } from "unist-util-visit";
import type { Root, Link } from "mdast";

// ---------------------------------------------------------------------------
// Types
// ---------------------------------------------------------------------------

interface LintIssue {
  file: string;
  line: number;
  column: number;
  severity: "error" | "warning";
  rule: string;
  message: string;
}

/**
 * A lint rule is a pure function that receives a parsed markdown AST, the
 * absolute path to the file being linted, and the project root. It returns
 * any issues found. Rules are stateless — keep side-effects out.
 */
type LintRule = (
  tree: Root,
  filePath: string,
  projectRoot: string
) => LintIssue[];

// ---------------------------------------------------------------------------
// Rules — SCOPE.md
// ---------------------------------------------------------------------------

/**
 * Checks that every link in SCOPE.md that points into design/features/ refers
 * to a file that actually exists on disk.
 *
 * The rule intentionally only checks links that look like feature references
 * (i.e. path contains "features/"). External URLs and other internal links are
 * ignored — those are the job of a link checker like lychee.
 */
function checkScopeMdFeatureLinksExist(
  tree: Root,
  filePath: string,
  projectRoot: string
): LintIssue[] {
  const issues: LintIssue[] = [];

  visit(tree, "link", (node: Link) => {
    const href = node.url;

    // Only consider local paths that reference the features directory
    if (href.startsWith("http://") || href.startsWith("https://")) return;
    if (!href.includes("features/")) return;

    // Resolve relative to the file being linted
    const resolvedPath = join(dirname(filePath), href);
    if (!existsSync(resolvedPath)) {
      issues.push({
        file: filePath,
        line: node.position?.start.line ?? 0,
        column: node.position?.start.column ?? 0,
        severity: "error",
        rule: "scope-feature-link-exists",
        message: `Linked feature file does not exist: ${href}`,
      });
    }
  });

  return issues;
}

// Add further SCOPE.md rules here as the spec matures:
// e.g. checkScopeMdHasRoadmapHeading, checkScopeMdHasImplementedHeading

const SCOPE_MD_RULES: LintRule[] = [
  checkScopeMdFeatureLinksExist,
];

// ---------------------------------------------------------------------------
// Linter core
// ---------------------------------------------------------------------------

async function lintFile(
  filePath: string,
  rules: LintRule[],
  projectRoot: string
): Promise<LintIssue[]> {
  const content = await Bun.file(filePath).text();
  const tree = unified().use(remarkParse).parse(content) as Root;
  return rules.flatMap((rule) => rule(tree, filePath, projectRoot));
}

// ---------------------------------------------------------------------------
// Reporting
// ---------------------------------------------------------------------------

function formatIssue(issue: LintIssue, cwd: string): string {
  const rel = relative(cwd, issue.file);
  return `${rel}:${issue.line}:${issue.column}: ${issue.severity}: ${issue.message} [${issue.rule}]`;
}

// ---------------------------------------------------------------------------
// Main
// ---------------------------------------------------------------------------

async function main() {
  const { values, positionals } = parseArgs({
    args: process.argv.slice(2),
    options: {
      help: { type: "boolean", short: "h" },
    },
    allowPositionals: true,
  });

  if (values.help || positionals.length === 0) {
    console.log(`
lint-design - Validate the design/ folder of an emergent design project

Usage:
  bun lint-design.ts <project-root>

Arguments:
  project-root   Absolute or relative path to the project root.
                 Must contain a design/ folder.

Options:
  -h, --help     Show this help message

Output format:
  file:line:col: severity: message [rule-name]

Exit codes:
  0  No errors (warnings permitted)
  1  One or more errors found
`);
    process.exit(positionals.length === 0 ? 1 : 0);
  }

  const projectRoot = positionals[0];
  const designDir = join(projectRoot, "design");
  const scopeMdPath = join(designDir, "SCOPE.md");

  if (!existsSync(designDir)) {
    console.error(`Error: design/ directory not found under ${projectRoot}`);
    process.exit(1);
  }

  if (!existsSync(scopeMdPath)) {
    console.error(`Error: design/SCOPE.md not found under ${projectRoot}`);
    process.exit(1);
  }

  const allIssues: LintIssue[] = [];

  // Lint SCOPE.md
  const scopeIssues = await lintFile(scopeMdPath, SCOPE_MD_RULES, projectRoot);
  allIssues.push(...scopeIssues);

  // TODO: Lint design/features/*.md
  // TODO: Lint design/test-scripts/*.md (check back-links to features)
  // TODO: Lint design/implementation/notes/ (check mirroring against source)

  if (allIssues.length === 0) {
    console.log("✓ No issues found");
    process.exit(0);
  }

  const cwd = process.cwd();
  for (const issue of allIssues) {
    console.log(formatIssue(issue, cwd));
  }

  const errorCount = allIssues.filter((i) => i.severity === "error").length;
  const warnCount = allIssues.filter((i) => i.severity === "warning").length;
  console.log(`\n${errorCount} error(s), ${warnCount} warning(s)`);
  process.exit(errorCount > 0 ? 1 : 0);
}

main();
