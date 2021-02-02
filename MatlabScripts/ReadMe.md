
﻿The source code and data to reproduce the results submitted to:

> S. Guo, C. F. Silva, W. Polifke. Robust Identification of Flame Frequency Response via Multi-Fidelity Gaussian Process Approach. 38th International Symposium on Combustion, 12-17 July, 2020, Adelaide, Australia.

The folders are organized as follows:

**BroadbandForcing**: Routines to generate broadband signals u' and Q' for system identification;

**HarmonicForcing**: Routines to perform harmonic forcing and identify FTF at discrete frequencies. In the current study, frequencies are only selected in 50:3:500 for the ease of coding. In real applications, harmonic forcing frequencies should be chosen continuously.

**Ref_FIR**: Routines to plot the reference FTF model (Fig. 2)

**SNR1_gain**: Routines to investigate the characteristics of MFGP approach and sensitivity of harmonic excitation settings, only for gain

**SNR1_phase**: Routines to investigate the characteristics of MFGP approach and sensitivity of harmonic excitation settings, only for phase

