# Quick Start Guide - Clinical Trial Randomization Tool

## 🚀 Launch the Application

The application is now running at: **http://127.0.0.1:3838**

Open your web browser and navigate to the URL above.

---

## 📋 Step-by-Step Workflow

### Step 1: Select Trial Phase
1. Click on the **"Phase Selection"** tab
2. Click on one of the phase cards:
   - **Phase 1:** Dose Optimization (120 patients, 3 arms)
   - **Phase 2:** Dose Expansion (160 patients, 2 arms)
   - **Phase 3:** Confirmatory Testing (440 patients, 2 arms)
3. Review the trial schema visual at the top

### Step 2: Configure Stratification
1. Click on the **"Stratification"** tab
2. Select stratification factors:
   - ✅ PDL1 Expression Level (<1% vs 1-49% vs ≥50%)
   - ✅ Histology (NSQ vs SQ)
   - ✅ Geographic Region (East Asia vs Rest of World)
   - Optional: ECOG PS, Age Group, Gender
3. Click **"Generate Strata Combinations"**
4. Review the strata table showing all possible combinations

### Step 3: Build Randomization List
1. Click on the **"Randomization Builder"** tab
2. Set parameters:
   - **Total Patients:** Enter number (e.g., 120 for Phase 1)
   - **Randomization Ratio:** Enter ratio (e.g., "1:1:1" for Phase 1, "1:1" for Phase 2/3)
   - **Block Size:** Select 4, 6, 8, or 12
   - ✅ Check "Use Stratified Randomization"
3. Click **"Generate Randomization List"**
4. Review the randomization table with patient assignments

### Step 4: Generate Envelopes
1. Click on the **"Envelope Generator"** tab
2. Configure:
   - **Number of Envelopes:** Match total patients
   - ✅ Check "Include Blinding Information"
   - **Site Code:** Enter your site code (e.g., "SITE001")
   - **Generation Date:** Select today's date
3. Click **"Generate Envelopes"**
4. Preview the envelope cards
5. Review the envelope log table

### Step 5: Run Simulations
1. Click on the **"Simulation & Outcomes"** tab
2. Configure simulation:
   - **Dose Escalation Scheme:** Select 3+3, CRM, or Accelerated
   - **Number of Cohorts:** Enter 10 (or desired number)
   - **Simulation Runs:** Enter 100
   - **Primary Endpoint:** Select ORR, PFS, OS, or DCR
3. Click **"Run Simulation"**
4. Review:
   - Dose escalation pathway plot
   - Treatment response by arm
   - Simulation results summary table

### Step 6: Monitor Trial Progress
1. Click on the **"Monitoring Dashboard"** tab
2. View real-time statistics:
   - Enrollment numbers
   - Randomization rate
   - Arm balance visualization
   - Patient randomization log

### Step 7: Export Data
1. Click on the **"Export & Reports"** tab
2. Select items to export:
   - ✅ Randomization List
   - ✅ Envelope Log
   - ✅ Patient Stratification Data
   - ✅ Simulation Results
   - ✅ Trial Summary Report
3. Choose export format (CSV, Excel, or PDF)
4. Click **"Download Export"**

---

## 🎯 Example: Complete Phase 1 Trial Setup

### Scenario: EIK1001 NSCLC Phase 1 Dose Optimization

1. **Phase Selection:** Click "Phase 1: Dose Optimization"
   - Review 3-arm design (Placebo, Low Dose, High Dose)
   - Note: N=120, Ratio=1:1:1

2. **Stratification:** Select factors
   - ✅ PDL1 Expression Level
   - ✅ Histology
   - ✅ Geographic Region
   - Click "Generate Strata Combinations"
   - Result: 12 strata (3 × 2 × 2)

3. **Randomization Builder:**
   - Total Patients: 120
   - Ratio: 1:1:1
   - Block Size: 6
   - ✅ Stratified Randomization
   - Click "Generate Randomization List"
   - Result: 120 patients assigned to 3 arms (~40 per arm)

4. **Envelope Generator:**
   - Number of Envelopes: 120
   - ✅ Include Blinding
   - Site Code: SITE001
   - Click "Generate Envelopes"
   - Result: 120 sealed envelopes ready for printing

5. **Simulation:**
   - Scheme: 3+3 Design
   - Cohorts: 10
   - Runs: 100
   - Endpoint: ORR
   - Click "Run Simulation"
   - Result: Dose escalation pathway with MTD identification

6. **Export:**
   - Select all items
   - Format: Excel
   - Click "Download Export"
   - Result: Complete trial documentation package

---

## 📊 Key Features Demonstration

### Stratified Randomization
- Ensures balance across important prognostic factors
- Each stratum gets balanced arm assignment
- Prevents chance imbalance in small trials

### Block Randomization
- Maintains balance throughout enrollment
- Block size determines allocation pattern
- Prevents selection bias

### Dose Escalation (Phase 1)
- **3+3 Design:** Standard approach with cohort expansion
- **CRM:** Model-based with target toxicity rate
- **Accelerated:** Rapid escalation with single patients

### Envelope System
- Sealed envelopes for site randomization
- Maintains allocation concealment
- Supports blinded trials

---

##  Output Files

After exporting, you'll receive:

1. **trial_export_randomization_YYYY-MM-DD.csv**
   - Patient IDs, arm assignments, stratification factors

2. **trial_export_envelopes_YYYY-MM-DD.csv**
   - Envelope numbers, arm assignments, blinding info

3. **trial_export_simulation_YYYY-MM-DD.csv**
   - Simulated outcomes, response rates, survival data

---

## 💡 Tips & Best Practices

### Randomization
- Use block sizes that are multiples of your randomization ratio
- For 1:1:1 ratio, use block sizes 6 or 12
- For 1:1 ratio, use block sizes 4 or 8

### Stratification
- Limit to 2-3 factors to avoid too many strata
- Each factor should be clinically important
- Too many strata = few patients per stratum = imbalance

### Simulation
- Run at least 100 simulations for stable estimates
- Use 3+3 design for standard dose finding
- CRM requires more statistical expertise

### Envelopes
- Print and seal envelopes before trial starts
- Store securely at each site
- Track envelope usage in trial log

---

## ❓ Troubleshooting

### Application Won't Start
```bash
# Check if R is installed
R --version

# Reinstall dependencies
Rscript install_dependencies.R
```

### Randomization Not Generating
- Ensure you've generated strata combinations first (if using stratified randomization)
- Check that total patients > 0
- Verify randomization ratio format (e.g., "1:1:1")

### Simulation Not Running
- For Phase 1, select a dose escalation scheme
- Ensure number of cohorts ≥ 3
- Check that simulation runs ≥ 10

### Export Not Working
- Ensure you've generated data in previous steps
- Check export format compatibility
- For Excel export, verify 'writexl' package is installed

---

## 📞 Need Help?

- **Documentation:** See README.md for complete documentation
- **References:** NCI Randomization System documentation
- **Support:** Review the examples in the application

---

## 🎓 Learning Resources

### Clinical Trial Randomization
- NCI Cancer Trials: https://prevention.cancer.gov/ctrandomization/
- Randomization Methods: https://prevention.cancer.gov/ctrandomization/instructions/

### Oncology Trials
- GDC Data Portal: https://portal.gdc.cancer.gov/
- HemOnc.org Drug Database: https://hemonc.org/wiki/Tutorial

---

**Happy Clinical Trial Design! 🧪📊**
