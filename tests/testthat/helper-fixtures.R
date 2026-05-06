sample_preprint_data <- function() {
  data.frame(
    node = 1:5,
    title = c(
      "Dementia biomarker study",
      "Vascular Dementia cohort",
      "Asthma control trial",
      "Dementia biomarker study",
      "Lipid metabolism review"
    ),
    abstract = c(
      "Alzheimer disease biomarker signal",
      "Vascular risk and dementia outcome",
      "Respiratory intervention",
      "Updated Alzheimer disease biomarker signal",
      "Metabolic pathway"
    ),
    authors = c("Alpha; Beta", "Gamma; Delta", "Epsilon", "Alpha; Beta", "Zeta"),
    date = c("2020-01-02", "2020-02-03", "2020-03-04", "2020-04-05", "2020-05-06"),
    category = c("Neurology", "Neurology", "Respiratory", "Neurology", "Metabolism"),
    doi = c(
      "10.1101/2020.01.02.1",
      "10.1101/2020.02.03.2",
      "10.1101/2020.03.04.3",
      "10.1101/2020.01.02.1",
      "10.1101/2020.05.06.5"
    ),
    version = c(1L, 1L, 1L, 2L, 1L),
    author_corresponding = c("Alpha", "Gamma", "Epsilon", "Alpha", "Zeta"),
    author_corresponding_institution = c("Inst A", "Inst B", "Inst C", "Inst A", "Inst D"),
    link = paste0("/content/10.1101/sample", 1:5),
    pdf = paste0("/content/10.1101/sample", 1:5, ".full.pdf"),
    link_page = paste0("https://www.medrxiv.org/content/10.1101/sample", 1:5),
    link_pdf = paste0("https://www.medrxiv.org/content/10.1101/sample", 1:5, ".full.pdf"),
    license = rep("cc_by_nc_nd", 5),
    published = c(NA, NA, NA, "10.1000/published", NA),
    stringsAsFactors = FALSE
  )
}

sample_api_response <- function(collection = sample_preprint_data(), total = nrow(collection)) {
  list(
    messages = data.frame(
      status = "ok",
      interval = "2020-01-01:2020-12-31",
      cursor = 0L,
      count = total,
      total = total
    ),
    collection = collection
  )
}

sample_raw_api_data <- function() {
  data.frame(
    title = c("dementia trial", "asthma cohort"),
    authors = c("alpha; beta", "gamma"),
    author_corresponding = c("alpha", "gamma"),
    author_corresponding_institution = c("Inst A", "Inst B"),
    doi = c("10.1101/2020.01.02.1", "10.1101/2020.03.04.3"),
    date = c("2020-01-02", "2020-03-04"),
    version = c(1L, 1L),
    type = c("new", "new"),
    license = c("cc_by_nc_nd", "cc_by_nc_nd"),
    category = c("neurology", "respiratory"),
    jatsxml = c("", ""),
    abstract = c("alzheimer signal", "respiratory intervention"),
    published = c(NA, NA),
    server = c("medrxiv", "medrxiv"),
    stringsAsFactors = FALSE
  )
}

with_test_bindings <- function(env, bindings, code) {
  old <- vector("list", length(bindings))
  names(old) <- names(bindings)
  was_locked <- logical(length(bindings))
  names(was_locked) <- names(bindings)

  for (nm in names(bindings)) {
    old[[nm]] <- get(nm, envir = env)
    was_locked[[nm]] <- bindingIsLocked(nm, env)
    if (was_locked[[nm]]) unlockBinding(nm, env)
    assign(nm, bindings[[nm]], envir = env)
    if (was_locked[[nm]]) lockBinding(nm, env)
  }

  on.exit({
    for (nm in rev(names(bindings))) {
      if (bindingIsLocked(nm, env)) unlockBinding(nm, env)
      assign(nm, old[[nm]], envir = env)
      if (was_locked[[nm]]) lockBinding(nm, env)
    }
  }, add = TRUE)

  eval.parent(substitute(code))
}
