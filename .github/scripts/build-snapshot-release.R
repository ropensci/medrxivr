out_dir <- "snapshot-release"
dir.create(out_dir, showWarnings = FALSE, recursive = TRUE)

snapshot <- medrxivr::mx_api_content(server = "medrxiv")
snapshot_date <- max(as.Date(snapshot$date), na.rm = TRUE)

snapshot_file <- file.path(out_dir, "snapshot.csv.gz")
con <- gzfile(snapshot_file, open = "wt")
on.exit(if (isOpen(con)) close(con), add = TRUE)
utils::write.csv(snapshot, con, row.names = FALSE)
close(con)

repo <- Sys.getenv("GITHUB_REPOSITORY", "ropensci/medrxivr")
base_url <- sprintf("https://github.com/%s/releases/download/snapshot", repo)

manifest <- list(
  version = 1,
  generated_at = format(Sys.time(), "%Y-%m-%dT%H:%M:%SZ", tz = "UTC"),
  snapshot_date = as.character(snapshot_date),
  record_count = nrow(snapshot),
  files = list(list(
    name = basename(snapshot_file),
    url = sprintf("%s/%s", base_url, basename(snapshot_file))
  ))
)

jsonlite::write_json(
  manifest,
  file.path(out_dir, "snapshot-manifest.json"),
  auto_unbox = TRUE,
  pretty = TRUE
)
