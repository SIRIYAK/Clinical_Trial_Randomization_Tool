# ============================================================================
# Clinical Trial Randomization Builder & Envelope Generator
# Comprehensive Tool for All Trial Phases (Phase 1/2/3)
# Based on NCI Cancer Trials Randomization System
# ============================================================================

library(shiny)
library(DT)
library(dplyr)
library(tidyr)
library(bslib)
library(plotly)
library(bsicons)

# ============================================================================
# STRATIFICATION FACTORS DATABASE
# ============================================================================

stratification_factors <- list(
  pdl1_expression = list(
    levels = c("<1%", "1-49%", "≥50%"),
    label = "PDL1 Expression Level"
  ),
  histology = list(
    levels = c("Non-Squamous (NSQ)", "Squamous (SQ)"),
    label = "Histology Type"
  ),
  region = list(
    levels = c("East Asia", "Rest of World"),
    label = "Geographic Region"
  ),
  ecog_ps = list(
    levels = c("0", "1"),
    label = "ECOG Performance Status"
  ),
  age_group = list(
    levels = c("<65 years", "≥65 years"),
    label = "Age Group"
  ),
  gender = list(
    levels = c("Male", "Female"),
    label = "Gender"
  )
)

# ============================================================================
# TRIAL PHASE CONFIGURATIONS
# ============================================================================

trial_phases_config <- list(
  phase1 = list(
    name = "Phase 1: Dose Optimization",
    description = "Dose escalation to identify optimal dose with safety and efficacy",
    n_target = 120,
    arms = list(
      arm1 = list(
        name = "Arm 1: Control",
        treatment = "Placebo + Pembrolizumab + Chemotherapy",
        ratio = 1
      ),
      arm2 = list(
        name = "Arm 2: EIK1001 Low Dose",
        treatment = "EIK1001 0.45 mg/m² + Pembrolizumab + Chemotherapy",
        ratio = 1
      ),
      arm3 = list(
        name = "Arm 3: EIK1001 High Dose",
        treatment = "EIK1001 0.60 mg/m² + Pembrolizumab + Chemotherapy",
        ratio = 1
      )
    ),
    randomization_ratio = "1:1:1",
    stratification = c("pdl1_expression", "histology", "region"),
    dose_escalation = TRUE
  ),
  phase2 = list(
    name = "Phase 2: Dose Expansion",
    description = "Expansion with selected dose to confirm efficacy",
    n_target = 160,
    arms = list(
      arm1 = list(
        name = "Arm 1: Control",
        treatment = "Placebo + Pembrolizumab + Chemotherapy",
        ratio = 1
      ),
      arm2 = list(
        name = "Arm 2: EIK1001 Selected Dose",
        treatment = "EIK1001 [Selected Dose] + Pembrolizumab + Chemotherapy",
        ratio = 1
      )
    ),
    randomization_ratio = "1:1",
    stratification = c("pdl1_expression", "histology", "region"),
    dose_escalation = FALSE
  ),
  phase3 = list(
    name = "Phase 3: Confirmatory Testing",
    description = "Confirmatory phase with selected dose vs standard of care",
    n_target = 440,
    arms = list(
      arm1 = list(
        name = "Arm 1: Control",
        treatment = "Placebo + Pembrolizumab + Chemotherapy",
        ratio = 1
      ),
      arm2 = list(
        name = "Arm 2: EIK1001 Selected Dose",
        treatment = "EIK1001 [Selected Dose] + Pembrolizumab + Chemotherapy",
        ratio = 1
      )
    ),
    randomization_ratio = "1:1",
    stratification = c("pdl1_expression", "histology", "region"),
    dose_escalation = FALSE
  )
)

# ============================================================================
# TREATMENT REGIMENS DATABASE
# ============================================================================

chemotherapy_regimens <- list(
  nsq = list(
    carboplatin_pemetrexed = list(
      name = "Carboplatin + Pemetrexed",
      drugs = c("Carboplatin (AUC 5-6)", "Pemetrexed (500 mg/m²)"),
      cycle = "Q3W",
      cycles = 4
    ),
    cisplatin_pemetrexed = list(
      name = "Cisplatin + Pemetrexed",
      drugs = c("Cisplatin (75 mg/m²)", "Pemetrexed (500 mg/m²)"),
      cycle = "Q3W",
      cycles = 4
    ),
    carboplatin_paclitaxel = list(
      name = "Carboplatin + Paclitaxel",
      drugs = c("Carboplatin (AUC 6)", "Paclitaxel (200 mg/m²)"),
      cycle = "Q3W",
      cycles = 4
    )
  ),
  sq = list(
    carboplatin_paclitaxel = list(
      name = "Carboplatin + Paclitaxel",
      drugs = c("Carboplatin (AUC 6)", "Paclitaxel (200 mg/m²)"),
      cycle = "Q3W",
      cycles = 4
    ),
    cisplatin_gemcitabine = list(
      name = "Cisplatin + Gemcitabine",
      drugs = c("Cisplatin (75 mg/m²)", "Gemcitabine (1250 mg/m²)"),
      cycle = "Q3W",
      cycles = 4
    ),
    carboplatin_nab_paclitaxel = list(
      name = "Carboplatin + Nab-Paclitaxel",
      drugs = c("Carboplatin (AUC 6)", "Nab-Paclitaxel (100 mg/m²)"),
      cycle = "Q3W",
      cycles = 4
    )
  )
)

# ============================================================================
# DOSE ESCALATION SCHEMES
# ============================================================================

dose_escalation_schemes <- list(
  three_plus_three = list(
    name = "3+3 Design",
    description = "Standard 3+3 dose escalation",
    cohort_size = 3,
    max_cohort_size = 6,
    dose_levels = c(0.30, 0.45, 0.60, 0.75),
    escalation_step = 0.15
  ),
  continual_reassessment = list(
    name = "Continual Reassessment Method (CRM)",
    description = "Model-based dose escalation",
    target_toxicity_rate = 0.25,
    dose_levels = c(0.30, 0.45, 0.60, 0.75),
    model = "logistic"
  ),
  accelerated = list(
    name = "Accelerated Titration",
    description = "Single patient cohorts with rapid escalation",
    cohort_size = 1,
    dose_levels = c(0.30, 0.45, 0.60, 0.75, 0.90),
    switch_to_3plus3_at = 2
  )
)

# ============================================================================
# UTILITY FUNCTIONS
# ============================================================================

generate_strata_combinations <- function(factors) {
  # Generate all possible stratification combinations
  factor_levels <- lapply(factors, function(f) stratification_factors[[f]]$levels)
  expand.grid(factor_levels, stringsAsFactors = FALSE)
}

block_randomization <- function(n, block_size, arm_ratios) {
  # Block randomization with specified ratios
  n_arms <- length(arm_ratios)
  block <- rep(1:n_arms, times = arm_ratios)
  
  # Shuffle block
  block <- sample(block)
  
  # Repeat blocks
  n_blocks <- ceiling(n / length(block))
  full_sequence <- rep(block, n_blocks)
  
  return(head(full_sequence, n))
}

stratified_randomization <- function(n, strata_df, arm_ratios) {
  # Stratified block randomization
  strata_combinations <- unique(strata_df)
  n_strata <- nrow(strata_combinations)
  
  randomization_list <- data.frame(
    stratum_id = integer(),
    arm_assignment = integer(),
    stringsAsFactors = FALSE
  )
  
  for (i in 1:n_strata) {
    # Count patients in this stratum
    stratum_count <- sum(apply(strata_df, 1, function(row) {
      all(row == strata_combinations[i, ])
    }))
    
    # Generate block randomization for this stratum
    assignments <- block_randomization(stratum_count, sum(arm_ratios), arm_ratios)
    
    # Add to results
    stratum_data <- data.frame(
      stratum_id = rep(i, stratum_count),
      arm_assignment = assignments,
      stringsAsFactors = FALSE
    )
    randomization_list <- rbind(randomization_list, stratum_data)
  }
  
  return(randomization_list)
}

generate_envelopes <- function(randomization_list, n_envelopes, include_blinding = TRUE) {
  # Generate randomization envelopes
  envelopes <- data.frame(
    envelope_number = 1:n_envelopes,
    patient_id = character(n_envelopes),
    stratum_id = randomization_list$arm_assignment[1:n_envelopes],
    arm_assignment = randomization_list$arm_assignment[1:n_envelopes],
    randomization_date = as.Date(NA),
    opened = FALSE,
    opened_date = as.Date(NA),
    operator = character(n_envelopes),
    stringsAsFactors = FALSE
  )
  
  if (include_blinding) {
    envelopes <- envelopes %>%
      mutate(
        blinded_arm = paste0("Treatment Arm ", arm_assignment),
        treatment_revealed = FALSE
      )
  }
  
  return(envelopes)
}

simulate_dose_escalation <- function(scheme, n_cohorts = 10) {
  # Simulate dose escalation trial
  dose_levels <- scheme$dose_levels
  n_doses <- length(dose_levels)
  
  results <- data.frame(
    cohort = 1:n_cohorts,
    dose_level = numeric(n_cohorts),
    n_patients = numeric(n_cohorts),
    n_dlt = numeric(n_cohorts),
    dlt_rate = numeric(n_cohorts),
    decision = character(n_cohorts, stringsAsFactors = FALSE),
    stringsAsFactors = FALSE
  )
  
  current_dose_idx <- 1
  escalation <- TRUE
  
  for (cohort in 1:n_cohorts) {
    if (!escalation) break
    
    n_patients <- scheme$cohort_size
    results$dose_level[cohort] <- dose_levels[current_dose_idx]
    results$n_patients[cohort] <- n_patients
    
    # Simulate DLTs (assume increasing probability with dose)
    dlt_prob <- 0.05 + (current_dose_idx / n_doses) * 0.30
    n_dlt <- rbinom(1, n_patients, dlt_prob)
    results$n_dlt[cohort] <- n_dlt
    results$dlt_rate[cohort] <- n_dlt / n_patients
    
    # Decision logic
    if (n_dlt == 0) {
      results$decision[cohort] <- "Escalate"
      if (current_dose_idx < n_doses) {
        current_dose_idx <- current_dose_idx + 1
      } else {
        escalation <- FALSE
        results$decision[cohort] <- "MTD Reached"
      }
    } else if (n_dlt == 1) {
      results$decision[cohort] <- "Expand Cohort"
      # Simulate expansion
      results$n_patients[cohort] <- n_patients + scheme$max_cohort_size - scheme$cohort_size
      expansion_dlt <- rbinom(1, scheme$max_cohort_size - scheme$cohort_size, dlt_prob)
      results$n_dlt[cohort] <- n_dlt + expansion_dlt
      results$dlt_rate[cohort] <- results$n_dlt[cohort] / results$n_patients[cohort]
      
      if (results$n_dlt[cohort] <= 1) {
        results$decision[cohort] <- "Escalate"
        if (current_dose_idx < n_doses) {
          current_dose_idx <- current_dose_idx + 1
        } else {
          escalation <- FALSE
          results$decision[cohort] <- "MTD Reached"
        }
      } else {
        results$decision[cohort] <- "De-escalate"
        current_dose_idx <- max(1, current_dose_idx - 1)
      }
    } else {
      results$decision[cohort] <- "De-escalate"
      current_dose_idx <- max(1, current_dose_idx - 1)
    }
  }
  
  # Identify MTD
  mtd_idx <- which(results$decision == "MTD Reached" | 
                   (c(results$decision[-1], "") == "De-escalate" & results$decision == "Escalate"))
  if (length(mtd_idx) > 0) {
    results$mtd <- FALSE
    results$mtd[max(mtd_idx)] <- TRUE
  }
  
  return(results)
}

generate_patient_data <- function(n, stratification_factors_list) {
  # Generate realistic patient stratification data
  set.seed(123)
  
  # Generate stratification combinations
  strata <- generate_strata_combinations(stratification_factors_list)
  n_strata <- nrow(strata)
  
  # Assign patients to strata with realistic probabilities
  strata_probs <- c(0.15, 0.10, 0.15, 0.10, 0.15, 0.10, 0.15, 0.10)  # Adjust as needed
  strata_probs <- strata_probs[1:min(n_strata, length(strata_probs))]
  strata_probs <- strata_probs / sum(strata_probs)
  
  patient_strata <- sample(1:n_strata, n, replace = TRUE, prob = strata_probs)
  
  # Generate patient IDs
  patient_ids <- sprintf("PT-%04d", 1:n)
  
  # Generate enrollment dates
  enrollment_dates <- seq(as.Date("2024-01-01"), by = "1 day", length.out = n)
  
  # Generate demographic data
  ages <- round(rnorm(n, 62, 10), 1)
  ages <- pmax(18, pmin(85, ages))
  gender <- sample(c("Male", "Female"), n, replace = TRUE, prob = c(0.60, 0.40))
  
  # Build patient data
  patient_data <- data.frame(
    patient_id = patient_ids,
    enrollment_date = enrollment_dates,
    age = ages,
    gender = gender,
    stringsAsFactors = FALSE
  )
  
  # Add stratification factors
  for (i in seq_along(stratification_factors_list)) {
    factor_name <- stratification_factors_list[[i]]
    col_name <- factor_name
    patient_data[[col_name]] <- strata[[factor_name]][patient_strata]
  }
  
  patient_data$stratum_id <- patient_strata
  
  return(patient_data)
}

simulate_trial_outcomes <- function(n_patients, arms, phase_config) {
  # Simulate trial outcomes based on phase
  set.seed(456)
  
  # Base response rates
  if (phase_config$dose_escalation) {
    # Phase 1: Lower response rates, focus on safety
    response_rates <- c(0.15, 0.20, 0.25)  # Placebo, Low dose, High dose
  } else if (grepl("Phase 2", phase_config$name)) {
    # Phase 2: Moderate response rates
    response_rates <- c(0.20, 0.35)
  } else {
    # Phase 3: Higher response rates
    response_rates <- c(0.25, 0.40)
  }
  
  # Assign arms
  n_arms <- length(arms)
  arm_assignments <- sample(1:n_arms, n_patients, replace = TRUE,
                           prob = sapply(arms, function(a) a$ratio))
  
  # Generate outcomes
  outcomes <- data.frame(
    patient_id = sprintf("PT-%04d", 1:n_patients),
    arm_assignment = arm_assignments,
    treatment = sapply(arm_assignments, function(a) arms[[a]]$treatment),
    stringsAsFactors = FALSE
  )
  
  # Simulate response
  outcomes$response <- sapply(1:n_patients, function(i) {
    arm_idx <- arm_assignments[i]
    prob_response <- response_rates[arm_idx]
    sample(c("Complete Response", "Partial Response", "Stable Disease", "Progressive Disease"),
           1, prob = c(prob_response * 0.3, prob_response * 0.5, (1 - prob_response) * 0.6, (1 - prob_response) * 0.4))
  })
  
  # Simulate adverse events
  outcomes$grade_3_4_ae <- rbinom(n_patients, 1, 0.15 + arm_assignments * 0.05)
  outcomes$serious_ae <- rbinom(n_patients, 1, 0.05 + arm_assignments * 0.02)
  
  # Simulate progression-free survival
  outcomes$pfs_months <- rexp(n_patients, rate = 0.1 + arm_assignments * 0.02)
  outcomes$pfs_months <- round(outcomes$pfs_months, 1)
  
  # Simulate overall survival
  outcomes$os_months <- rexp(n_patients, rate = 0.08 + arm_assignments * 0.015)
  outcomes$os_months <- round(outcomes$os_months, 1)
  
  return(outcomes)
}

# ============================================================================
# UI DEFINITION
# ============================================================================

ui <- fluidPage(
  theme = bs_theme(
    version = 5,
    bootswatch = "flatly",
    primary = "#1a5276",
    secondary = "#2874a6",
    success = "#27ae60",
    info = "#2980b9",
    warning = "#f39c12",
    danger = "#e74c3c"
  ),
  
  tags$head(
    tags$style(HTML("
      .trial-header {
        background: linear-gradient(135deg, #1a5276 0%, #2874a6 100%);
        color: white;
        padding: 20px;
        box-shadow: 0 2px 4px rgba(0,0,0,0.1);
      }
      .phase-card {
        border: 2px solid #2874a6;
        border-radius: 10px;
        padding: 15px;
        margin: 10px;
        background: white;
        transition: all 0.3s;
        cursor: pointer;
      }
      .phase-card:hover {
        box-shadow: 0 4px 8px rgba(0,0,0,0.2);
        transform: translateY(-2px);
      }
      .phase-card.active {
        background: #2874a6;
        color: white;
      }
      .stratum-badge {
        display: inline-block;
        background: #e8f6f3;
        color: #1a5276;
        padding: 5px 10px;
        border-radius: 15px;
        margin: 3px;
        font-size: 12px;
        border: 1px solid #2874a6;
      }
      .arm-badge {
        display: inline-block;
        background: #fef9e7;
        color: #7d6608;
        padding: 8px 12px;
        border-radius: 5px;
        margin: 5px;
        border: 2px solid #f39c12;
        font-weight: bold;
      }
      .stat-card {
        background: white;
        border-radius: 8px;
        padding: 15px;
        box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        text-align: center;
        margin: 10px;
      }
      .stat-value {
        font-size: 32px;
        font-weight: bold;
        color: #1a5276;
      }
      .stat-label {
        font-size: 14px;
        color: #666;
        margin-top: 5px;
      }
      .envelope-card {
        background: #fef9e7;
        border: 2px dashed #f39c12;
        border-radius: 8px;
        padding: 10px;
        margin: 8px;
        text-align: center;
      }
      .progress-bar-custom {
        background-color: #2874a6;
      }
    "))
  ),
  
  # Header
  div(class = "trial-header",
      fluidRow(
        column(8,
               h2("Clinical Trial Randomization Builder", style = "margin: 0;"),
               h4("Phase I/II/III Trial Design & Simulation Platform", style = "margin: 5px 0 0 0; opacity: 0.9;")
        ),
        column(4,
               div(style = "text-align: right; margin-top: 10px;",
                   selectInput("trialTemplate", "Trial Template:",
                              choices = c("EIK1001 NSCLC Phase I/II/III", 
                                        "Custom Phase I", 
                                        "Custom Phase II",
                                        "Custom Phase III",
                                        "Basket Trial",
                                        "Umbrella Trial"),
                              selected = "EIK1001 NSCLC Phase I/II/III",
                              width = "100%")
               )
        )
      )
  ),
  
  # Trial Schema Overview
  div(style = "padding: 20px; background: #f8f9fa;",
      fluidRow(
        column(12,
               h4("Trial Schema", style = "color: #1a5276; border-bottom: 3px solid #2874a6; padding-bottom: 10px;"),
               div(style = "background: white; padding: 20px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1);",
                   uiOutput("trialSchemaVisual")
               )
        )
      )
  ),
  
  # Main Content Area
  fluidRow(
    column(12,
           tabsetPanel(id = "mainTabs",
                       tabPanel("Phase Selection", icon = icon("layer-group")),
                       tabPanel("Stratification", icon = icon("sitemap")),
                       tabPanel("Randomization Builder", icon = icon("random")),
                       tabPanel("Envelope Generator", icon = icon("envelope-open")),
                       tabPanel("Simulation & Outcomes", icon = icon("chart-line")),
                       tabPanel("Monitoring Dashboard", icon = icon("tachometer-alt")),
                       tabPanel("Export & Reports", icon = icon("file-export"))
           )
    )
  ),
  
  # Phase Selection Panel
  conditionalPanel(
    condition = "input.mainTabs == 'Phase Selection'",
    div(style = "padding: 20px;",
        fluidRow(
          column(12,
                 h4("Select Trial Phase", style = "color: #1a5276;"),
                 p("Choose the phase of clinical trial to configure randomization parameters")
          )
        ),
        fluidRow(
          column(4,
                 div(class = "phase-card",
                     onclick = "Shiny.setInputValue('selectedPhase', 'phase1');",
                     h4("Phase 1"),
                     h5("Dose Optimization", style = "color: #2874a6;"),
                     p("N = 120 patients"),
                     p("3 treatment arms (1:1:1)"),
                     p("Dose escalation to identify MTD"),
                     tags$ul(
                       tags$li("Arm 1: Placebo + Pembro + Chemo"),
                       tags$li("Arm 2: EIK1001 0.45 mg/m² + Pembro + Chemo"),
                       tags$li("Arm 3: EIK1001 0.60 mg/m² + Pembro + Chemo")
                     )
                 )
          ),
          column(4,
                 div(class = "phase-card",
                     onclick = "Shiny.setInputValue('selectedPhase', 'phase2');",
                     h4("Phase 2"),
                     h5("Dose Expansion", style = "color: #2874a6;"),
                     p("N = 160 additional patients"),
                     p("2 treatment arms (1:1)"),
                     p("Expansion with selected dose"),
                     tags$ul(
                       tags$li("Arm 1: Placebo + Pembro + Chemo"),
                       tags$li("Arm 2: EIK1001 [Selected] + Pembro + Chemo")
                     )
                 )
          ),
          column(4,
                 div(class = "phase-card",
                     onclick = "Shiny.setInputValue('selectedPhase', 'phase3');",
                     h4("Phase 3"),
                     h5("Confirmatory Testing", style = "color: #2874a6;"),
                     p("N = 440 additional patients"),
                     p("2 treatment arms (1:1)"),
                     p("Confirm efficacy and safety"),
                     tags$ul(
                       tags$li("Arm 1: Placebo + Pembro + Chemo"),
                       tags$li("Arm 2: EIK1001 [Selected] + Pembro + Chemo")
                     )
                 )
          )
        ),
        fluidRow(
          column(12,
                 div(style = "background: white; padding: 20px; border-radius: 8px; margin-top: 20px;",
                     h5("Selected Phase Details"),
                     uiOutput("phaseDetails")
                 )
          )
        )
    )
  ),
  
  # Stratification Panel
  conditionalPanel(
    condition = "input.mainTabs == 'Stratification'",
    div(style = "padding: 20px;",
        fluidRow(
          column(6,
                 h4("Stratification Factors", style = "color: #1a5276;"),
                 p("Select factors for stratified randomization"),
                 div(style = "background: white; padding: 20px; border-radius: 8px;",
                     checkboxGroupInput("stratFactors", "Select Stratification Factors:",
                                       choices = c(
                                         "PDL1 Expression Level (<1% vs 1-49% vs ≥50%)" = "pdl1_expression",
                                         "Histology (NSQ vs SQ)" = "histology",
                                         "Geographic Region (East Asia vs Rest of World)" = "region",
                                         "ECOG Performance Status (0 vs 1)" = "ecog_ps",
                                         "Age Group (<65 vs ≥65)" = "age_group",
                                         "Gender (Male vs Female)" = "gender"
                                       ),
                                       selected = c("pdl1_expression", "histology", "region")),
                     hr(),
                     actionButton("generateStrata", "Generate Strata Combinations", 
                                 icon = icon("cogs"), class = "btn-primary")
                 )
          ),
          column(6,
                 h4("Strata Combinations", style = "color: #1a5276;"),
                 div(style = "background: white; padding: 20px; border-radius: 8px; max-height: 500px; overflow-y: auto;",
                     uiOutput("strataTable")
                 )
          )
        ),
        fluidRow(
          column(12,
                 div(style = "background: white; padding: 20px; border-radius: 8px; margin-top: 20px;",
                     h5("Stratification Summary"),
                     fluidRow(
                       column(4, div(class = "stat-card",
                                     uiOutput("nStrata"),
                                     div(class = "stat-label", "Total Strata"))),
                       column(4, div(class = "stat-card",
                                     uiOutput("minPerStratum"),
                                     div(class = "stat-label", "Min Patients per Stratum"))),
                       column(4, div(class = "stat-card",
                                     uiOutput("maxPerStratum"),
                                     div(class = "stat-label", "Max Patients per Stratum")))
                     )
                 )
          )
        )
    )
  ),
  
  # Randomization Builder Panel
  conditionalPanel(
    condition = "input.mainTabs == 'Randomization Builder'",
    div(style = "padding: 20px;",
        fluidRow(
          column(6,
                 h4("Randomization Parameters", style = "color: #1a5276;"),
                 div(style = "background: white; padding: 20px; border-radius: 8px;",
                     numericInput("totalPatients", "Total Number of Patients:", 
                                 value = 120, min = 10, max = 1000),
                     textInput("randomizationRatio", "Randomization Ratio (e.g., 1:1:1):", 
                              value = "1:1:1"),
                     selectInput("blockSize", "Block Size:",
                                choices = c(4, 6, 8, 12),
                                selected = 6),
                     checkboxInput("stratifiedRandomization", "Use Stratified Randomization", 
                                  value = TRUE),
                     hr(),
                     actionButton("generateRandomization", "Generate Randomization List",
                                 icon = icon("magic"), class = "btn-primary")
                 )
          ),
          column(6,
                 h4("Treatment Arms", style = "color: #1a5276;"),
                 div(style = "background: white; padding: 20px; border-radius: 8px;",
                     uiOutput("treatmentArms")
                 )
          )
        ),
        fluidRow(
          column(12,
                 div(style = "background: white; padding: 20px; border-radius: 8px; margin-top: 20px;",
                     h5("Randomization List"),
                     DTOutput("randomizationTable")
                 )
          )
        )
    )
  ),
  
  # Envelope Generator Panel
  conditionalPanel(
    condition = "input.mainTabs == 'Envelope Generator'",
    div(style = "padding: 20px;",
        fluidRow(
          column(4,
                 h4("Envelope Configuration", style = "color: #1a5276;"),
                 div(style = "background: white; padding: 20px; border-radius: 8px;",
                     numericInput("nEnvelopes", "Number of Envelopes:",
                                 value = 120, min = 10, max = 1000),
                     checkboxInput("includeBlinding", "Include Blinding Information", 
                                  value = TRUE),
                     textInput("siteCode", "Site Code:", value = "SITE001"),
                     dateInput("generationDate", "Generation Date:", 
                              value = Sys.Date()),
                     hr(),
                     actionButton("generateEnvelopes", "Generate Envelopes",
                                 icon = icon("envelope"), class = "btn-primary"),
                     actionButton("downloadEnvelopes", "Download Envelope PDF",
                                 icon = icon("download"), class = "btn-success")
                 )
          ),
          column(8,
                 h4("Randomization Envelopes", style = "color: #1a5276;"),
                 div(style = "background: white; padding: 20px; border-radius: 8px;",
                     uiOutput("envelopePreview")
                 )
          )
        ),
        fluidRow(
          column(12,
                 div(style = "background: white; padding: 20px; border-radius: 8px; margin-top: 20px;",
                     h5("Envelope Log"),
                     DTOutput("envelopeTable")
                 )
          )
        )
    )
  ),
  
  # Simulation Panel
  conditionalPanel(
    condition = "input.mainTabs == 'Simulation & Outcomes'",
    div(style = "padding: 20px;",
        fluidRow(
          column(12,
                 h4("Trial Simulation", style = "color: #1a5276;"),
                 div(style = "background: white; padding: 20px; border-radius: 8px;",
                     fluidRow(
                       column(4,
                              selectInput("doseEscalationScheme", "Dose Escalation Scheme:",
                                         choices = c("3+3 Design", 
                                                   "Continual Reassessment Method (CRM)",
                                                   "Accelerated Titration"),
                                         selected = "3+3 Design"),
                              numericInput("nCohorts", "Number of Cohorts:",
                                          value = 10, min = 3, max = 20)
                       ),
                       column(4,
                              numericInput("simulationRuns", "Number of Simulation Runs:",
                                          value = 100, min = 10, max = 1000),
                              selectInput("outcomeEndpoint", "Primary Endpoint:",
                                         choices = c("Objective Response Rate (ORR)",
                                                   "Progression-Free Survival (PFS)",
                                                   "Overall Survival (OS)",
                                                   "Disease Control Rate (DCR)"),
                                         selected = "Objective Response Rate (ORR)")
                       ),
                       column(4,
                              actionButton("runSimulation", "Run Simulation",
                                          icon = icon("play-circle"), 
                                          class = "btn-primary",
                                          style = "margin-top: 32px; width: 100%;"),
                              actionButton("resetSimulation", "Reset",
                                          icon = icon("undo"), 
                                          class = "btn-secondary",
                                          style = "margin-top: 10px; width: 100%;")
                       )
                     )
                 )
          )
        ),
        fluidRow(
          column(6,
                 div(style = "background: white; padding: 20px; border-radius: 8px; margin-top: 20px;",
                     h5("Dose Escalation Results"),
                     plotOutput("doseEscalationPlot", height = 400)
                 )
          ),
          column(6,
                 div(style = "background: white; padding: 20px; border-radius: 8px; margin-top: 20px;",
                     h5("Treatment Response by Arm"),
                     plotOutput("responsePlot", height = 400)
                 )
          )
        ),
        fluidRow(
          column(12,
                 div(style = "background: white; padding: 20px; border-radius: 8px; margin-top: 20px;",
                     h5("Simulation Results Summary"),
                     DTOutput("simulationResultsTable")
                 )
          )
        )
    )
  ),
  
  # Monitoring Dashboard Panel
  conditionalPanel(
    condition = "input.mainTabs == 'Monitoring Dashboard'",
    div(style = "padding: 20px;",
        fluidRow(
          column(3, div(class = "stat-card",
                        div(class = "stat-value", "120"),
                        div(class = "stat-label", "Enrolled"))),
          column(3, div(class = "stat-card",
                        div(class = "stat-value", "95"),
                        div(class = "stat-label", "Randomized"))),
          column(3, div(class = "stat-card",
                        div(class = "stat-value", "25"),
                        div(class = "stat-label", "Screen Failures"))),
          column(3, div(class = "stat-card",
                        div(class = "stat-value", "87%"),
                        div(class = "stat-label", "Randomization Rate")))
        ),
        fluidRow(
          column(6,
                 div(style = "background: white; padding: 20px; border-radius: 8px; margin-top: 20px;",
                     h5("Enrollment by Phase"),
                     plotOutput("enrollmentPlot", height = 300)
                 )
          ),
          column(6,
                 div(style = "background: white; padding: 20px; border-radius: 8px; margin-top: 20px;",
                     h5("Arm Balance Monitoring"),
                     plotOutput("armBalancePlot", height = 300)
                 )
          )
        ),
        fluidRow(
          column(12,
                 div(style = "background: white; padding: 20px; border-radius: 8px; margin-top: 20px;",
                     h5("Real-Time Randomization Log"),
                     DTOutput("monitoringTable")
                 )
          )
        )
    )
  ),
  
  # Export Panel
  conditionalPanel(
    condition = "input.mainTabs == 'Export & Reports'",
    div(style = "padding: 20px;",
        fluidRow(
          column(6,
                 h4("Export Data", style = "color: #1a5276;"),
                 div(style = "background: white; padding: 20px; border-radius: 8px;",
                     checkboxGroupInput("exportItems", "Select Items to Export:",
                                       choices = c("Randomization List",
                                                 "Envelope Log",
                                                 "Patient Stratification Data",
                                                 "Simulation Results",
                                                 "Trial Summary Report"),
                                       selected = c("Randomization List", 
                                                  "Envelope Log",
                                                  "Trial Summary Report")),
                     radioButtons("exportFormat", "Export Format:",
                                 choices = c("CSV", "Excel", "PDF Report"),
                                 selected = "CSV", inline = TRUE),
                     hr(),
                     actionButton("exportData", "Download Export",
                                 icon = icon("download"), class = "btn-primary")
                 )
          ),
          column(6,
                 h4("Trial Summary Report", style = "color: #1a5276;"),
                 div(style = "background: white; padding: 20px; border-radius: 8px;",
                     uiOutput("trialSummary")
                 )
          )
        )
    )
  )
)

# ============================================================================
# SERVER LOGIC
# ============================================================================

server <- function(input, output, session) {
  
  # Reactive values
  selected_phase <- reactiveVal("phase1")
  strata_data <- reactiveVal(NULL)
  randomization_list <- reactiveVal(NULL)
  envelope_data <- reactiveVal(NULL)
  simulation_results <- reactiveVal(NULL)
  
  # Observe phase selection
  observeEvent(input$selectedPhase, {
    selected_phase(input$selectedPhase)
  })
  
  # Display trial schema
  output$trialSchemaVisual <- renderUI({
    phase <- selected_phase()
    config <- trial_phases_config[[phase]]
    
    HTML(paste0("
      <div style='text-align: center;'>
        <h5>", config$name, "</h5>
        <p>", config$description, "</p>
        <div style='margin: 20px 0;'>
          <div class='arm-badge'>", config$arms$arm1$name, "<br><small>", config$arms$arm1$treatment, "</small></div>
          <div class='arm-badge'>", config$arms$arm2$name, "<br><small>", config$arms$arm2$treatment, "</small></div>
          ", if(phase == "phase1") paste0("<div class='arm-badge'>", config$arms$arm3$name, "<br><small>", config$arms$arm3$treatment, "</small></div>"), "
        </div>
        <p><strong>Randomization Ratio:</strong> ", config$randomization_ratio, "</p>
        <p><strong>Target Enrollment:</strong> N = ", config$n_target, "</p>
        <p><strong>Stratification:</strong> ", paste(config$stratification, collapse = ", "), "</p>
      </div>
    "))
  })
  
  # Display phase details
  output$phaseDetails <- renderUI({
    phase <- selected_phase()
    config <- trial_phases_config[[phase]]
    
    fluidRow(
      column(4, div(class = "stat-card",
                    div(class = "stat-value", config$n_target),
                    div(class = "stat-label", "Target Patients"))),
      column(4, div(class = "stat-card",
                    div(class = "stat-value", length(config$arms)),
                    div(class = "stat-label", "Treatment Arms"))),
      column(4, div(class = "stat-card",
                    div(class = "stat-value", config$randomization_ratio),
                    div(class = "stat-label", "Randomization Ratio")))
    )
  })
  
  # Generate strata combinations
  observeEvent(input$generateStrata, {
    factors <- input$stratFactors
    if (length(factors) == 0) {
      showNotification("Please select at least one stratification factor", type = "warning")
      return()
    }
    
    strata <- generate_strata_combinations(factors)
    strata_data(strata)
  })
  
  # Display strata table
  output$strataTable <- renderUI({
    strata <- strata_data()
    
    if (is.null(strata)) {
      return(p("Click 'Generate Strata Combinations' to see strata", style = "color: #999;"))
    }
    
    n_strata <- nrow(strata)
    n_cols <- ncol(strata)
    
    table_html <- "<table class='table table-striped table-sm'><thead><tr>"
    for (col in names(strata)) {
      table_html <- paste0(table_html, "<th>", stratification_factors[[col]]$label, "</th>")
    }
    table_html <- paste0(table_html, "<th>Stratum ID</th></tr></thead><tbody>")
    
    for (i in 1:n_strata) {
      table_html <- paste0(table_html, "<tr>")
      for (j in 1:n_cols) {
        table_html <- paste0(table_html, "<td><span class='stratum-badge'>", strata[i, j], "</span></td>")
      }
      table_html <- paste0(table_html, "<td><strong>", i, "</strong></td></tr>")
    }
    table_html <- paste0(table_html, "</tbody></table>")
    
    HTML(table_html)
  })
  
  # Summary statistics for strata
  output$nStrata <- renderUI({
    strata <- strata_data()
    if (is.null(strata)) return("0")
    nrow(strata)
  })
  
  output$minPerStratum <- renderUI({
    strata <- strata_data()
    if (is.null(strata)) return("N/A")
    phase <- selected_phase()
    n_patients <- trial_phases_config[[phase]]$n_target
    n_strata <- nrow(strata)
    floor(n_patients / n_strata)
  })
  
  output$maxPerStratum <- renderUI({
    strata <- strata_data()
    if (is.null(strata)) return("N/A")
    phase <- selected_phase()
    n_patients <- trial_phases_config[[phase]]$n_target
    n_strata <- nrow(strata)
    ceiling(n_patients / n_strata)
  })
  
  # Display treatment arms
  output$treatmentArms <- renderUI({
    phase <- selected_phase()
    config <- trial_phases_config[[phase]]
    
    tagList(
      lapply(names(config$arms), function(arm_name) {
        arm <- config$arms[[arm_name]]
        div(style = "background: #f8f9fa; padding: 15px; border-radius: 5px; margin: 10px 0; border-left: 4px solid #2874a6;",
            h5(arm$name, style = "margin: 0 0 10px 0;"),
            p(arm$treatment, style = "margin: 0;"),
            p(paste("Ratio:", arm$ratio), style = "margin: 5px 0 0 0; color: #666;")
        )
      })
    )
  })
  
  # Generate randomization list
  observeEvent(input$generateRandomization, {
    n_patients <- input$totalPatients
    phase <- selected_phase()
    config <- trial_phases_config[[phase]]
    
    # Parse randomization ratio
    ratios <- as.numeric(strsplit(input$randomizationRatio, ":")[[1]])
    
    # Generate patient data with stratification
    if (input$stratifiedRandomization && !is.null(strata_data())) {
      strata <- strata_data()
      patient_data <- generate_patient_data(n_patients, input$stratFactors)
      
      # Generate stratified randomization
      rand_list <- stratified_randomization(n_patients, patient_data[, input$stratFactors], ratios)
      
      # Merge with patient data
      randomization_list(cbind(patient_data, rand_list))
    } else {
      # Simple block randomization
      arm_assignments <- block_randomization(n_patients, input$blockSize, ratios)
      
      randomization_list(data.frame(
        patient_id = sprintf("PT-%04d", 1:n_patients),
        arm_assignment = arm_assignments,
        stringsAsFactors = FALSE
      ))
    }
  })
  
  # Display randomization table
  output$randomizationTable <- renderDT({
    rand <- randomization_list()
    if (is.null(rand)) return(datatable(data.frame()))
    datatable(rand, options = list(pageLength = 15, searching = TRUE))
  })
  
  # Generate envelopes
  observeEvent(input$generateEnvelopes, {
    n_envelopes <- input$nEnvelopes
    rand <- randomization_list()
    
    if (is.null(rand) || nrow(rand) < n_envelopes) {
      # Generate randomization if not available
      phase <- selected_phase()
      config <- trial_phases_config[[phase]]
      ratios <- as.numeric(strsplit(config$randomization_ratio, ":")[[1]])
      arm_assignments <- block_randomization(n_envelopes, 6, ratios)
      rand <- data.frame(arm_assignment = arm_assignments, stringsAsFactors = FALSE)
    }
    
    envelopes <- generate_envelopes(rand, n_envelopes, input$includeBlinding)
    envelope_data(envelopes)
  })
  
  # Display envelope preview
  output$envelopePreview <- renderUI({
    envelopes <- envelope_data()
    
    if (is.null(envelopes)) {
      return(p("Click 'Generate Envelopes' to preview", style = "color: #999;"))
    }
    
    # Show first 6 envelopes as preview
    preview_envelopes <- head(envelopes, 6)
    
    tagList(
      fluidRow(
        lapply(1:nrow(preview_envelopes), function(i) {
          env <- preview_envelopes[i, ]
          column(4,
                 div(class = "envelope-card",
                     h5(paste("Envelope #", env$envelope_number)),
                     p(paste("Arm:", env$arm_assignment)),
                     p(paste("Stratum:", env$stratum_id)),
                     if(input$includeBlinding) p(paste("Blinded:", env$blinded_arm), style = "color: #666;")
                 )
          )
        })
      )
    )
  })
  
  # Display envelope table
  output$envelopeTable <- renderDT({
    env <- envelope_data()
    if (is.null(env)) return(datatable(data.frame()))
    datatable(env, options = list(pageLength = 15))
  })
  
  # Run simulation
  observeEvent(input$runSimulation, {
    phase <- selected_phase()
    config <- trial_phases_config[[phase]]
    
    # Simulate dose escalation for Phase 1
    dose_results <- NULL
    if (phase == "phase1") {
      scheme_name <- input$doseEscalationScheme
      scheme <- dose_escalation_schemes[[gsub(" ", "_", tolower(scheme_name))]]
      if (!is.null(scheme)) {
        dose_results <- simulate_dose_escalation(scheme, input$nCohorts)
      }
    }
    
    # Simulate trial outcomes
    outcomes <- simulate_trial_outcomes(config$n_target, config$arms, config)
    
    simulation_results(list(
      dose_escalation = dose_results,
      outcomes = outcomes,
      phase = phase
    ))
  })
  
  # Display dose escalation plot
  output$doseEscalationPlot <- renderPlot({
    sim <- simulation_results()
    if (is.null(sim) || is.null(sim$dose_escalation)) {
      plot(1, type = "n", xlab = "", ylab = "", main = "Run simulation to see results")
      return()
    }
    
    dose_results <- sim$dose_escalation
    
    par(mar = c(5, 4, 4, 8))
    plot(dose_results$cohort, dose_results$dose_level,
         type = "b", pch = 19, col = "#2874a6",
         xlab = "Cohort", ylab = "Dose Level (mg/m²)",
         main = "Dose Escalation Pathway")
    
    # Add DLT rate
    par(new = TRUE)
    plot(dose_results$cohort, dose_results$dlt_rate,
         type = "b", pch = 17, col = "#e74c3c",
         xlab = "", ylab = "", ylim = c(0, 1))
    axis(4)
    mtext("DLT Rate", side = 4, line = 3)
    
    # Add MTD marker
    if ("mtd" %in% names(dose_results)) {
      mtd_idx <- which(dose_results$mtd)
      if (length(mtd_idx) > 0) {
        abline(v = mtd_idx, lty = 2, col = "#27ae60", lwd = 2)
        text(mtd_idx, max(dose_results$dose_level) * 0.9, "MTD", col = "#27ae60", font = 2)
      }
    }
    
    legend("topright", legend = c("Dose Level", "DLT Rate", "MTD"),
           col = c("#2874a6", "#e74c3c", "#27ae60"),
           lty = c(1, 1, 2), pch = c(19, 17, NA), lwd = c(1, 1, 2))
  })
  
  # Display response plot
  output$responsePlot <- renderPlot({
    sim <- simulation_results()
    if (is.null(sim) || is.null(sim$outcomes)) {
      plot(1, type = "n", xlab = "", ylab = "", main = "Run simulation to see results")
      return()
    }
    
    outcomes <- sim$outcomes
    
    response_table <- table(outcomes$arm_assignment, outcomes$response)
    
    par(mar = c(5, 4, 4, 2))
    barplot(t(response_table),
            beside = TRUE,
            col = c("#27ae60", "#2ecc71", "#f39c12", "#e74c3c"),
            xlab = "Treatment Arm",
            ylab = "Number of Patients",
            main = "Treatment Response by Arm",
            legend.text = rownames(response_table),
            args.legend = list(x = "topright"))
  })
  
  # Display simulation results table
  output$simulationResultsTable <- renderDT({
    sim <- simulation_results()
    if (is.null(sim) || is.null(sim$outcomes)) return(datatable(data.frame()))
    
    outcomes <- sim$outcomes
    
    # Summarize by arm
    summary_data <- outcomes %>%
      group_by(arm_assignment) %>%
      summarize(
        N = n(),
        CR = sum(response == "Complete Response"),
        PR = sum(response == "Partial Response"),
        SD = sum(response == "Stable Disease"),
        PD = sum(response == "Progressive Disease"),
        ORR = round((CR + PR) / N * 100, 1),
        DCR = round((CR + PR + SD) / N * 100, 1),
        Median_PFS = round(median(pfs_months), 1),
        Median_OS = round(median(os_months), 1),
        Grade_3_4_AE = sum(grade_3_4_ae),
        Serious_AE = sum(serious_ae),
        .groups = "drop"
      )
    
    datatable(summary_data, options = list(pageLength = 10))
  })
  
  # Monitoring plots
  output$enrollmentPlot <- renderPlot({
    par(mar = c(5, 4, 4, 2))
    barplot(c(40, 60, 20),
            names.arg = c("Phase 1", "Phase 2", "Phase 3"),
            col = c("#3498db", "#2ecc71", "#f39c12"),
            main = "Enrollment by Phase",
            ylab = "Number of Patients")
  })
  
  output$armBalancePlot <- renderPlot({
    par(mar = c(5, 4, 4, 2))
    barplot(c(32, 31, 32),
            names.arg = c("Arm 1", "Arm 2", "Arm 3"),
            col = c("#e74c3c", "#3498db", "#2ecc71"),
            main = "Randomization Balance (Phase 1)",
            ylab = "Number of Patients")
    abline(h = 95/3, lty = 2, col = "#999")
  })
  
  output$monitoringTable <- renderDT({
    # Generate mock monitoring data
    n_patients <- 95
    data.frame(
      Patient_ID = sprintf("PT-%04d", 1:n_patients),
      Enrollment_Date = seq(as.Date("2024-01-01"), by = "3 days", length.out = n_patients),
      Randomization_Date = seq(as.Date("2024-01-08"), by = "3 days", length.out = n_patients),
      Arm = sample(c("Arm 1", "Arm 2", "Arm 3"), n_patients, replace = TRUE),
      Status = sample(c("On Treatment", "Completed", "Discontinued"), n_patients, 
                     replace = TRUE, prob = c(0.70, 0.20, 0.10)),
      stringsAsFactors = FALSE
    ) %>% datatable(options = list(pageLength = 15))
  })
  
  # Trial summary
  output$trialSummary <- renderUI({
    phase <- selected_phase()
    config <- trial_phases_config[[phase]]
    
    HTML(paste0("
      <div style='line-height: 1.8;'>
        <h5>Trial Design Summary</h5>
        <p><strong>Phase:</strong> ", config$name, "</p>
        <p><strong>Objective:</strong> ", config$description, "</p>
        <p><strong>Target Enrollment:</strong> N = ", config$n_target, " patients</p>
        <p><strong>Treatment Arms:</strong> ", length(config$arms), "</p>
        <p><strong>Randomization Ratio:</strong> ", config$randomization_ratio, "</p>
        <p><strong>Stratification Factors:</strong> ", paste(config$stratification, collapse = ", "), "</p>
        <p><strong>Primary Endpoint:</strong> Objective Response Rate (ORR)</p>
        <p><strong>Secondary Endpoints:</strong> PFS, OS, Safety, DCR</p>
        <hr>
        <h5>Treatment Arms</h5>
        ", paste(sapply(names(config$arms), function(name) {
          arm <- config$arms[[name]]
          paste0("<p><strong>", arm$name, ":</strong><br>", arm$treatment, "</p>")
        }), collapse = ""), "
      </div>
    "))
  })
  
  # Export functionality
  observeEvent(input$exportData, {
    items <- input$exportItems
    format <- input$exportFormat
    
    if (length(items) == 0) {
      showNotification("Please select at least one item to export", type = "warning")
      return()
    }
    
    # Create export data
    export_data <- list()
    
    if ("Randomization List" %in% items && !is.null(randomization_list())) {
      export_data$randomization <- randomization_list()
    }
    
    if ("Envelope Log" %in% items && !is.null(envelope_data())) {
      export_data$envelopes <- envelope_data()
    }
    
    if ("Simulation Results" %in% items && !is.null(simulation_results())) {
      export_data$simulation <- simulation_results()$outcomes
    }
    
    if (length(export_data) == 0) {
      showNotification("No data available to export. Please generate data first.", type = "warning")
      return()
    }
    
    # Export based on format
    if (format == "CSV") {
      for (name in names(export_data)) {
        filename <- paste0("trial_export_", name, "_", Sys.Date(), ".csv")
        write.csv(export_data[[name]], filename, row.names = FALSE)
      }
      showNotification(paste("Exported", length(export_data), "files in CSV format"), type = "message")
    } else if (format == "Excel") {
      tryCatch({
        library(writexl)
        filename <- paste0("trial_export_", Sys.Date(), ".xlsx")
        write_xlsx(export_data, filename)
        showNotification(paste("Exported to", filename), type = "message")
      }, error = function(e) {
        showNotification("Excel export requires 'writexl' package", type = "error")
      })
    } else {
      showNotification("PDF report generation coming soon", type = "info")
    }
  })
}

# ============================================================================
# RUN APPLICATION
# ============================================================================

shinyApp(ui = ui, server = server)
