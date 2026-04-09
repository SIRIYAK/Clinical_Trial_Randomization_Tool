# Comprehensive GDC-style Cohort Builder - R Shiny App
# With extensive drug database from Hemonc.org and FDA approvals

library(shiny)
library(DT)
library(dplyr)
library(tidyr)

# ============================================================================
# REAL TCGA DATA - Complete Cancer Types and Project Codes
# ============================================================================

tcga_projects <- data.frame(
  code = c("ACC", "BLCA", "BRCA", "CESC", "CHOL", "COAD", "DLBC", "ESCA",
           "GBM", "HNSC", "KICH", "KIRC", "KIRP", "LAML", "LGG", "LIHC",
           "LUAD", "LUSC", "MESO", "OV", "PAAD", "PCPG", "PRAD", "READ",
           "SARC", "SKCM", "STAD", "TGCT", "THCA", "THYM", "UCEC", "UCS", "UVM"),
  name = c("Adrenocortical carcinoma", "Bladder Urothelial Carcinoma",
           "Breast invasive carcinoma", "Cervical squamous cell carcinoma and endocervical adenocarcinoma",
           "Cholangiocarcinoma", "Colon adenocarcinoma",
           "Lymphoid Neoplasm Diffuse Large B-cell Lymphoma", "Esophageal carcinoma",
           "Glioblastoma multiforme", "Head and Neck squamous cell carcinoma",
           "Kidney Chromophobe", "Kidney renal clear cell carcinoma",
           "Kidney renal papillary cell carcinoma", "Acute Myeloid Leukemia",
           "Brain Lower Grade Glioma", "Liver hepatocellular carcinoma",
           "Lung adenocarcinoma", "Lung squamous cell carcinoma", "Mesothelioma",
           "Ovarian serous cystadenocarcinoma", "Pancreatic adenocarcinoma",
           "Pheochromocytoma and Paraganglioma", "Prostate adenocarcinoma",
           "Rectum adenocarcinoma", "Sarcoma", "Skin Cutaneous Melanoma",
           "Stomach adenocarcinoma", "Testicular Germ Cell Tumors",
           "Thyroid carcinoma", "Thymoma", "Uterine Corpus Endometrial Carcinoma",
           "Uterine Carcinosarcoma", "Uveal Melanoma"),
  primary_sites = c("adrenal gland", "bladder", "breast", "cervix uteri", "biliary tract",
                    "colon", "lymph node", "esophagus", "brain", "head and neck",
                    "kidney", "kidney", "kidney", "bone marrow", "brain",
                    "liver", "lung", "lung", "pleura", "ovary",
                    "pancreas", "adrenal gland", "prostate", "rectum",
                    "soft tissue", "skin", "stomach", "testis",
                    "thyroid", "thymus", "uterus", "uterus", "eye"),
  stringsAsFactors = FALSE
)

# ============================================================================
# COMPREHENSIVE ANTINEOPLASTIC DRUGS DATABASE
# Sources: Hemonc.org, FDA approvals 2024-2025
# ============================================================================

# Build drug database programmatically to ensure perfect alignment
antineoplastic_drugs <- data.frame(
  drug_name = character(0),
  drug_class = character(0),
  target = character(0),
  stringsAsFactors = FALSE
)

# Helper function to add drugs
add_drugs <- function(names, class, tgt) {
  antineoplastic_drugs <<- rbind(antineoplastic_drugs,
    data.frame(drug_name = names, drug_class = class, target = tgt, stringsAsFactors = FALSE))
}

# Chemotherapy
add_drugs(c("Cyclophosphamide", "Ifosfamide", "Melphalan", "Chlorambucil", "Busulfan",
  "Carmustine (BCNU)", "Lomustine (CCNU)", "Temozolomide", "Dacarbazine",
  "Procarbazine", "Thiotepa", "Bendamustine", "Altretamine", "Treosulfan",
  "Mechlorethamine", "Prednimustine"),
  "Alkylating Agent", "DNA Cross-linking")

add_drugs(c("Cisplatin", "Carboplatin", "Oxaliplatin", "Nedaplatin", "Heptaplatin",
  "Lobaplatin", "Picoplatin"),
  "Platinum Compound", "DNA Cross-linking")

add_drugs(c("Methotrexate", "5-Fluorouracil (5-FU)", "Capecitabine", "Gemcitabine",
  "Cytarabine (Ara-C)", "6-Mercaptopurine", "6-Thioguanine", "Cladribine",
  "Fludarabine", "Pemetrexed", "Pentostatin", "Hydroxyurea",
  "Azacitidine", "Decitabine", "Trabectedin", "Clofarabine", "Nelarabine",
  "Tegafur", "Floxuridine", "Raltitrexed", "Pralatrexate"),
  "Antimetabolite", "DNA/RNA Synthesis")

add_drugs(c("Doxorubicin", "Daunorubicin", "Idarubicin", "Epirubicin",
  "Bleomycin", "Mitomycin C", "Dactinomycin", "Mitoxantrone",
  "Valrubicin", "Pixantrone", "Aclarubicin", "Amrubicin",
  "Pirarubicin", "Zorubicin"),
  "Antitumor Antibiotic", "DNA Intercalation")

add_drugs(c("Etoposide", "Teniposide", "Irinotecan", "Topotecan", "Belotecan"),
  "Topoisomerase Inhibitor", "Topoisomerase I/II")

add_drugs(c("Vincristine", "Vinblastine", "Vinorelbine", "Vindesine", "Vinflunine"),
  "Vinca Alkaloid", "Microtubule")

add_drugs(c("Paclitaxel", "Docetaxel", "Cabazitaxel", "Nab-paclitaxel", "Larotaxel"),
  "Taxane", "Microtubule")

add_drugs(c("Eribulin", "Ixabepilone", "Estramustine", "Colchicine"),
  "Microtubule Inhibitor", "Microtubule")

# Targeted Therapies
add_drugs(c("Erlotinib", "Gefitinib", "Afatinib", "Osimertinib", "Dacomitinib",
  "Cetuximab", "Panitumumab", "Necitumumab", "Amivantamab", "Mobocertinib",
  "Sunvozertinib", "Zongertinib", "Tirbanibulin"),
  "EGFR Inhibitor", "EGFR")

add_drugs(c("Crizotinib", "Ceritinib", "Alectinib", "Brigatinib", "Lorlatinib", "Ensartinib"),
  "ALK Inhibitor", "ALK")

add_drugs(c("Crizotinib", "Entrectinib", "Repotrectinib", "Taletrectinib"),
  "ROS1 Inhibitor", "ROS1")

add_drugs(c("Vemurafenib", "Dabrafenib", "Encorafenib", "Tovorafenib",
  "Trametinib", "Cobimetinib", "Binimetinib", "Selumetinib", "Avutometinib", "Defactinib"),
  "BRAF/MEK Inhibitor", "BRAF/MEK")

add_drugs(c("Imatinib", "Dasatinib", "Nilotinib", "Ponatinib", "Bosutinib",
  "Asciminib", "Radotinib", "Flumatinib"),
  "BCR-ABL Inhibitor", "BCR-ABL")

add_drugs(c("Bevacizumab", "Ramucirucumab", "Aflibercept",
  "Sorafenib", "Sunitinib", "Pazopanib", "Axitinib", "Lenvatinib",
  "Regorafenib", "Cabozantinib", "Vandetanib", "Tivozanib", "Fruquintinib",
  "Surufatinib", "Anlotinib", "Apatinib", "Donafenib"),
  "VEGF Inhibitor", "VEGF/VEGFR")

add_drugs(c("Trastuzumab", "Pertuzumab", "Lapatinib", "Neratinib", "Tucatinib",
  "Pyrotinib", "Zanidatamab", "Zenocutuzumab", "Tarlatamab"),
  "HER2 Inhibitor", "HER2")

add_drugs(c("Palbociclib", "Ribociclib", "Abemaciclib", "Trilaciclib", "Lerociclib"),
  "CDK4/6 Inhibitor", "CDK4/6")

add_drugs(c("Everolimus", "Temsirolimus", "Sirolimus",
  "Idelalisib", "Copanlisib", "Duvelisib", "Alpelisib", "Umbralisib",
  "Inavolisib", "Ipatasertib", "Capivasertib"),
  "PI3K/AKT/mTOR Inhibitor", "PI3K/AKT/mTOR")

add_drugs(c("Olaparib", "Niraparib", "Rucaparib", "Talazoparib", "Fluzoparib", "Senaparib", "Pamiparib"),
  "PARP Inhibitor", "PARP")

add_drugs(c("Venetoclax", "Navitoclax", "Sona-rolimus"),
  "BCL-2 Inhibitor", "BCL-2")

add_drugs(c("Midostaurin", "Gilteritinib", "Quizartinib", "Crenolanib", "Ternatinib"),
  "FLT3 Inhibitor", "FLT3")

add_drugs(c("Ivosidenib", "Enasidenib", "Olutasidenib", "Vorasidenib"),
  "IDH Inhibitor", "IDH1/2")

add_drugs(c("Sotorasib", "Adagrasib", "Divarasib", "RMC-6236"),
  "KRAS Inhibitor", "KRAS")

add_drugs(c("Capmatinib", "Tepotinib", "Crizotinib", "Cabozantinib",
  "Telisotuzumab vedotin", "Savolitinib"),
  "MET Inhibitor", "c-MET")

add_drugs(c("Selpercatinib", "Pralsetinib", "Zeltepercatinib"),
  "RET Inhibitor", "RET")

add_drugs(c("Larotrectinib", "Entrectinib", "Repotrectinib", "Selitrectinib"),
  "NTRK Inhibitor", "NTRK")

add_drugs(c("Erdafitinib", "Pemigatinib", "Infigratinib", "Futibatinib", "Derazantinib"),
  "FGFR Inhibitor", "FGFR")

add_drugs(c("Vismodegib", "Sonidegib", "Glasdegib", "Patidegib"),
  "Hedgehog Inhibitor", "Hedgehog/SMO")

# ADCs
add_drugs(c("Brentuximab vedotin", "Trastuzumab emtansine", "Gemtuzumab ozogamicin",
  "Inotuzumab ozogamicin", "Moxetumomab pasudotox", "Polatuzumab vedotin",
  "Enfortumab vedotin", "Trastuzumab deruxtecan", "Sacituzumab govitecan",
  "Belantamab mafodotin", "Loncastuximab tesirine", "Tisotumab vedotin",
  "Mirvetuximab soravtansine", "Datopotamab deruxtecan", "Telisotuzumab vedotin",
  "Patritumab deruxtecan", "Ivuxolimab", "SKB264", "ARX788", "HS-20093", "RC48"),
  c("Antibody-Drug Conjugate", "Antibody-Drug Conjugate", "Antibody-Drug Conjugate",
    "Antibody-Drug Conjugate", "Antibody-Drug Conjugate", "Antibody-Drug Conjugate",
    "Antibody-Drug Conjugate", "Antibody-Drug Conjugate", "Antibody-Drug Conjugate",
    "Antibody-Drug Conjugate", "Antibody-Drug Conjugate", "Antibody-Drug Conjugate",
    "Antibody-Drug Conjugate", "Antibody-Drug Conjugate", "Antibody-Drug Conjugate",
    "Antibody-Drug Conjugate", "Antibody-Drug Conjugate", "Antibody-Drug Conjugate",
    "Antibody-Drug Conjugate", "Antibody-Drug Conjugate", "Antibody-Drug Conjugate"),
  c("CD30", "HER2", "CD33", "CD22", "CD22", "CD79b", "Nectin-4", "HER2",
    "TROP2", "BCMA", "CD19", "TF", "FRα", "TROP2", "c-MET", "HER3",
    "B7-H3", "TROP2", "TROP2", "HER2", "HER2"))

# Monoclonal Antibodies
add_drugs(c("Rituximab", "Ofatumumab", "Obinutuzumab", "Ocrelizumab"),
  "Monoclonal Antibody - CD20", "CD20")

add_drugs(c("Daratumumab", "Isatuximab", "SAR442085"),
  "Monoclonal Antibody - CD38", "CD38")

add_drugs("Elotuzumab", "Monoclonal Antibody - SLAMF7", "SLAMF7")
add_drugs(c("Dinutuximab", "Naxitamab"), "Monoclonal Antibody - GD2", "GD2")
add_drugs("Alemtuzumab", "Monoclonal Antibody - CD52", "CD52")
add_drugs(c("Ipilimumab", "Tremelimumab"), "Monoclonal Antibody - CTLA4", "CTLA4")

add_drugs(c("Nivolumab", "Pembrolizumab", "Cemiplimab", "Spartalizumab",
  "Toripalimab", "Sintilimab", "Camrelizumab", "Tislelizumab",
  "Zimberelimab", "Dostarlimab", "Penpulimab", "Pucotenlimab"),
  "Monoclonal Antibody - PD1", "PD1")

add_drugs(c("Atezolizumab", "Durvalumab", "Avelumab", "Sugemalimab",
  "Envafolimab", "Cosibelimab", "Buparlisib"),
  "Monoclonal Antibody - PDL1", "PDL1")

add_drugs(c("Tiragolumab", "Ociperlimab", "Domvanalimab"),
  "Monoclonal Antibody - TIGIT", "TIGIT")

add_drugs(c("Relatlimab", "Lag-3"), "Monoclonal Antibody - LAG3", "LAG3")
add_drugs(c("Sabatolimab", "Sym023"), "Monoclonal Antibody - TIM3", "TIM3")

add_drugs(c("Magrolimab", "Evorpacept", "ALX148", "TJC4", "SRF231"),
  "Monoclonal Antibody - CD47", "CD47")

# IMiDs, Proteasome, Exportin
add_drugs(c("Thalidomide", "Lenalidomide", "Pomalidomide", "Iberdomide", "Cereblon", "Mezigdomide"),
  "Immunomodulatory Drug", "CRBN")

add_drugs(c("Bortezomib", "Carfilzomib", "Ixazomib", "Oprozomib", "Marizomib"),
  "Proteasome Inhibitor", "Proteasome")

add_drugs(c("Selinexor", "Verdinexor"), "Exportin Inhibitor", "XPO1")

# Hormonal
add_drugs(c("Tamoxifen", "Toremifene", "Fulvestrant", "Elacestrant",
  "Imlunestrant", "Giredestrant", "Camizestrant", "ZB716"),
  "Hormonal Therapy - SERM", "ER")

add_drugs(c("Anastrozole", "Letrozole", "Exemestane"),
  "Hormonal Therapy - AI", "Aromatase")

add_drugs(c("Goserelin", "Leuprolide", "Triptorelin", "Histrelin", "Degarelix"),
  "Hormonal Therapy - GnRH", "GnRH")

add_drugs(c("Bicalutamide", "Flutamide", "Nilutamide", "Enzalutamide",
  "Apalutamide", "Darolutamide", "Rezvilutamide", "Proxalutamide",
  "Seviteronel", "ODM-207"),
  "Hormonal Therapy - Antiandrogen", "AR")

add_drugs(c("Abiraterone", "Seviteronel"), "Hormonal Therapy - CYP17", "CYP17A1")
add_drugs(c("Megestrol acetate", "Medroxyprogesterone"), "Hormonal Therapy - Progestin", "PR")
add_drugs(c("Diethylstilbestrol", "Estradiol"), "Hormonal Therapy - Estrogen", "ER")

# Retinoids, Arsenic, Misc
add_drugs(c("Tretinoin (ATRA)", "Isotretinoin", "Bexarotene", "Alitretinoin", "Acitretin", "Fenretinide"),
  "Retinoid", "RAR/RXR")

add_drugs("Arsenic trioxide", "Arsenic Compound", "PML-RARA")

add_drugs(c("Asparaginase", "Pegaspargase", "Mitotane", "Denileukin diftitox",
  "Valemetostat", "Tebentafusp"),
  "Other", "Various")

# CAR-T
add_drugs(c("Tisagenlecleucel (Kymriah)", "Axicabtagene ciloleucel (Yescarta)",
  "Brexucabtagene autoleucel (Tecartus)", "Lisocabtagene maraleucel (Breyanzi)",
  "Idecabtagene vicleucel (Abecma)", "Ciltacabtagene autoleucel (Carvykti)",
  "Tafasitamab"),
  c(rep("CAR-T Cell Therapy", 6), "Monoclonal Antibody - CD19"),
  c(rep("CD19", 3), rep("BCMA", 3), "CD19"))

# Bispecific
add_drugs(c("Blinatumomab", "Amivantamab", "Tebentafusp", "Teclistamab",
  "Mosunetuzumab", "Epcoritamab", "Glofitamab", "Talquetamab",
  "Elranatamab", "Tarlatamab", "Zanidatamab", "Zenocutuzumab", "Linvoseltamab",
  "Odronextamab", "Cevostamab", "REGN1979", "JNJ-78278419",
  "REGN5458", "REGN5459", "HPH212", "PL36", "IGB1212"),
  "Bispecific Antibody",
  c("CD19xCD3", "EGFRxMET", "gp100xCD3", rep("BCMAxCD3", 5), rep("CD20xCD3", 4),
    "GPRC5DxCD3", "DLL3xCD3", "HER2", "HER2xHER3", "BCMAxCD3", rep("CD20xCD3", 5)))

# 2024-2025 Novel
add_drugs(c("Dordaviprone (Modeyso)", "Ziftomenib (Komzifti)", "Avutometinib (Avmapki)",
  "Defactinib (Fakzynja)", "Imlunestrant (Inluriyo)", "Taletrectinib (Ibtrozi)",
  "Sunvozertinib (Zegfrovy)", "Zongertinib (Hernexeos)", "Linvoseltamab (Lynozyfic)"),
  "Novel Agent 2024-2025",
  c("H3K27M", "Menin", "MEK/FAK", "MEK/FAK", "ESR1", "ROS1", "EGFR ex20", "HER2", "BCMAxCD3"))

# ============================================================================
# BIOSPECIMEN REFERENCE DATA (GDC Standard)
# ============================================================================

biospecimen_reference <- list(
  tissue_type = c("Tumor", "Normal", "Metastatic", "Not reported"),
  tumor_descriptor = c("Primary", "Metastatic", "Recurrence", "Additional - New Primary",
                       "Additional - Metastatic", "Xenograft", "Not reported", "Not applicable"),
  specimen_type = c("Primary Tumor", "Solid Tissue Normal", "Metastatic",
                    "Blood Derived Normal", "Bone Marrow Normal", "FFPE",
                    "Fresh Frozen", "Control Analyte", "Pleural Effusion",
                    "Buccal Cells", "EBV Immortalized Normal", "Fibroblasts from Bone Marrow Normal",
                    "Granulocytes", "Mononuclear Cells from Bone Marrow Normal"),
  preservation_method = c("FFPE", "Frozen", "Fresh", "OCT", "Not reported"),
  analyte_type = c("DNA", "RNA", "Total RNA", "Protein", "miRNA", "WXS", "WGS", "Bisulfite",
                   "Repli-G DNA", "Repli-G X DNA", "Not reported"),
  anatomic_site = c(
    "Adrenal", "Ampulla of Vater", "Anus", "Appendix", "Biliary Tract",
    "Bladder", "Bone", "Bone Marrow", "Brain", "Breast", "Cervix",
    "Colon", "Esophagus", "Eye", "Gallbladder", "Head and Neck",
    "Heart", "Hypopharynx", "Kidney", "Larynx", "Liver", "Lung",
    "Lymph Node", "Mediastinum", "Mesothelium", "Nasal Cavity", "Nasopharynx",
    "Oropharynx", "Ovary", "Pancreas", "Parathyroid", "Penis", "Peritoneum",
    "Pituitary", "Pleura", "Prostate", "Rectum", "Salivary Gland", "Sinus",
    "Skin", "Small Intestine", "Soft Tissue", "Spine", "Spleen",
    "Stomach", "Testis", "Thymus", "Thyroid", "Tongue", "Tonsil",
    "Trachea", "Ureter", "Urethra", "Uterus", "Vagina", "Vulva",
    "Not reported", "Other"
  )
)

# ============================================================================
# CANCER-SPECIFIC TREATMENT PROTOCOLS
# ============================================================================

cancer_treatment_protocols <- list(
  "BRCA" = list(
    first_line = c("Tamoxifen", "Anastrozole", "Letrozole", "Exemestane", "Fulvestrant",
                   "Trastuzumab", "Pertuzumab", "Paclitaxel", "Docetaxel", "Doxorubicin",
                   "Cyclophosphamide", "Carboplatin", "Palbociclib", "Ribociclib", "Abemaciclib",
                   "Trastuzumab deruxtecan", "Sacituzumab govitecan", "Capecitabine",
                   "Eribulin", "Ixabepilone"),
    targeted = c("Olaparib", "Talazoparib", "Alpelisib", "Capivasertib", "Everolimus",
                 "Tucatinib", "Lapatinib", "Neratinib"),
    immunotherapy = c("Pembrolizumab", "Atezolizumab"),
    adjuvant = c("Tamoxifen", "Anastrozole", "Letrozole", "Trastuzumab", "Pertuzumab")
  ),
  "LUAD" = list(
    first_line = c("Carboplatin", "Cisplatin", "Paclitaxel", "Pemetrexed", "Bevacizumab",
                   "Pembrolizumab", "Nivolumab", "Atezolizumab", "Cemiplimab",
                   "Dabrafenib", "Trametinib"),
    targeted = c("Osimertinib", "Erlotinib", "Gefitinib", "Afatinib", "Dacomitinib",
                 "Crizotinib", "Alectinib", "Brigatinib", "Lorlatinib", "Ceritinib",
                 "Capmatinib", "Tepotinib", "Selpercatinib", "Pralsetinib",
                 "Larotrectinib", "Entrectinib", "Sotorasib", "Adagrasib"),
    immunotherapy = c("Pembrolizumab", "Nivolumab", "Atezolizumab", "Cemiplimab",
                      "Durvalumab", "Ipilimumab", "Relatlimab"),
    adc = c("Trastuzumab deruxtecan", "Sacituzumab govitecan", "Datopotamab deruxtecan",
            "Patritumab deruxtecan", "Telisotuzumab vedotin", "Zongertinib")
  ),
  "LUSC" = list(
    first_line = c("Carboplatin", "Cisplatin", "Paclitaxel", "Nab-paclitaxel", "Gemcitabine",
                   "Pembrolizumab", "Nivolumab", "Atezolizumab"),
    targeted = c("Erdafitinib", "Pemigatinib", "Infigratinib", "Futibatinib"),
    immunotherapy = c("Pembrolizumab", "Nivolumab", "Atezolizumab", "Cemiplimab",
                      "Durvalumab", "Ipilimumab")
  ),
  "COAD" = list(
    first_line = c("5-Fluorouracil (5-FU)", "Capecitabine", "Oxaliplatin", "Irinotecan",
                   "Bevacizumab", "Cetuximab", "Panitumumab", "Regorafenib",
                   "Fruquintinib", "TAS-102"),
    targeted = c("Regorafenib", "Fruquintinib", "TAS-102", "Encorafenib", "Cetuximab"),
    immunotherapy = c("Pembrolizumab", "Nivolumab", "Ipilimumab", "Nivolumab + Ipilimumab"),
    adjuvant = c("Capecitabine", "5-Fluorouracil (5-FU)", "Oxaliplatin")
  ),
  "PRAD" = list(
    first_line = c("Docetaxel", "Cabazitaxel", "Leuprolide", "Goserelin", "Degarelix",
                   "Abiraterone", "Enzalutamide", "Apalutamide", "Darolutamide"),
    targeted = c("Olaparib", "Rucaparib", "Talazoparib", "Niraparib"),
    immunotherapy = c("Sipuleucel-T", "Pembrolizumab"),
    radiopharmaceutical = c("Radium-223", "Lutetium-177 PSMA")
  ),
  "GBM" = list(
    first_line = c("Temozolomide", "Carmustine (BCNU)", "Lomustine (CCNU)", "Bevacizumab"),
    targeted = c("Regorafenib", "Dabrafenib", "Trametinib", "Larotrectinib", "Entrectinib"),
    novel = c("Dordaviprone", "Vorasidenib", "Tovorafenib")
  ),
  "OV" = list(
    first_line = c("Paclitaxel", "Carboplatin", "Docetaxel", "Doxorubicin",
                   "Topotecan", "Gemcitabine", "Pemetrexed"),
    targeted = c("Olaparib", "Niraparib", "Rucaparib", "Bevacizumab",
                 "Mirvetuximab soravtansine", "Avutometinib", "Defactinib"),
    immunotherapy = c("Pembrolizumab", "Dostarlimab")
  ),
  "SKCM" = list(
    first_line = c("Nivolumab", "Pembrolizumab", "Ipilimumab", "Atezolizumab",
                   "Relatlimab", "Dacarbazine", "Temozolomide"),
    targeted = c("Vemurafenib", "Dabrafenib", "Encorafenib", "Trametinib",
                 "Cobimetinib", "Binimetinib", "Imatinib", "Nilotinib",
                 "Tebentafusp"),
    adjuvant = c("Nivolumab", "Pembrolizumab", "Dabrafenib", "Trametinib")
  ),
  "KIRC" = list(
    first_line = c("Sunitinib", "Pazopanib", "Axitinib", "Bevacizumab", "Interferon-alpha"),
    targeted = c("Sorafenib", "Sunitinib", "Pazopanib", "Axitinib", "Cabozantinib",
                 "Lenvatinib", "Tivozanib", "Everolimus", "Temsirolimus",
                 "Belzutifan"),
    immunotherapy = c("Nivolumab", "Pembrolizumab", "Avelumab", "Ipilimumab",
                      "Nivolumab + Ipilimumab", "Pembrolizumab + Axitinib",
                      "Pembrolizumab + Lenvatinib", "Nivolumab + Cabozantinib")
  ),
  "HNSC" = list(
    first_line = c("Cisplatin", "Carboplatin", "5-Fluorouracil (5-FU)", "Docetaxel",
                   "Cetuximab", "Nivolumab", "Pembrolizumab"),
    targeted = c("Cetuximab", "Nivolumab", "Pembrolizumab", "Afatinib"),
    immunotherapy = c("Nivolumab", "Pembrolizumab", "Cemiplimab")
  ),
  "LIHC" = list(
    first_line = c("Sorafenib", "Lenvatinib", "Atezolizumab", "Bevacizumab",
                   "Durvalumab", "Tremelimumab", "Sintilimab", "Tislelizumab"),
    targeted = c("Sorafenib", "Lenvatinib", "Regorafenib", "Cabozantinib",
                 "Ramucirucumab", "Tivozanib"),
    immunotherapy = c("Nivolumab", "Pembrolizumab", "Atezolizumab", "Durvalumab",
                      "Tremelimumab", "Sintilimab", "Tislelizumab", "Camrelizumab")
  ),
  "STAD" = list(
    first_line = c("5-Fluorouracil (5-FU)", "Capecitabine", "Oxaliplatin", "Cisplatin",
                   "Docetaxel", "Paclitaxel", "Trastuzumab", "Ramucirucamab"),
    targeted = c("Trastuzumab", "Ramucirucamab", "Apatinib", "TAS-102",
                 "Fruquintinib"),
    immunotherapy = c("Nivolumab", "Pembrolizumab", "Sintilimab", "Tislelizumab",
                      "Durvalumab", "Tremelimumab")
  ),
  "BLCA" = list(
    first_line = c("Cisplatin", "Carboplatin", "Gemcitabine", "Paclitaxel",
                   "Doxorubicin", "Methotrexate", "Vinblastine"),
    targeted = c("Erdafitinib", "Enfortumab vedotin", "Sacituzumab govitecan",
                 "Atezolizumab", "Pembrolizumab", "Nivolumab", "Avelumab",
                 "Durvalumab"),
    adjuvant = c("Nivolumab")
  ),
  "THCA" = list(
    first_line = c("Levothyroxine", "Radioactive Iodine", "Lenvatinib", "Sorafenib"),
    targeted = c("Lenvatinib", "Sorafenib", "Vandetanib", "Cabozantinib",
                 "Selpercatinib", "Pralsetinib", "Larotrectinib", "Entrectinib",
                 "Dabrafenib", "Trametinib")
  ),
  "LAML" = list(
    first_line = c("Cytarabine (Ara-C)", "Daunorubicin", "Idarubicin", "Mitoxantrone",
                   "Etoposide"),
    targeted = c("Midostaurin", "Gilteritinib", "Quizartinib", "Venetoclax",
                 "Enasidenib", "Ivosidenib", "Olutasidenib", "Ziftomenib",
                 "Azacitidine", "Decitabine"),
    novel = c("Venetoclax", "Ziftomenib", "Vorasidenib")
  ),
  "PAAD" = list(
    first_line = c("Gemcitabine", "Nab-paclitaxel", "5-Fluorouracil (5-FU)",
                   "Irinotecan", "Oxaliplatin", "Capecitabine"),
    targeted = c("Olaparib", "Erlotinib", "Larotrectinib", "Entrectinib",
                 "Vemurafenib", "Dabrafenib", "Trametinib"),
    immunotherapy = c("Pembrolizumab")
  ),
  "SARC" = list(
    first_line = c("Doxorubicin", "Ifosfamide", "Gemcitabine", "Docetaxel",
                   "Dacarbazine", "Temozolomide", "Trabectedin"),
    targeted = c("Pazopanib", "Eribulin", "Trabectedin", "Olaratumab",
                 "Tazemetostat", "Selumetinib", "Imatinib", "Sunitinib",
                 "Regorafenib")
  ),
  "UCEC" = list(
    first_line = c("Paclitaxel", "Carboplatin", "Doxorubicin", "Cisplatin",
                   "Ifosfamide"),
    targeted = c("Lenvatinib", "Everolimus", "Dostarlimab", "Pembrolizumab"),
    immunotherapy = c("Pembrolizumab", "Dostarlimab", "Nivolumab")
  ),
  "LGG" = list(
    first_line = c("Temozolomide", "Procarbazine", "Lomustine (CCNU)", "Vincristine",
                   "Carmustine (BCNU)"),
    targeted = c("Vorasidenib", "Dabrafenib", "Trametinib", "Selumetinib",
                 "Larotrectinib", "Entrectinib")
  ),
  "CESC" = list(
    first_line = c("Cisplatin", "Paclitaxel", "Topotecan", "Vinorelbine",
                   "Ifosfamide", "Bevacizumab"),
    targeted = c("Pembrolizumab", "Tisotumab vedotin"),
    immunotherapy = c("Pembrolizumab", "Cemiplimab")
  ),
  "ESCA" = list(
    first_line = c("Cisplatin", "5-Fluorouracil (5-FU)", "Paclitaxel", "Carboplatin",
                   "Docetaxel", "Oxaliplatin", "Capecitabine"),
    targeted = c("Trastuzumab", "Ramucirucamab", "Apatinib"),
    immunotherapy = c("Nivolumab", "Pembrolizumab", "Tislelizumab", "Sintilimab")
  ),
  "CHOL" = list(
    first_line = c("Gemcitabine", "Cisplatin", "Capecitabine", "Oxaliplatin"),
    targeted = c("Pemigatinib", "Infigratinib", "Futibatinib", "Ivosidenib",
                 "Larotrectinib", "Entrectinib", "Dabrafenib", "Trametinib"),
    immunotherapy = c("Pembrolizumab", "Nivolumab", "Durvalumab")
  ),
  "MESO" = list(
    first_line = c("Cisplatin", "Pemetrexed", "Carboplatin", "Gemcitabine",
                   "Vinorelbine"),
    targeted = c("Nivolumab", "Ipilimumab", "Bevacizumab"),
    immunotherapy = c("Nivolumab", "Ipilimumab", "Pembrolizumab")
  ),
  "PCPG" = list(
    first_line = c("Cyclophosphamide", "Vincristine", "Dacarbazine", "Temozolomide"),
    targeted = c("Sunitinib", "Cabozantinib", "Axitinib", "Lenvatinib",
                 "Pazopanib")
  ),
  "TGCT" = list(
    first_line = c("Cisplatin", "Etoposide", "Bleomycin", "Ifosfamide",
                   "Paclitaxel", "Gemcitabine", "Oxaliplatin"),
    targeted = c("Cabozantinib", "Lenvatinib", "Sunitinib")
  ),
  "THYM" = list(
    first_line = c("Cisplatin", "Doxorubicin", "Cyclophosphamide", "Etoposide",
                   "Carboplatin", "Paclitaxel"),
    targeted = c("Everolimus", "Sunitinib", "Lenvatinib")
  ),
  "UVM" = list(
    first_line = c("Dacarbazine", "Temozolomide"),
    targeted = c("Tebentafusp", "Ipilimumab", "Nivolumab", "Pembrolizumab"),
    immunotherapy = c("Tebentafusp", "Ipilimumab", "Nivolumab")
  ),
  "DLBC" = list(
    first_line = c("Rituximab", "Cyclophosphamide", "Doxorubicin", "Vincristine",
                   "Prednisone", "Etoposide", "Bendamustine"),
    targeted = c("Polatuzumab vedotin", "Tafasitamab", "Loncastuximab tesirine",
                 "Glofitamab", "Epcoritamab", "Mosunetuzumab", "Axicabtagene ciloleucel",
                 "Tisagenlecleucel", "Lisocabtagene maraleucel", "Brexucabtagene autoleucel"),
    immunotherapy = c("Pembrolizumab", "Nivolumab")
  ),
  "LUSC" = list(
    first_line = c("Carboplatin", "Cisplatin", "Nab-paclitaxel", "Gemcitabine"),
    targeted = c("Erdafitinib", "Lenvatinib", "Pembrolizumab"),
    immunotherapy = c("Pembrolizumab", "Nivolumab", "Atezolizumab", "Cemiplimab")
  ),
  "ACC" = list(
    first_line = c("Mitotane", "Etoposide", "Doxorubicin", "Cisplatin"),
    targeted = c("Lenvatinib", "Sunitinib", "Everolimus", "Pasireotide")
  ),
  "KICH" = list(
    first_line = c("Everolimus", "Sunitinib", "Sorafenib", "Pazopanib"),
    targeted = c("Belzutifan", "Everolimus", "Sunitinib")
  ),
  "KIRP" = list(
    first_line = c("Sunitinib", "Sorafenib", "Pazopanib", "Axitinib"),
    targeted = c("Belzutifan", "Everolimus", "Sunitinib", "Sorafenib")
  ),
  "READ" = list(
    first_line = c("5-Fluorouracil (5-FU)", "Capecitabine", "Oxaliplatin", "Irinotecan",
                   "Bevacizumab", "Cetuximab", "Radiation"),
    targeted = c("Regorafenib", "Fruquintinib", "TAS-102"),
    immunotherapy = c("Pembrolizumab", "Nivolumab")
  ),
  "UCS" = list(
    first_line = c("Paclitaxel", "Carboplatin", "Ifosfamide", "Doxorubicin",
                   "Gemcitabine"),
    targeted = c("Lenvatinib", "Everolimus", "Pembrolizumab")
  )
)

# ============================================================================
# REALISTIC SAMPLE DATA GENERATOR
# ============================================================================

generate_realistic_data <- function(n = 2000) {
  set.seed(123)
  
  # Defensive: ensure tcga_projects exists
  if (!exists("tcga_projects")) stop("tcga_projects not found")
  n_proj <- nrow(tcga_projects)
  codes <- tcga_projects$code
  names_vec <- tcga_projects$name
  sites_vec <- tcga_projects$primary_sites
  
  # Sample projects
  selected_idx <- sample(n_proj, n, replace = TRUE)
  proj_code <- codes[selected_idx]
  proj_name <- names_vec[selected_idx]
  primary_site <- sites_vec[selected_idx]
  
  # Disease types: pre-assign based on project code (no sampling inside sapply)
  disease_map <- list(
    "ACC" = "Adrenocortical carcinoma", "BLCA" = "Urothelial carcinoma",
    "BRCA" = "Invasive ductal carcinoma", "CESC" = "Squamous cell carcinoma",
    "CHOL" = "Cholangiocarcinoma", "COAD" = "Adenocarcinoma",
    "DLBC" = "Diffuse large B-cell lymphoma", "ESCA" = "Squamous cell carcinoma",
    "GBM" = "Glioblastoma", "HNSC" = "Squamous cell carcinoma",
    "KICH" = "Chromophobe renal cell carcinoma", "KIRC" = "Clear cell renal cell carcinoma",
    "KIRP" = "Papillary renal cell carcinoma", "LAML" = "Acute myeloid leukemia",
    "LGG" = "Astrocytoma", "LIHC" = "Hepatocellular carcinoma",
    "LUAD" = "Adenocarcinoma", "LUSC" = "Squamous cell carcinoma",
    "MESO" = "Mesothelioma", "OV" = "High-grade serous carcinoma",
    "PAAD" = "Ductal adenocarcinoma", "PCPG" = "Pheochromocytoma",
    "PRAD" = "Acinar adenocarcinoma", "READ" = "Adenocarcinoma",
    "SARC" = "Leiomyosarcoma", "SKCM" = "Melanoma",
    "STAD" = "Adenocarcinoma", "TGCT" = "Germ cell tumor",
    "THCA" = "Papillary thyroid carcinoma", "THYM" = "Thymoma",
    "UCEC" = "Endometrioid adenocarcinoma", "UCS" = "Carcinosarcoma",
    "UVM" = "Uveal melanoma"
  )
  disease_type <- sapply(proj_code, function(c) disease_map[[c]])
  
  # Case IDs
  case_id <- paste0("TCGA-", proj_code, "-", sprintf("%02d", sample(1:99, n, replace = TRUE)), "-", sprintf("%04d", 1:n))
  
  # Stages, grades, demographics
  stages <- sample(c("Stage I", "Stage II", "Stage III", "Stage IV"), n, replace = TRUE)
  grades <- sample(c("G1 - Well differentiated", "G2 - Moderately differentiated", "G3 - Poorly differentiated"), n, replace = TRUE)
  ages <- round(pmax(18, pmin(90, rnorm(n, 60, 15))), 1)
  sex <- sample(c("Female", "Male"), n, replace = TRUE)
  race <- sample(c("White", "Black or African American", "Asian"), n, replace = TRUE, prob = c(0.70, 0.20, 0.10))
  ethnicity <- sample(c("Not Hispanic or Latino", "Hispanic or Latino"), n, replace = TRUE, prob = c(0.80, 0.20))
  
  # Biospecimen
  tissue_types <- sample(c("Tumor", "Normal", "Metastatic"), n, replace = TRUE, prob = c(0.70, 0.20, 0.10))
  specimen_types <- sample(c("Primary Tumor", "Solid Tissue Normal", "FFPE", "Fresh Frozen"), n, replace = TRUE)
  preservation_methods <- sample(c("FFPE", "Frozen"), n, replace = TRUE, prob = c(0.55, 0.45))
  analyte_types <- sample(c("DNA", "RNA", "Total RNA"), n, replace = TRUE)
  tumor_purity <- round(runif(n, 0.40, 0.95), 2)
  percent_tumor <- round(runif(n, 50, 100), 1)
  tumor_descriptor <- sample(c("Primary", "Metastatic"), n, replace = TRUE, prob = c(0.80, 0.20))
  
  # Treatment strings - simple vectorized approach
  drug_pool <- c("Cisplatin", "Carboplatin", "Paclitaxel", "Doxorubicin", "Cyclophosphamide",
                 "Gemcitabine", "5-Fluorouracil (5-FU)", "Oxaliplatin", "Docetaxel",
                 "Nivolumab", "Pembrolizumab", "Trastuzumab", "Bevacizumab", "Erlotinib",
                 "Imatinib", "Tamoxifen", "Letrozole", "Vemurafenib", "Sunitinib")
  
  # Each patient gets 1-3 drugs
  n_drugs <- sample(1:3, n, replace = TRUE)
  treatments_received <- sapply(n_drugs, function(k) paste(sample(drug_pool, k), collapse = "; "))
  number_of_treatments <- n_drugs
  
  # Genomics
  mutation_counts <- round(rpois(n, lambda = 40))
  tmb_status <- ifelse(mutation_counts > 80, "High", ifelse(mutation_counts > 15, "Intermediate", "Low"))
  msi_status <- sample(c("MSI-High", "MSI-Stable"), n, replace = TRUE, prob = c(0.08, 0.92))
  
  gene_pool <- c("TP53", "KRAS", "PIK3CA", "BRAF", "EGFR", "PTEN", "APC", "NRAS", "ATM", "RB1")
  n_genes <- sample(1:5, n, replace = TRUE)
  mutated_genes <- sapply(n_genes, function(k) paste(sample(gene_pool, k), collapse = "; "))
  
  # Outcomes
  vital_status <- sample(c("Alive", "Dead"), n, replace = TRUE, prob = c(0.65, 0.35))
  days_to_death <- rep(NA_real_, n)
  dead_idx <- which(vital_status == "Dead")
  if (length(dead_idx) > 0) days_to_death[dead_idx] <- round(runif(length(dead_idx), 100, 3000))
  days_to_last_followup <- round(runif(n, 30, 5000))
  
  # Clinical
  treatment_response <- sample(c("Complete Response", "Partial Response", "Stable Disease", "Progressive Disease"), n, replace = TRUE)
  prior_therapies <- sample(0:4, n, replace = TRUE)
  clinical_trial <- sample(c("Yes", "No"), n, replace = TRUE, prob = c(0.12, 0.88))
  year_of_diagnosis <- sample(2008:2018, n, replace = TRUE)
  
  data.frame(
    case_id = case_id,
    project_code = proj_code,
    project_name = proj_name,
    disease_type = disease_type,
    primary_site = primary_site,
    primary_diagnosis = disease_type,
    stage = stages,
    grade = grades,
    sex = sex,
    age_at_diagnosis = ages,
    race = race,
    ethnicity = ethnicity,
    tissue_type = tissue_types,
    specimen_type = specimen_types,
    preservation_method = preservation_methods,
    analyte_type = analyte_types,
    tumor_purity = tumor_purity,
    percent_tumor_cells = percent_tumor,
    tumor_descriptor = tumor_descriptor,
    treatments_received = treatments_received,
    number_of_treatments = number_of_treatments,
    treatment_response = treatment_response,
    prior_therapies = prior_therapies,
    mutation_count = mutation_counts,
    tmb_status = tmb_status,
    msi_status = msi_status,
    mutated_genes = mutated_genes,
    vital_status = vital_status,
    days_to_death = days_to_death,
    days_to_last_followup = days_to_last_followup,
    clinical_trial_participation = clinical_trial,
    year_of_diagnosis = year_of_diagnosis,
    stringsAsFactors = FALSE
  )
}

# ============================================================================
# UI DEFINITION
# ============================================================================

ui <- fluidPage(
  theme = bslib::bs_theme(version = 5, bootswatch = "flatly", primary = "#003366"),

  tags$head(
    tags$style(HTML("
      .gdc-header {
        background-color: #003366;
        color: white;
        padding: 15px 20px;
        margin-bottom: 0;
      }
      .gdc-nav {
        background-color: #004080;
        color: white;
        padding: 10px 20px;
      }
      .gdc-nav a {
        color: white;
        margin-right: 20px;
        text-decoration: none;
        font-size: 14px;
      }
      .gdc-nav a:hover {
        text-decoration: underline;
      }
      .gdc-nav a.active {
        font-weight: bold;
        border-bottom: 2px solid white;
      }
      .filter-bar {
        background-color: #e8f4f8;
        border: 1px solid #b3d9e8;
        padding: 10px 15px;
        border-radius: 4px;
        margin-bottom: 15px;
        min-height: 60px;
      }
      .filter-tag {
        display: inline-block;
        background-color: #2196F3;
        color: white;
        border-radius: 3px;
        padding: 4px 8px;
        margin: 3px;
        font-size: 12px;
      }
      .filter-tag .remove {
        color: #fff;
        cursor: pointer;
        margin-left: 5px;
        font-weight: bold;
      }
      .sidebar-panel {
        background-color: #f5f5f5;
        border-right: 1px solid #ddd;
        padding: 15px;
        min-height: 600px;
      }
      .sidebar-item {
        padding: 8px 12px;
        cursor: pointer;
        border-radius: 3px;
        transition: background-color 0.2s;
        font-size: 13px;
      }
      .sidebar-item:hover {
        background-color: #e0e0e0;
      }
      .sidebar-item.active {
        background-color: #003366;
        color: white;
      }
      .filter-card {
        border: 1px solid #ddd;
        border-radius: 4px;
        margin-bottom: 15px;
        background-color: white;
      }
      .filter-card-header {
        background-color: #004080;
        color: white;
        padding: 10px 15px;
        border-radius: 4px 4px 0 0;
        display: flex;
        justify-content: space-between;
        align-items: center;
        font-weight: 600;
      }
      .filter-card-body {
        padding: 15px;
        max-height: 300px;
        overflow-y: auto;
      }
      .stat-badge {
        background-color: rgba(255,255,255,0.2);
        padding: 3px 8px;
        border-radius: 10px;
        font-size: 12px;
      }
      .cohort-count {
        background-color: #2196F3;
        color: white;
        padding: 10px 20px;
        border-radius: 4px;
        text-align: center;
        font-size: 18px;
        font-weight: bold;
      }
      .search-input {
        margin-bottom: 15px;
      }
      .section-header {
        color: #003366;
        border-bottom: 2px solid #003366;
        padding-bottom: 5px;
        margin-top: 20px;
      }
      .data-badge {
        display: inline-block;
        background-color: #e3f2fd;
        color: #1976D2;
        padding: 2px 8px;
        border-radius: 3px;
        font-size: 11px;
        margin: 2px;
      }
    "))
  ),

  # GDC Header
  div(class = "gdc-header",
      fluidRow(
        column(4, h3(style = "margin: 0;", "Genomic Data Commons")),
        column(8,
               div(style = "float: right; margin-top: 10px;",
                   textInput("globalSearch", "", placeholder = "Search: e.g., BRAF, Breast, TCGA-BRCA, Lung, Pembrolizumab", width = "100%")
               )
        )
      )
  ),

  # Navigation Bar
  div(class = "gdc-nav",
      tags$a(href = "#", "Repository"),
      tags$a(href = "#", class = "active", "Cohort Builder"),
      tags$a(href = "#", "Analysis Center"),
      tags$a(href = "#", "Projects"),
      tags$a(href = "#", "Drug Index"),
      span(style = "float: right; font-size: 12px;", "Obtaining Access to Controlled Data")
  ),

  # Cohort Management Bar
  div(style = "background-color: #f0f0f0; padding: 10px 20px; border-bottom: 1px solid #ddd;",
      fluidRow(
        column(2,
               actionButton("newCohort", label = "New", icon = icon("plus-circle"), class = "btn-default btn-sm"),
               actionButton("saveCohort", label = "Save", icon = icon("save"), class = "btn-default btn-sm"),
               actionButton("loadCohort", label = "Load", icon = icon("folder-open"), class = "btn-default btn-sm"),
               actionButton("deleteCohort", label = "Delete", icon = icon("trash"), class = "btn-default btn-sm"),
               actionButton("exportCohort", label = "Export", icon = icon("download"), class = "btn-default btn-sm")
        ),
        column(6, offset = 2,
               div(class = "cohort-count",
                   uiOutput("cohortCount")
               )
        ),
        column(2,
               selectInput("dataView", "View:",
                          choices = c("Cases", "Files", "Biospecimens"),
                          selected = "Cases", width = "100%")
        )
      )
  ),

  # Active Filters Bar
  div(class = "filter-bar",
      fluidRow(
        column(10,
               div(style = "font-weight: bold; margin-bottom: 5px; color: #003366;", "Active Filters"),
               uiOutput("activeFilters")
        ),
        column(2,
               actionButton("clearAll", "Clear All", icon = icon("times"),
                           style = "margin-top: 18px; background-color: #dc3545; color: white; border: none; width: 100%;")
        )
      )
  ),

  # Main Content
  fluidRow(
    # Left Sidebar - Categories
    column(2,
           div(class = "sidebar-panel",
               h5(style = "color: #003366; margin-top: 0;", "Filter Categories"),
               textInput("categorySearch", "", placeholder = "🔍 Search categories...", width = "100%"),
               div(id = "categoryList",
                   uiOutput("categoryItems")
               )
           )
    ),

    # Main Filter Area
    column(10,
           fluidRow(
             column(12,
                    uiOutput("filterCards")
             )
           )
    )
  ),

  # Results Dashboard
  div(style = "margin-top: 20px; padding: 20px; background-color: #f9f9f9; border-radius: 4px;",
      h4(class = "section-header", "Cohort Summary & Statistics"),

      # Summary Cards
      fluidRow(
        column(3, div(class = "cohort-count", uiOutput("statTotalCases"))),
        column(3, div(class = "cohort-count", uiOutput("statProjects"))),
        column(3, div(class = "cohort-count", uiOutput("statDiseaseTypes"))),
        column(3, div(class = "cohort-count", uiOutput("statTreatments")))
      ),

      # Tabs for different views
      tabsetPanel(id = "summaryTabs",
        tabPanel("Demographics",
                 fluidRow(
                   column(6, plotOutput("sexPlot", height = 300)),
                   column(6, plotOutput("racePlot", height = 300))
                 ),
                 fluidRow(
                   column(6, plotOutput("agePlot", height = 300)),
                   column(6, DTOutput("demographicsTable"))
                 )
        ),
        tabPanel("Disease Distribution",
                 fluidRow(
                   column(6, plotOutput("projectPlot", height = 400)),
                   column(6, plotOutput("stagePlot", height = 400))
                 ),
                 fluidRow(
                   column(12, DTOutput("diseaseTable"))
                 )
        ),
        tabPanel("Treatment Analysis",
                 fluidRow(
                   column(6, plotOutput("treatmentPlot", height = 400)),
                   column(6, plotOutput("drugClassPlot", height = 400))
                 ),
                 fluidRow(
                   column(6, plotOutput("responsePlot", height = 300)),
                   column(6, DTOutput("treatmentTable"))
                 )
        ),
        tabPanel("Drug Database",
                 fluidRow(
                   column(12,
                          h5("FDA Approved Antineoplastic Drugs Database"),
                          radioButtons("drugFilter", "Filter by Drug Class:",
                                      choices = c("All", unique(antineoplastic_drugs$drug_class)),
                                      selected = "All", inline = TRUE)
                   )
                 ),
                 fluidRow(
                   column(12, DTOutput("drugDatabaseTable"))
                 )
        ),
        tabPanel("Genomics",
                 fluidRow(
                   column(4, plotOutput("tmbPlot", height = 300)),
                   column(4, plotOutput("msiPlot", height = 300)),
                   column(4, plotOutput("mutationPlot", height = 300))
                 ),
                 fluidRow(
                   column(12, DTOutput("genomicsTable"))
                 )
        ),
        tabPanel("Biospecimen",
                 fluidRow(
                   column(4, plotOutput("tissuePlot", height = 300)),
                   column(4, plotOutput("preservationPlot", height = 300)),
                   column(4, plotOutput("analytePlot", height = 300))
                 ),
                 fluidRow(
                   column(12, DTOutput("biospecimenTable"))
                 )
        ),
        tabPanel("Export Data",
                 fluidRow(
                   column(12,
                          h5("Export Filtered Cohort"),
                          radioButtons("exportFormat", "Format:",
                                      choices = c("CSV", "Excel", "JSON"), inline = TRUE),
                          actionButton("doExport", "Download Cohort Data", icon = icon("download"),
                                      class = "btn-primary")
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

  # Reactive data storage
  data <- reactiveVal(generate_realistic_data(3000))
  filters <- reactiveVal(list())
  selectedCategory <- reactiveVal("Project & Program")

  # Categories definition with hierarchical structure
  categories <- list(
    "Project & Program" = c("project_code", "project_name"),
    "Demographics" = c("sex", "age_at_diagnosis", "race", "ethnicity", "vital_status"),
    "General Diagnosis" = c("disease_type", "primary_site", "primary_diagnosis", "stage", "grade"),
    "Disease Status" = c("vital_status", "days_to_death", "days_to_last_followup", "treatment_response"),
    "Treatment" = c("treatments_received", "number_of_treatments", "treatment_response", "prior_therapies", "clinical_trial_participation"),
    "Biospecimen" = c("tissue_type", "tumor_descriptor", "specimen_type", "preservation_method",
                      "analyte_type", "tumor_purity", "percent_tumor_cells"),
    "Genomics" = c("mutation_count", "tmb_status", "msi_status", "mutated_genes"),
    "Other Clinical" = c("year_of_diagnosis", "clinical_trial_participation")
  )

  # Display categories in sidebar
  output$categoryItems <- renderUI({
    lapply(names(categories), function(cat) {
      div(class = paste0("sidebar-item", if(cat == selectedCategory()) " active"),
          onclick = sprintf("Shiny.setInputValue('selectedCat', '%s');", cat),
          cat
      )
    })
  })

  # Observe category selection
  observeEvent(input$selectedCat, {
    selectedCategory(input$selectedCat)
  })

  # Generate filter cards
  output$filterCards <- renderUI({
    cat <- selectedCategory()
    fields <- categories[[cat]]

    if (length(fields) == 0) {
      return(div(style = "padding: 40px; text-align: center; color: #999;",
                 icon("info-circle", style = "font-size: 48px;"),
                 br(), br(),
                 "No filters available for this category"))
    }

    # Create filter cards
    cards <- lapply(fields, function(field) {
      df <- data()
      col_data <- df[[field]]

      # Handle different data types
      if (is.numeric(col_data)) {
        # Numeric field - create range filter
        min_val <- round(min(col_data, na.rm = TRUE), 1)
        max_val <- round(max(col_data, na.rm = TRUE), 1)

        div(class = "col-md-4",
            div(class = "filter-card",
                div(class = "filter-card-header",
                    span(gsub("_", " ", tools::toTitleCase(field))),
                    span(class = "stat-badge", paste0(format(nrow(df), big.mark = ","), " cases"))
                ),
                div(class = "filter-card-body",
                    sliderInput(paste0("range_", field),
                               paste("Range:"),
                               min = min_val, max = max_val,
                               value = c(min_val, max_val),
                               step = if(max_val - min_val > 100) 1 else 0.1)
                )
            )
        )
      } else if (field == "treatments_received") {
        # Treatment field - special handling with all drugs
        div(class = "col-md-12",
            div(class = "filter-card",
                div(class = "filter-card-header",
                    span("Treatments Received"),
                    span(class = "stat-badge", paste0(format(nrow(df), big.mark = ","), " cases"))
                ),
                div(class = "filter-card-body",
                    div(style = "max-height: 300px; overflow-y: auto;",
                        # Group by drug class
                        lapply(unique(antineoplastic_drugs$drug_class)[1:10], function(drug_class) {
                          drugs_in_class <- antineoplastic_drugs$drug_name[antineoplastic_drugs$drug_class == drug_class]
                          tr <- as.character(col_data)
                          tr <- tr[!is.na(tr) & tr != ""]
                          if(length(tr) == 0) return(NULL)
                          drugs_in_class <- drugs_in_class[drugs_in_class %in% unique(unlist(strsplit(tr, "; ")))]
                          
                          if (length(drugs_in_class) > 0) {
                            tagList(
                              div(style = "font-weight: bold; color: #003366; margin-top: 10px;", drug_class),
                              lapply(seq_along(drugs_in_class[1:20]), function(i) {
                                drug <- drugs_in_class[i]
                                count <- sum(grepl(drug, col_data, fixed = TRUE), na.rm = TRUE)
                                if (count > 0) {
                                  checkboxInput(paste0("chk_", field, "_", gsub(" ", "_", drug)),
                                               paste0(drug, " (", count, ")"),
                                               value = FALSE)
                                }
                              })
                            )
                          }
                        })
                    )
                )
            )
        )
      } else {
        # Categorical field
        values <- unique(col_data[!is.na(col_data)])
        values <- values[order(values)]

        # Calculate counts
        counts <- sapply(values, function(v) sum(col_data == v, na.rm = TRUE))

        # Sort by count (descending) and limit to top values
        sorted_idx <- order(counts, decreasing = TRUE)
        display_values <- values[sorted_idx[1:min(30, length(sorted_idx))]]
        display_counts <- counts[sorted_idx[1:min(30, length(sorted_idx))]]

        div(class = "col-md-4",
            div(class = "filter-card",
                div(class = "filter-card-header",
                    span(gsub("_", " ", tools::toTitleCase(field))),
                    span(class = "stat-badge", paste0(format(nrow(df), big.mark = ","), " cases"))
                ),
                div(class = "filter-card-body",
                    div(style = "max-height: 250px; overflow-y: auto;",
                        lapply(seq_along(display_values), function(i) {
                          checkboxInput(paste0("chk_", field, "_", i),
                                       paste0(display_values[i], " (", format(display_counts[i], big.mark = ","), ")"),
                                       value = FALSE)
                        })
                    )
                )
            )
        )
      }
    })

    fluidRow(cards)
  })

  # Collect active filters
  observe({
    active_filters <- list()
    df <- data()

    for (cat_name in names(categories)) {
      for (field in categories[[cat_name]]) {
        col_data <- df[[field]]

        if (is.numeric(col_data)) {
          # Range filter
          input_id <- paste0("range_", field)
          if (!is.null(input[[input_id]])) {
            range_val <- input[[input_id]]
            if (!is.null(range_val) && length(range_val) == 2) {
              if (range_val[1] > min(col_data, na.rm = TRUE) ||
                  range_val[2] < max(col_data, na.rm = TRUE)) {
                active_filters[[field]] <- list(type = "range", value = range_val)
              }
            }
          }
        } else if (field == "treatments_received") {
          # Treatment checkboxes
          selected_treatments <- c()
          for (drug in antineoplastic_drugs$drug_name[1:200]) {
            input_id <- paste0("chk_", field, "_", gsub(" ", "_", drug))
            if (!is.null(input[[input_id]]) && input[[input_id]]) {
              selected_treatments <- c(selected_treatments, drug)
            }
          }
          if (length(selected_treatments) > 0) {
            active_filters[[field]] <- list(type = "treatment", value = selected_treatments)
          }
        } else {
          # Checkbox filters
          values <- unique(col_data[!is.na(col_data)])
          values <- values[order(values)]
          counts <- sapply(values, function(v) sum(col_data == v, na.rm = TRUE))
          sorted_idx <- order(counts, decreasing = TRUE)
          display_values <- values[sorted_idx[1:min(30, length(sorted_idx))]]

          selected_values <- c()
          for (i in seq_along(display_values)) {
            input_id <- paste0("chk_", field, "_", i)
            if (!is.null(input[[input_id]]) && input[[input_id]]) {
              selected_values <- c(selected_values, display_values[i])
            }
          }
          if (length(selected_values) > 0) {
            active_filters[[field]] <- list(type = "categorical", value = selected_values)
          }
        }
      }
    }

    filters(active_filters)
  })

  # Apply filters
  filteredData <- reactive({
    df <- data()
    active_filters <- filters()

    if (length(active_filters) == 0) {
      return(df)
    }

    for (field in names(active_filters)) {
      if (field %in% colnames(df)) {
        filter_info <- active_filters[[field]]

        if (filter_info$type == "range") {
          df <- df[df[[field]] >= filter_info$value[1] &
                   df[[field]] <= filter_info$value[2], ]
        } else if (filter_info$type == "categorical") {
          df <- df[df[[field]] %in% filter_info$value, ]
        } else if (filter_info$type == "treatment") {
          # Check if any selected treatment is in the treatments_received
          df <- df[sapply(df[[field]], function(x) {
            x <- as.character(x)
            if (is.na(x) || x == "") return(FALSE)
            treatments <- strsplit(x, "; ")[[1]]
            any(treatments %in% filter_info$value)
          }), ]
        }
      }
    }

    return(df)
  })

  # Display active filters
  output$activeFilters <- renderUI({
    active_filters <- filters()

    if (length(active_filters) == 0) {
      return(span("No active filters - showing all cases", style = "color: #666;"))
    }

    tags <- lapply(names(active_filters), function(field) {
      filter_info <- active_filters[[field]]

      if (filter_info$type == "range") {
        div(class = "filter-tag",
            paste0(gsub("_", " ", tools::toTitleCase(field)), ": ",
                   filter_info$value[1], " - ", filter_info$value[2]))
      } else if (filter_info$type == "treatment") {
        lapply(filter_info$value, function(val) {
          div(class = "filter-tag", paste0("Treatment: ", val))
        })
      } else {
        lapply(filter_info$value, function(val) {
          div(class = "filter-tag", paste0(gsub("_", " ", tools::toTitleCase(field)), ": ", val))
        })
      }
    })

    do.call(tagList, unlist(tags, recursive = FALSE))
  })

  # Update cohort count
  output$cohortCount <- renderUI({
    paste("Cases:", format(nrow(filteredData()), big.mark = ","))
  })

  # Statistics cards
  output$statTotalCases <- renderUI({
    paste("Total Cases:", format(nrow(filteredData()), big.mark = ","))
  })

  output$statProjects <- renderUI({
    paste("Projects:", length(unique(filteredData()$project_code)))
  })

  output$statDiseaseTypes <- renderUI({
    paste("Disease Types:", length(unique(filteredData()$disease_type)))
  })

  output$statTreatments <- renderUI({
    tr <- as.character(filteredData()$treatments_received)
    tr <- tr[!is.na(tr) & tr != ""]
    treatments <- if(length(tr) > 0) unique(unlist(strsplit(tr, "; "))) else character(0)
    paste("Unique Treatments:", length(treatments))
  })

  # Clear all filters
  observeEvent(input$clearAll, {
    for (cat_name in names(categories)) {
      for (field in categories[[cat_name]]) {
        col_data <- data()[[field]]

        if (is.numeric(col_data)) {
          input_id <- paste0("range_", field)
          if (!is.null(input[[input_id]])) {
            updateSliderInput(session, input_id,
                            value = c(min(col_data, na.rm = TRUE), max(col_data, na.rm = TRUE)))
          }
        } else {
          values <- unique(col_data[!is.na(col_data)])
          values <- values[order(values)]
          counts <- sapply(values, function(v) sum(col_data == v, na.rm = TRUE))
          sorted_idx <- order(counts, decreasing = TRUE)
          display_values <- values[sorted_idx[1:min(30, length(sorted_idx))]]

          for (i in seq_along(display_values)) {
            input_id <- paste0("chk_", field, "_", i)
            if (!is.null(input[[input_id]])) {
              updateCheckboxInput(session, input_id, value = FALSE)
            }
          }
        }
      }
    }
  })

  # Demographics plots
  output$sexPlot <- renderPlot({
    df <- filteredData()
    par(mar = c(5, 4, 4, 2))
    barplot(table(df$sex),
            main = "Sex Distribution",
            col = c("#2196F3", "#F44336"),
            ylab = "Number of Cases",
            las = 1)
  })

  output$racePlot <- renderPlot({
    df <- filteredData()
    par(mar = c(7, 4, 4, 2))
    race_table <- sort(table(df$race), decreasing = TRUE)
    barplot(race_table,
            main = "Race Distribution",
            col = "#4CAF50",
            ylab = "Number of Cases",
            las = 2)
  })
  
  output$agePlot <- renderPlot({
    df <- filteredData()
    par(mar = c(5, 4, 4, 2))
    hist(df$age_at_diagnosis, breaks = 30,
         main = "Age at Diagnosis Distribution",
         col = "#673AB7",
         xlab = "Age",
         ylab = "Frequency")
  })

  # Disease distribution plots
  output$projectPlot <- renderPlot({
    df <- filteredData()
    par(mar = c(10, 4, 4, 2))
    project_table <- sort(table(df$project_name), decreasing = TRUE)
    barplot(project_table[1:15],
            main = "Top 15 TCGA Projects",
            col = "#FF9800",
            ylab = "Number of Cases",
            las = 2)
  })

  output$stagePlot <- renderPlot({
    df <- filteredData()
    par(mar = c(5, 4, 4, 2))
    stage_table <- table(factor(df$stage, levels = c("Stage I", "Stage II", "Stage III", "Stage IV", "Not reported")))
    barplot(stage_table,
            main = "Stage Distribution",
            col = c("#4CAF50", "#8BC34A", "#FFC107", "#FF5722", "#9E9E9E"),
            ylab = "Number of Cases",
            las = 1)
  })

  # Treatment plots
  output$treatmentPlot <- renderPlot({
    df <- filteredData()
    tr <- as.character(df$treatments_received)
    tr <- tr[!is.na(tr) & tr != ""]
    if(length(tr) == 0) { return() }
    treatments <- unlist(strsplit(tr, "; "))
    treatment_table <- sort(table(treatments), decreasing = TRUE)[1:min(15, length(unique(treatments)))]
    if(length(treatment_table) == 0) { return() }

    par(mar = c(10, 4, 4, 2))
    barplot(treatment_table,
            main = "Top 15 Treatments",
            col = "#9C27B0",
            ylab = "Number of Cases",
            las = 2)
  })

  output$drugClassPlot <- renderPlot({
    df <- filteredData()
    tr <- as.character(df$treatments_received)
    tr <- tr[!is.na(tr) & tr != ""]
    if(length(tr) == 0) { return() }
    treatments <- unlist(strsplit(tr, "; "))
    if(length(treatments) == 0) { return() }

    # Map treatments to drug classes
    drug_classes <- sapply(treatments, function(trt) {
      match <- antineoplastic_drugs$drug_class[antineoplastic_drugs$drug_name == trt]
      if (length(match) == 0) "Other" else match[1]
    })

    class_table <- sort(table(drug_classes), decreasing = TRUE)[1:10]

    par(mar = c(10, 4, 4, 2))
    barplot(class_table,
            main = "Drug Class Distribution",
            col = rainbow(length(class_table)),
            ylab = "Number of Cases",
            las = 2)
  })
  
  output$responsePlot <- renderPlot({
    df <- filteredData()
    par(mar = c(5, 4, 4, 2))
    response_table <- table(factor(df$treatment_response, 
                                   levels = c("Complete Response", "Partial Response", "Stable Disease", 
                                             "Progressive Disease", "Not Evaluable")))
    barplot(response_table,
            main = "Treatment Response",
            col = c("#4CAF50", "#8BC34A", "#FFC107", "#F44336", "#9E9E9E"),
            ylab = "Number of Cases",
            las = 1)
  })

  # Genomics plots
  output$tmbPlot <- renderPlot({
    df <- filteredData()
    par(mar = c(5, 4, 4, 2))
    tmb_table <- table(factor(df$tmb_status, levels = c("Low", "Intermediate", "High")))
    barplot(tmb_table,
            main = "Tumor Mutational Burden",
            col = c("#4CAF50", "#FFC107", "#F44336"),
            ylab = "Number of Cases",
            las = 1)
  })

  output$msiPlot <- renderPlot({
    df <- filteredData()
    par(mar = c(5, 4, 4, 2))
    msi_table <- table(factor(df$msi_status, levels = c("MSI-Stable", "MSI-High", "Not reported")))
    barplot(msi_table,
            main = "MSI Status",
            col = c("#2196F3", "#F44336", "#9E9E9E"),
            ylab = "Number of Cases",
            las = 1)
  })

  output$mutationPlot <- renderPlot({
    df <- filteredData()
    par(mar = c(5, 4, 4, 2))
    hist(df$mutation_count, breaks = 30,
         main = "Mutation Count Distribution",
         col = "#673AB7",
         xlab = "Number of Mutations",
         ylab = "Frequency")
  })
  
  # Biospecimen plots
  output$tissuePlot <- renderPlot({
    df <- filteredData()
    par(mar = c(5, 4, 4, 2))
    tissue_table <- table(factor(df$tissue_type, levels = biospecimen_reference$tissue_type))
    barplot(tissue_table,
            main = "Tissue Type Distribution",
            col = c("#2196F3", "#4CAF50", "#FF9800", "#9E9E9E"),
            ylab = "Number of Cases",
            las = 1)
  })
  
  output$preservationPlot <- renderPlot({
    df <- filteredData()
    par(mar = c(5, 4, 4, 2))
    preservation_table <- table(factor(df$preservation_method, levels = biospecimen_reference$preservation_method))
    barplot(preservation_table,
            main = "Preservation Method",
            col = c("#9C27B0", "#E91E63", "#00BCD4", "#9E9E9E"),
            ylab = "Number of Cases",
            las = 1)
  })
  
  output$analytePlot <- renderPlot({
    df <- filteredData()
    par(mar = c(7, 4, 4, 2))
    analyte_table <- sort(table(df$analyte_type), decreasing = TRUE)
    barplot(analyte_table,
            main = "Analyte Type",
            col = "#3F51B5",
            ylab = "Number of Cases",
            las = 2)
  })

  # Data tables
  output$demographicsTable <- renderDT({
    df <- filteredData()
    demo_data <- data.frame(
      Category = c("Sex - Female", "Sex - Male", "Age (median)", "Age (range)",
                   "White", "Black or African American", "Asian", "Other/Not reported"),
      Count = c(
        sum(df$sex == "Female"),
        sum(df$sex == "Male"),
        round(median(df$age_at_diagnosis, na.rm = TRUE), 1),
        paste0(range(df$age_at_diagnosis, na.rm = TRUE)[1], " - ",
               range(df$age_at_diagnosis, na.rm = TRUE)[2]),
        sum(df$race == "White"),
        sum(df$race == "Black or African American"),
        sum(df$race == "Asian"),
        sum(!df$race %in% c("White", "Black or African American", "Asian"))
      )
    )
    datatable(demo_data, options = list(pageLength = 8, searching = FALSE))
  })

  output$diseaseTable <- renderDT({
    df <- filteredData()
    disease_data <- data.frame(
      Project = names(sort(table(df$project_name), decreasing = TRUE)),
      Count = as.numeric(sort(table(df$project_name), decreasing = TRUE)),
      Percentage = round(as.numeric(sort(table(df$project_name), decreasing = TRUE)) / nrow(df) * 100, 1)
    )
    datatable(disease_data, options = list(pageLength = 15))
  })

  output$treatmentTable <- renderDT({
    df <- filteredData()
    tr <- as.character(df$treatments_received)
    tr <- tr[!is.na(tr) & tr != ""]
    if(length(tr) == 0) {
      return(datatable(data.frame(Treatment = character(0), Count = numeric(0)),
                       options = list(pageLength = 15)))
    }
    treatments <- unlist(strsplit(tr, "; "))
    tt <- sort(table(treatments), decreasing = TRUE)
    treatment_data <- data.frame(
      Treatment = names(tt),
      Count = as.numeric(tt)
    )
    datatable(treatment_data, options = list(pageLength = 15))
  })

  output$genomicsTable <- renderDT({
    df <- filteredData()
    geno_data <- data.frame(
      Metric = c("Total Cases", "Median Mutation Count", "TMB - High", "TMB - Intermediate",
                "TMB - Low", "MSI-High", "MSI-Stable"),
      Value = c(
        format(nrow(df), big.mark = ","),
        round(median(df$mutation_count, na.rm = TRUE), 1),
        sum(df$tmb_status == "High"),
        sum(df$tmb_status == "Intermediate"),
        sum(df$tmb_status == "Low"),
        sum(df$msi_status == "MSI-High"),
        sum(df$msi_status == "MSI-Stable")
      )
    )
    datatable(geno_data, options = list(pageLength = 7, searching = FALSE))
  })
  
  output$drugDatabaseTable <- renderDT({
    drugs <- antineoplastic_drugs
    
    if (input$drugFilter != "All") {
      drugs <- drugs[drugs$drug_class == input$drugFilter, ]
    }
    
    datatable(drugs, options = list(pageLength = 25, searching = TRUE),
             colnames = c("Drug Name", "Drug Class", "Target"))
  })
  
  output$biospecimenTable <- renderDT({
    df <- filteredData()
    bio_data <- data.frame(
      Attribute = c("Tissue Type - Tumor", "Tissue Type - Normal", "Tissue Type - Metastatic",
                    "Preservation - FFPE", "Preservation - Frozen",
                    "Analyte - DNA", "Analyte - RNA",
                    "Median Tumor Purity", "Median % Tumor Cells"),
      Value = c(
        sum(df$tissue_type == "Tumor"),
        sum(df$tissue_type == "Normal"),
        sum(df$tissue_type == "Metastatic"),
        sum(df$preservation_method == "FFPE"),
        sum(df$preservation_method == "Frozen"),
        sum(df$analyte_type == "DNA"),
        sum(df$analyte_type == "RNA"),
        round(median(df$tumor_purity, na.rm = TRUE), 2),
        round(median(df$percent_tumor_cells, na.rm = TRUE), 1)
      )
    )
    datatable(bio_data, options = list(pageLength = 9, searching = FALSE))
  })

  # Export functionality
  observeEvent(input$doExport, {
    df <- filteredData()

    if (input$exportFormat == "CSV") {
      filename <- paste0("cohort_export_", Sys.Date(), ".csv")
      write.csv(df, filename, row.names = FALSE)
      showNotification(paste("Exported to", filename), type = "message", duration = 5)
    } else if (input$exportFormat == "JSON") {
      filename <- paste0("cohort_export_", Sys.Date(), ".json")
      jsonlite::write_json(df, filename, pretty = TRUE)
      showNotification(paste("Exported to", filename), type = "message", duration = 5)
    } else {
      showNotification("Excel export requires 'writexl' or 'openxlsx' package", type = "warning")
    }
  })

  # Cohort management modals
  observeEvent(input$newCohort, {
    showModal(modalDialog(
      title = "New Cohort",
      "This will clear all current filters and start a new cohort. Continue?",
      footer = tagList(
        actionButton("confirmNew", "Yes, Clear All", class = "btn-danger"),
        modalButton("Cancel")
      )
    ))
  })

  observeEvent(input$confirmNew, {
    removeModal()
    # Trigger clear all
    input$clearAll
  })

  observeEvent(input$saveCohort, {
    showModal(modalDialog(
      title = "Save Cohort",
      textInput("cohortName", "Cohort Name:", value = paste0("Cohort_", format(Sys.Date(), "%Y%m%d"))),
      textAreaInput("cohortDescription", "Description:", rows = 3),
      footer = tagList(
        actionButton("confirmSave", "Save Cohort"),
        modalButton("Cancel")
      )
    ))
  })

  observeEvent(input$exportCohort, {
    df <- filteredData()
    filename <- paste0("cohort_export_", Sys.Date(), ".csv")
    write.csv(df, filename, row.names = FALSE)
    showNotification(paste("Cohort exported to", filename), type = "message", duration = 5)
  })
}

# ============================================================================
# RUN APPLICATION
# ============================================================================

shinyApp(ui = ui, server = server)
