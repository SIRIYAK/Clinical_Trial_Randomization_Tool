# ============================================================================
# Clinical Trial Randomization Tool - Dependency Installer
# ============================================================================

# Check if packages are installed, install if missing
required_packages <- c(
  "shiny",
  "DT",
  "dplyr",
  "tidyr",
  "bslib",
  "plotly",
  "bsicons",
  "writexl"
)

cat("Clinical Trial Randomization Tool - Dependency Installer\n")
cat("========================================================\n\n")

# Check which packages are missing
installed <- rownames(installed.packages())
missing_packages <- setdiff(required_packages, installed)

if (length(missing_packages) > 0) {
  cat("Installing missing packages:\n")
  for (pkg in missing_packages) {
    cat(paste0("  - Installing ", pkg, "...\n"))
    install.packages(pkg, dependencies = TRUE, quiet = TRUE)
    cat(paste0("  ✓ ", pkg, " installed successfully\n"))
  }
  cat("\nAll packages installed!\n")
} else {
  cat("All required packages are already installed!\n")
}

cat("\nYou can now run the application with:\n")
cat("  Rscript -e \"shiny::runApp('app.R')\"\n")
cat("  or\n")
cat("  R -e \"shiny::runApp('app.R')\"\n\n")
