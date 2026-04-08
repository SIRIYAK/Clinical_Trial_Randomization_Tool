# Contributing to Clinical Trial Randomization Builder

Thank you for your interest in contributing to this open-source project! 🎉

This project is built for the global clinical research community, and we welcome contributions from researchers, statisticians, developers, and anyone passionate about making clinical trial design accessible.

---

## 🌟 How You Can Contribute

### 1. Report Bugs 🐛

Found a bug? We'd love to hear about it!

**Before reporting:**
- Check existing issues to avoid duplicates
- Test on the latest version
- Gather information about your environment

**Bug report should include:**
- Clear title describing the issue
- Steps to reproduce the problem
- Expected vs actual behavior
- R version and OS information
- Screenshots if applicable

### 2. Suggest Features 💡

Have an idea to make this tool better?

**Feature requests should include:**
- Clear description of the feature
- Use case or problem it solves
- Examples of how it would work
- Any relevant references or mockups

### 3. Improve Documentation 📝

Help make this tool more accessible:

- Fix typos or unclear instructions
- Add examples and tutorials
- Translate documentation
- Improve code comments
- Add FAQ entries

### 4. Add New Cancer Types 🎗️

We want to support all cancer types! To add a new cancer type:

1. Define cancer characteristics:
   - Name and abbreviation
   - Histology types
   - Relevant biomarkers
   - Standard treatment regimens

2. Add to `cancer_types` list in `app.R`

3. Update documentation

### 5. Submit Code 🔧

Ready to code? Here's how:

### 6. Share Your Experience 📊

Used this tool for your trial design? Share:
- Your experience and workflow
- Tips for other users
- Custom templates you created
- Success stories

---

## 🚀 Getting Started

### Prerequisites

- R (version 4.0 or higher)
- Git
- Basic understanding of R and Shiny

### Setup Development Environment

```bash
# Clone the repository
git clone https://github.com/yourusername/Clinical_Trial_Randomization_Tool.git

# Navigate to project directory
cd Clinical_Trial_Randomization_Tool

# Install dependencies
Rscript install_dependencies.R

# Run the application
Rscript -e "shiny::runApp('app.R')"
```

### Understanding the Code Structure

```
app.R
├── FDA Guidelines Database (Lines 1-150)
├── Stratification Factors (Lines 150-300)
├── Cancer Types Database (Lines 300-450)
├── Trial Phase Configurations (Lines 450-550)
├── Treatment Regimens (Lines 550-650)
├── Dose Escalation Schemes (Lines 650-700)
├── Utility Functions (Lines 700-850)
├── UI Definition (Lines 850-1100)
└── Server Logic (Lines 1100-1400)
```

---

## 📋 Contribution Workflow

### Step 1: Fork the Repository

Click the "Fork" button on GitHub to create your own copy.

### Step 2: Create a Feature Branch

```bash
git checkout -b feature/your-feature-name
```

**Branch naming conventions:**
- `feature/add-breast-cancer-regimens`
- `bugfix/fix-randomization-ratio-parsing`
- `docs/improve-quick-start-guide`
- `translation/add-spanish-docs`

### Step 3: Make Your Changes

**Code style guidelines:**
- Use consistent indentation (2 spaces)
- Add comments for complex logic
- Follow existing naming conventions
- Keep functions focused and modular
- Test your changes thoroughly

**Commit message guidelines:**
```
# Good commit messages
Add NSCLC dose escalation simulation
Fix envelope generation for stratified randomization
Update FDA guidelines links
Improve playground UI responsiveness

# Bad commit messages
fix stuff
update
WIP
```

### Step 4: Test Your Changes

Ensure your changes:
- ✅ Don't break existing functionality
- ✅ Work with different R versions (if possible)
- ✅ Include appropriate error handling
- ✅ Update documentation if needed

### Step 5: Submit a Pull Request

1. Push your changes: `git push origin feature/your-feature-name`
2. Go to the original repository
3. Click "New Pull Request"
4. Fill out the PR template
5. Wait for review and feedback

---

## 📝 Pull Request Template

```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix (non-breaking change which fixes an issue)
- [ ] New feature (non-breaking change which adds functionality)
- [ ] Breaking change (fix or feature that would cause existing functionality to not work as expected)
- [ ] Documentation update
- [ ] New cancer type addition
- [ ] Code refactoring

## Testing
- [ ] I have tested these changes locally
- [ ] I have ensured the application still runs without errors
- [ ] I have tested the new feature with different inputs

## Screenshots (if applicable)
Add screenshots to help explain your changes

## Additional Notes
Any other information reviewers should know
```

---

## 🎯 Priority Areas for Contribution

### High Priority
- [ ] Add more cancer types (Pancreatic, Liver, Brain tumors, etc.)
- [ ] Implement adaptive randomization methods
- [ ] Add survival curve generation (Kaplan-Meier)
- [ ] Create PDF report generation
- [ ] Add multi-language support
- [ ] Implement more dose-finding designs (mTPI, i3+3)

### Medium Priority
- [ ] Add Bayesian hierarchical models for basket trials
- [ ] Implement response-adaptive randomization
- [ ] Add sample size calculation tools
- [ ] Create interactive trial schema builder
- [ ] Add data validation and error checking
- [ ] Implement audit trail functionality

### Nice to Have
- [ ] Mobile-responsive design
- [ ] Dark mode theme
- [ ] Export to REDCap format
- [ ] Integration with clinical trial management systems
- [ ] Add video tutorials
- [ ] Create R package version

---

## 📚 Resources for Contributors

### Learning R & Shiny
- [R for Data Science](https://r4ds.had.co.nz/)
- [Mastering Shiny](https://mastering-shiny.org/)
- [Advanced R](https://adv-r.hadley.nz/)

### Clinical Trial Design
- [FDA Guidance Documents](https://www.fda.gov/regulatory-information/search-fda-guidance-documents/drugs)
- [ICH Guidelines](https://www.ich.org/page/ich-guidelines)
- [NCI Clinical Trials Information](https://www.cancer.gov/about-cancer/treatment/clinical-trials)

### Open Source Contribution
- [GitHub Guides](https://guides.github.com/)
- [How to Contribute to Open Source](https://opensource.guide/how-to-contribute/)

---

## 🤝 Code of Conduct

### Our Pledge

We pledge to make participation in this project a harassment-free experience for everyone, regardless of age, body size, disability, ethnicity, gender identity and expression, level of experience, nationality, personal appearance, race, religion, or sexual identity and orientation.

### Expected Behavior

- Be respectful and inclusive
- Accept constructive criticism
- Focus on what's best for the community
- Show empathy towards other community members

### Unacceptable Behavior

- Use of sexualized language or imagery
- Trolling, insulting comments, or personal attacks
- Public or private harassment
- Publishing others' private information without permission

---

## 🏆 Recognition

All contributors will be recognized in:
- README.md contributors section
- Release notes
- Annual acknowledgments

**Special recognition for:**
- First-time contributors
- Consistent contributors
- Contributors who help others

---

## ❓ Frequently Asked Questions

### Q: Do I need to be a clinical trial expert to contribute?

**A:** No! We welcome contributions from all skill levels. Documentation improvements, bug reports, and feature suggestions are just as valuable as code contributions.

### Q: Can I contribute if I'm not a programmer?

**A:** Absolutely! You can contribute by:
- Reporting bugs
- Suggesting features
- Improving documentation
- Testing the application
- Sharing your experience
- Translating content

### Q: How long does it take for PRs to be reviewed?

**A:** We aim to review PRs within 1-2 weeks. Complex changes may take longer.

### Q: Can I use this tool for my actual clinical trial?

**A:** This tool is for planning, simulation, and educational purposes. Always consult with biostatisticians and regulatory experts for actual trial implementation.

### Q: Is this project affiliated with FDA or NCI?

**A:** No, this is an independent open-source project inspired by FDA and NCI guidelines. It is not officially endorsed by any regulatory agency.

---

## 🙏 Thank You

Every contribution, no matter how small, makes a difference. Thank you for helping make clinical trial design accessible to researchers worldwide! 💙

---

## 📧 Contact

- **Issues:** [GitHub Issues](https://github.com/yourusername/Clinical_Trial_Randomization_Tool/issues)
- **Discussions:** [GitHub Discussions](https://github.com/yourusername/Clinical_Trial_Randomization_Tool/discussions)
- **Email:** [Your contact information]

---

<div align="center">

**Together, we can democratize clinical trial design** 🌍

*Thank you for being part of this open-source community!*

</div>
