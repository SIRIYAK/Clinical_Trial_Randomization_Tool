# Clinical Trial Randomization Builder

<div align="center">

![Open Source](https://img.shields.io/badge/Open%20Source-Yes-brightgreen)
![License](https://img.shields.io/badge/License-MIT-blue)
![R](https://img.shields.io/badge/R-%3E%3D4.0-blue)
![Shiny](https://img.shields.io/badge/Shiny-Yes-red)

**A Free, Open-Source Platform for Designing Clinical Trials**

*Based on FDA & ICH Guidelines | Built for Researchers Worldwide*

</div>

---

## 🎯 What is This?

A comprehensive **R Shiny application** for designing, simulating, and managing clinical trial randomization across all phases (Phase I/II/III). This is a **100% free, open-source tool** built for:

- 🏥 **Academic Researchers** - Design trials without expensive software
- 📊 **Biostatisticians** - Prototype randomization schemes
- 🧪 **Clinical Trial Coordinators** - Generate envelopes and randomization lists
- 📚 **Students & Educators** - Learn clinical trial design principles
- 🌍 **Global Health Initiatives** - Access professional tools without cost

---

## ✨ Key Features

### 🎮 **Randomization Playground**
- **12+ Cancer Types** - NSCLC, Breast, CRC, Melanoma, RCC, Prostate, Bladder, Gastric, Ovarian, HNSCC, Lymphoma, AML
- **Custom Trial Builder** - Define any trial from scratch
- **Unlimited Treatment Arms** - Add as many arms as needed
- **Quick Templates** - One-click control, experimental, or combination arms
- **Disease-Specific Regimens** - Pre-loaded standard treatments for each cancer type

### 📋 **Complete Trial Lifecycle**
- **Phase 1:** Dose Optimization (3+3, CRM, BOIN, Accelerated)
- **Phase 2:** Dose Expansion (2-arm randomized)
- **Phase 3:** Confirmatory Testing (large-scale RCT)
- **Basket Trials:** Multi-cancer, single biomarker
- **Umbrella Trials:** Single cancer, multiple biomarkers
- **Platform Trials:** Adaptive multi-arm designs

### 🎲 **Advanced Randomization**
- **12 Stratification Factors** - PDL1, histology, region, ECOG, age, gender, BMI, renal/hepatic function, prior therapy, disease stage, biomarker status
- **Block Randomization** - Configurable block sizes (4, 6, 8, 12, 16)
- **Stratified Randomization** - Balanced allocation across all strata
- **Custom Ratios** - Any ratio (1:1, 1:1:1, 2:1, 3:2:1, etc.)
- **Unlimited Patients** - Support for 20 to 2,000 patients

### 💊 **Treatment Regimen Library**
- **NSCLC Regimens:** Carboplatin/Pembrolizumab, Cisplatin/Pemetrexed, etc.
- **Colorectal:** FOLFOX, FOLFIRI, CAPOX
- **Lymphoma:** R-CHOP, Bendamustine+Rituximab
- **Breast:** AC→T, Trastuzumab+Pertuzumab
- **Custom Regimens:** Define your own treatment combinations

### 📧 **Envelope Generation**
- **Sealed Envelopes** - Printable randomization envelopes
- **Blinding Support** - Maintain allocation concealment
- **Multi-Site** - Site codes for multi-center trials
- **Audit Trail** - Generation dates, operator logs

### 📈 **Simulation & Analytics**
- **Dose Escalation:** 3+3, CRM, BOIN, Accelerated Titration
- **Outcome Prediction:** ORR, PFS, OS, DCR by arm
- **Toxicity Modeling:** Grade 3/4 AE, serious AE rates
- **MTD Identification:** Automatic maximum tolerated dose detection
- **Visual Reports:** Dose pathways, response plots, survival curves

### 📖 **FDA Guidelines Integration**
- **30+ FDA/ICH Documents** - Direct links to official guidance
- **Organized by Topic:**
  - Randomization & Blinding (ICH E9, E10)
  - Dose-Finding Studies (ICH E4, E-R relationships)
  - Oncology-Specific (Endpoints, biomarkers, PRO)
  - Stratification & Subgroups (Demographics, enrichment)
  - Safety Reporting (ICH E2A, E2F, CTCAE v6.0)
  - Statistical Guidance (Multiplicity, missing data)
- **Downloadable PDFs** - Direct access to regulatory documents

### 📤 **Export Capabilities**
- **Multiple Formats:** CSV, Excel, JSON
- **Comprehensive Reports:**
  - Randomization lists with patient IDs and arms
  - Envelope logs with blinding information
  - Patient stratification data
  - Simulation results with statistics
  - Trial summary reports
  - FDA compliance checklists

---

## 🚀 Quick Start

### Installation

```bash
# Install dependencies
Rscript install_dependencies.R

# Run the application
Rscript -e "shiny::runApp('app.R')"
```

Or from R/RStudio:

```R
library(shiny)
runApp("app.R")
```

The application opens at **http://127.0.0.1:3838**

### 3-Minute Tutorial

1. **Select Cancer Type** - Click NSCLC, Breast, or any cancer type
2. **Define Arms** - Use quick templates or define custom arms
3. **Configure Randomization** - Set patient count, ratio, block size
4. **Generate** - Click "Generate Randomization" for instant results
5. **Simulate** - Run trial simulation to predict outcomes
6. **Export** - Download complete trial documentation

---

## 📚 FDA Guidelines & Regulatory References

This tool includes direct links to **30+ official FDA and ICH guidance documents**:

### Randomization & Statistical Design
- [ICH E9: Statistical Principles for Clinical Trials](https://www.fda.gov/media/134433/download)
- [ICH E10: Choice of Control Group](https://www.fda.gov/media/134438/download)
- [FDA: Adaptive Designs for Clinical Trials](https://www.fda.gov/media/78495/download)
- [FDA: Master Protocols (Basket/Umbrella/Platform)](https://www.fda.gov/media/147710/download)

### Dose-Finding & Oncology
- [ICH E4: Dose-Response Information](https://www.fda.gov/media/134445/download)
- [FDA: Exposure-Response Relationships](https://www.fda.gov/media/71494/download)
- [FDA: Oncology Clinical Trial Endpoints](https://www.fda.gov/media/71193/download)
- [FDA: Biomarker Development in Oncology](https://www.fda.gov/media/133395/download)

### Safety & Regulatory
- [ICH E2A: Safety Assessment](https://www.fda.gov/media/134443/download)
- [ICH E2F: DSUR](https://www.fda.gov/media/134444/download)
- [NCI CTCAE v6.0](https://ctep.cancer.gov/protocolDevelopment/electronic_applications/ctc.htm)

**All links go directly to official FDA.gov or ICH.org PDFs.**

---

## 🎮 Playground Examples

### Example 1: NSCLC Phase III Trial

```
Cancer Type: Non-Small Cell Lung Cancer (NSCLC)
Phase: Phase 3 Confirmatory
Patients: 440
Arms:
  - Control: Carboplatin + Pembrolizumab (Ratio: 1)
  - Experimental: EIK1001 + Carboplatin + Pembrolizumab (Ratio: 1)
Stratification: PDL1, Histology, Region
Randomization: 1:1, Block Size 6, Stratified
```

### Example 2: Basket Trial (HER2+)

```
Cancer Type: Custom (Multi-Cancer)
Phase: Phase 2 Expansion
Patients: 200
Arms:
  - Trastuzumab Emtansine (Ratio: 1)
Stratification: Cancer Type, Biomarker Status, Prior Therapy
Randomization: Single Arm, Block Size 4
Cancers: Breast, Gastric, NSCLC, Bladder (all HER2+)
```

### Example 3: Phase I Dose-Finding

```
Cancer Type: Acute Myeloid Leukemia (AML)
Phase: Phase 1 Dose Optimization
Patients: 48
Arms:
  - Control: 7+3 Induction (Ratio: 1)
  - Low Dose: Drug 30 mg + 7+3 (Ratio: 1)
  - Mid Dose: Drug 45 mg + 7+3 (Ratio: 1)
  - High Dose: Drug 60 mg + 7+3 (Ratio: 1)
Dose Escalation: 3+3 Design
Stratification: FLT3 Status, Age Group, Disease Stage
```

---

## 📊 Cancer Types Supported

| Cancer Type | Abbreviation | Biomarkers | Standard Regimens |
|------------|--------------|------------|-------------------|
| Non-Small Cell Lung Cancer | NSCLC | PDL1, EGFR, ALK, ROS1, KRAS | 3 regimens |
| Breast Cancer | BC | ER, PR, HER2, BRCA | 3 regimens |
| Colorectal Cancer | CRC | MSI, RAS, BRAF, HER2 | 3 regimens |
| Melanoma | MEL | BRAF, NRAS, KIT | 3 regimens |
| Renal Cell Carcinoma | RCC | PDL1, VHL | 3 regimens |
| Prostate Cancer | PC | AR, BRCA, ATM, MSI | 3 regimens |
| Bladder/Urothelial | UC | PDL1, FGFR, ERBB2 | 3 regimens |
| Gastric/GEJ | GC | HER2, PDL1, MSI, CLDN18.2 | 3 regimens |
| Ovarian Cancer | OC | BRCA, HRD, PDL1 | 3 regimens |
| Head & Neck SCC | HNSCC | PDL1, HPV, EGFR | 3 regimens |
| Non-Hodgkin Lymphoma | NHL | CD20, BCL2, MYC | 3 regimens |
| Acute Myeloid Leukemia | AML | FLT3, NPM1, IDH1/2 | 3 regimens |

---

## 🧪 Simulation Features

### Dose Escalation Schemes

1. **3+3 Design** (Standard)
   - 3 patients per cohort
   - Escalate if 0/3 DLTs
   - Expand to 6 if 1 DLT
   - De-escalate if ≥2 DLTs

2. **Continual Reassessment Method (CRM)**
   - Model-based approach
   - Target toxicity rate: 25%
   - Logistic dose-toxicity model

3. **Bayesian Optimal Interval (BOIN)**
   - Interval-finding design
   - Target toxicity rate: 25%
   - λ1=0.20, λ2=0.30

4. **Accelerated Titration**
   - Single patient cohorts
   - Rapid escalation
   - Switch to 3+3 at dose level 2

### Outcome Simulation

- **Response Rates:** CR, PR, SD, PD by arm
- **Survival Analysis:** PFS and OS (exponential distribution)
- **Toxicity:** Grade 3/4 AE, serious AE rates
- **Phase-Specific:** Different response rates for Phase 1/2/3

---

## 📁 File Structure

```
Clinical_Trial_Randomization_Tool/
├── app.R                        # Main application (1,500+ lines)
├── install_dependencies.R       # Package installer
├── README.md                    # This file
├── QUICK_START.md              # Step-by-step guide
├── FEATURES.md                 # Technical specifications
├── CONTRIBUTING.md             # How to contribute (open source)
├── LICENSE                     # MIT License
└── .gitattributes              # Git configuration
```

---

## 🌟 Why Open Source?

### For the Community
- **Free Access** - No licensing fees, no restrictions
- **Transparency** - See exactly how randomization works
- **Customization** - Modify for your specific needs
- **Education** - Learn from real clinical trial design

### For Global Health
- **Equity** - Researchers in low-income countries can access professional tools
- **Capacity Building** - Train the next generation of clinical trialists
- **Innovation** - Community-driven improvements and features

---

## 🤝 Contributing

This is an **open-source project** and we welcome contributions!

### Ways to Contribute
- 🐛 **Report Bugs** - Open an issue on GitHub
- 💡 **Suggest Features** - Request new cancer types, regimens, or features
- 📝 **Improve Documentation** - Help make guides clearer
- 🔧 **Submit Code** - Pull requests welcome
- 🌍 **Translate** - Help make this accessible in multiple languages

### How to Contribute
1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

---

## 📖 Documentation

- **[QUICK_START.md](QUICK_START.md)** - Step-by-step user guide
- **[FEATURES.md](FEATURES.md)** - Technical feature specifications
- **[CONTRIBUTING.md](CONTRIBUTING.md)** - Contribution guidelines

---

## 🔗 References & Resources

### Official Guidelines
- [FDA Clinical Trial Guidance Documents](https://www.fda.gov/regulatory-information/search-fda-guidance-documents/drugs)
- [ICH Guidelines](https://www.ich.org/page/ich-guidelines)
- [NCI Cancer Trials Randomization](https://prevention.cancer.gov/ctrandomization/)
- [ClinicalTrials.gov](https://clinicaltrials.gov/)

### Educational Resources
- [FDA Drug Development Process](https://www.fda.gov/patients/drug-development-process)
- [NCI Clinical Trials Information](https://www.cancer.gov/about-cancer/treatment/clinical-trials)
- [GDC Data Portal](https://portal.gdc.cancer.gov/)
- [HemOnc.org Drug Database](https://hemonc.org/wiki/Tutorial)

---

## 📜 License

This project is licensed under the **MIT License** - see the [LICENSE](LICENSE) file for details.

**You are free to:**
- ✅ Use for academic research
- ✅ Use for commercial purposes
- ✅ Modify and distribute
- ✅ Use in teaching and education

**With no restrictions beyond attribution.**

---

## ⚠️ Disclaimer

This tool is for **clinical trial planning, simulation, and educational purposes only**. 

- **Not for Direct Patient Care** - This tool does not manage real patient data
- **Consult Experts** - Always work with biostatisticians and regulatory experts
- **Verify Designs** - Randomization schemes should be reviewed by qualified professionals
- **Regulatory Compliance** - Ensure your trial design meets local regulatory requirements

**The developers assume no liability for the use of this software in actual clinical trials.**

---

## 🙏 Acknowledgments

Built with inspiration from:
- **NCI Cancer Trials Randomization System** - https://prevention.cancer.gov/ctrandomization/
- **FDA Guidance Documents** - https://www.fda.gov/regulatory-information/search-fda-guidance-documents
- **ICH Harmonised Guidelines** - https://www.ich.org/page/ich-guidelines

Made with ❤️ for the global clinical research community

---

## 📧 Contact & Support

- **Issues:** Open an issue on GitHub
- **Discussions:** Use GitHub Discussions for questions
- **Email:** [Your contact information]

---

<div align="center">

** Making Clinical Trial Design Accessible to Everyone 🌍**

*Built with R, Shiny, and Open-Source Values*

</div>
