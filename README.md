# Scene Decomposition Alters Lightness Beyond Explicit Judgment

This repository contains the materials, analysis code, and computational-model code associated with:

**Toscani, M., & Metzger, A.**  
*Scene Decomposition Alters Lightness Beyond Explicit Judgment*

The project examines the Anderson–Winawer lightness illusion using three complementary approaches: a laboratory pupillometry experiment, an online presentation-duration experiment, and a task-optimized neural network trained to recover surface reflectance from layered images.

## Repository structure

```text
.
├── README.md
├── Experiment1/
│   ├── analyse_experiment1_paper.m
│   ├── ANALYSE.m
│   ├── rm_anova2.m
│   ├── data/
│   └── ...
├── Experiment2/
│   ├── analyse_participant_exp2.m
│   ├── analyse_experiment2_paper.m
│   ├── rm_anova_nd.m
│   ├── data/
│   ├── pavlovia/
│   └── ...
└── DNN/
    ├── stimulus_generation/
    ├── training/
    ├── evaluation/
    ├── rsa/
    └── ...
