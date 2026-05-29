#!/usr/bin/env Rscript

# Handle dependencies
dependencies = c("optparse", "yaml", "fs", "dplyr", "stringr", "readr")
for (dep in dependencies) {
  if (!requireNamespace(dep, quietly = TRUE)) {
    message("Installing dependency: ", dep)
    install.packages(dep, repos = "https://cloud.r-project.org")
  }
}

# 1. Define options
option_list = list(
  optparse::make_option(
    c("-o", "--output"),
    type = "character",
    default = NULL,
    help = "an output file (defaults to stdout)",
    metavar = "FILE"
  ),
  # Example parameter
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
  description = "Check emergent design documents for consistency"
)
opt = optparse::parse_args(opt_parser)

# 3. Handle output connection
if (is.null(opt$output)) {
  conn = stdout()
} else {
  conn = tryCatch(
    {
      out_dir = dirname(opt$output)
      if (out_dir != "." && !dir.exists(out_dir)) {
        dir.create(out_dir, recursive = TRUE)
      }
      file(opt$output, "w")
    },
    error = function(e) {
      stop(
        opt$output,
        " could not be opened for writing: ",
        e$message,
        call. = FALSE
      )
    }
  )
}

# 4. Find em directory & project root

if (is.null(opt$dir)) {
  git_dir = getwd()
  while (!fs::dir_exists(fs::path(git_dir, ".git"))) {
    git_dir = fs::path_dir(git_dir)
    if (git_dir == fs::path_home()) {
      stop("Could not find `.git` directory from: ", getwd())
    }
  }
  dir = git_dir
} else {
  dir = fs::path_abs(opt$dir)
  git_dir = dir
  while (!fs::dir_exists(fs::path(git_dir, ".git"))) {
    git_dir = fs::path_dir(git_dir)
    if (git_dir == fs::path_home()) {
      stop("Could not find `.git` directory from: ", getwd())
    }
  }
}

message("Analysing directory: ", dir)

# dir = fs::path_expand("~/Git/agent-skills/legacy-codebases/emergent-design-methology/examples")
em_dir = fs::path(dir, ".agents", "em")
fs::dir_create(em_dir)

## setup / load existing em data ----
files_file = fs::path(em_dir, "files.tsv")
if (!fs::file_exists(files_file)) {
  readr::write_tsv(dplyr::tibble(
    path = character(),
    modified = integer(),
    status = character(),
    target_version = character()
  ), files_file)
}
previous_files = readr::read_tsv(files_file, col_types = "cicc")

links_file = fs::path(em_dir, "links.tsv")
if (!fs::file_exists(links_file)) {
  readr::write_tsv(dplyr::tibble(
    source = character(),
    line_no = integer(),
    type = character(),
    target = character()
  ), links_file)
}
current_links = readr::read_tsv(links_file, col_types = "cicc")

## Read in git files ignoring .agents directory ----
.files_ls = function(dir) {
  tmp = system2(
    "git",
    c("ls-files", "-o", "--exclude-standard", dir),
    stdout = TRUE
  )
  tmp = fs::path(git_dir, tmp)
  df = fs::file_info(tmp) %>% dplyr::mutate(
    path = fs::path_rel(tmp, dir),
    modified = as.integer(modification_time),
    .keep = "none"
  )
  df = df %>%
    dplyr::filter(!startsWith(path, ".agents")) %>%
    dplyr::filter(!startsWith(path, ".opencode")) %>%
    dplyr::filter(!startsWith(path, ".claude")) %>%
    dplyr::filter(!startsWith(path, ".copilot")) %>%
    dplyr::filter(!startsWith(path, ".pi"))
  return(df)
}

current_files = .files_ls(dir)
unchanged_files = previous_files %>% dplyr::semi_join(current_files, by = c("path", "modified"))
updated_files = current_files %>% dplyr::anti_join(previous_files, by = c("path", "modified"))
removed_files = previous_files %>% dplyr::anti_join(current_files, by = c("path", "modified"))

## Metadata ----

# md_file = "architecture/FRAMEWORK.md"
# md_file = "design/features/feat-001-prints-hello-world.md"
.extract_md_metadata = function(md_file) {
  metadata = dplyr::tibble(
    status = NA_character_,
    `target-version` = NA_character_
  )
  if (fs::path_ext(md_file) %in% c("md", "Rmd", "qmd")) {
    return(metadata)
  }

  lines = readr::read_lines(fs::path(dir, md_file))
  if (grepl("^---+$", lines[1])) {
    matches = which(lines == lines[1])
    if (length(matches) >= 2) {
      close = matches[2]
      if (close > 2) {
        yaml = lines[2:(close - 1)]
        parsed = yaml::yaml.load(yaml)
        metadata = dplyr::as_tibble(parsed)
      } else {
        message("Empty yaml block: ", md_file)
      }
    } else {
      message("Unclosed yaml block: ", md_file)
    }
  }
  # May be no yaml header which is basically normal.
  return(metadata %>% dplyr::rename(target_version = `target-version`))
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
    target_version
  )

readr::write_tsv(current_files, files_file)

## Links ----

# .extract_links(file = "design/features/feat-002-greets-user-by-name.md")
# .extract_links(file = "src/main/java/Greeter.java")
# .extract_links(file = "architecture/FRAMEWORK.md")
.extract_links = function(file) {
  lines = readr::read_lines(fs::path(dir, file))
  lines = gsub("<!--.*?-->", "", lines)
  links = grepv("\\[[A-Z_]+\\]\\([^\\)]+\\)", lines, perl = TRUE)

  if (length(links) > 0) {
    line_nos = which(grepv("\\[[A-Z_]+\\]\\([^\\)]+\\)", lines, perl = TRUE))
    types = gsub("^.*?\\[([A-Z_]+)\\]\\([^\\)]+\\).*$", "\\1", links, perl = TRUE)
    targets = gsub("^.*?\\[[A-Z_]+\\]\\(([^\\)]+)\\).*$", "\\1", links)
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
      target = targets
    ))
  } else {
    return(dplyr::tibble(
      source = character(),
      line_no = integer(),
      type = character(),
      target = character()
    ))
  }
}

new_links = dplyr::bind_rows(lapply(
  updated_files$path,
  .extract_links
))

unchanged_links = current_links %>%
  dplyr::anti_join(updated_files, by = c("source" = "path")) %>%
  dplyr::anti_join(removed_files, by = c("source" = "path"))

current_links = dplyr::bind_rows(unchanged_links, new_links) %>%
  dplyr::arrange(source, type, target) %>%
  dplyr::select(source, type, target)

readr::write_tsv(current_links, links_file)

## Quality checks ----

.write_count = function(title, df) {
  write(sprintf("\n## %s: %d", title, nrow(df)), conn)
  if (nrow(df) > 0) {
    readr::write_tsv(df, conn)
  }
}

write("DESIGN CONSISTENCY CHECKS", conn)
write("=========================", conn)

targets = unique(current_links$target)
exists = sapply(targets, function(t) fs::file_exists(fs::path(dir, t)))
broken = targets[!exists]

.write_count(
  "Broken links",
  current_links %>% dplyr::filter(target %in% broken)
)

.write_count(
  "Links with incorrect target type",
  current_links %>% dplyr::filter(
    (type == "FEATURE" & !startsWith(target, "design/feature")) |
      (type == "TEST" & !startsWith(target, "design/test-script")) |
      (type == "PROTOTYPE" & !startsWith(target, "design/prototype")) |
      (type == "INTERFACE" & !startsWith(target, "design/external-interfaces")) |
      (type == "REPRODUCES" & !startsWith(target, "design/implementation/issues")) |
      (type == "IMPLEMENTS" &
        !(
          startsWith(target, "design/test-script") |
            startsWith(target, "design/feature") |
            startsWith(target, "design/prototype") |
            startsWith(target, "design/external-interface")
        )
      )
  )
)

.write_count(
  "Links with incorrect source type",
  current_links %>% dplyr::filter(
    (type == "IMPACTS" & !(
      startsWith(source, "design/implementation/plans") |
        startsWith(source, "design/implementation/debt")
    )) |
      (type == "TESTDATA" & !(
        startsWith(source, "design/test-script") |
          startsWith(source, "design/prototype")
      ))
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

# All features have status and target-version:
.write_count(
  "[Defect] Features without correct metadata",
  current_files %>%
    dplyr::filter(startsWith(path, "design/features") &
      (is.na(status) | is.na(`target-version`)))
)

# All design artifacts have status and target-version:
.write_count(
  "[Defect] Design artifacts without correct metadata",
  current_files %>% dplyr::filter(
    (
      startsWith(path, "design/features") |
        startsWith(path, "design/prototypes") |
        startsWith(path, "design/implementation") |
        startsWith(path, "design/external-interfaces") |
        startsWith(path, "design/test-scripts")
    ) &
      (is.na(status) | is.na(`target-version`))
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
    current_links %>% dplyr::filter(type == "FEATURE"),
    by = c("path" = "source")
  )
)

# When a feature has a final status it must link to one or more test-scripts
.write_count(
  "[Defect] Final features not linking to test-scripts",
  current_files %>%
    dplyr::filter(status == "final" & startsWith(path, "design/features")) %>%
    dplyr::anti_join(
      current_links %>% dplyr::filter(type == "TEST"),
      by = c("path" = "source")
    )
)

# Open issues must have linked reproducible test cases
.write_count(
  "[Defect] Open issues not reproduced as a test case",
  current_files %>%
    dplyr::filter(status == "open" & startsWith(path, "design/implementation/issues")) %>%
    dplyr::anti_join(
      current_links %>% dplyr::filter(type == "REPRODUCES"),
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
      current_links %>% dplyr::filter(type == "IMPLEMENTS"),
      by = c("path" = "target")
    )
)

# Tests without implementation
.write_count(
  "[Advisory] Final features or test scripts without prototype or interface",
  current_files %>%
    dplyr::filter(status == "final" & (
      startsWith(path, "design/test-script") |
        startsWith(path, "design/feature")
    )) %>%
    dplyr::anti_join(
      current_links %>% dplyr::filter(type %in% c("PROTOTYPE", "INTERFACE")),
      by = c("path" = "source")
    )
)

# Implementation files are things that are in a subdirectory but not a design
# or architecture subdirectory, and are not linked to as test data.
implementation = current_files %>%
  dplyr::filter(!(
    startsWith(path, "design") |
      startsWith(path, "architecture")
  ) & fs::path_dir(path) != ".") %>%
  dplyr::anti_join(
    current_links %>% dplyr::filter(type %in% c("TESTDATA")),
    by = c("path" = "target")
  )

.write_count(
  "[Advisory] Implementation files with no links to design",
  implementation %>%
    dplyr::anti_join(
      current_links %>% dplyr::filter(type %in% c("IMPLEMENTS")),
      by = c("path" = "source")
    )
)


# 5. Tidy up
# Close connection if it's a file
try(close(conn), silent = TRUE)
