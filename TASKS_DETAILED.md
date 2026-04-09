# Clinical Trial Platform - Detailed Task Specifications

This document provides detailed task breakdowns for each milestone, enabling completion across multiple development sessions.

---

## 🔴 Milestone 1: TLF Generator

**Goal:** Automated generation of regulatory-ready clinical trial tables, listings, and figures

**Estimated Effort:** 3-4 sessions (5-6 hours)

---

### Session 1.1: Demographics & Baseline Characteristics Table

**Objective:** Build Table 14.1 - Demographics and Baseline Characteristics

**Tasks:**
- [ ] **Task 1.1.1:** Create UI structure for TLF Generator
  - Add new tab panel "TLF Generator"
  - Create sidebar with TLF categories (Tables, Listings, Figures)
  - Add export format selector (CSV, Excel, RTF)
  - **Location:** `app.R` - UI section
  - **Dependencies:** None
  - **Time:** 30 min

- [ ] **Task 1.1.2:** Build demographics summary calculator
  - Function: `generate_demographics_table(patient_data, treatment_arms)`
  - Calculate for each arm:
    - N (total patients)
    - Age: Mean (SD), Median (Min, Max)
    - Sex: Female N (%), Male N (%)
    - Race: White N (%), Black N (%), Asian N (%), Other N (%)
    - Ethnicity: Hispanic N (%), Non-Hispanic N (%)
    - Height: Mean (SD)
    - Weight: Mean (SD)
    - BMI: Mean (SD)
  - **Location:** `app.R` - Server section or new utility file
  - **Dependencies:** Task 1.1.1
  - **Time:** 45 min

- [ ] **Task 1.1.3:** Create demographics table renderer
  - Display in formatted DT datatable
  - Column structure: Parameter | Arm 1 | Arm 2 | Arm 3 | Overall
  - Add proper formatting (mean±SD, N%)
  - **Location:** `app.R` - Server section
  - **Dependencies:** Task 1.1.2
  - **Time:** 30 min

- [ ] **Task 1.1.4:** Add baseline characteristics
  - ECOG Performance Status: 0 N (%), 1 N (%)
  - Disease Stage: II N (%), III N (%), IV N (%)
  - Prior Therapies: 0 N (%), 1 N (%), ≥2 N (%)
  - Biomarker Status (PDL1): <1% N (%), 1-49% N (%), ≥50% N (%)
  - Histology: NSQ N (%), SQ N (%)
  - **Location:** `app.R` - Server section
  - **Dependencies:** Task 1.1.3
  - **Time:** 45 min

- [ ] **Task 1.1.5:** Implement export functionality
  - Export to CSV with proper formatting
  - Export to Excel with multiple sheets (one per table)
  - **Location:** `app.R` - Server section
  - **Dependencies:** Task 1.1.4
  - **Time:** 30 min

**Deliverables:**
- ✅ Complete demographics table (Table 14.1)
- ✅ Export to CSV/Excel
- ✅ Professional formatting

**Success Criteria:**
- All statistics calculate correctly
- Formatting matches regulatory standards
- Export works without errors

---

### Session 1.2: Efficacy & Safety Tables

**Objective:** Build Table 14.2 (Efficacy) and Table 14.3 (Safety Summary)

**Tasks:**
- [ ] **Task 1.2.1:** Build efficacy analysis table
  - Function: `generate_efficacy_table(outcomes, treatment_arms)`
  - Calculate for each arm:
    - Total N
    - Complete Response (CR): N (%)
    - Partial Response (PR): N (%)
    - Stable Disease (SD): N (%)
    - Progressive Disease (PD): N (%)
    - ORR (CR+PR): N (%) with 95% CI
    - DCR (CR+PR+SD): N (%) with 95% CI
    - Median PFS (months) with 95% CI
    - Median OS (months) with 95% CI
  - Add 95% CI calculation using Wilson score method
  - **Location:** `app.R` - Server section
  - **Dependencies:** Session 1.1 complete
  - **Time:** 60 min

- [ ] **Task 1.2.2:** Build safety summary table
  - Function: `generate_safety_table(outcomes, treatment_arms)`
  - Calculate for each arm:
    - Safety Population N (all exposed patients)
    - Any Treatment-Emergent AE: N (%)
    - Grade 3-4 AE: N (%)
    - Serious AE: N (%)
    - AE Leading to Discontinuation: N (%)
    - Deaths: N (%)
    - Most Common AEs (≥10%): List N (%)
  - **Location:** `app.R` - Server section
  - **Dependencies:** Task 1.2.1
  - **Time:** 45 min

- [ ] **Task 1.2.3:** Build AE by SOC/PT table
  - Function: `generate_ae_by_soc_pt(ae_data)`
  - Group by System Organ Class (SOC)
  - Within SOC, list Preferred Terms (PT)
  - Show N (%) by treatment arm
  - **Location:** `app.R` - Server section
  - **Dependencies:** Task 1.2.2
  - **Time:** 45 min

- [ ] **Task 1.2.4:** Add disposition table (Table 14.4)
  - Function: `generate_disposition_table(patient_data, outcomes)`
  - Screened: N
  - Screen Failures: N (%)
  - Randomized: N (%)
  - Completed Treatment: N (%)
  - Discontinued: N (%) with reasons
  - Completed Study: N (%)
  - **Location:** `app.R` - Server section
  - **Dependencies:** Task 1.2.3
  - **Time:** 30 min

**Deliverables:**
- ✅ Efficacy table with 95% CI
- ✅ Safety summary table
- ✅ AE by SOC/PT table
- ✅ Disposition table

**Success Criteria:**
- Confidence intervals calculate correctly
- AE table properly nested by SOC/PT
- All percentages accurate

---

### Session 1.3: Patient Listings

**Objective:** Generate patient-level data listings

**Tasks:**
- [ ] **Task 1.3.1:** Patient demographics listing
  - Function: `generate_patient_listing(patient_data)`
  - Columns: Patient ID, Arm, Age, Sex, Race, Ethnicity, Site
  - Sortable, filterable DT table
  - **Location:** `app.R` - Server section
  - **Dependencies:** Session 1.2 complete
  - **Time:** 30 min

- [ ] **Task 1.3.2:** Adverse events listing
  - Function: `generate_ae_listing(ae_data)`
  - Columns: Patient ID, Arm, AE Term, SOC, Grade, Onset Date, Resolution Date, Outcome, Relationship
  - Group by patient
  - **Location:** `app.R` - Server section
  - **Dependencies:** Task 1.3.1
  - **Time:** 45 min

- [ ] **Task 1.3.3:** Concomitant medications listing
  - Function: `generate_conmed_listing(conmed_data)`
  - Columns: Patient ID, Arm, Medication, Indication, Start Date, End Date, Dose
  - **Location:** `app.R` - Server section
  - **Dependencies:** Task 1.3.2
  - **Time:** 30 min

- [ ] **Task 1.3.4:** Efficacy measurements listing
  - Function: `generate_efficacy_listing(efficacy_data)`
  - Columns: Patient ID, Arm, Visit, Assessment Date, Tumor Measurements, Response
  - **Location:** `app.R` - Server section
  - **Dependencies:** Task 1.3.3
  - **Time:** 30 min

- [ ] **Task 1.3.5:** Lab values listing with abnormal flags
  - Function: `generate_lab_listing(lab_data)`
  - Columns: Patient ID, Arm, Visit, Lab Test, Result, Unit, Normal Range, Abnormal Flag
  - **Location:** `app.R` - Server section
  - **Dependencies:** Task 1.3.4
  - **Time:** 30 min

**Deliverables:**
- ✅ 5 patient-level listings
- ✅ Sortable/filterable tables
- ✅ Export to CSV/Excel

**Success Criteria:**
- All listings generate correctly
- Proper column formatting
- Export functionality works

---

### Session 1.4: Figures & Visualizations

**Objective:** Create Kaplan-Meier curves, forest plots, and other clinical trial figures

**Tasks:**
- [ ] **Task 1.4.1:** Kaplan-Meier survival curves
  - Function: `plot_kaplan_meier(survival_data, treatment_arms)`
  - Use survival package for estimation
  - Plot OS and PFS curves
  - Add number at risk table below
  - Add median survival times with 95% CI
  - Add log-rank test p-value
  - **Location:** `app.R` - Server section
  - **Dependencies:** Session 1.3 complete
  - **Required Package:** survival, survminer
  - **Time:** 60 min

- [ ] **Task 1.4.2:** Forest plot for subgroup analysis
  - Function: `plot_forest_subgroup(outcomes, subgroup_variable)`
  - Calculate hazard ratios by subgroup
  - Display as forest plot
  - Include overall effect
  - **Location:** `app.R` - Server section
  - **Dependencies:** Task 1.4.1
  - **Required Package:** forestplot
  - **Time:** 60 min

- [ ] **Task 1.4.3:** Swimmer plot
  - Function: `plot_swimmer(patient_data, outcomes)`
  - One horizontal bar per patient
  - Show treatment duration
  - Color-code by response
  - Mark death/discontinuation
  - **Location:** `app.R` - Server section
  - **Dependencies:** Task 1.4.2
  - **Required Package:** ggplot2
  - **Time:** 60 min

- [ ] **Task 1.4.4:** Waterfall plot (tumor response)
  - Function: `plot_waterfall(tumor_measurements)`
  - Show % change in tumor size
  - One bar per patient
  - Color by response category
  - Add RECIST v1.1 lines (-30%, +20%)
  - **Location:** `app.R` - Server section
  - **Dependencies:** Task 1.4.3
  - **Required Package:** ggplot2
  - **Time:** 45 min

- [ ] **Task 1.4.5:** Bar chart for response rates
  - Function: `plot_response_rates(efficacy_data)`
  - Show ORR, DCR by arm
  - Add 95% CI error bars
  - **Location:** `app.R` - Server section
  - **Dependencies:** Task 1.4.4
  - **Required Package:** ggplot2
  - **Time:** 30 min

**Deliverables:**
- ✅ Kaplan-Meier curves with at-risk table
- ✅ Forest plot
- ✅ Swimmer plot
- ✅ Waterfall plot
- ✅ Response rate bar chart

**Success Criteria:**
- All plots render correctly
- Statistical tests included
- Professional publication quality
- Export to PNG/PDF

---

## 🔴 Milestone 2: FDA eCTD JSON Export

**Goal:** Structured export package for FDA regulatory submission

**Estimated Effort:** 2-3 sessions (4-5 hours)

---

### Session 2.1: SDTM Dataset Generation

**Objective:** Create Study Data Tabulation Model datasets

**Tasks:**
- [ ] **Task 2.1.1:** SDTM Demographics (DM) domain
  - Function: `generate_sdtm_dm(patient_data, randomization)`
  - Variables: STUDYID, USUBJID, SUBJID, RFSTDTC, RFENDTC, SITEID, AGE, SEX, RACE, ETHNIC, ARMCD, ARM
  - Format dates as ISO 8601
  - Use CDISC controlled terminology
  - **Location:** `app.R` - Server or utility file
  - **Dependencies:** Milestone 1 complete
  - **Time:** 45 min

- [ ] **Task 2.1.2:** SDTM Adverse Events (AE) domain
  - Function: `generate_sdtm_ae(ae_data, patient_data)`
  - Variables: STUDYID, USUBJID, AETERM, AEDECOD, AESOC, AESEV, AESER, AEREL, AESTDTC, AEENDTC, AEOUT
  - Map to MedDRA terms
  - **Location:** `app.R` - Server section
  - **Dependencies:** Task 2.1.1
  - **Time:** 45 min

- [ ] **Task 2.1.3:** SDTM Disposition (DS) domain
  - Function: `generate_sdtm_ds(disposition_data)`
  - Variables: STUDYID, USUBJID, DSDECOD, DSTERM, DSSTDTC, DSCAT
  - Include screening, randomization, completion, discontinuation
  - **Location:** `app.R` - Server section
  - **Dependencies:** Task 2.1.2
  - **Time:** 30 min

- [ ] **Task 2.1.4:** SDTM Exposure (EX) domain
  - Function: `generate_sdtm_ex(exposure_data)`
  - Variables: STUDYID, USUBJID, EXTRT, EXDOSE, EXDOSU, EXSTDTC, EXENDTC, EXROUTE
  - **Location:** `app.R` - Server section
  - **Dependencies:** Task 2.1.3
  - **Time:** 30 min

- [ ] **Task 2.1.5:** Additional SDTM domains
  - RS (Response - Solid Tumor)
  - TU (Tumor Identification)
  - TR (Tumor Results)
  - LB (Laboratory Tests) - if available
  - VS (Vital Signs) - if available
  - **Location:** `app.R` - Server section
  - **Dependencies:** Task 2.1.4
  - **Time:** 60 min

**Deliverables:**
- ✅ 8+ SDTM domains
- ✅ CDISC-compliant variable naming
- ✅ ISO 8601 date formatting
- ✅ Controlled terminology

**Success Criteria:**
- Pass FDA Data Standards Validator
- All required variables present
- Proper codelist references

---

### Session 2.2: ADaM Dataset Generation

**Objective:** Create Analysis Data Model datasets

**Tasks:**
- [ ] **Task 2.2.1:** ADaM ADSL (Subject-Level)
  - Function: `generate_adam_adsl(patient_data, outcomes)`
  - Variables: STUDYID, USUBJID, SITEID, AGE, SEX, RACE, ETHNIC, ARMCD, ARM, SAFFL, ITTFL, AAGE, AAGEU
  - Add analysis flags (SAFFL, ITTFL)
  - **Location:** `app.R` - Server section
  - **Dependencies:** Session 2.1 complete
  - **Time:** 45 min

- [ ] **Task 2.2.2:** ADaM ADEFF (Efficacy Analysis)
  - Function: `generate_adam_adeff(efficacy_data)`
  - Variables: STUDYID, USUBJID, PARAM, PARAMCD, AVAL, AVALC, ANL01FL
  - Include derived efficacy endpoints
  - **Location:** `app.R` - Server section
  - **Dependencies:** Task 2.2.1
  - **Time:** 45 min

- [ ] **Task 2.2.3:** ADaM ADSAFF (Safety Analysis)
  - Function: `generate_adam_adsaff(safety_data)`
  - Variables: STUDYID, USUBJID, PARAM, PARAMCD, AVAL, AVALC, ANL01FL
  - Include safety endpoints (AEs, lab values)
  - **Location:** `app.R` - Server section
  - **Dependencies:** Task 2.2.2
  - **Time:** 30 min

- [ ] **Task 2.2.4:** ADaM ADTTE (Time-to-Event)
  - Function: `generate_adam_adtte(survival_data)`
  - Variables: STUDYID, USUBJID, PARAM, PARAMCD, AVAL, CNSR, CNSRVAL, STARTDT, ADT
  - Include censoring information
  - **Location:** `app.R` - Server section
  - **Dependencies:** Task 2.2.3
  - **Time:** 45 min

**Deliverables:**
- ✅ 4 ADaM datasets
- ✅ Analysis-ready format
- ✅ Proper flags and derivations

**Success Criteria:**
- Analysis populations defined
- Derivations documented
- Compatible with statistical software

---

### Session 2.3: define.xml & JSON Package

**Objective:** Create metadata and submission package

**Tasks:**
- [ ] **Task 2.3.1:** define.xml generator
  - Function: `generate_define_xml(sdtm_datasets, adam_datasets)`
  - Include dataset metadata
  - Variable-level definitions
  - Codelist definitions
  - Derivation algorithms
  - **Location:** `app.R` - Server section
  - **Dependencies:** Session 2.2 complete
  - **Required Package:** xml2 or manual XML generation
  - **Time:** 60 min

- [ ] **Task 2.3.2:** JSON export for FDA gateway
  - Function: `generate_fda_json(all_data)`
  - Structure per FDA Technical Conformance Guide
  - Include study metadata
  - Dataset references
  - **Location:** `app.R` - Server section
  - **Dependencies:** Task 2.3.1
  - **Required Package:** jsonlite
  - **Time:** 45 min

- [ ] **Task 2.3.3:** Validation checklist
  - Function: `validate_submission(data)`
  - Check required domains
  - Verify variable presence
  - Validate date formats
  - Check codelist compliance
  - **Location:** `app.R` - Server section
  - **Dependencies:** Task 2.3.2
  - **Time:** 30 min

- [ ] **Task 2.3.4:** One-click export package
  - UI: "FDA eCTD Export" button
  - Zip all files together
  - Create folder structure per eCTD
  - **Location:** `app.R` - UI + Server
  - **Dependencies:** Task 2.3.3
  - **Required Package:** zip
  - **Time:** 30 min

**Deliverables:**
- ✅ define.xml
- ✅ JSON submission package
- ✅ Validation report
- ✅ One-click export

**Success Criteria:**
- Pass FDA Data Standards Validator
- Complete metadata
- Proper file structure

---

## 🟡 Milestone 3: Sample Size Calculator

**Goal:** Statistical planning tool for trial design

**Estimated Effort:** 2-3 sessions (3-4 hours)

---

### Session 3.1: Phase-Specific Calculators

**Objective:** Sample size calculations for each trial phase

**Tasks:**
- [ ] **Task 3.1.1:** Phase 2 single-arm (Simon's 2-stage)
  - Function: `calc_sample_size_simon2stage(p0, p1, alpha, beta)`
  - Inputs: Null ORR, Alternative ORR, Type I error, Power
  - Outputs: Stage 1 N, Total N, Stopping rules
  - **Location:** `app.R` - Server or utility
  - **Dependencies:** None
  - **Time:** 45 min

- [ ] **Task 3.1.2:** Phase 2 randomized (ORR-based)
  - Function: `calc_sample_size_binary(p1, p2, alpha, beta, ratio)`
  - Compare two proportions
  - Include continuity correction
  - **Location:** `app.R` - Server section
  - **Dependencies:** Task 3.1.1
  - **Time:** 30 min

- [ ] **Task 3.1.3:** Phase 3 superiority (time-to-event)
  - Function: `calc_sample_size_survival(median_control, median_experimental, alpha, beta, accrual, followup)`
  - Log-rank test for survival endpoints
  - Account for dropout rate
  - **Location:** `app.R` - Server section
  - **Dependencies:** Task 3.1.2
  - **Time:** 45 min

- [ ] **Task 3.1.4:** Phase 3 non-inferiority
  - Function: `calc_sample_size_noninf(delta, sigma, alpha, beta)`
  - Non-inferiority margin
  - Continuous or binary endpoints
  - **Location:** `app.R` - Server section
  - **Dependencies:** Task 3.1.3
  - **Time:** 45 min

**Deliverables:**
- ✅ 4 sample size calculators
- ✅ Interactive UI with sliders
- ✅ Results with interpretation

**Success Criteria:**
- Results match standard software
- Clear parameter descriptions
- Proper statistical assumptions

---

### Session 3.2: Advanced Features

**Objective:** Power curves, interim analysis, and export

**Tasks:**
- [ ] **Task 3.2.1:** Power curve visualization
  - Function: `plot_power_curve(sample_sizes, effect_sizes, power_values)`
  - Plot N vs. Power for different effect sizes
  - Interactive plotly chart
  - **Location:** `app.R` - Server section
  - **Dependencies:** Session 3.1 complete
  - **Required Package:** plotly
  - **Time:** 30 min

- [ ] **Task 3.2.2:** Interim analysis planning
  - Function: `calc_interim_analysis(n_looks, alpha_spending)`
  - O'Brien-Fleming boundaries
  - Pocock boundaries
  - Haybittle-Peto boundaries
  - **Location:** `app.R` - Server section
  - **Dependencies:** Task 3.2.1
  - **Required Package:** gsDesign or rpact
  - **Time:** 60 min

- [ ] **Task 3.2.3:** Dropout adjustment
  - Function: `adjust_for_dropout(n_calc, dropout_rate)`
  - Calculate inflated sample size
  - Show scenarios (5%, 10%, 20%)
  - **Location:** `app.R` - Server section
  - **Dependencies:** Task 3.2.2
  - **Time:** 30 min

- [ ] **Task 3.2.4:** Protocol justification text
  - Function: `generate_sample_size_justification(inputs, results)`
  - Auto-generate text for protocol
  - Include assumptions and calculations
  - **Location:** `app.R` - Server section
  - **Dependencies:** Task 3.2.3
  - **Time:** 30 min

- [ ] **Task 3.2.5:** Export to CSV/Excel
  - Export calculation results
  - Include power curves
  - **Location:** `app.R` - Server section
  - **Dependencies:** Task 3.2.4
  - **Time:** 15 min

**Deliverables:**
- ✅ Power curves
- ✅ Interim analysis boundaries
- ✅ Protocol-ready justification
- ✅ Export functionality

**Success Criteria:**
- Visualizations clear and accurate
- Interim boundaries correct
- Export works properly

---

## Notes for Development

### General Guidelines
- Each task should be completable in 30-60 minutes
- Test each function independently before integrating
- Use simulated data for testing (generate_patient_data function)
- Add error handling for edge cases
- Document all functions with comments

### Testing Strategy
- Create test datasets with known outputs
- Verify calculations against standard software
- Test with edge cases (N=0, missing data, etc.)
- Validate exports with FDA validator when available

### Code Organization
- Keep utility functions in separate files if app.R gets too large
- Use consistent naming conventions
- Add comprehensive comments
- Include example usage in comments

---

**This detailed task breakdown enables incremental development across multiple sessions, with clear deliverables and success criteria for each task.**
