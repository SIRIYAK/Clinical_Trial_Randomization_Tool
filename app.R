# ============================================================================
# Clinical Trial Randomization Builder & Envelope Generator
# Open-Source Platform for All Trial Phases (Phase I/II/III)
# Based on NCI & FDA Guidelines
# ============================================================================

library(shiny)
library(DT)
library(dplyr)
library(tidyr)
library(bslib)
library(plotly)
library(bsicons)
library(shinyjs)

# ============================================================================
# FDA GUIDELINES & REGULATORY REFERENCES DATABASE
# ============================================================================

fda_guidelines <- list(
  randomization = list(
    title = "Randomization & Blinding",
    documents = list(
      list(
        name = "E9 Statistical Principles for Clinical Trials",
        url = "https://www.fda.gov/media/134433/download",
        description = "ICH E9 guideline on statistical principles, randomization, blinding"
      ),
      list(
        name = "E10 Choice of Control Group",
        url = "https://www.fda.gov/media/134438/download",
        description = "Guidance on selection of control groups and randomization"
      ),
      list(
        name = "Adaptive Designs for Clinical Trials",
        url = "https://www.fda.gov/media/78495/download",
        description = "FDA guidance on adaptive designs including randomization modifications"
      ),
      list(
        name = "Master Protocols: Efficient Clinical Trial Design",
        url = "https://www.fda.gov/media/147710/download",
        description = "Guidance on basket, umbrella, and platform trials"
      )
    )
  ),
  dose_finding = list(
    title = "Dose-Finding Studies",
    documents = list(
      list(
        name = "Dose-Response Information in Drug Development",
        url = "https://www.fda.gov/media/134445/download",
        description = "ICH E4 guidance on dose-response studies"
      ),
      list(
        name = "Exposure-Response Relationships",
        url = "https://www.fda.gov/media/71494/download",
        description = "Guidance on E-R studies to support dose selection"
      ),
      list(
        name = "Clinical Trial Endpoints for Oncology Drugs",
        url = "https://www.fda.gov/media/71193/download",
        description = "Guidance on endpoints for cancer drug approvals"
      )
    )
  ),
  oncology = list(
    title = "Oncology-Specific Guidance",
    documents = list(
      list(
        name = "Oncology Clinical Trial Endpoints",
        url = "https://www.fda.gov/media/71193/download",
        description = "ORR, PFS, OS, DOR endpoints for cancer trials"
      ),
      list(
        name = "Patient-Reported Outcome Measures",
        url = "https://www.fda.gov/media/77832/download",
        description = "PRO instruments for oncology trials"
      ),
      list(
        name = "Biomarker Development in Oncology",
        url = "https://www.fda.gov/media/133395/download",
        description = "Enrichment strategies and biomarker-guided trials"
      ),
      list(
        name = "Real-World Evidence in Oncology",
        url = "https://www.fda.gov/media/120060/download",
        description = "Use of RWE to support oncology drug development"
      )
    )
  ),
  stratification = list(
    title = "Stratification & Subgroups",
    documents = list(
      list(
        name = "Collection of Race and Ethnicity Data",
        url = "https://www.fda.gov/media/128058/download",
        description = "FDA guidance on demographic data collection"
      ),
      list(
        name = "Evaluation of Sex Differences in Clinical Trials",
        url = "https://www.fda.gov/media/134437/download",
        description = "ICH E5 guidance on ethnic factors"
      ),
      list(
        name = "Enrichment Strategies for Clinical Trials",
        url = "https://www.fda.gov/media/121314/download",
        description = "Selecting patients to enrich trial population"
      )
    )
  ),
  safety = list(
    title = "Safety & AE Reporting",
    documents = list(
      list(
        name = "Safety Assessment for IND Safety Reporting",
        url = "https://www.fda.gov/media/134443/download",
        description = "ICH E2A guidance on safety reporting"
      ),
      list(
        name = "Development Safety Update Report",
        url = "https://www.fda.gov/media/134444/download",
        description = "ICH E2F guidance on DSUR"
      ),
      list(
        name = "CTCAE v6.0 (Common Terminology Criteria)",
        url = "https://ctep.cancer.gov/protocolDevelopment/electronic_applications/ctc.htm",
        description = "NCI CTCAE version 6.0 for adverse event grading"
      )
    )
  ),
  statistics = list(
    title = "Statistical Guidance",
    documents = list(
      list(
        name = "Statistical Aspects of INDs",
        url = "https://www.fda.gov/media/134440/download",
        description = "Guidance on statistical considerations in INDs"
      ),
      list(
        name = "Multiplicity Issues in Clinical Trials",
        url = "https://www.fda.gov/media/134441/download",
        description = "ICH E9 addendum on multiplicity"
      ),
      list(
        name = "Missing Data in Clinical Trials",
        url = "https://www.fda.gov/media/134442/download",
        description = "Guidance on handling missing data"
      )
    )
  )
)

# ============================================================================
# STRATIFICATION FACTORS DATABASE
# ============================================================================

stratification_factors <- list(
  pdl1_expression = list(
    levels = c("<1%", "1-49%", "≥50%"),
    label = "PDL1 Expression Level",
    category = "Biomarker"
  ),
  histology = list(
    levels = c("Non-Squamous (NSQ)", "Squamous (SQ)"),
    label = "Histology Type",
    category = "Pathology"
  ),
  region = list(
    levels = c("East Asia", "Rest of World"),
    label = "Geographic Region",
    category = "Demographics"
  ),
  ecog_ps = list(
    levels = c("0", "1", "2"),
    label = "ECOG Performance Status",
    category = "Clinical"
  ),
  age_group = list(
    levels = c("<65 years", "≥65 years"),
    label = "Age Group",
    category = "Demographics"
  ),
  gender = list(
    levels = c("Male", "Female"),
    label = "Gender",
    category = "Demographics"
  ),
  bmi_category = list(
    levels = c("<25 kg/m²", "25-30 kg/m²", ">30 kg/m²"),
    label = "BMI Category",
    category = "Clinical"
  ),
  renal_function = list(
    levels = c("Normal", "Mild Impairment", "Moderate Impairment"),
    label = "Renal Function",
    category = "Clinical"
  ),
  hepatic_function = list(
    levels = c("Normal", "Mild Impairment", "Moderate Impairment"),
    label = "Hepatic Function",
    category = "Clinical"
  ),
  prior_therapy = list(
    levels = c("Treatment-Naive", "1 Prior Line", "≥2 Prior Lines"),
    label = "Prior Therapy Lines",
    category = "Clinical"
  ),
  disease_stage = list(
    levels = c("Stage II", "Stage III", "Stage IV"),
    label = "Disease Stage",
    category = "Clinical"
  ),
  biomarker_status = list(
    levels = c("Positive", "Negative", "Unknown"),
    label = "Biomarker Status",
    category = "Biomarker"
  )
)

# ============================================================================
# CANCER TYPES & INDICATIONS DATABASE
# ============================================================================

cancer_types <- list(
  lung = list(
    name = "Non-Small Cell Lung Cancer (NSCLC)",
    abbreviation = "NSCLC",
    histologies = c("Adenocarcinoma", "Squamous Cell", "Large Cell"),
    biomarkers = c("PDL1", "EGFR", "ALK", "ROS1", "KRAS", "BRAF", "MET", "RET", "NTRK"),
    standard_regimens = c("Carboplatin+Pembrolizumab", "Cisplatin+Pemetrexed", "Carboplatin+Paclitaxel")
  ),
  breast = list(
    name = "Breast Cancer",
    abbreviation = "BC",
    histologies = c("Invasive Ductal", "Invasive Lobular", "DCIS"),
    biomarkers = c("ER", "PR", "HER2", "BRCA1/2", "PDL1"),
    standard_regimens = c("Doxorubicin+Cyclophosphamide", "Paclitaxel", "Trastuzumab+Pertuzumab")
  ),
  colorectal = list(
    name = "Colorectal Cancer",
    abbreviation = "CRC",
    histologies = c("Adenocarcinoma"),
    biomarkers = c("MSI", "RAS", "BRAF", "HER2"),
    standard_regimens = c("FOLFOX", "FOLFIRI", "CAPOX")
  ),
  melanoma = list(
    name = "Melanoma",
    abbreviation = "MEL",
    histologies = c("Cutaneous", "Mucosal", "Ocular"),
    biomarkers = c("BRAF", "NRAS", "KIT"),
    standard_regimens = c("Nivolumab+Ipilimumab", "Dabrafenib+Trametinib", "Pembrolizumab")
  ),
  renal = list(
    name = "Renal Cell Carcinoma",
    abbreviation = "RCC",
    histologies = c("Clear Cell", "Papillary", "Chromophobe"),
    biomarkers = c("PDL1", "VHL"),
    standard_regimens = c("Nivolumab+Ipilimumab", "Pazopanib", "Sunitinib")
  ),
  prostate = list(
    name = "Prostate Cancer",
    abbreviation = "PC",
    histologies = c("Adenocarcinoma"),
    biomarkers = c("AR", "BRCA1/2", "ATM", "MSI"),
    standard_regimens = c("Docetaxel", "Abiraterone", "Enzalutamide")
  ),
  bladder = list(
    name = "Bladder/Urothelial Cancer",
    abbreviation = "UC",
    histologies = c("Urothelial Carcinoma"),
    biomarkers = c("PDL1", "FGFR", "ERBB2"),
    standard_regimens = c("Cisplatin+Gemcitabine", "Carboplatin+Gemcitabine", "Atezolizumab")
  ),
  gastric = list(
    name = "Gastric/GEJ Cancer",
    abbreviation = "GC",
    histologies = c("Adenocarcinoma"),
    biomarkers = c("HER2", "PDL1", "MSI", "CLDN18.2"),
    standard_regimens = c("FOLFOX", "CAPOX", "Trastuzumab+Chemotherapy")
  ),
  ovarian = list(
    name = "Ovarian Cancer",
    abbreviation = "OC",
    histologies = c("High-Grade Serous", "Clear Cell", "Endometrioid"),
    biomarkers = c("BRCA1/2", "HRD", "PDL1"),
    standard_regimens = c("Carboplatin+Paclitaxel", "Bevacizumab", "PARP Inhibitors")
  ),
  head_neck = list(
    name = "Head and Neck Squamous Cell Carcinoma",
    abbreviation = "HNSCC",
    histologies = c("Squamous Cell"),
    biomarkers = c("PDL1", "HPV", "EGFR"),
    standard_regimens = c("Cisplatin+5-FU", "Cetuximab", "Pembrolizumab")
  ),
  lymphoma = list(
    name = "Non-Hodgkin Lymphoma",
    abbreviation = "NHL",
    histologies = c("DLBCL", "Follicular", "Mantle Cell"),
    biomarkers = c("CD20", "BCL2", "MYC"),
    standard_regimens = c("R-CHOP", "Bendamustine+Rituximab", "CAR-T")
  ),
  leukemia = list(
    name = "Acute Myeloid Leukemia",
    abbreviation = "AML",
    histologies = c("De Novo", "Secondary", "Therapy-Related"),
    biomarkers = c("FLT3", "NPM1", "IDH1/2", "TP53"),
    standard_regimens = c("7+3 Induction", "Venetoclax+Azacitidine", "Midostaurin")
  )
)

# ============================================================================
# TRIAL PHASE CONFIGURATIONS
# ============================================================================

trial_phases_config <- list(
  phase1 = list(
    name = "Phase 1: Dose Optimization",
    description = "Dose escalation to identify MTD/RP2D with safety and preliminary efficacy",
    n_target = 120,
    arms = list(
      arm1 = list(name = "Control", treatment = "Placebo + Standard of Care", ratio = 1),
      arm2 = list(name = "Experimental Low", treatment = "Drug 0.45 mg/m² + Standard of Care", ratio = 1),
      arm3 = list(name = "Experimental High", treatment = "Drug 0.60 mg/m² + Standard of Care", ratio = 1)
    ),
    randomization_ratio = "1:1:1",
    stratification = c("pdl1_expression", "histology", "region"),
    dose_escalation = TRUE
  ),
  phase2 = list(
    name = "Phase 2: Dose Expansion",
    description = "Expansion cohort to confirm efficacy at selected dose",
    n_target = 160,
    arms = list(
      arm1 = list(name = "Control", treatment = "Placebo + Standard of Care", ratio = 1),
      arm2 = list(name = "Experimental", treatment = "Drug [Selected Dose] + Standard of Care", ratio = 1)
    ),
    randomization_ratio = "1:1",
    stratification = c("pdl1_expression", "histology", "region"),
    dose_escalation = FALSE
  ),
  phase3 = list(
    name = "Phase 3: Confirmatory Testing",
    description = "Confirmatory phase to demonstrate efficacy vs standard of care",
    n_target = 440,
    arms = list(
      arm1 = list(name = "Control", treatment = "Standard of Care", ratio = 1),
      arm2 = list(name = "Experimental", treatment = "Drug [Selected Dose] + Standard of Care", ratio = 1)
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
    carboplatin_pemetrexed = list(name = "Carboplatin + Pemetrexed", drugs = c("Carboplatin (AUC 5-6)", "Pemetrexed (500 mg/m²)"), cycle = "Q3W", cycles = 4),
    cisplatin_pemetrexed = list(name = "Cisplatin + Pemetrexed", drugs = c("Cisplatin (75 mg/m²)", "Pemetrexed (500 mg/m²)"), cycle = "Q3W", cycles = 4),
    carboplatin_paclitaxel = list(name = "Carboplatin + Paclitaxel", drugs = c("Carboplatin (AUC 6)", "Paclitaxel (200 mg/m²)"), cycle = "Q3W", cycles = 4)
  ),
  sq = list(
    carboplatin_paclitaxel = list(name = "Carboplatin + Paclitaxel", drugs = c("Carboplatin (AUC 6)", "Paclitaxel (200 mg/m²)"), cycle = "Q3W", cycles = 4),
    cisplatin_gemcitabine = list(name = "Cisplatin + Gemcitabine", drugs = c("Cisplatin (75 mg/m²)", "Gemcitabine (1250 mg/m²)"), cycle = "Q3W", cycles = 4),
    carboplatin_nab_paclitaxel = list(name = "Carboplatin + Nab-Paclitaxel", drugs = c("Carboplatin (AUC 6)", "Nab-Paclitaxel (100 mg/m²)"), cycle = "Q3W", cycles = 4)
  ),
  general = list(
    folfox = list(name = "FOLFOX", drugs = c("5-FU", "Leucovorin", "Oxaliplatin"), cycle = "Q2W", cycles = 12),
    folfiri = list(name = "FOLFIRI", drugs = c("5-FU", "Leucovorin", "Irinotecan"), cycle = "Q2W", cycles = 12),
    capox = list(name = "CAPOX", drugs = c("Capecitabine", "Oxaliplatin"), cycle = "Q3W", cycles = 8),
    r_chop = list(name = "R-CHOP", drugs = c("Rituximab", "Cyclophosphamide", "Doxorubicin", "Vincristine", "Prednisone"), cycle = "Q3W", cycles = 6),
    ac_t = list(name = "AC→T", drugs = c("Doxorubicin", "Cyclophosphamide", "→ Paclitaxel"), cycle = "Q2-3W", cycles = 8)
  )
)

# ============================================================================
# DOSE ESCALATION SCHEMES
# ============================================================================

dose_escalation_schemes <- list(
  three_plus_three = list(name = "3+3 Design", description = "Standard 3+3 dose escalation", cohort_size = 3, max_cohort_size = 6, dose_levels = c(0.30, 0.45, 0.60, 0.75), escalation_step = 0.15),
  continual_reassessment = list(name = "Continual Reassessment Method (CRM)", description = "Model-based dose escalation", target_toxicity_rate = 0.25, dose_levels = c(0.30, 0.45, 0.60, 0.75), model = "logistic"),
  accelerated = list(name = "Accelerated Titration", description = "Single patient cohorts with rapid escalation", cohort_size = 1, dose_levels = c(0.30, 0.45, 0.60, 0.75, 0.90), switch_to_3plus3_at = 2),
  bayesian_optimal = list(name = "Bayesian Optimal Interval (BOIN)", description = "Bayesian interval-finding design", target_toxicity_rate = 0.25, dose_levels = c(0.30, 0.45, 0.60, 0.75, 0.90), lambda1 = 0.2, lambda2 = 0.3)
)

# ============================================================================
# UTILITY FUNCTIONS
# ============================================================================

generate_strata_combinations <- function(factors) {
  factor_levels <- lapply(factors, function(f) stratification_factors[[f]]$levels)
  expand.grid(factor_levels, stringsAsFactors = FALSE)
}

block_randomization <- function(n, block_size, arm_ratios) {
  n_arms <- length(arm_ratios)
  block <- rep(1:n_arms, times = arm_ratios)
  block <- sample(block)
  n_blocks <- ceiling(n / length(block))
  full_sequence <- rep(block, n_blocks)
  return(head(full_sequence, n))
}

stratified_randomization <- function(n, strata_df, arm_ratios) {
  strata_combinations <- unique(strata_df)
  n_strata <- nrow(strata_combinations)
  
  randomization_list <- data.frame(
    stratum_id = integer(),
    arm_assignment = integer(),
    stringsAsFactors = FALSE
  )
  
  for (i in 1:n_strata) {
    stratum_count <- sum(apply(strata_df, 1, function(row) all(row == strata_combinations[i, ])))
    assignments <- block_randomization(stratum_count, sum(arm_ratios), arm_ratios)
    stratum_data <- data.frame(stratum_id = rep(i, stratum_count), arm_assignment = assignments, stringsAsFactors = FALSE)
    randomization_list <- rbind(randomization_list, stratum_data)
  }
  
  return(randomization_list)
}

generate_envelopes <- function(randomization_list, n_envelopes, include_blinding = TRUE) {
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
    envelopes$blinded_arm <- paste0("Treatment Arm ", envelopes$arm_assignment)
    envelopes$treatment_revealed <- FALSE
  }
  
  return(envelopes)
}

simulate_dose_escalation <- function(scheme, n_cohorts = 10) {
  dose_levels <- scheme$dose_levels
  n_doses <- length(dose_levels)
  
  results <- data.frame(
    cohort = 1:n_cohorts,
    dose_level = numeric(n_cohorts),
    n_patients = numeric(n_cohorts),
    n_dlt = numeric(n_cohorts),
    dlt_rate = numeric(n_cohorts),
    decision = character(n_cohorts),
    stringsAsFactors = FALSE
  )
  
  current_dose_idx <- 1
  escalation <- TRUE
  
  for (cohort in 1:n_cohorts) {
    if (!escalation) break
    
    n_patients <- scheme$cohort_size
    results$dose_level[cohort] <- dose_levels[current_dose_idx]
    results$n_patients[cohort] <- n_patients
    
    dlt_prob <- 0.05 + (current_dose_idx / n_doses) * 0.30
    n_dlt <- rbinom(1, n_patients, dlt_prob)
    results$n_dlt[cohort] <- n_dlt
    results$dlt_rate[cohort] <- n_dlt / n_patients
    
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
  
  mtd_idx <- which(results$decision == "MTD Reached" | 
                   (c(results$decision[-1], "") == "De-escalate" & results$decision == "Escalate"))
  if (length(mtd_idx) > 0) {
    results$mtd <- FALSE
    results$mtd[max(mtd_idx)] <- TRUE
  }
  
  return(results)
}

generate_patient_data <- function(n, stratification_factors_list) {
  set.seed(123)
  
  strata <- generate_strata_combinations(stratification_factors_list)
  n_strata <- nrow(strata)
  
  strata_probs <- rep(1/n_strata, n_strata)
  strata_probs <- strata_probs[1:min(n_strata, length(strata_probs))]
  strata_probs <- strata_probs / sum(strata_probs)
  
  patient_strata <- sample(1:n_strata, n, replace = TRUE, prob = strata_probs)
  patient_ids <- sprintf("PT-%04d", 1:n)
  enrollment_dates <- seq(as.Date("2024-01-01"), by = "1 day", length.out = n)
  ages <- round(rnorm(n, 62, 10), 1)
  ages <- pmax(18, pmin(85, ages))
  gender <- sample(c("Male", "Female"), n, replace = TRUE, prob = c(0.60, 0.40))
  
  patient_data <- data.frame(
    patient_id = patient_ids,
    enrollment_date = enrollment_dates,
    age = ages,
    gender = gender,
    stringsAsFactors = FALSE
  )
  
  for (i in seq_along(stratification_factors_list)) {
    factor_name <- stratification_factors_list[[i]]
    patient_data[[factor_name]] <- strata[[factor_name]][patient_strata]
  }
  
  patient_data$stratum_id <- patient_strata
  return(patient_data)
}

simulate_trial_outcomes <- function(n_patients, arms, phase_config) {
  set.seed(456)
  
  if (phase_config$dose_escalation) {
    response_rates <- c(0.15, 0.20, 0.25)
  } else if (grepl("Phase 2", phase_config$name)) {
    response_rates <- c(0.20, 0.35)
  } else {
    response_rates <- c(0.25, 0.40)
  }
  
  n_arms <- length(arms)
  arm_assignments <- sample(1:n_arms, n_patients, replace = TRUE, prob = sapply(arms, function(a) a$ratio))
  
  outcomes <- data.frame(
    patient_id = sprintf("PT-%04d", 1:n_patients),
    arm_assignment = arm_assignments,
    treatment = sapply(arm_assignments, function(a) arms[[a]]$treatment),
    stringsAsFactors = FALSE
  )
  
  outcomes$response <- sapply(1:n_patients, function(i) {
    arm_idx <- arm_assignments[i]
    prob_response <- response_rates[min(arm_idx, length(response_rates))]
    sample(c("Complete Response", "Partial Response", "Stable Disease", "Progressive Disease"),
           1, prob = c(prob_response * 0.3, prob_response * 0.5, (1 - prob_response) * 0.6, (1 - prob_response) * 0.4))
  })
  
  outcomes$grade_3_4_ae <- rbinom(n_patients, 1, 0.15 + arm_assignments * 0.05)
  outcomes$serious_ae <- rbinom(n_patients, 1, 0.05 + arm_assignments * 0.02)
  outcomes$pfs_months <- rexp(n_patients, rate = 0.1 + arm_assignments * 0.02)
  outcomes$pfs_months <- round(outcomes$pfs_months, 1)
  outcomes$os_months <- rexp(n_patients, rate = 0.08 + arm_assignments * 0.015)
  outcomes$os_months <- round(outcomes$os_months, 1)
  
  return(outcomes)
}

# ============================================================================
# UI DEFINITION
# ============================================================================

ui <- fluidPage(
  useShinyjs(),
  theme = bs_theme(version = 5, bootswatch = "flatly", primary = "#1a5276", secondary = "#2874a6"),
  
  tags$head(
    tags$style(HTML("
      .trial-header {
        background: linear-gradient(135deg, #1a5276 0%, #2874a6 100%);
        color: white; padding: 20px;
      }
      .open-source-badge {
        background: #27ae60; color: white; padding: 5px 15px;
        border-radius: 20px; font-size: 12px; display: inline-block;
      }
      .phase-card {
        border: 2px solid #2874a6; border-radius: 10px; padding: 15px;
        margin: 10px; background: white; cursor: pointer; transition: all 0.3s;
      }
      .phase-card:hover { box-shadow: 0 4px 8px rgba(0,0,0,0.2); transform: translateY(-2px); }
      .phase-card.active { background: #2874a6; color: white; }
      .stratum-badge {
        display: inline-block; background: #e8f6f3; color: #1a5276;
        padding: 5px 10px; border-radius: 15px; margin: 3px; font-size: 12px;
        border: 1px solid #2874a6;
      }
      .arm-badge {
        display: inline-block; background: #fef9e7; color: #7d6608;
        padding: 8px 12px; border-radius: 5px; margin: 5px;
        border: 2px solid #f39c12; font-weight: bold;
      }
      .stat-card {
        background: white; border-radius: 8px; padding: 15px;
        box-shadow: 0 2px 4px rgba(0,0,0,0.1); text-align: center; margin: 10px;
      }
      .stat-value { font-size: 32px; font-weight: bold; color: #1a5276; }
      .stat-label { font-size: 14px; color: #666; margin-top: 5px; }
      .envelope-card {
        background: #fef9e7; border: 2px dashed #f39c12;
        border-radius: 8px; padding: 10px; margin: 8px; text-align: center;
      }
      .fda-guideline-card {
        background: #f8f9fa; border-left: 4px solid #2874a6;
        padding: 15px; margin: 10px 0; border-radius: 5px;
      }
      .cancer-type-card {
        background: white; border: 2px solid #e0e0e0; border-radius: 8px;
        padding: 15px; margin: 10px; cursor: pointer; transition: all 0.3s;
      }
      .cancer-type-card:hover { border-color: #2874a6; box-shadow: 0 2px 8px rgba(0,0,0,0.1); }
      .cancer-type-card.active { border-color: #2874a6; background: #e8f6f3; }
      .playground-section {
        background: #fff3cd; border: 2px solid #f39c12; border-radius: 10px;
        padding: 20px; margin: 15px 0;
      }
      .template-section {
        background: #e8f6f3; border: 2px solid #27ae60; border-radius: 10px;
        padding: 20px; margin: 15px 0;
      }
    "))
  ),
  
  # Header with Open Source Badge
  div(class = "trial-header",
      fluidRow(
        column(8,
               h2("Clinical Trial Randomization Builder", style = "margin: 0;"),
               h4("Open-Source Platform for Phase I/II/III Trial Design & Simulation", style = "margin: 5px 0; opacity: 0.9;"),
               tags$span(class = "open-source-badge", icon("code-branch"), " Open Source | MIT License | Community Driven")
        ),
        column(4,
               div(style = "text-align: right; margin-top: 10px;",
                   selectInput("trialTemplate", "Trial Template:",
                              choices = c(
                                "Custom Trial Builder",
                                "EIK1001 NSCLC Phase I/II/III",
                                "Phase I Dose-Finding Only",
                                "Phase II Expansion Only",
                                "Phase III Confirmatory Only",
                                "Basket Trial (Multi-Cancer)",
                                "Umbrella Trial (Multi-Arm)",
                                "Platform Trial (Adaptive)"
                              ),
                              selected = "Custom Trial Builder", width = "100%")
               )
        )
      )
  ),
  
  # Trial Schema Overview
  div(style = "padding: 20px; background: #f8f9fa;",
      fluidRow(
        column(12,
               h4("Trial Schema", style = "color: #1a5276;"),
               div(style = "background: white; padding: 20px; border-radius: 8px;",
                   uiOutput("trialSchemaVisual")
               )
        )
      )
  ),
  
  # Main Tabs
  fluidRow(
    column(12,
           tabsetPanel(id = "mainTabs",
                       tabPanel("Playground", icon = icon("gamepad")),
                       tabPanel("Trial Design", icon = icon("blueprint")),
                       tabPanel("Stratification", icon = icon("sitemap")),
                       tabPanel("Randomization Builder", icon = icon("random")),
                       tabPanel("Envelope Generator", icon = icon("envelope-open")),
                       tabPanel("Simulation & Analytics", icon = icon("chart-line")),
                       tabPanel("FDA Guidelines", icon = icon("book")),
                       tabPanel("Monitoring Dashboard", icon = icon("tachometer-alt")),
                       tabPanel("Export & Reports", icon = icon("file-export"))
           )
    )
  ),
  
  # =================== PLAYGROUND TAB ===================
  conditionalPanel(
    condition = "input.mainTabs == 'Playground'",
    div(style = "padding: 20px;",
        # Playground Header
        fluidRow(
          column(12,
                 div(class = "playground-section",
                     h3(icon("gamepad"), " Randomization Playground", style = "color: #856404;"),
                     p("Build any clinical trial design from scratch. Select cancer type, define treatment arms, configure randomization, and simulate outcomes.", style = "font-size: 16px;"),
                     tags$ul(
                       tags$li("Choose from 12+ cancer types with disease-specific regimens"),
                       tags$li("Define unlimited treatment arms with custom names and ratios"),
                       tags$li("Select stratification factors relevant to your indication"),
                       tags$li("Generate randomization lists and envelopes instantly"),
                       tags$li("Simulate trial outcomes with FDA-endorsed methods")
                     )
                 )
          )
        ),
        
        # Step 1: Cancer Type Selection
        fluidRow(
          column(12,
                 h4("Step 1: Select Cancer Type", style = "color: #1a5276; margin-top: 20px;"),
                 fluidRow(
                   lapply(seq_along(cancer_types), function(i) {
                     cancer <- cancer_types[[i]]
                     column(3,
                            div(class = "cancer-type-card",
                                onclick = sprintf("Shiny.setInputValue('selectedCancer', '%s');", names(cancer_types)[i]),
                                h5(icon("disease"), cancer$name),
                                p(paste("Biomarkers:", paste(head(cancer$biomarkers, 3), collapse = ", ")), style = "font-size: 12px; color: #666;")
                            )
                     )
                   })
                 )
          )
        ),
        
        # Step 2: Define Treatment Arms
        fluidRow(
          column(12,
                 h4("Step 2: Define Treatment Arms", style = "color: #1a5276; margin-top: 20px;"),
                 div(style = "background: white; padding: 20px; border-radius: 8px;",
                     numericInput("nArms", "Number of Treatment Arms:", value = 2, min = 2, max = 10),
                     div(id = "armsContainer", uiOutput("armsInputs")),
                     actionButton("addArm", icon("plus-circle"), "Add Arm", class = "btn-secondary btn-sm"),
                     hr(),
                     h5("Quick Templates for Arms:"),
                     fluidRow(
                       column(4, actionButton("addControlArm", "Add Control Arm", icon = icon("shield"), class = "btn-outline-primary btn-sm")),
                       column(4, actionButton("addExperimentalArm", "Add Experimental Arm", icon = icon("flask"), class = "btn-outline-primary btn-sm")),
                       column(4, actionButton("addComboArm", "Add Combination Arm", icon = icon("puzzle-piece"), class = "btn-outline-primary btn-sm"))
                     )
                 )
          )
        ),
        
        # Step 3: Configure Randomization
        fluidRow(
          column(6,
                 h4("Step 3: Configure Randomization", style = "color: #1a5276; margin-top: 20px;"),
                 div(style = "background: white; padding: 20px; border-radius: 8px;",
                     numericInput("playgroundTotalPatients", "Total Patients:", value = 120, min = 20, max = 2000),
                     textInput("playgroundRatio", "Randomization Ratio (e.g., 1:1):", value = "1:1"),
                     selectInput("playgroundBlockSize", "Block Size:", choices = c(4, 6, 8, 12, 16), selected = 6),
                     checkboxInput("playgroundStratified", "Use Stratified Randomization", value = TRUE)
                 )
          ),
          column(6,
                 h4("Step 4: Generate & Simulate", style = "color: #1a5276; margin-top: 20px;"),
                 div(style = "background: white; padding: 20px; border-radius: 8px;",
                     actionButton("generatePlaygroundRandomization", icon("magic"), "Generate Randomization", class = "btn-primary", style = "width: 100%; margin-bottom: 10px;"),
                     actionButton("simulatePlaygroundOutcomes", icon("play-circle"), "Simulate Trial Outcomes", class = "btn-success", style = "width: 100%; margin-bottom: 10px;"),
                     actionButton("downloadPlaygroundReport", icon("download"), "Download Complete Report", class = "btn-info", style = "width: 100%;")
                 )
          )
        )
    )
  ),
  
  # =================== TRIAL DESIGN TAB ===================
  conditionalPanel(
    condition = "input.mainTabs == 'Trial Design'",
    div(style = "padding: 20px;",
        fluidRow(
          column(12,
                 h4("Trial Design Configuration", style = "color: #1a5276;"),
                 div(style = "background: white; padding: 20px; border-radius: 8px;",
                     selectInput("designPhase", "Trial Phase:",
                                choices = c("Phase 1: Dose Optimization", "Phase 2: Dose Expansion", "Phase 3: Confirmatory Testing"),
                                selected = "Phase 1: Dose Optimization"),
                     numericInput("designNPatients", "Target Sample Size:", value = 120, min = 20, max = 2000),
                     selectInput("designPrimaryEndpoint", "Primary Endpoint:",
                                choices = c("Objective Response Rate (ORR)",
                                          "Progression-Free Survival (PFS)",
                                          "Overall Survival (OS)",
                                          "Disease Control Rate (DCR)",
                                          "Complete Response Rate (CRR)"),
                                selected = "Objective Response Rate (ORR)"),
                     textAreaInput("designInclusionCriteria", "Inclusion Criteria (one per line):",
                                  value = "Histologically confirmed NSCLC\nMeasurable disease per RECIST v1.1\nECOG PS 0-1\nAdequate organ function",
                                  rows = 5),
                     textAreaInput("designExclusionCriteria", "Exclusion Criteria (one per line):",
                                  value = "Prior systemic therapy for advanced disease\nActive CNS metastases\nAutoimmune disease requiring immunosuppression",
                                  rows = 5),
                     actionButton("saveDesign", icon("save"), "Save Trial Design", class = "btn-primary")
                 )
          )
        )
    )
  ),
  
  # =================== STRATIFICATION TAB ===================
  conditionalPanel(
    condition = "input.mainTabs == 'Stratification'",
    div(style = "padding: 20px;",
        fluidRow(
          column(6,
                 h4("Stratification Factors", style = "color: #1a5276;"),
                 div(style = "background: white; padding: 20px; border-radius: 8px;",
                     checkboxGroupInput("stratFactors", "Select Factors:",
                                       choices = c(
                                         "PDL1 Expression (<1% vs 1-49% vs ≥50%)" = "pdl1_expression",
                                         "Histology (NSQ vs SQ)" = "histology",
                                         "Geographic Region" = "region",
                                         "ECOG Performance Status" = "ecog_ps",
                                         "Age Group (<65 vs ≥65)" = "age_group",
                                         "Gender" = "gender",
                                         "BMI Category" = "bmi_category",
                                         "Renal Function" = "renal_function",
                                         "Hepatic Function" = "hepatic_function",
                                         "Prior Therapy Lines" = "prior_therapy",
                                         "Disease Stage" = "disease_stage",
                                         "Biomarker Status" = "biomarker_status"
                                       ),
                                       selected = c("pdl1_expression", "histology", "region")),
                     hr(),
                     actionButton("generateStrata", icon("cogs"), "Generate Strata", class = "btn-primary")
                 )
          ),
          column(6,
                 h4("Strata Combinations", style = "color: #1a5276;"),
                 div(style = "background: white; padding: 20px; border-radius: 8px; max-height: 500px; overflow-y: auto;",
                     uiOutput("strataTable")
                 )
          )
        )
    )
  ),
  
  # =================== RANDOMIZATION BUILDER TAB ===================
  conditionalPanel(
    condition = "input.mainTabs == 'Randomization Builder'",
    div(style = "padding: 20px;",
        fluidRow(
          column(6,
                 h4("Randomization Parameters", style = "color: #1a5276;"),
                 div(style = "background: white; padding: 20px; border-radius: 8px;",
                     numericInput("randTotalPatients", "Total Patients:", value = 120, min = 10, max = 1000),
                     textInput("randRatio", "Randomization Ratio:", value = "1:1:1"),
                     selectInput("randBlockSize", "Block Size:", choices = c(4, 6, 8, 12), selected = 6),
                     checkboxInput("randStratified", "Stratified Randomization", value = TRUE),
                     hr(),
                     actionButton("generateRandList", icon("magic"), "Generate List", class = "btn-primary")
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
  
  # =================== ENVELOPE GENERATOR TAB ===================
  conditionalPanel(
    condition = "input.mainTabs == 'Envelope Generator'",
    div(style = "padding: 20px;",
        fluidRow(
          column(4,
                 h4("Envelope Configuration", style = "color: #1a5276;"),
                 div(style = "background: white; padding: 20px; border-radius: 8px;",
                     numericInput("nEnvelopes", "Number of Envelopes:", value = 120, min = 10, max = 1000),
                     checkboxInput("includeBlinding", "Include Blinding", value = TRUE),
                     textInput("siteCode", "Site Code:", value = "SITE001"),
                     dateInput("generationDate", "Generation Date:", value = Sys.Date()),
                     hr(),
                     actionButton("generateEnvelopes", icon("envelope"), "Generate", class = "btn-primary"),
                     actionButton("downloadEnvelopes", icon("download"), "Download PDF", class = "btn-success")
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
  
  # =================== SIMULATION TAB ===================
  conditionalPanel(
    condition = "input.mainTabs == 'Simulation & Analytics'",
    div(style = "padding: 20px;",
        fluidRow(
          column(12,
                 h4("Trial Simulation", style = "color: #1a5276;"),
                 div(style = "background: white; padding: 20px; border-radius: 8px;",
                     fluidRow(
                       column(4,
                              selectInput("doseEscalationScheme", "Dose Escalation Scheme:",
                                         choices = c("3+3 Design", "CRM", "Accelerated Titration", "BOIN"),
                                         selected = "3+3 Design"),
                              numericInput("nCohorts", "Number of Cohorts:", value = 10, min = 3, max = 20)
                       ),
                       column(4,
                              numericInput("simulationRuns", "Simulation Runs:", value = 100, min = 10, max = 1000),
                              selectInput("outcomeEndpoint", "Primary Endpoint:",
                                         choices = c("ORR", "PFS", "OS", "DCR"),
                                         selected = "ORR")
                       ),
                       column(4,
                              actionButton("runSimulation", icon("play-circle"), "Run Simulation", class = "btn-primary", style = "margin-top: 32px; width: 100%;"),
                              actionButton("resetSimulation", icon("undo"), "Reset", class = "btn-secondary", style = "margin-top: 10px; width: 100%;")
                       )
                     )
                 )
          )
        ),
        fluidRow(
          column(6, plotOutput("doseEscalationPlot", height = 400)),
          column(6, plotOutput("responsePlot", height = 400))
        ),
        fluidRow(
          column(12, DTOutput("simulationResultsTable"))
        )
    )
  ),
  
  # =================== FDA GUIDELINES TAB ===================
  conditionalPanel(
    condition = "input.mainTabs == 'FDA Guidelines'",
    div(style = "padding: 20px;",
        fluidRow(
          column(12,
                 h4("FDA Regulatory Guidelines & References", style = "color: #1a5276;"),
                 p("Comprehensive collection of FDA and ICH guidelines relevant to clinical trial design, randomization, and regulatory submissions.", style = "font-size: 16px;")
          )
        ),
        fluidRow(
          column(12,
                 div(style = "background: #fff3cd; padding: 15px; border-radius: 8px; margin-bottom: 20px; border-left: 4px solid #f39c12;",
                     h5(icon("exclamation-triangle"), " Important Note", style = "color: #856404;"),
                     p("Always consult with regulatory experts and biostatisticians when designing clinical trials. This tool provides guidance references but does not constitute regulatory advice.", style = "color: #856404;")
                 )
          )
        ),
        uiOutput("fdaGuidelinesContent")
    )
  ),
  
  # =================== MONITORING DASHBOARD TAB ===================
  conditionalPanel(
    condition = "input.mainTabs == 'Monitoring Dashboard'",
    div(style = "padding: 20px;",
        fluidRow(
          column(3, div(class = "stat-card", div(class = "stat-value", "120"), div(class = "stat-label", "Enrolled"))),
          column(3, div(class = "stat-card", div(class = "stat-value", "95"), div(class = "stat-label", "Randomized"))),
          column(3, div(class = "stat-card", div(class = "stat-value", "25"), div(class = "stat-label", "Screen Failures"))),
          column(3, div(class = "stat-card", div(class = "stat-value", "87%"), div(class = "stat-label", "Randomization Rate")))
        ),
        fluidRow(
          column(6, plotOutput("enrollmentPlot", height = 300)),
          column(6, plotOutput("armBalancePlot", height = 300))
        ),
        fluidRow(
          column(12, DTOutput("monitoringTable"))
        )
    )
  ),
  
  # =================== EXPORT TAB ===================
  conditionalPanel(
    condition = "input.mainTabs == 'Export & Reports'",
    div(style = "padding: 20px;",
        fluidRow(
          column(6,
                 h4("Export Data", style = "color: #1a5276;"),
                 div(style = "background: white; padding: 20px; border-radius: 8px;",
                     checkboxGroupInput("exportItems", "Select Items:",
                                       choices = c("Randomization List", "Envelope Log", "Patient Data", "Simulation Results", "Trial Summary", "FDA Compliance Checklist"),
                                       selected = c("Randomization List", "Envelope Log", "Trial Summary")),
                     radioButtons("exportFormat", "Format:",
                                 choices = c("CSV", "Excel", "JSON"), selected = "CSV", inline = TRUE),
                     hr(),
                     actionButton("exportData", icon("download"), "Download Export", class = "btn-primary")
                 )
          ),
          column(6,
                 h4("Trial Summary", style = "color: #1a5276;"),
                 div(style = "background: white; padding: 20px; border-radius: 8px;",
                     uiOutput("trialSummary")
                 )
          )
        )
    )
  ),
  
  # Footer
  div(style = "background: #1a5276; color: white; padding: 20px; text-align: center; margin-top: 40px;",
      p("Clinical Trial Randomization Builder | Open Source | MIT License"),
      p("Based on NCI & FDA Guidelines | For Research & Educational Use"),
      p("References: FDA.gov | ICH.org | ClinicalTrials.gov")
  )
)

# ============================================================================
# SERVER LOGIC
# ============================================================================

server <- function(input, output, session) {
  
  selected_phase <- reactiveVal("phase1")
  selected_cancer <- reactiveVal(NULL)
  strata_data <- reactiveVal(NULL)
  randomization_list <- reactiveVal(NULL)
  envelope_data <- reactiveVal(NULL)
  simulation_results <- reactiveVal(NULL)
  trial_arms <- reactiveVal(list())
  
  # Initialize with default arms
  trial_arms(list(
    list(name = "Control", treatment = "Placebo + Standard of Care", ratio = 1),
    list(name = "Experimental", treatment = "Drug + Standard of Care", ratio = 1)
  ))
  
  observeEvent(input$trialTemplate, {
    template <- input$trialTemplate
    if (template == "Custom Trial Builder") {
      # Reset to playground mode
    } else if (grepl("EIK1001", template)) {
      selected_phase("phase1")
      updateSelectInput(session, "designPhase", selected = "Phase 1: Dose Optimization")
    }
  })
  
  observeEvent(input$selectedCancer, {
    selected_cancer(input$selectedCancer)
  })
  
  # Arms inputs renderer
  output$armsInputs <- renderUI({
    n_arms <- input$nArms
    current_arms <- trial_arms()
    
    tagList(
      lapply(1:n_arms, function(i) {
        arm <- if (i <= length(current_arms)) current_arms[[i]] else list(name = "", treatment = "", ratio = 1)
        fluidRow(
          column(4, textInput(sprintf("armName_%d", i), sprintf("Arm %d Name:", i), value = arm$name, placeholder = "e.g., Control")),
          column(5, textInput(sprintf("armTreatment_%d", i), sprintf("Arm %d Treatment:", i), value = arm$treatment, placeholder = "e.g., Placebo + Chemo")),
          column(3, numericInput(sprintf("armRatio_%d", i), paste0("Arm ", i, " Ratio:"), value = arm$ratio, min = 1, max = 10))
        )
      })
    )
  })
  
  observeEvent(input$addArm, {
    n_arms <- input$nArms + 1
    updateNumericInput(session, "nArms", value = n_arms)
    current_arms <- trial_arms()
    current_arms[[n_arms]] <- list(name = "", treatment = "", ratio = 1)
    trial_arms(current_arms)
  })
  
  observeEvent(input$addControlArm, {
    current_arms <- trial_arms()
    current_arms[[length(current_arms) + 1]] <- list(
      name = "Control",
      treatment = "Placebo + Standard of Care",
      ratio = 1
    )
    trial_arms(current_arms)
    updateNumericInput(session, "nArms", value = length(current_arms))
  })
  
  observeEvent(input$addExperimentalArm, {
    current_arms <- trial_arms()
    current_arms[[length(current_arms) + 1]] <- list(
      name = "Experimental",
      treatment = "Drug + Standard of Care",
      ratio = 1
    )
    trial_arms(current_arms)
    updateNumericInput(session, "nArms", value = length(current_arms))
  })
  
  observeEvent(input$addComboArm, {
    current_arms <- trial_arms()
    current_arms[[length(current_arms) + 1]] <- list(
      name = "Combination",
      treatment = "Drug A + Drug B + Standard of Care",
      ratio = 1
    )
    trial_arms(current_arms)
    updateNumericInput(session, "nArms", value = length(current_arms))
  })
  
  # Display trial schema
  output$trialSchemaVisual <- renderUI({
    cancer <- selected_cancer()
    arms <- trial_arms()
    
    cancer_info <- if (!is.null(cancer) && cancer %in% names(cancer_types)) cancer_types[[cancer]] else NULL
    
    HTML(paste0("
      <div style='text-align: center;'>
        ", if(!is.null(cancer_info)) paste0("<h4>", cancer_info$name, "</h4>"), "
        <div style='margin: 20px 0;'>
          ", paste(sapply(arms, function(arm) {
            paste0("<div class='arm-badge'>", arm$name, "<br><small>", arm$treatment, "</small></div>")
          }), collapse = ""), "
        </div>
        <p><strong>Randomization Ratio:</strong> ", paste(sapply(arms, function(a) a$ratio), collapse = ":"), "</p>
        <p><strong>Number of Arms:</strong> ", length(arms), "</p>
      </div>
    "))
  })
  
  # Generate strata
  observeEvent(input$generateStrata, {
    factors <- input$stratFactors
    if (length(factors) == 0) {
      showNotification("Please select at least one stratification factor", type = "warning")
      return()
    }
    strata <- generate_strata_combinations(factors)
    strata_data(strata)
  })
  
  output$strataTable <- renderUI({
    strata <- strata_data()
    if (is.null(strata)) return(p("Click 'Generate Strata' to see combinations", style = "color: #999;"))
    
    n_strata <- nrow(strata)
    table_html <- "<table class='table table-sm'><thead><tr>"
    for (col in names(strata)) {
      table_html <- paste0(table_html, "<th>", stratification_factors[[col]]$label, "</th>")
    }
    table_html <- paste0(table_html, "<th>ID</th></tr></thead><tbody>")
    for (i in 1:n_strata) {
      table_html <- paste0(table_html, "<tr>")
      for (j in 1:ncol(strata)) {
        table_html <- paste0(table_html, "<td><span class='stratum-badge'>", strata[i, j], "</span></td>")
      }
      table_html <- paste0(table_html, "<td><strong>", i, "</strong></td></tr>")
    }
    table_html <- paste0(table_html, "</tbody></table>")
    HTML(table_html)
  })
  
  # Treatment arms display
  output$treatmentArms <- renderUI({
    arms <- trial_arms()
    tagList(
      lapply(arms, function(arm) {
        div(style = "background: #f8f9fa; padding: 15px; border-radius: 5px; margin: 10px 0; border-left: 4px solid #2874a6;",
            h5(arm$name, style = "margin: 0 0 10px 0;"),
            p(arm$treatment, style = "margin: 0;"),
            p(paste("Ratio:", arm$ratio), style = "margin: 5px 0 0 0; color: #666;")
        )
      })
    )
  })
  
  # Generate randomization
  observeEvent(input$generateRandList, {
    n_patients <- input$randTotalPatients
    ratios <- as.numeric(strsplit(input$randRatio, ":")[[1]])
    arms <- trial_arms()
    
    # Validate ratios
    if (any(is.na(ratios)) || length(ratios) == 0) {
      showNotification("Invalid randomization ratio format. Use format like 1:1 or 1:1:1", type = "error")
      return()
    }
    
    if (input$randStratified && !is.null(strata_data()) && !is.null(input$stratFactors) && length(input$stratFactors) > 0) {
      patient_data <- generate_patient_data(n_patients, input$stratFactors)
      # Only select columns that exist in patient_data
      valid_factors <- intersect(input$stratFactors, names(patient_data))
      if (length(valid_factors) > 0) {
        rand_list <- stratified_randomization(n_patients, patient_data[, valid_factors, drop = FALSE], ratios)
        randomization_list(cbind(patient_data, rand_list))
      } else {
        showNotification("No valid stratification factors found. Using simple randomization.", type = "warning")
        arm_assignments <- block_randomization(n_patients, input$randBlockSize, ratios)
        randomization_list(data.frame(
          patient_id = sprintf("PT-%04d", 1:n_patients),
          arm_assignment = arm_assignments,
          stringsAsFactors = FALSE
        ))
      }
    } else {
      arm_assignments <- block_randomization(n_patients, input$randBlockSize, ratios)
      randomization_list(data.frame(
        patient_id = sprintf("PT-%04d", 1:n_patients),
        arm_assignment = arm_assignments,
        stringsAsFactors = FALSE
      ))
    }
  })

  # =================== PLAYGROUND BUTTON HANDLERS ===================
  
  # Playground: Generate Randomization
  observeEvent(input$generatePlaygroundRandomization, {
    n_patients <- input$playgroundTotalPatients
    ratio_str <- input$playgroundRatio
    ratios <- as.numeric(strsplit(ratio_str, ":")[[1]])
    
    # Validate inputs
    if (any(is.na(ratios)) || length(ratios) == 0) {
      showNotification("Invalid ratio format. Use format like 1:1 or 1:1:1", type = "error")
      return()
    }
    
    # Get arm configurations from inputs
    n_arms <- input$nArms
    arms_config <- list()
    for (i in 1:n_arms) {
      arm_name <- input[[paste0("armName_", i)]]
      arm_treatment <- input[[paste0("armTreatment_", i)]]
      arm_ratio <- input[[paste0("armRatio_", i)]]
      if (!is.null(arm_name) && !is.null(arm_treatment)) {
        arms_config[[i]] <- list(
          name = if(is.null(arm_name) || arm_name == "") paste0("Arm ", i) else arm_name,
          treatment = if(is.null(arm_treatment) || arm_treatment == "") paste0("Treatment ", i) else arm_treatment,
          ratio = if(is.null(arm_ratio)) 1 else arm_ratio
        )
      }
    }
    
    if (length(arms_config) == 0) {
      showNotification("Please define at least one treatment arm", type = "warning")
      return()
    }
    
    # Generate randomization
    if (input$playgroundStratified && !is.null(strata_data()) && !is.null(input$stratFactors) && length(input$stratFactors) > 0) {
      patient_data <- generate_patient_data(n_patients, input$stratFactors)
      valid_factors <- intersect(input$stratFactors, names(patient_data))
      if (length(valid_factors) > 0) {
        rand_list <- stratified_randomization(n_patients, patient_data[, valid_factors, drop = FALSE], ratios)
        randomization_list(cbind(patient_data, rand_list))
        showNotification(paste("✓ Generated stratified randomization for", n_patients, "patients"), type = "message")
      } else {
        arm_assignments <- block_randomization(n_patients, input$playgroundBlockSize, ratios)
        randomization_list(data.frame(
          patient_id = sprintf("PT-%04d", 1:n_patients),
          arm_assignment = arm_assignments,
          stringsAsFactors = FALSE
        ))
        showNotification(paste("✓ Generated simple randomization for", n_patients, "patients (no valid strata)"), type = "message")
      }
    } else {
      arm_assignments <- block_randomization(n_patients, input$playgroundBlockSize, ratios)
      randomization_list(data.frame(
        patient_id = sprintf("PT-%04d", 1:n_patients),
        arm_assignment = arm_assignments,
        stringsAsFactors = FALSE
      ))
      showNotification(paste("✓ Generated randomization for", n_patients, "patients"), type = "message")
    }
  })
  
  # Playground: Simulate Outcomes
  observeEvent(input$simulatePlaygroundOutcomes, {
    rand <- randomization_list()
    if (is.null(rand)) {
      showNotification("Please generate randomization first", type = "warning")
      return()
    }
    
    n_patients <- nrow(rand)
    n_arms <- input$nArms
    
    # Build arms config for simulation
    arms_config <- list()
    for (i in 1:n_arms) {
      arm_name <- input[[paste0("armName_", i)]]
      arm_treatment <- input[[paste0("armTreatment_", i)]]
      arm_ratio <- input[[paste0("armRatio_", i)]]
      arms_config[[i]] <- list(
        name = if(is.null(arm_name) || arm_name == "") paste0("Arm ", i) else arm_name,
        treatment = if(is.null(arm_treatment) || arm_treatment == "") paste0("Treatment ", i) else arm_treatment,
        ratio = if(is.null(arm_ratio)) 1 else arm_ratio
      )
    }
    
    # Create phase config for simulation
    phase_config <- list(
      name = "Playground Trial",
      dose_escalation = FALSE
    )
    
    # Run simulation
    outcomes <- simulate_trial_outcomes(n_patients, arms_config, phase_config)
    simulation_results(list(
      dose_escalation = NULL,
      outcomes = outcomes,
      phase = "playground"
    ))
    
    showNotification("✓ Trial simulation completed!", type = "message")
  })
  
  # Playground: Download Report
  observeEvent(input$downloadPlaygroundReport, {
    rand <- randomization_list()
    sim <- simulation_results()
    
    if (is.null(rand)) {
      showNotification("Please generate randomization first", type = "warning")
      return()
    }
    
    # Prepare export data
    export_data <- list(
      randomization = rand
    )
    
    if (!is.null(sim) && !is.null(sim$outcomes)) {
      export_data$simulation_results <- sim$outcomes
    }
    
    # Add trial design info
    n_arms <- input$nArms
    arms_info <- data.frame(
      Arm_Number = 1:n_arms,
      Arm_Name = sapply(1:n_arms, function(i) {
        name <- input[[paste0("armName_", i)]]
        if(is.null(name) || name == "") paste0("Arm ", i) else name
      }),
      Treatment = sapply(1:n_arms, function(i) {
        treatment <- input[[paste0("armTreatment_", i)]]
        if(is.null(treatment) || treatment == "") paste0("Treatment ", i) else treatment
      }),
      Ratio = sapply(1:n_arms, function(i) {
        ratio <- input[[paste0("armRatio_", i)]]
        if(is.null(ratio)) 1 else ratio
      }),
      stringsAsFactors = FALSE
    )
    export_data$trial_design <- arms_info
    
    # Export to CSV
    timestamp <- format(Sys.time(), "%Y%m%d_%H%M%S")
    for (name in names(export_data)) {
      filename <- paste0("playground_", name, "_", timestamp, ".csv")
      write.csv(export_data[[name]], filename, row.names = FALSE)
    }
    
    showNotification(paste("✓ Downloaded", length(export_data), "CSV files"), type = "message")
  })

  output$randomizationTable <- renderDT({
    rand <- randomization_list()
    if (is.null(rand)) return(datatable(data.frame()))
    datatable(rand, options = list(pageLength = 15))
  })
  
  # Generate envelopes
  observeEvent(input$generateEnvelopes, {
    n_envelopes <- input$nEnvelopes
    rand <- randomization_list()
    
    if (is.null(rand) || nrow(rand) < n_envelopes) {
      ratios <- as.numeric(strsplit("1:1", ":")[[1]])
      arm_assignments <- block_randomization(n_envelopes, 6, ratios)
      rand <- data.frame(arm_assignment = arm_assignments, stringsAsFactors = FALSE)
    }
    
    envelopes <- generate_envelopes(rand, n_envelopes, input$includeBlinding)
    envelope_data(envelopes)
  })
  
  output$envelopePreview <- renderUI({
    envelopes <- envelope_data()
    if (is.null(envelopes)) return(p("Click 'Generate' to preview", style = "color: #999;"))
    
    preview <- head(envelopes, 6)
    tagList(
      fluidRow(
        lapply(1:nrow(preview), function(i) {
          env <- preview[i, ]
          column(4,
                 div(class = "envelope-card",
                     h5(paste("Envelope #", env$envelope_number)),
                     p(paste("Arm:", env$arm_assignment))
                 )
          )
        })
      )
    )
  })
  
  output$envelopeTable <- renderDT({
    env <- envelope_data()
    if (is.null(env)) return(datatable(data.frame()))
    datatable(env, options = list(pageLength = 15))
  })
  
  # Run simulation
  observeEvent(input$runSimulation, {
    phase <- selected_phase()
    config <- trial_phases_config[[phase]]
    arms <- trial_arms()
    
    dose_results <- NULL
    if (phase == "phase1") {
      scheme_name <- input$doseEscalationScheme
      scheme_map <- c("3+3 Design" = "three_plus_three", "CRM" = "continual_reassessment",
                     "Accelerated Titration" = "accelerated", "BOIN" = "bayesian_optimal")
      scheme <- dose_escalation_schemes[[scheme_map[scheme_name]]]
      if (!is.null(scheme)) dose_results <- simulate_dose_escalation(scheme, input$nCohorts)
    }
    
    outcomes <- simulate_trial_outcomes(config$n_target, arms, config)
    simulation_results(list(dose_escalation = dose_results, outcomes = outcomes, phase = phase))
  })
  
  output$doseEscalationPlot <- renderPlot({
    sim <- simulation_results()
    if (is.null(sim) || is.null(sim$dose_escalation)) {
      plot(1, type = "n", xlab = "", ylab = "", main = "Run simulation to see results")
      return()
    }
    
    dose_results <- sim$dose_escalation
    par(mar = c(5, 4, 4, 8))
    plot(dose_results$cohort, dose_results$dose_level, type = "b", pch = 19, col = "#2874a6",
         xlab = "Cohort", ylab = "Dose Level (mg/m²)", main = "Dose Escalation Pathway")
    par(new = TRUE)
    plot(dose_results$cohort, dose_results$dlt_rate, type = "b", pch = 17, col = "#e74c3c",
         xlab = "", ylab = "", ylim = c(0, 1))
    axis(4)
    mtext("DLT Rate", side = 4, line = 3)
    
    if ("mtd" %in% names(dose_results)) {
      mtd_idx <- which(dose_results$mtd)
      if (length(mtd_idx) > 0) {
        abline(v = mtd_idx, lty = 2, col = "#27ae60", lwd = 2)
        text(mtd_idx, max(dose_results$dose_level) * 0.9, "MTD", col = "#27ae60", font = 2)
      }
    }
    legend("topright", legend = c("Dose Level", "DLT Rate", "MTD"),
           col = c("#2874a6", "#e74c3c", "#27ae60"), lty = c(1, 1, 2), pch = c(19, 17, NA))
  })
  
  output$responsePlot <- renderPlot({
    sim <- simulation_results()
    if (is.null(sim) || is.null(sim$outcomes)) {
      plot(1, type = "n", xlab = "", ylab = "", main = "Run simulation to see results")
      return()
    }
    
    outcomes <- sim$outcomes
    response_table <- table(outcomes$arm_assignment, outcomes$response)
    par(mar = c(5, 4, 4, 2))
    barplot(t(response_table), beside = TRUE, col = c("#27ae60", "#2ecc71", "#f39c12", "#e74c3c"),
            xlab = "Treatment Arm", ylab = "Number of Patients", main = "Treatment Response by Arm",
            legend.text = rownames(response_table), args.legend = list(x = "topright"))
  })
  
  output$simulationResultsTable <- renderDT({
    sim <- simulation_results()
    if (is.null(sim) || is.null(sim$outcomes)) return(datatable(data.frame()))
    
    outcomes <- sim$outcomes
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
  
  # FDA Guidelines content
  output$fdaGuidelinesContent <- renderUI({
    tagList(
      lapply(names(fda_guidelines), function(category) {
        cat_info <- fda_guidelines[[category]]
        div(class = "fda-guideline-card",
            h4(icon("book-medical"), cat_info$title, style = "color: #1a5276;"),
            lapply(cat_info$documents, function(doc) {
              div(style = "margin: 10px 0; padding: 10px; background: white; border-radius: 5px;",
                  h5(a(doc$name, href = doc$url, target = "_blank", style = "color: #2874a6;")),
                  p(doc$description, style = "font-size: 14px; color: #666;"),
                  p(a("Download PDF", href = doc$url, target = "_blank", class = "btn btn-sm btn-outline-primary"), style = "margin-top: 5px;")
              )
            })
        )
      })
    )
  })
  
  # Monitoring plots
  output$enrollmentPlot <- renderPlot({
    par(mar = c(5, 4, 4, 2))
    barplot(c(40, 60, 20), names.arg = c("Phase 1", "Phase 2", "Phase 3"),
            col = c("#3498db", "#2ecc71", "#f39c12"), main = "Enrollment by Phase", ylab = "Patients")
  })
  
  output$armBalancePlot <- renderPlot({
    par(mar = c(5, 4, 4, 2))
    barplot(c(32, 31, 32), names.arg = c("Arm 1", "Arm 2", "Arm 3"),
            col = c("#e74c3c", "#3498db", "#2ecc71"), main = "Arm Balance", ylab = "Patients")
    abline(h = 95/3, lty = 2, col = "#999")
  })
  
  output$monitoringTable <- renderDT({
    n_patients <- 95
    monitoring_data <- data.frame(
      Patient_ID = sprintf("PT-%04d", 1:n_patients),
      Enrollment_Date = seq(as.Date("2024-01-01"), by = "3 days", length.out = n_patients),
      Randomization_Date = seq(as.Date("2024-01-08"), by = "3 days", length.out = n_patients),
      Arm = sample(c("Arm 1", "Arm 2", "Arm 3"), n_patients, replace = TRUE),
      Status = sample(c("On Treatment", "Completed", "Discontinued"), n_patients, prob = c(0.70, 0.20, 0.10)),
      stringsAsFactors = FALSE
    )
    datatable(monitoring_data, options = list(pageLength = 15))
  })
  
  # Trial summary
  output$trialSummary <- renderUI({
    arms <- trial_arms()
    HTML(paste0("
      <div style='line-height: 1.8;'>
        <h5>Trial Design Summary</h5>
        <p><strong>Number of Arms:</strong> ", length(arms), "</p>
        <p><strong>Randomization Ratio:</strong> ", paste(sapply(arms, function(a) a$ratio), collapse = ":"), "</p>
        <hr>
        <h5>Treatment Arms</h5>
        ", paste(sapply(arms, function(arm) {
          paste0("<p><strong>", arm$name, ":</strong><br>", arm$treatment, "<br>Ratio: ", arm$ratio, "</p>")
        }), collapse = ""), "
      </div>
    "))
  })
  
  # Export
  observeEvent(input$exportData, {
    items <- input$exportItems
    format <- input$exportFormat
    
    if (length(items) == 0) {
      showNotification("Please select at least one item to export", type = "warning")
      return()
    }
    
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
    
    if (format == "CSV") {
      for (name in names(export_data)) {
        filename <- paste0("trial_export_", name, "_", Sys.Date(), ".csv")
        write.csv(export_data[[name]], filename, row.names = FALSE)
      }
      showNotification(paste("Exported", length(export_data), "CSV files"), type = "message")
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
      showNotification("JSON export coming soon", type = "info")
    }
  })
}

# ============================================================================
# RUN APPLICATION
# ============================================================================

shinyApp(ui = ui, server = server)
