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
    c("-v", "--vignette"),
    type = "character",
    default = NULL,
    help = "a vignette name",
    metavar = "character"
  ),
  optparse::make_option(
    c("-m", "--manual"),
    type = "character",
    default = NULL,
    help = "a manual page name",
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
Export specific manual pages or vignettes in an R package as plain text.
The package must be installed locally."
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
    sprintf("Package: %s", opt$package)
  ),
  conn
)

# Vignettes
if (!is.null(opt$vignette) && opt$vignette %in% gsub("\\.R?md", "", md)) {

  file = md[opt$vignette==gsub("\\.R?md", "", md)]
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
if (!is.null(opt$manual) && opt$manual %in% gsub("\\.Rd", "", names(rddb))) {
  nm = names(rddb)[opt$manual==gsub("\\.Rd", "", names(rddb))]
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
