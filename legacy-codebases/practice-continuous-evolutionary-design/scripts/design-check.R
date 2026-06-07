#!/usr/bin/env Rscript

# Extract the script path from trailing command line arguments
cmd_args = commandArgs(trailingOnly = FALSE)
file_arg = "--file="
script_path = sub(file_arg, "", cmd_args[grep(file_arg, cmd_args)])
if (!interactive()) {
  source(file.path(dirname(normalizePath(script_path)), "utils.R"))
}

# Settings:

EM_DESIGN_LINKS = c(
  "HAS_FEATURE",
  "HAS_TEST",
  "HAS_PROTOTYPE",
  "HAS_INTERFACE",
  "HAS_PLAN",
  "TESTS",
  "TESTED_BY",
  "IMPLEMENTS",
  "IMPLEMENTED_BY",
  "USES_DATA",
  "CREATES_DATA",
  "IMPACTS"
)

# 1. Define options ----

option_list = list(
  optparse::make_option(
    c("-d", "--dir"),
    type = "character",
    default = NULL,
    help = "the root directory of the project",
    metavar = "DIRECTORY"
  ),
  optparse::make_option(
    c("-x", "--no-save"),
    action = "store_true",
    default = FALSE,
    help = "omit saving the changes to the history"
  )
)

opt_parser = optparse::OptionParser(
  option_list = option_list,
  description = "Check continuous evolutionary design documents for consistency"
)
opt = optparse::parse_args(opt_parser)

# 2. Find em directory & project root ----

tmp = .directories(opt$dir)
dir = tmp$dir
git_dir = tmp$git_dir
em_dir = tmp$em_dir

no_save = opt[["no-save"]]
if (no_save) message("Dry run enabled.")

# 4. Load existing files ----

# fs::file_delete(fs::path(em_dir, c("files.tsv","links.tsv")))

## setup / load existing em data ----
files_file = fs::path(em_dir, "files.tsv")
if (!fs::file_exists(files_file)) {
  readr::write_tsv(dplyr::tibble(
    path = character(),
    modified = integer(),
    status = character(),
    target_version = character(),
    tags = character()
  ), files_file)
}
previous_files = readr::read_tsv(files_file, col_types = "cicc")

# 5. Find project contents ----

current_files = .files_ls(dir)

unchanged_files = previous_files %>% dplyr::semi_join(current_files, by = c("path", "modified"))
updated_files = current_files %>% dplyr::anti_join(previous_files, by = c("path", "modified"))
removed_files = previous_files %>% dplyr::anti_join(current_files, by = c("path", "modified"))

# 6. Extract metadata from yaml in files ----

# md_file = "architecture/FRAMEWORK.md"
# md_file = "design/features/feat-001-prints-hello-world.md"
# md_file = "src/test/java/InternationalGreeterTest.java"
.extract_md_metadata = function(md_file) {
  metadata = dplyr::tibble(
    status = NA_character_,
    target_version = NA_character_,
    tags = NA_character_
  )

  lines = readr::read_lines(fs::path(dir, md_file))

  if (!fs::path_ext(md_file) %in% c("md", "Rmd", "qmd")) {
    if (grepl("^(.*?)---+$", lines[1])) {
      # First line matches a prefixed yaml line.
      head = gsub("^(.*?)---+$", "\\1", lines[1])
      # Strip the prefix from all lines
      lines = substr(lines, nchar(head) + 1, nchar(lines))
    } else {
      return(metadata)
    }
  }


  if (grepl("^---+$", lines[1])) {
    matches = which(lines == lines[1])
    if (length(matches) >= 2) {
      close = matches[2]
      if (close > 2) {
        yaml = lines[2:(close - 1)]
        parsed = yaml::yaml.load(yaml)
        metadata = dplyr::as_tibble(parsed)
        if ("target-version" %in% colnames(metadata)) {
          metadata = metadata %>% dplyr::rename(target_version = `target-version`)
        }
        if ("since-version" %in% colnames(metadata)) {
          metadata = metadata %>% dplyr::rename(since_version = `since-version`)
        }
      } else {
        message("Empty yaml block: ", md_file)
      }
    } else {
      message("Unclosed yaml block: ", md_file)
    }
  }
  # May be no yaml header which is basically normal.
  return(metadata)
}

updated_files = updated_files %>%
  dplyr::mutate(
    metadata = purrr::map(path, .extract_md_metadata)
  ) %>%
  tidyr::unnest(metadata)

current_files = dplyr::bind_rows(unchanged_files, updated_files) %>%
  dplyr::arrange(path) %>%
  dplyr::select(
    path,
    modified,
    status,
    target_version,
    tags
  )

if (!no_save) readr::write_tsv(current_files, files_file)

# 7. find links in files ----

links_file = fs::path(em_dir, "links.tsv")
if (!fs::file_exists(links_file)) {
  readr::write_tsv(dplyr::tibble(
    source = character(),
    line_no = integer(),
    type = character(),
    target = character(),
    anchor = character()
  ), links_file)
}
current_links = readr::read_tsv(links_file, col_types = "ciccc")

# .extract_links(file = "design/features/feat-002-greets-user-by-name.md")
# .extract_links(file = "src/main/java/Greeter.java")
# .extract_links(file = "architecture/FRAMEWORK.md")
.extract_links = function(file) {
  lines = readr::read_lines(fs::path(dir, file))
  lines = gsub("<!--.*?-->", "", lines)
  links = grepv("\\[[A-Z_]+\\]\\([^\\)]+\\)", lines, perl = TRUE)

  if (length(links) > 0) {
    line_nos = which(grepl("\\[[A-Z_]+\\]\\([^\\)]+\\)", lines, perl = TRUE))
    types = gsub("^.*?\\[([A-Z_]+)\\]\\([^\\)]+\\).*$", "\\1", links, perl = TRUE)
    targets = gsub("^.*?\\[[A-Z_]+\\]\\(([^\\)]+)\\).*$", "\\1", links)
    # targets = c("/abc/def/ghi.md#anchor","/abc/def/ghi.md")
    anchors = sapply(strsplit(targets, "#", fixed = TRUE), function(x) if (length(x) > 1) x[2] else NA)
    targets = sapply(strsplit(targets, "#", fixed = TRUE), `[`, 1)
    targets = fs::path_rel(
      ifelse(
        startsWith(targets, "/"),
        fs::path(dir, targets),
        fs::path_norm(fs::path(dir, fs::path_dir(file), targets))
      ),
      dir
    )
    return(dplyr::tibble(
      source = file,
      line_no = line_nos,
      type = types,
      target = targets,
      anchor = anchors
    ))
  } else {
    return(dplyr::tibble(
      source = character(),
      line_no = integer(),
      type = character(),
      target = character(),
      anchor = character()
    ))
  }
}

new_links = dplyr::bind_rows(lapply(
  updated_files$path,
  .extract_links
))

# Select out the links that are supported in EM designs:
# All upper snake case are extracted:
if (nrow(new_links) > 0) {
  new_links = new_links %>% dplyr::filter(grepl("^[A-Z_]+$", type))
}

unchanged_links = current_links %>%
  dplyr::anti_join(updated_files, by = c("source" = "path")) %>%
  dplyr::anti_join(removed_files, by = c("source" = "path"))

current_links = dplyr::bind_rows(unchanged_links, new_links) %>%
  dplyr::arrange(source, type, target) %>%
  dplyr::select(source, line_no, type, target, anchor)

if (!no_save) readr::write_tsv(current_links, links_file)

# 8. Implementation file comments ----

# Implementation files are things that are in a subdirectory but not a design
# or architecture subdirectory, and are not linked to as test data.
implementation = current_files %>%
  dplyr::filter(!(
    startsWith(path, "design") |
      startsWith(path, "architecture")
  ) & fs::path_dir(path) != ".") %>%
  dplyr::anti_join(
    current_links %>% dplyr::filter(type %in% c("USES_DATA", "CREATES_DATA")),
    by = c("path" = "target")
  )

implementation_notes_file = fs::path(em_dir, "implementation-notes.json")
if (fs::file_exists(implementation_notes_file)) {
  implementation_notes = jsonlite::read_json(implementation_notes_file)
} else {
  implementation_notes = list()
}

# Hacky search for definitions in source code files
# N.B. problems with overmatching
# .find_definitions = function(source_code) {
#   lines <- trimws(source_code)
#   # Define the 3 Tiers using PERL-compatible regex
#   patterns <- c(
#     # Tier 1: Keywords (class, struct, enum, trait, def, fn, function)
#     tier1 = "\\b(class|struct|enum|trait|def|fn|function)\\s+([a-zA-Z_][a-zA-Z0-9_]*)",
#     # Tier 2: Assignment/Symbol markers (R, JS arrows, Bash empty parens)
#     tier2 = "^([a-zA-Z_][a-zA-Z0-9_\\.]*)\\s*(?:<\\-|=|\\(\\s*\\))\\s*(?:function|\\([^)]*\\)\\s*=>|\\{)?",
#     # Tier 3: C++/Java Type-Name-Parens (ignores control flow keywords via negative lookahead)
#     tier3 = "^(?!if\\b|for\\b|while\\b|switch\\b|catch\\b|return\\b)(?:[a-zA-Z0-9_<>]+\\s+)+([a-zA-Z_][a-zA-Z0-9_]*)\\s*\\("
#   )
#   # Helper function to vectorise matching and extraction for a single pattern
#   results <- dplyr::bind_rows(lapply(names(patterns),  function(nm) {
#     pattern = patterns[nm]
#     # Find matching line indices
#     idx <- grep(pattern, lines, perl = TRUE)
#     if (length(idx) == 0) return(NULL)
#     # Extract capture groups vectorially
#     matches <- regexec(pattern, lines[idx], perl = TRUE)
#     captured <- regmatches(lines[idx], matches)
#     # Extract the name (always the last capture group in our patterns)
#     names_extracted <- sapply(captured, function(x) tail(x, 1))
#     dplyr::tibble(line = idx, name = names_extracted)
#   })) %>% dplyr::distinct()
#
#   if (is.null(results) || nrow(results) == 0) {
#     return(list())
#   }
#
#   out = as.list(results$name)
#   names(out)= sprintf("line: %d",results$line)
#
#   return(out)
# }

new_implementation_notes = implementation %>%
  dplyr::mutate(
    lines = purrr::map(path, ~ readr::read_lines(fs::path(dir, .x))),
    comments = purrr::map(lines, ~ {
      line_no = which(grepl("^\\s*(?:\\/\\/|#['#]?|--|/\\*|%|<!--)\\s*EM:", .x))
      comment = as.list(.x[line_no])
      names(comment) = sprintf("line: %d", line_no)
      comment
    }),
    # anchors = purrr::map(lines, .find_definitions),
    anchors = purrr::map(lines, ~ {
      line_no = which(grepl("^\\s*(?:\\/\\/|#['#]?|--|/\\*|%|<!--)\\s*###\\s*", .x))
      anchor = .x[line_no]
      anchor = gsub(
        "^\\s*(?:\\/\\/|#['#]?|--|/\\*|%|<!--)\\s*###\\s*",
        replacement = "",
        anchor
      )
      anchor = strsplit(anchor, split = " ", fixed = TRUE)
      anchor = sapply(anchor, `[`, 1)
      line_no = as.list(line_no)
      names(line_no) = anchor
      line_no
    }),
    count_lines = purrr::map_int(lines, ~ length(.x)),
    percent = purrr::map2_dbl(
      comments,
      count_lines,
      ~ ifelse(.y == 0, 100, length(.x) / .y * 100)
    )
  ) %>%
  dplyr::select(path, modified, comments, anchors, count_lines, percent)


tmp = lapply(seq_len(nrow(new_implementation_notes)), function(i) {
  row = new_implementation_notes[i, ]
  ls = as.list(row %>% dplyr::select(-path))
  ls = lapply(ls, unlist, recursive = FALSE)
})
names(tmp) = new_implementation_notes$path
current_implementation_notes = modifyList(implementation_notes, tmp)

current_implementation_notes = current_implementation_notes[order(names(current_implementation_notes))]

if (!no_save) {
  jsonlite::write_json(
    current_implementation_notes,
    implementation_notes_file,
    pretty = TRUE,
    auto_unbox = TRUE
  )
}

## TODO: extract structural elements or anchors from code files

## 8. Perform quality checks on design graph ----



write("DESIGN CONSISTENCY CHECKS", conn)
write("=========================", conn)

write(
  sprintf(
    "Implementation files: %d",
    nrow(implementation)
  ),
  conn
)
write(
  sprintf(
    "Design features: %d",
    nrow(current_files %>% dplyr::filter(startsWith(path, "design/features")))
  ),
  conn
)
write(
  sprintf(
    "Prototypes: %d",
    nrow(current_files %>% dplyr::filter(startsWith(path, "design/prototypes")))
  ),
  conn
)
write(
  sprintf(
    "External interfaces: %d",
    nrow(current_files %>% dplyr::filter(startsWith(path, "design/external-interfaces")))
  ),
  conn
)
write(
  sprintf(
    "Test scripts: %d",
    nrow(current_files %>% dplyr::filter(startsWith(path, "design/test-scripts")))
  ),
  conn
)
write(
  sprintf(
    "Issues: %d",
    nrow(current_files %>% dplyr::filter(startsWith(path, "design/implementation/issues")))
  ),
  conn
)

targets = unique(current_links$target)
exists = sapply(targets, function(t) fs::file_exists(fs::path(dir, t)))
broken = targets[!exists]

bidirectional_links = current_links %>%
  dplyr::select(source, target, forward = type) %>%
  dplyr::distinct() %>%
  dplyr::left_join(
    current_links %>%
      dplyr::select(source, target, backward = type) %>%
      dplyr::distinct(),
    by = c("source" = "target", "target" = "source")
  ) %>%
  dplyr::mutate(
    expected = dplyr::case_when(
      !forward %in% EM_DESIGN_LINKS ~ NA,
      forward == "IMPLEMENTS" & startsWith(target, "design") ~ "IMPLEMENTED_BY",
      forward == "IMPLEMENTED_BY" & startsWith(source, "design") ~ "IMPLEMENTS",
      forward == "TESTS" & startsWith(target, "design") ~ "TESTED_BY",
      forward == "TESTED_BY" & startsWith(source, "design") ~ "TESTS",
      startsWith(target, "design") ~ dplyr::case_when(
        startsWith(source, "design/external-interfaces") ~ "HAS_INTERFACE",
        startsWith(source, "design/test-script") ~ "HAS_TEST",
        startsWith(source, "design/prototype") ~ "HAS_PROTOTYPE",
        startsWith(source, "design/implementation/plan") ~ "HAS_PLAN",
        startsWith(source, "design/feature") ~ "HAS_FEATURE"
      ),
      TRUE ~ NA
    )
  )

## Structural defects ----

.write_count(
  "[Defect] Broken links",
  current_links %>% dplyr::filter(target %in% broken)
)

.write_count(
  "[Defect] Links with incorrect target type",
  current_links %>% dplyr::filter(
    (type == "HAS_FEATURE" & !startsWith(target, "design/features")) |
      (type == "HAS_TEST" & !startsWith(target, "design/test-scripts")) |
      (type == "HAS_PROTOTYPE" & !startsWith(target, "design/prototypes")) |
      (type == "HAS_INTERFACE" & !startsWith(target, "design/external-interfaces")) |
      (type == "HAS_PLAN" & !startsWith(target, "design/implementation/plans")) |
      (type == "TESTS" &
        !(
          startsWith(target, "design/implementation/issues") |
            startsWith(target, "design/test-scripts")
        )
      ) |
      (type == "IMPLEMENTS" &
        !(
          startsWith(target, "design/features") |
            startsWith(target, "design/prototypes") |
            startsWith(target, "design/external-interfaces")
        )
      )
  )
)

.write_count(
  "[Defect] Links with incorrect source type",
  current_links %>% dplyr::filter(
    (type == "IMPACTS" & !(
      startsWith(source, "design/implementation/plans") |
        startsWith(source, "design/implementation/debt")
    )) |
      (type == "USES_DATA" & !(
        startsWith(source, "design/test-scripts")
      )) |
      (type == "CREATES_DATA" & !(
        startsWith(source, "design/prototypes")
      )) |
      (type == "IMPLEMENTED_BY" &
        !(
          startsWith(source, "design/features") |
            startsWith(source, "design/prototypes") |
            startsWith(source, "design/external-interfaces")
        )
      ) |
      (type == "TESTED_BY" &
        !(
          startsWith(source, "design/test-scripts") |
            startsWith(source, "design/implementation/issue")
        )
      )
  )
)

.write_count(
  "[Defect] Missing reverse links",
  bidirectional_links %>% dplyr::filter(
    is.na(backward) & !is.na(expected) &
      source != "design/SCOPE.md"
  ) %>% dplyr::transmute(
    from = target,
    missing_link = sprintf("[%s](/%s)", expected, source)
  )
)

## Design defects ----

# All non deprecated features linked to from SCOPE.md
.write_count(
  "[Defect] Features not in SCOPE",
  current_files %>% dplyr::filter(
    startsWith(path, "design/features") &
      status != "deprecated"
  ) %>%
    dplyr::anti_join(
      current_links %>% dplyr::filter(source == "design/SCOPE.md"),
      by = c("path" = "target")
    )
)

# All design artifacts have status and target-version:
.write_count(
  "[Defect] Design artifacts without correct metadata",
  current_files %>% dplyr::filter(
    (
      startsWith(path, "design") &
        path != "design/SCOPE.md"
    ) &
      (is.na(status) | is.na(target_version))
  )
)

# Features must be linked to by design artifacts (except issues)
.write_count(
  "[Defect] Design artifacts without linked feature",
  current_files %>% dplyr::filter(
    (
      startsWith(path, "design/prototypes") |
        startsWith(path, "design/implementation/plans") |
        startsWith(path, "design/external-interfaces") |
        startsWith(path, "design/test-scripts")
    )
  ) %>% dplyr::anti_join(
    current_links %>% dplyr::filter(type == "HAS_FEATURE"),
    by = c("path" = "source")
  )
)

# When a feature has a final status it must link to one or more test-scripts
.write_count(
  "[Defect] Final features not linking to test-scripts",
  current_files %>%
    dplyr::filter(status == "final" & startsWith(path, "design/features")) %>%
    dplyr::anti_join(
      current_links %>% dplyr::filter(type == "HAS_TEST"),
      by = c("path" = "source")
    )
)

# Open issues must have linked reproducible test cases
.write_count(
  "[Defect] Open issues not reproduced as a test case",
  current_files %>%
    dplyr::filter(status == "open" & startsWith(path, "design/implementation/issues")) %>%
    dplyr::anti_join(
      current_links %>% dplyr::filter(type == "TESTS"),
      by = c("path" = "target")
    )
)

## Design improvement targets ----

# Features without implementation
.write_count(
  "[Advisory] Final features without implementation",
  current_files %>%
    dplyr::filter(status == "final" & startsWith(path, "design/features")) %>%
    dplyr::anti_join(
      current_links %>% dplyr::filter(type == "IMPLEMENTS"),
      by = c("path" = "target")
    )
)

# Tests without implementation
.write_count(
  "[Advisory] Final test scripts without implementation",
  current_files %>%
    dplyr::filter(status == "final" & startsWith(path, "design/test-script")) %>%
    dplyr::anti_join(
      current_links %>% dplyr::filter(type == "TESTS"),
      by = c("path" = "target")
    )
)

# Features or test-scripts without prototypes or external interfaces.
.write_count(
  "[Advisory] Final features or test scripts without prototype or external interface spec",
  current_files %>%
    dplyr::filter(status == "final" & (
      startsWith(path, "design/test-script") |
        startsWith(path, "design/feature")
    )) %>%
    dplyr::anti_join(
      current_links %>% dplyr::filter(type %in% c("HAS_PROTOTYPE", "HAS_INTERFACE")),
      by = c("path" = "source")
    )
)

# Implementation files not linked from designs, test-scripts or issues
.write_count(
  "[Advisory] No design artifacts link to implementation files",
  implementation %>%
    dplyr::anti_join(
      current_links %>% dplyr::filter(type %in% c("IMPLEMENTED_BY", "TESTED_BY")),
      by = c("path" = "target")
    )
)

# Implementation files not linked to designs, test-scripts or issues
.write_count(
  "[Advisory] Implementation files with no links to design artifacts",
  implementation %>%
    dplyr::anti_join(
      current_links %>% dplyr::filter(type %in% c("IMPLEMENTS", "TESTS")),
      by = c("path" = "source")
    )
)

# Implementation files 10-25% EM comments
.write_count(
  "[Advisory] Implementation files with comments < 10% or > 25%",
  dplyr::bind_rows(current_implementation_notes %>% purrr::discard(
    ~ .x$percent > 10 & .x$percent < 25
  ) %>% purrr::imap(~ dplyr::tibble(path = .y, percent = .x$percent)))
)


# Implementation files 10-25% EM comments
.write_count(
  "[Advisory] Design documents in draft status",
  current_files %>%
    dplyr::filter(!is.na(status) & !status %in% c("final", "closed"))
)

# 5. Tidy up
# Close connection if it's a file
try(close(conn), silent = TRUE)
