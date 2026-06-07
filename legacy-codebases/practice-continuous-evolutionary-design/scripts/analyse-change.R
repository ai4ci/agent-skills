#!/usr/bin/env Rscript

# Extract the script path from trailing command line arguments
cmd_args = commandArgs(trailingOnly = FALSE)
file_arg = "--file="
script_path = sub(file_arg, "", cmd_args[grep(file_arg, cmd_args)])
if (!interactive()) {
  source(file.path(dirname(normalizePath(script_path)), "utils.R"))
}

option_list = list(
  optparse::make_option(
    c("-d", "--dir"),
    type = "character",
    default = NULL,
    help = "the root directory of the project",
    metavar = "DIRECTORY"
  )
)

opt_parser = optparse::OptionParser(
  option_list = option_list,
  description = "Check continuous evolutionary design documents for consistency"
)
opt = optparse::parse_args(opt_parser, positional_arguments = TRUE)

# 2. Find em directory & project root ----

tmp = .directories(opt$dir)
dir = tmp$dir
git_dir = tmp$git_dir
em_dir = tmp$em_dir


files_file = fs::path(em_dir, "files.tsv")
if (!fs::file_exists(files_file)) stop("No `.agents/em/files.tsv` to compare. Have you run `em design` yet?")
previous_files = readr::read_tsv(files_file, col_types = "cicc")

links_file = fs::path(em_dir, "links.tsv")
if (!fs::file_exists(links_file)) stop("No `.agents/em/links.tsv` to compare. Have you run `em design` yet?")
current_links = readr::read_tsv(links_file, col_types = "ciccc")

implementation_notes_file = fs::path(em_dir, "implementation-notes.json")
if (!fs::file_exists(implementation_notes_file)) stop("No `.agents/em/implementation-notes.json` to compare. Have you run `em design` yet?")
implementation_notes = jsonlite::read_json(implementation_notes_file)

if (length(opt$args) > 0) {
  # paths = c("src/main/java/Greeter.java", "~/Git/agent-skills/legacy-codebases/practice-continuous-evolutionary-design/examples/design/prototypes/prototype-001-mvp.Rmd", "design/test-scripts/test-001-script-for-mvp.md")
  paths = opt$args
  paths = fs::path_expand(paths)
  paths = ifelse(fs::is_absolute_path(paths), fs::path_rel(paths, dir), paths)

  updated_files = dplyr::tibble(path = paths)
  removed_files = dplyr::tibble(path = character())
} else {
  current_files = .files_ls(dir)
  # unchanged_files = previous_files %>% dplyr::semi_join(current_files, by = c("path", "modified"))
  updated_files = current_files %>% dplyr::anti_join(previous_files, by = c("path", "modified"))
  removed_files = previous_files %>% dplyr::anti_join(current_files, by = c("path", "modified"))
}

traverse = .traverser(current_links, keep_path = TRUE)
traverse2 = .traverser(current_links, keep_path = FALSE)

EM_DESIGN_DESIGN_LINKS = c(
  "HAS_FEATURE",
  "HAS_TEST",
  "HAS_PROTOTYPE",
  "HAS_INTERFACE",
  "HAS_PLAN"
)

EM_CODE_DESIGN_LINKS = c(
  "TESTS",
  "IMPLEMENTS"
)

EM_DESIGN_CODE_LINKS = c(
  "IMPACTS",
  "TESTED_BY",
  "IMPLEMENTED_BY"
)

write("CHANGE IMPACT PREDICTION", conn)
write("========================", conn)

.write_count(
  "Updated files (or files to update)",
  updated_files
)

.write_count(
  "Removed files",
  removed_files
)

.write_count(
  "First degree design impacted by design updates",
  updated_files %>% traverse(dir = "out", relationship = EM_DESIGN_DESIGN_LINKS)
)

.write_count(
  "First degree code impacted by design updates",
  updated_files %>% traverse(dir = "out", relationship = EM_DESIGN_CODE_LINKS)
)

.write_count(
  "First degree design impacted by code updates",
  updated_files %>% traverse(dir = "out", relationship = EM_CODE_DESIGN_LINKS)
)

.write_count(
  "Second degree code impacted by code updates",
  updated_files %>%
    traverse(dir = "out", relationship = EM_CODE_DESIGN_LINKS) %>%
    traverse(dir = "out", relationship = EM_DESIGN_CODE_LINKS) %>%
    dplyr::filter(origin != path)
)

.write_count(
  "Third degree code impacted by code updates",
  updated_files %>%
    traverse(dir = "out", relationship = EM_CODE_DESIGN_LINKS) %>%
    traverse(dir = "out", relationship = EM_DESIGN_DESIGN_LINKS) %>%
    traverse(dir = "out", relationship = EM_DESIGN_CODE_LINKS) %>%
    dplyr::filter(origin != path)
)

.write_count(
  "First degree code & design changes impacted by deletions",
  removed_files %>%
    traverse2(dir = "both")
)
