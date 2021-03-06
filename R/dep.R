#' @export
as_pkgdep <- function(x) {
  x <- as.data.frame(x)
  fields <- c("Package", "Depends", "Imports", "LinkingTo", "Suggests", "Enhances")
  stopifnot(fields %in% names(x))

  dep_fields <- setdiff(fields, "Package")
  new_dep_fields <- paste0("Dep.", dep_fields)

  x <- x[fields]
  names(x) <- c(setdiff(fields, dep_fields), new_dep_fields)

  x_long <- reshape(
    x,
    direction = "long",
    varying = new_dep_fields,
    timevar = "DepType",
    times = "Deps"
  )
  rownames(x_long) <- NULL
  x_long$id <- NULL
  x_long <- x_long[!is.na(x_long$Dep), ]
  x_long$Package <- as.character(x_long$Package)
  x_long$Dep <- as.character(x_long$Dep)

  x_long$Dep <- strsplit(x_long$Dep, ",[[:space:]]*", perl = TRUE)
  lengths <- lengths(x_long$Dep)
  idx <- rep(seq_along(lengths), lengths)

  x_unnested <- data.frame(
    Package = x_long$Package[idx],
    DepType = x_long$DepType[idx],
    Dep = unlist(x_long$Dep),
    stringsAsFactors = FALSE
  )

  version_rx <- "^([^\\s]+)[\\s]*(?:|[(]((?:.|\\s)*)[)])[\\s]*$"
  x_unnested$Version <- gsub(version_rx, "\\2", x_unnested$Dep, perl = TRUE)
  x_unnested$Version[x_unnested$Version == ""] <- NA_character_
  x_unnested$Dep <- gsub(version_rx, "\\1", x_unnested$Dep, perl = TRUE)

  x_unnested[x_unnested$Dep != "R", ]
}

#' @export
get_all_deps <- function(x, pkgdep, dependencies = TRUE) {
  if (isTRUE(dependencies)) {
    dependencies <- c("Depends", "Imports", "Suggests", "LinkingTo")
    next_dependencies <- c("Depends", "Imports", "LinkingTo")
  } else {
    next_dependencies <- dependencies
  }

  todo <- x
  ret <- pkgdep[0, ]
  while (length(todo) > 0) {
    rows <- (pkgdep$DepType %in% dependencies) & (pkgdep$Package %in% todo)
    new <- pkgdep[rows, ]
    ret <- rbind(ret, new)
    todo <- setdiff(new$Dep, ret$Package)
    dependencies <- next_dependencies
  }

  ret
}
