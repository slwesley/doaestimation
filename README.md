# doaestimation
This repository contains MATLAB code for DoA (Direction of Arrival) estimation algorithms that use second-order statistics. To get started, run the main script: main_2run.m.

## Array Geometries
The code supports multiple array geometries, including ULA (Uniform Linear Array) and various sparse linear array configurations (NLAs or SLAs). At the start, choose both an array geometry and an algorithm.

## Algorithms
There are two types of algorithms available:
- Spectrum-like algorithms
- Search-free algorithms
(Pseudo-)Spectrum plots are generated for spectrum-like algorithms. Additionally, RMSE (Root Mean Square Error) curves against SNR and snapshots can be plotted for both spectrum-like and search-free algorithms.

Please note: some algorithms are designed to work with specific geometries. For example, ULA is compatible with all algorithms, but MRA cannot be used with root-MUSIC or root-MVDR, since those algorithms specifically requires ULA geometry.
Additionally, geometry NAQ2 is not compatible with LS-ESPRIT, as LS-ESPRIT requires a centro-symmetric array geometry. The code automatically checks for these conditions before running the algorithms.

## Beam Pattern
The code also generates beam patterns (in dB) assuming uniformly weighted beamforming.

## Need Help?
If you have any questions, feel free to reach out! I'm happy to assist.

Contact: wesleysouzaleite {at} gmail.com

Cheers,

Wesley S. Leite

Rio de Janeiro, RJ - Brazil

September 24, 2024
