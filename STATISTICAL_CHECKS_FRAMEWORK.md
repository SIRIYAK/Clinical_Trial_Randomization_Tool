# Clinical Trial Statistical Checks & Quality Assurance

## 🎯 Comprehensive Statistical Validation Framework

This document outlines **all statistical checks** needed for clinical trial analysis, aligned with **FDA 21 CFR Part 11**, **ICH E9**, and **ICH E6(R3)** guidelines.

---

## 📊 Category 1: Data Quality Checks

### 1.1 Completeness Checks

| Check ID | Description | Method | Action if Failed |
|----------|-------------|--------|------------------|
| **DQC-01** | Missing Demographics | Check all required fields populated | Flag patient, query site |
| **DQC-02** | Missing Randomization Data | Verify arm assignment exists for all patients | Exclude from analysis or impute |
| **DQC-03** | Missing Outcome Data | Check response assessments at all visits | Flag for sensitivity analysis |
| **DQC-04** | Missing Survival Data | Verify last known alive date | Use last follow-up date |
| **DQC-05** | Missing AE Data | Check AE form completion rate | Query if <95% complete |
| **DQC-06** | Missing Lab Data | Verify lab assessments per schedule | Document as protocol deviation |
| **DQC-07** | Missing Concomitant Meds | Check concomitant medication forms | Query incomplete records |
| **DQC-08** | Missing Visit Dates | Verify all visit dates present | Flag for data clarification |

**Implementation:**
```r
check_missing_data <- function(data, required_fields) {
  results <- list()
  for (field in required_fields) {
    n_missing <- sum(is.na(data[[field]]))
    pct_missing <- n_missing / nrow(data) * 100
    results[[field]] <- list(
      n_missing = n_missing,
      pct_missing = round(pct_missing, 2),
      status = ifelse(pct_missing < 5, "PASS", 
                ifelse(pct_missing < 10, "WARNING", "FAIL"))
    )
  }
  return(results)
}
```

---

### 1.2 Consistency Checks

| Check ID | Description | Validation Rule | Tolerance |
|----------|-------------|-----------------|-----------|
| **CSC-01** | Date Consistency | Informed consent < Randomization < Treatment < Outcome | No violations allowed |
| **CSC-02** | Age Calculation | Age = (Randomization Date - Birth Date) / 365.25 | ±0.1 years |
| **CSC-03** | Visit Windows | Visit dates within protocol-defined windows | ±7 days for most visits |
| **CSC-04** | Dose Calculations | Actual dose matches prescribed dose | ±5% |
| **CSC-05** | Lab Value Ranges | Values within biologically plausible ranges | Check against reference |
| **CSC-06** | Vital Sign Ranges | BP, HR, Temp within plausible ranges | Check against reference |
| **CSC-07** | Tumor Measurements | Sum of longest diameters matches individual lesions | ±1 mm |
| **CSC-08** | Response Assessment | RECIST response matches measurement changes | 100% agreement |

**Implementation:**
```r
check_date_consistency <- function(patient_data) {
  violations <- patient_data %>%
    filter(
      informed_consent_date >= randomization_date |
      randomization_date > treatment_start_date |
      treatment_start_date > outcome_assessment_date
    )
  
  return(list(
    n_violations = nrow(violations),
    pct_violations = round(nrow(violations) / nrow(patient_data) * 100, 2),
    patient_ids = if(nrow(violations) > 0) violations$patient_id else NULL
  ))
}
```

---

### 1.3 Outlier Detection

| Check ID | Description | Method | Threshold |
|----------|-------------|--------|-----------|
| **OTL-01** | Continuous Variables | Z-score method | |Z| > 3 |
| **OTL-02** | Categorical Variables | Frequency analysis | <0.1% or >99.9% |
| **OTL-03** | Lab Values | Clinical significance flags | Per CTCAE v6.0 |
| **OTL-04** | Change from Baseline | IQR method | <Q1-1.5×IQR or >Q3+1.5×IQR |
| **OTL-05** | Survival Times | Visual inspection of KM curve | Check for data errors |
| **OTL-06** | Tumor Response | Waterfall plot review | Investigate extreme values |

**Implementation:**
```r
detect_outliers_zscore <- function(data, numeric_vars) {
  outliers <- list()
  for (var in numeric_vars) {
    z_scores <- scale(data[[var]], center = TRUE, scale = TRUE)
    outlier_flags <- abs(z_scores) > 3
    outliers[[var]] <- data.frame(
      patient_id = data$patient_id[outlier_flags],
      value = data[[var]][outlier_flags],
      z_score = z_scores[outlier_flags]
    )
  }
  return(outliers)
}
```

---

## 📈 Category 2: Randomization Quality Checks

### 2.1 Balance Assessment

| Check ID | Description | Method | Acceptance Criteria |
|----------|-------------|--------|---------------------|
| **RQC-01** | Arm Balance | Chi-square test | p > 0.05 |
| **RQC-02** | Stratification Balance | Cochran-Mantel-Haenszel test | No significant imbalance |
| **RQC-03** | Block Size Verification | Check block size matches protocol | Exact match |
| **RQC-04** | Randomization Ratio | Verify observed vs expected ratio | Within 5% of target |
| **RQC-05** | Temporal Balance | Check enrollment pattern over time | No systematic pattern |
| **RQC-06** | Site Balance | Verify balance within each site | Chi-square p > 0.05 per site |
| **RQC-07** | Predictability Check | Test for selection bias | No predictable pattern |

**Implementation:**
```r
check_arm_balance <- function(randomization_data) {
  # Chi-square test for arm balance
  arm_counts <- table(randomization_data$arm_assignment)
  chisq_result <- chisq.test(arm_counts)
  
  return(list(
    arm_counts = arm_counts,
    chi_square_statistic = round(chisq_result$statistic, 3),
    p_value = round(chisq_result$p.value, 4),
    balance_status = ifelse(chisq_result$p.value > 0.05, "BALANCED", "IMBALANCED"),
    expected_per_arm = nrow(randomization_data) / length(arm_counts),
    deviation_from_expected = round(arm_counts - chisq_result$expected, 2)
  ))
}
```

---

### 2.2 Stratification Quality

| Check ID | Description | Method | Acceptance Criteria |
|----------|-------------|--------|---------------------|
| **SQC-01** | Strata Distribution | Check patients per stratum | ≥5 patients per stratum |
| **SQC-02** | Empty Strata | Verify no empty strata | 0 empty strata |
| **SQC-03** | Factor Balance | Check each factor balanced within arms | No significant imbalance |
| **SQC-04** | Interaction Check | Test for treatment × factor interaction | Pre-specify in SAP |
| **SQC-05** | Strata Pooling | Pool strata with <5 patients | Document in SAP |

**Implementation:**
```r
check_stratification_quality <- function(patient_data, strat_factors) {
  strata_table <- table(patient_data[, strat_factors])
  
  # Check for sparse strata
  sparse_strata <- sum(strata_table < 5)
  empty_strata <- sum(strata_table == 0)
  
  return(list(
    n_strata = length(strata_table),
    min_stratum_size = min(strata_table),
    max_stratum_size = max(strata_table),
    median_stratum_size = median(strata_table),
    sparse_strata = sparse_strata,
    empty_strata = empty_strata,
    strata_distribution = strata_table,
    quality_status = ifelse(sparse_strata == 0 & empty_strata == 0, 
                           "PASS", "REVIEW_NEEDED")
  ))
}
```

---

## 🔬 Category 3: Efficacy Analysis Checks

### 3.1 Primary Endpoint Validation

| Check ID | Description | Method | Acceptance Criteria |
|----------|-------------|--------|---------------------|
| **EFF-01** | Endpoint Completeness | Check primary endpoint assessed in all patients | ≥95% complete |
| **EFF-02** | Assessment Timing | Verify assessments at protocol-defined visits | ±7 days |
| **EFF-03** | Response Confirmation | Confirm responses per RECIST v1.1 | ≥4 weeks confirmation |
| **EFF-04** | Missing Data Pattern | Test if data missing completely at random (MCAR) | Little's MCAR test p > 0.05 |
| **EFF-05** | Imputation Appropriateness | Verify imputation method per SAP | Documented & justified |
| **EFF-06** | Analysis Population | Verify ITT and PP populations defined | All randomized (ITT) |

**Implementation:**
```r
check_endpoint_completeness <- function(efficacy_data, endpoint_var) {
  n_total <- nrow(efficacy_data)
  n_complete <- sum(!is.na(efficacy_data[[endpoint_var]]))
  n_missing <- n_total - n_complete
  pct_complete <- n_complete / n_total * 100
  
  return(list(
    n_total = n_total,
    n_complete = n_complete,
    n_missing = n_missing,
    pct_complete = round(pct_complete, 2),
    completeness_status = ifelse(pct_complete >= 95, "PASS", 
                           ifelse(pct_complete >= 90, "WARNING", "FAIL"))
  ))
}
```

---

### 3.2 Statistical Test Assumptions

| Check ID | Description | Test | Acceptance Criteria |
|----------|-------------|------|---------------------|
| **STA-01** | Normality (Continuous) | Shapiro-Wilk test | p > 0.05 or N > 30 (CLT) |
| **STA-02** | Homogeneity of Variance | Levene's test | p > 0.05 |
| **STA-03** | Proportions Validity | Check 0 < p < 1 for all arms | All proportions valid |
| **STA-04** | Event Count | Check sufficient events for analysis | ≥10 events per variable |
| **STA-05** | Proportional Hazards | Schoenfeld residuals test | p > 0.05 for PH assumption |
| **STA-06** | Linearity | Check linear relationship (if applicable) | Residual plots |
| **STA-07** | Independence | Verify independence of observations | Study design check |

**Implementation:**
```r
check_statistical_assumptions <- function(data, outcome_var, group_var) {
  results <- list()
  
  # Normality test (by group)
  for (group in unique(data[[group_var]])) {
    group_data <- data[[outcome_var]][data[[group_var]] == group]
    if (length(group_data) >= 3 & length(group_data) <= 5000) {
      shapiro_result <- shapiro.test(group_data)
      results[[paste0("normality_", group)]] <- list(
        statistic = round(shapiro_result$statistic, 4),
        p_value = round(shapiro_result$p.value, 4),
        normal = shapiro_result$p.value > 0.05
      )
    }
  }
  
  # Homogeneity of variance (Levene's test)
  if (length(unique(data[[group_var]])) >= 2) {
    library(car)
    levene_result <- leveneTest(outcome_var ~ as.factor(data[[group_var]]))
    results$homogeneity <- list(
      statistic = round(levene_result[1, "F value"], 3),
      p_value = round(levene_result[1, "Pr(>F)"], 4),
      equal_variance = levene_result[1, "Pr(>F)"] > 0.05
    )
  }
  
  return(results)
}
```

---

### 3.3 Treatment Effect Estimation

| Check ID | Description | Method | Output |
|----------|-------------|--------|--------|
| **TTE-01** | Point Estimate | Treatment difference with 95% CI | Effect size |
| **TTE-02** | Hypothesis Test | Appropriate test (t-test, chi-square, log-rank) | p-value |
| **TTE-03** | Clinical Significance | Compare to minimally important difference | Clinically meaningful? |
| **TTE-04** | Subgroup Analysis | Treatment effect by key subgroups | Forest plot |
| **TTE-05** | Sensitivity Analysis | Multiple imputation, per-protocol, as-treated | Robustness check |
| **TTE-06** | Multiplicity Adjustment | Gatekeeping, Hochberg, or alpha spending | Adjusted p-values |

**Implementation:**
```r
estimate_treatment_effect <- function(data, outcome_var, group_var, 
                                      outcome_type = "continuous") {
  results <- list()
  
  if (outcome_type == "continuous") {
    # T-test or ANOVA
    groups <- unique(data[[group_var]])
    if (length(groups) == 2) {
      t_result <- t.test(data[[outcome_var]] ~ data[[group_var]])
      results$test_type <- "Welch t-test"
      results$estimate <- round(diff(t_result$estimate), 3)
      results$ci_lower <- round(t_result$conf.int[1], 3)
      results$ci_upper <- round(t_result$conf.int[2], 3)
      results$p_value <- round(t_result$p.value, 4)
    } else {
      aov_result <- aov(data[[outcome_var]] ~ as.factor(data[[group_var]]))
      results$test_type <- "ANOVA"
      results$f_statistic <- round(summary(aov_result)[[1]][1, "F value"], 3)
      results$p_value <- round(summary(aov_result)[[1]][1, "Pr(>F)"], 4)
    }
  } else if (outcome_type == "binary") {
    # Chi-square test with odds ratio
    table_result <- table(data[[group_var]], data[[outcome_var]])
    chisq_result <- chisq.test(table_result)
    results$test_type <- "Chi-square"
    results$chi_square <- round(chisq_result$statistic, 3)
    results$p_value <- round(chisq_result$p.value, 4)
    
    # Calculate proportions by group
    results$proportions <- prop.table(table_result, margin = 1)
  } else if (outcome_type == "survival") {
    # Log-rank test
    library(survival)
    surv_object <- Surv(time = data$time, event = data$status)
    survdiff_result <- survdiff(surv_object ~ data[[group_var]])
    results$test_type <- "Log-rank"
    results$chi_square <- round(survdiff_result$chisq, 3)
    results$p_value <- round(1 - pchisq(survdiff_result$chisq, 
                                        length(survdiff_result$n) - 1), 4)
  }
  
  return(results)
}
```

---

## ⚠️ Category 4: Safety Analysis Checks

### 4.1 Adverse Event Analysis

| Check ID | Description | Method | Acceptance Criteria |
|----------|-------------|--------|---------------------|
| **SAF-01** | AE Completeness | Check all patients have AE assessment | ≥98% complete |
| **SAF-02** | AE Coding | Verify MedDRA coding | 100% coded |
| **SAF-03** | Grade Distribution | Check AE grade distribution | Expected pattern |
| **SAF-04** | SAE Reporting | Verify SAEs reported within 24h | ≤24h for 100% |
| **SAF-05** | Relatedness Assessment | Check investigator causality assessment | All assessed |
| **SAF-06** | AE Leading to Discontinuation | Count & characterize | Document all |
| **SAF-07** | Deaths | Count & characterize by cause | Document all |
| **SAF-08** | Exposure-Adjusted AE Rates | Calculate per patient-year | Incidence rates |

**Implementation:**
```r
analyze_adverse_events <- function(ae_data, patient_data) {
  results <- list()
  
  # AE incidence by arm
  ae_by_arm <- table(ae_data$arm, ae_data$preferred_term)
  results$ae_by_arm <- ae_by_arm
  
  # Proportion with ≥1 AE
  patients_with_ae <- table(ae_data$arm)
  results$ae_incidence <- patients_with_ae / table(patient_data$arm) * 100
  
  # Grade distribution
  results$grade_distribution <- table(ae_data$grade, ae_data$arm)
  
  # Serious AEs
  sae_count <- sum(ae_data$serious == "Yes")
  results$sae_count <- sae_count
  results$sae_rate <- sae_count / nrow(ae_data) * 100
  
  # Treatment-related AEs
  related_ae <- sum(ae_data$relationship == "Related" | 
                    ae_data$relationship == "Possibly Related")
  results$related_ae_count <- related_ae
  
  # Most common AEs (≥10%)
  ae_freq <- sort(table(ae_data$preferred_term), decreasing = TRUE)
  results$common_aes <- ae_freq[ae_freq / nrow(ae_data) * 100 >= 10]
  
  return(results)
}
```

---

### 4.2 Laboratory Safety

| Check ID | Description | Method | Flagging |
|----------|-------------|--------|----------|
| **LAB-01** | Lab Completeness | Check lab assessments per schedule | ≥90% complete |
| **LAB-02** | Shift Tables | Baseline to worst on-treatment | Low/High flags |
| **LAB-03** | Hy's Law Cases | Check ALT/AST >3×ULN + Bilirubin >2×ULN | Flag immediately |
| **LAB-04** | Clinically Significant Changes | Compare to reference ranges | Per CTCAE |
| **LAB-05** | Laboratory Outliers | Check extreme values | Investigate |
| **LAB-06** | Potentially Fatal Toxicities | Monitor critical labs | Real-time alerts |

**Implementation:**
```r
generate_lab_shift_table <- function(lab_data, lab_var, uln) {
  # Baseline categorization
  lab_data$baseline_category <- cut(lab_data$baseline_value,
                                    breaks = c(0, uln * 0.5, uln, uln * 1.5, uln * 3, Inf),
                                    labels = c("Low", "Normal", "High", "Very High", "Extreme"))
  
  # Worst on-treatment categorization
  lab_data$worst_category <- cut(lab_data$worst_value,
                                 breaks = c(0, uln * 0.5, uln, uln * 1.5, uln * 3, Inf),
                                 labels = c("Low", "Normal", "High", "Very High", "Extreme"))
  
  # Shift table
  shift_table <- table(lab_data$baseline_category, lab_data$worst_category)
  
  return(list(
    shift_table = shift_table,
    n_normal_to_high = sum(shift_table["Normal", c("High", "Very High", "Extreme")]),
    n_normal_to_low = sum(shift_table["Normal", c("Low")]),
    pct_shifted = sum(shift_table["Normal", c("High", "Very High", "Extreme")]) / 
                  sum(shift_table["Normal", ]) * 100
  ))
}
```

---

## 📋 Category 5: Protocol Adherence Checks

### 5.1 Eligibility Criteria

| Check ID | Description | Method | Action |
|----------|-------------|--------|--------|
| **PRO-01** | Inclusion Criteria Met | Verify all inclusion criteria documented | Query if missing |
| **PRO-02** | Exclusion Criteria Absent | Verify no exclusion criteria present | Flag violations |
| **PRO-03** | Informed Consent | Verify signed before any procedures | Must be 100% |
| **PRO-04** | Window Violations | Check visit timing | Document & report |
| **PRO-05** | Dose Modifications | Verify dose adjustments per protocol | Document deviations |
| **PRO-06** | Concomitant Medications | Check prohibited medications | Flag violations |
| **PRO-07** | Discontinuation Reasons | Verify reason documented for all discontinuations | 100% documented |

**Implementation:**
```r
check_protocol_deviations <- function(patient_data, protocol_rules) {
  deviations <- list()
  
  # Check inclusion criteria
  deviations$inclusion_violations <- patient_data %>%
    filter(!inclusion_criteria_met) %>%
    select(patient_id, violation_details)
  
  # Check exclusion criteria
  deviations$exclusion_violations <- patient_data %>%
    filter(exclusion_criteria_present) %>%
    select(patient_id, exclusion_criterion)
  
  # Check informed consent
  deviations$consent_violations <- patient_data %>%
    filter(is.na(informed_consent_date) | 
           informed_consent_date > randomization_date) %>%
    select(patient_id, consent_date, randomization_date)
  
  # Check visit windows
  deviations$window_violations <- patient_data %>%
    filter(visit_date < visit_window_start | visit_date > visit_window_end) %>%
    select(patient_id, visit, visit_date, window_start, window_end)
  
  return(list(
    n_inclusion_violations = nrow(deviations$inclusion_violations),
    n_exclusion_violations = nrow(deviations$exclusion_violations),
    n_consent_violations = nrow(deviations$consent_violations),
    n_window_violations = nrow(deviations$window_violations),
    total_violations = sum(
      nrow(deviations$inclusion_violations),
      nrow(deviations$exclusion_violations),
      nrow(deviations$consent_violations),
      nrow(deviations$window_violations)
    ),
    deviation_rate = sum(
      nrow(deviations$inclusion_violations),
      nrow(deviations$exclusion_violations),
      nrow(deviations$consent_violations),
      nrow(deviations$window_violations)
    ) / nrow(patient_data) * 100,
    details = deviations
  ))
}
```

---

## 🔢 Category 6: Sample Size & Power Checks

### 6.1 Post-Hoc Power Analysis

| Check ID | Description | Method | Interpretation |
|----------|-------------|--------|----------------|
| **SSC-01** | Achieved Power | Calculate power based on actual sample size | Should be ≥80% |
| **SSC-02** | Detectable Effect Size | Calculate minimum detectable effect | Clinically meaningful? |
| **SSC-03** | Event Count | Check if sufficient events occurred | ≥10 events per variable |
| **SSC-04** | Dropout Rate | Compare actual vs expected dropout | Within 5% of expected |
| **SSC-05** | Analysis Population | Check ITT and PP sizes | ITT = all randomized |

**Implementation:**
```r
post_hoc_power_analysis <- function(n_per_arm, observed_effect_size, alpha = 0.05) {
  # Calculate achieved power for two-sample t-test
  library(pwr)
  power_result <- pwr.t.test(
    n = n_per_arm,
    d = observed_effect_size,
    sig.level = alpha,
    type = "two.sample",
    alternative = "two.sided"
  )
  
  return(list(
    n_per_arm = n_per_arm,
    total_n = n_per_arm * 2,
    observed_effect_size = observed_effect_size,
    alpha = alpha,
    achieved_power = round(power_result$power, 3),
    power_status = ifelse(power_result$power >= 0.80, "ADEQUATE", "UNDERPOWERED")
  ))
}
```

---

## 📊 Category 7: Interim Analysis Checks

### 7.1 Group Sequential Monitoring

| Check ID | Description | Method | Decision Rule |
|----------|-------------|--------|---------------|
| **INT-01** | Alpha Spending | Check alpha used at each look | O'Brien-Fleming or Pocock |
| **INT-02** | Stopping Boundaries | Calculate efficacy/futility boundaries | Pre-specified in charter |
| **INT-03** | Conditional Power | Calculate probability of success at end | <20% stop for futility |
| **INT-04** | Data Maturity | Check % of events observed | ≥50% of planned events |
| **INT-05** | Type I Error Inflation | Adjust for multiple looks | Alpha spending function |

**Implementation:**
```r
check_interim_analysis <- function(current_data, planned_analysis, alpha_spending = "OBrienFleming") {
  library(gsDesign)
  
  # Calculate information fraction
  observed_events <- sum(current_data$event)
  planned_events <- planned_analysis$total_events
  information_fraction <- observed_events / planned_events
  
  # Design group sequential trial
  gs_design <- gsDesign(
    k = planned_analysis$n_looks,
    test.type = 4,
    alpha = 0.025,
    beta = 0.20,
    sfu = alpha_spending,
    sfl = "Pocock",
    n.fix = planned_analysis$sample_size
  )
  
  # Check if at interim boundary
  current_z <- observed_z_statistic(current_data)
  efficacy_boundary <- gs_design$upper$bound[planned_analysis$current_look]
  futility_boundary <- gs_design$lower$bound[planned_analysis$current_look]
  
  return(list(
    information_fraction = round(information_fraction, 3),
    current_z_statistic = round(current_z, 3),
    efficacy_boundary = round(efficacy_boundary, 3),
    futility_boundary = round(futility_boundary, 3),
    recommendation = ifelse(current_z >= efficacy_boundary, "STOP_EFFICACY",
                      ifelse(current_z <= futility_boundary, "STOP_FUTILITY",
                             "CONTINUE")),
    conditional_power = calculate_conditional_power(current_data, planned_analysis)
  ))
}
```

---

## 🛡️ Category 8: Multiplicity Adjustments

### 8.1 Multiple Testing Corrections

| Check ID | Description | Method | When to Apply |
|----------|-------------|--------|---------------|
| **MUL-01** | Multiple Primary Endpoints | Gatekeeping procedure | ≥2 primary endpoints |
| **MUL-02** | Multiple Arms | Dunnett's test or Hochberg | ≥3 treatment arms |
| **MUL-03** | Multiple Timepoints | Adjusted p-values | Repeated measures |
| **MUL-04** | Subgroup Analyses | Pre-specify & limit | Key subgroups only |
| **MUL-05** | Interim Looks | Alpha spending | ≥1 interim analysis |
| **MUL-06** | Secondary Endpoints | Hierarchical testing | After primary significant |

**Implementation:**
```r
adjust_for_multiplicity <- function(p_values, method = "Hochberg", 
                                     hierarchy = NULL) {
  results <- list()
  
  if (method == "Bonferroni") {
    results$adjusted_p <- p.adjust(p_values, method = "bonferroni")
  } else if (method == "Hochberg") {
    results$adjusted_p <- p.adjust(p_values, method = "hochberg")
  } else if (method == "Holm") {
    results$adjusted_p <- p.adjust(p_values, method = "holm")
  } else if (method == "BH") {
    results$adjusted_p <- p.adjust(p_values, method = "BH")  # FDR control
  } else if (method == "Gatekeeping") {
    # Hierarchical gatekeeping
    if (is.null(hierarchy)) stop("Hierarchy required for gatekeeping")
    results$adjusted_p <- rep(NA, length(p_values))
    
    # Test in order, stop at first non-significant
    for (i in hierarchy) {
      if (p_values[i] < 0.05) {
        results$adjusted_p[i] <- p_values[i]
        results$significant[i] <- TRUE
      } else {
        results$adjusted_p[i] <- p_values[i]
        results$significant[i] <- FALSE
        break  # Stop testing
      }
    }
  }
  
  results$method <- method
  results$original_p <- p_values
  results$any_significant <- any(results$adjusted_p < 0.05, na.rm = TRUE)
  
  return(results)
}
```

---

## 📝 Category 9: Missing Data Analysis

### 9.1 Missing Data Patterns

| Check ID | Description | Method | Action |
|----------|-------------|--------|--------|
| **MIS-01** | Missingness Mechanism | Little's MCAR test | Determine if MCAR, MAR, or MNAR |
| **MIS-02** | Missing Data Pattern | Monotone vs intermittent | Choose imputation method |
| **MIS-03** | Missing Data Proportion | Calculate % missing per variable | Document in CSR |
| **MIS-04** | Sensitivity to Missing | Multiple imputation vs complete case | Assess robustness |
| **MIS-05** | Pattern Mixture Models | Test MNAR assumption | If suspected MNAR |

**Implementation:**
```r
analyze_missing_data <- function(data) {
  library(mice)
  
  # Missing data pattern
  missing_pattern <- md.pattern(data, plot = FALSE)
  
  # Proportion missing per variable
  pct_missing <- sapply(data, function(x) sum(is.na(x)) / length(x) * 100)
  
  # Little's MCAR test
  mcar_test <- LittleMCAR(data)
  
  return(list(
    pct_missing_by_variable = round(pct_missing, 2),
    overall_missing_pct = round(sum(is.na(data)) / (nrow(data) * ncol(data)) * 100, 2),
    missing_pattern = missing_pattern,
    mcar_test_statistic = round(mcar_test$statistic, 3),
    mcar_test_p_value = round(mcar_test$p.value, 4),
    missingness_mechanism = ifelse(mcar_test$p.value > 0.05, 
                                   "MCAR (Missing Completely at Random)",
                                   "Not MCAR (may be MAR or MNAR)"),
    recommendations = generate_missing_data_recommendations(pct_missing, mcar_test)
  ))
}
```

---

## ✅ Category 10: Overall Quality Dashboard

### 10.1 Trial Quality Score

| Check ID | Description | Weight | Scoring |
|----------|-------------|--------|---------|
| **QLT-01** | Data Completeness | 20% | % of completeness checks passed |
| **QLT-02** | Randomization Quality | 15% | Balance, stratification quality |
| **QLT-03** | Statistical Assumptions | 15% | % of assumptions met |
| **QLT-04** | Protocol Adherence | 15% | % without major deviations |
| **QLT-05** | Safety Data Quality | 10% | AE reporting completeness |
| **QLT-06** | Missing Data | 10% | % missing, mechanism |
| **QLT-07** | Analysis Appropriateness | 15% | Methods match SAP |

**Implementation:**
```r
generate_quality_dashboard <- function(all_checks) {
  quality_scores <- list()
  
  # Data Completeness (20%)
  completeness_passed <- sum(sapply(all_checks$completeness, 
                                     function(x) x$status == "PASS"))
  completeness_total <- length(all_checks$completeness)
  quality_scores$completeness <- completeness_passed / completeness_total * 100
  
  # Randomization Quality (15%)
  quality_scores$randomization <- ifelse(all_checks$randomization$balance_status == "BALANCED", 
                                          100, 50)
  
  # Statistical Assumptions (15%)
  assumptions_passed <- sum(sapply(all_checks$assumptions, function(x) x$met))
  assumptions_total <- length(all_checks$assumptions)
  quality_scores$assumptions <- assumptions_passed / assumptions_total * 100
  
  # Protocol Adherence (15%)
  quality_scores$protocol <- 100 - all_checks$protocol$deviation_rate
  
  # Safety Data Quality (10%)
  quality_scores$safety <- all_checks$safety$ae_completeness_pct
  
  # Missing Data (10%)
  quality_scores$missing <- 100 - all_checks$missing$overall_missing_pct
  
  # Analysis Appropriateness (15%)
  quality_scores$analysis <- ifelse(all_checks$analysis$methods_appropriate, 100, 50)
  
  # Overall Score
  overall_score <- (
    quality_scores$completeness * 0.20 +
    quality_scores$randomization * 0.15 +
    quality_scores$assumptions * 0.15 +
    quality_scores$protocol * 0.15 +
    quality_scores$safety * 0.10 +
    quality_scores$missing * 0.10 +
    quality_scores$analysis * 0.15
  )
  
  quality_scores$overall <- round(overall_score, 2)
  quality_scores$grade <- ifelse(overall_score >= 90, "A",
                          ifelse(overall_score >= 80, "B",
                          ifelse(overall_score >= 70, "C",
                          ifelse(overall_score >= 60, "D", "F"))))
  
  return(quality_scores)
}
```

---

## 📊 Implementation Priority

### 🔴 Phase 1: Essential Checks (Build First)
1. **Data Quality** (DQC-01 to DQC-08, CSC-01 to CSC-08)
2. **Randomization Balance** (RQC-01 to RQC-07)
3. **Endpoint Completeness** (EFF-01 to EFF-06)
4. **AE Analysis** (SAF-01 to SAF-08)

### 🟡 Phase 2: Statistical Validation
5. **Statistical Assumptions** (STA-01 to STA-07)
6. **Treatment Effect** (TTE-01 to TTE-06)
7. **Missing Data** (MIS-01 to MIS-05)
8. **Protocol Adherence** (PRO-01 to PRO-07)

### 🟢 Phase 3: Advanced Checks
9. **Multiplicity** (MUL-01 to MUL-06)
10. **Interim Analysis** (INT-01 to INT-05)
11. **Sample Size** (SSC-01 to SSC-05)
12. **Quality Dashboard** (QLT-01 to QLT-07)

---

## 💡 Next Steps

1. **Prioritize Phase 1 checks** for immediate implementation
2. **Build modular functions** for each check category
3. **Create validation UI** in Shiny app with checklists
4. **Generate quality reports** for export
5. **Integrate with TLF Generator** for automated validation

**This comprehensive framework ensures all FDA-required statistical checks are implemented, producing regulatory-ready clinical trial analyses.**
