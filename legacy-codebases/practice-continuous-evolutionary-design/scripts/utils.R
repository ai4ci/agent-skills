# Handle dependencies
dependencies = c("optparse", "yaml", "fs", "dplyr", "stringr", "readr", "jsonlite")
for (dep in dependencies) {
  if (!requireNamespace(dep, quietly = TRUE)) {
    message("Installing dependency: ", dep)
    install.packages(dep, repos = "https://cloud.r-project.org")
  }
}

if (Sys.which("rg") == "") stop("
Unmet dependency on `ripgrep`.
Please install before use:
e.g. `sudo apt-get install ripgrep`
`https://github.com/burntsushi/ripgrep`
")

# Find the root of the git repository given a regular path
.search_for = function(dir, ..., .default = getwd()) {
  git_dir = dir
  while (!fs::dir_exists(fs::path(git_dir, ...))) {
    git_dir = fs::path_dir(git_dir)
    if (git_dir == fs::path_home()) {
      git_dir = .default
    }
  }
  return(git_dir)
}

# Locate directories
.directories = function(path = NULL) {
  # 2. Find em directory & project root ----

  if (is.null(path)) {
    git_dir = .search_for(getwd(), ".git")
    if (!interactive()) {
      dir = .search_for(getwd(), ".agents", "em", .default = git_dir)
    } else {
      dir = fs::path_expand("~/Git/agent-skills/legacy-codebases/practice-continuous-evolutionary-design/examples")
    }
  } else {
    if (fs::is_absolute_path(path)) {
      dir = path
    } else {
      dir = fs::path_abs(fs::path(getwd(), path))
    }
    git_dir = .search_for(dir, ".git")
  }
  em_dir = fs::path(dir, ".agents", "em")
  fs::dir_create(em_dir)


  message("Project directory: ", dir)
  message("Em dir: ", em_dir)
  message("Git root: ", git_dir)
  return(list(
    dir = dir,
    em_dir = em_dir,
    git_dir = git_dir
  ))
}

conn = stdout()


## Read in git files ignoring .agents directory ----
.files_ls = function(dir) {
  setwd(git_dir)
  tmp = system2(
    "rg",
    c("--files", fs::path_abs(dir)),
    stdout = TRUE
  )
  # by passing absolute path to ripgrep we always get back absolute path
  # tmp = fs::path(git_dir, tmp)
  df = fs::file_info(tmp) %>% dplyr::mutate(
    path = fs::path_rel(tmp, dir),
    modified = as.integer(modification_time),
    .keep = "none"
  )
  df = df %>%
    # ripgrep excludes all hidden files
    # dplyr::filter(!startsWith(path, ".agents")) %>%
    # dplyr::filter(!startsWith(path, ".opencode")) %>%
    # dplyr::filter(!startsWith(path, ".claude")) %>%
    # dplyr::filter(!startsWith(path, ".copilot")) %>%
    # dplyr::filter(!startsWith(path, ".pi")) %>%
    dplyr::filter(path != "em")
  return(df)
}

.traverser = function(links, keep_path = TRUE) {
  return(

    function(
  df,
  relationship = NULL,
  dir = c("out", "in", "both")
    ) {
      dir = match.arg(dir)
      tmp = dplyr::tibble(
        origin = character(),
        traversal = character(),
        path = character(),
        type = character()
      )
      if (!"traversal" %in% colnames(df)) df = df %>% dplyr::mutate(traversal = "", origin = path)
      if (dir %in% c("in", "both")) {
        tmp = df %>%
          dplyr::inner_join(links, by = c("path" = "target")) %>%
          dplyr::mutate(traversal = paste0(traversal, "<", type, "-")) %>%
          dplyr::select(origin, traversal, path = source, type) %>%
          dplyr::bind_rows(tmp)
      }
      if (dir %in% c("out", "both")) {
        tmp = df %>%
          dplyr::inner_join(links, by = c("path" = "source")) %>%
          dplyr::mutate(traversal = paste0(traversal, "-", type, ">")) %>%
          dplyr::select(origin, traversal, path = target, type) %>%
          dplyr::bind_rows(tmp)
      }
      if (!is.null(relationship)) {
        tmp = tmp %>%
          dplyr::filter(type %in% relationship)
      }
      if (!keep_path) tmp = tmp %>% dplyr::select(-traversal)
      return(tmp %>% dplyr::select(-type) %>% dplyr::distinct())
    }
  )
}

.write_count = function(title, df) {
  write(sprintf("\n## %s: %d", title, nrow(df)), conn)
  df = df %>%
    dplyr::ungroup() %>%
    dplyr::arrange(dplyr::pick(1))
  if (nrow(df) > 0) {
    readr::write_tsv(df, conn, progress = FALSE)
  }
}
