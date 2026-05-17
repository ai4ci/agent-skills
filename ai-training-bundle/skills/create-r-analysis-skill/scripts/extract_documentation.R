#!/usr/bin/env Rscript
dependencies = c("optparse")
for (dep in dependencies) {
  if (!requireNamespace(dep, quietly = TRUE)) {
    install.packages(dep, repos = "https://cloud.r-project.org")
  }
}

option_list = list(
  optparse::make_option(
    c("-p", "--package"),
    type = "character",
    default = NULL,
    help = "the R package name",
    metavar = "character"
  ),
  optparse::make_option(
    c("-o", "--output"),
    type = "character",
    default = NULL,
    help = "an output file (defaults to stdout)",
    metavar = "character"
  )
)

opt_parser = optparse::OptionParser(
  option_list = option_list,
  description = "
Export all the documentation for an R package as plain text
including vignettes. The package must be installed locally."
)
opt = optparse::parse_args(opt_parser)

if (is.null(opt$package)) {
  optparse::print_help(opt_parser)
  stop("Package argument must be supplied (--package)", call. = FALSE)
}

#opt = list(package="dplyr")

# Vignettes
doc_dir = system.file("doc", package = opt$package)
md = unique(c(
  list.files(doc_dir, pattern = ".*\\.Rmd|.*\\.md")
))

if (is.null(opt$output)) {
  conn = stdout()
} else {
  conn = tryCatch(
    {
      out_dir <- dirname(opt$output)
      if (out_dir != "." && !dir.exists(out_dir)) {
        dir.create(out_dir, recursive = TRUE)
      }
      file(opt$output, "w")
    },
    error = function(e) {
      stop(opt$output, " could not be opened for writing: ", e$message)
    }
  )
}

# Description

writeLines(
  c(
    "=============================================",
    sprintf("DESCRIPTION: %s", opt$package),
    "=============================================",
    "",
    readLines(system.file("DESCRIPTION", package = opt$package)),
    ""
  ),
  conn
)

# Vignettes

for (file in md) {
  pth = file.path(doc_dir, file)
  writeLines(
    c(
      "=============================================",
      sprintf("Vignette: %s", gsub("\\.R?md", "", file)),
      "=============================================",
      "",
      readLines(pth),
      ""
    ),
    conn
  )
}

# Function reference
tools::Rd2txt_options(underline_titles = FALSE)
rddb = tools::Rd_db(package = opt$package)
for (nm in names(rddb)) {
  writeLines(
    c(
      "=============================================",
      sprintf("Manual: %s", gsub("\\.Rd", "", nm)),
      "=============================================",
      ""
    ),
    conn
  )
  tools::Rd2txt(rddb[[nm]], out = conn)
}

try(close(conn), silent = TRUE)
