revdep <- function(x, pkgdep, dependencies = c("Depends", "Imports", "Suggests")) {
  rows <- (pkgdep$DepType %in% dependencies) & (pkgdep$Dep %in% x)
  unique(pkgdep$Package[rows])
}
