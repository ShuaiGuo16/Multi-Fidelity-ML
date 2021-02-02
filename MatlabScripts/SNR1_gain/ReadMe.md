# LHS
Code and data to investigate the sensitivity of the performance of multi-fidelity approach against high-fidelity harmonic excitation settings. FTF gain is predicted here.

Run **SampleGenerator.m** to generate 20 Latin-Hypercube harmonic forcing samples;

Run **Multi_gain_LHS.m** to calculate multi-fidelity predictions for each harmonic forcing sample;

Run **Accu_cost.m** to compare the performance of multi-fidelity approach and broadband approach with an equivalent computational budget
# Point
Code to investigate the characteristics of MFGP approach. FTF gain is predicted here.

Run **Multi_gain_point.m** to perform multi-fidelity FTF gain prediction;

Run **LongTermFIR.m** to calculate the converged broadband results
# UtilityFunctions&Data
All the functions called by **LHS** folder and **Point** folder are stored here
