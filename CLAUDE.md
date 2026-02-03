# CLAUDE.md - AI Assistant Guide for DoA Estimation Toolkit

This document provides comprehensive guidance for AI assistants working with this MATLAB-based Direction of Arrival (DoA) estimation codebase.

## Project Overview

**Purpose**: A MATLAB toolkit implementing multiple DoA estimation algorithms using second-order statistics for narrowband, far-field sources impinging on linear sensor arrays.

**Author**: Wesley S. Leite (CETUC / PUC-Rio, Rio de Janeiro, Brazil)
**License**: MIT (Copyright 2024)
**Contact**: wesleysouzaleite@gmail.com

## Quick Start

The main entry point is `main_2run.m`. Run it in MATLAB to:
1. Configure simulation parameters (SNR, snapshots, array geometry)
2. Select DoA estimation algorithms
3. Generate spectrum plots, beam patterns, and RMSE curves

## Directory Structure

```
/doaestimation/
├── main_2run.m              # Primary entry point - master simulation script
├── main_2run.asv            # MATLAB auto-save backup
│
├── Spectrum-Based Algorithms
│   ├── wmusic.m             # MUSIC algorithm
│   ├── wmvdr.m              # MVDR/Capon beamformer
│   └── wbart.m              # Bartlett beamformer
│
├── Search-Free Algorithms
│   ├── wroot_music.m        # Root-MUSIC (ULA only)
│   ├── wroot_mvdr.m         # Root-MVDR/Root-Capon (ULA only)
│   └── wls_esprit.m         # LS-ESPRIT (centro-symmetric arrays)
│
├── Array Generation
│   ├── arraygen.m           # Master array geometry generator
│   ├── twonestarray.m       # 2-level nested arrays
│   └── ularray.m            # Uniform linear arrays
│
├── Data Processing
│   ├── rawdata.m            # Raw signal data generator
│   ├── corrdata.m           # Correlated source projection matrix
│   ├── spect2doa.m          # Extract DoAs from spectrum
│   └── music.m              # Alternative MUSIC implementation
│
├── Utilities
│   ├── weigfunct.m          # Weight function calculation
│   ├── findula.m            # Find ULA positions in co-arrays
│   ├── mutcoup.m            # Mutual coupling matrix
│   ├── beampatt.m           # Beam pattern calculation
│   └── vline.m              # Vertical line plotting utility
│
├── Validation Functions
│   ├── chkcovmat.m          # Validate covariance matrix properties
│   ├── isCentroSymmetricArray.m  # Check centro-symmetry
│   ├── isSpacedByOne.m      # Check ULA unit spacing
│   └── isToeplitzMatrix.m   # Check Toeplitz structure
│
├── Data Generators (for specific array types)
│   ├── data_MHA_gen.m       # Minimum Hole Array data
│   └── data_MRA_gen.m       # Minimum Redundancy Array data
│
├── data/
│   ├── data_MHA.mat         # Pre-generated MHA test data
│   └── data_MRA.mat         # Pre-generated MRA test data
│
├── README.md
└── LICENSE
```

## Key Technologies

- **Language**: MATLAB
- **Required Toolboxes**: Signal Processing Toolbox (for `findpeaks`)
- **Key MATLAB Features Used**:
  - Eigenvalue decomposition (`eig`)
  - Singular Value Decomposition (`svd`)
  - Polynomial root finding (`roots`)
  - Parallel computing (`parfor`)

## Algorithm-Geometry Compatibility

**CRITICAL**: Not all algorithms work with all array geometries. The code validates this at runtime.

| Algorithm     | ULA | MRA | MHA | NAQ2 | SNAQ2 | Notes |
|--------------|-----|-----|-----|------|-------|-------|
| MUSIC        | Yes | Yes | Yes | Yes  | Yes   | Works with all geometries |
| Bartlett     | Yes | Yes | Yes | Yes  | Yes   | Works with all geometries |
| MVDR         | Yes | Yes | Yes | Yes  | Yes   | Works with all geometries |
| root-MUSIC   | Yes | No  | No  | No   | No    | **ULA only** (requires unit spacing) |
| root-MVDR    | Yes | No  | No  | No   | No    | **ULA only** (requires unit spacing) |
| LS-ESPRIT    | Yes | Yes | Yes | No   | Yes   | Centro-symmetric arrays only |

## Code Conventions

### Naming Patterns

- **Algorithm functions**: `w<algorithm>.m` prefix (e.g., `wmusic.m`, `wmvdr.m`)
- **Validation functions**: `is<Property>.m` (e.g., `isSpacedByOne.m`)
- **Backup files**: `.asv` extension (MATLAB auto-save)

### Function Signature Pattern

All DoA algorithm functions follow this signature:
```matlab
function [doa, spectrum] = algorithm(R, array, D, grid, d)
% R      - Covariance matrix
% array  - Sensor positions (normalized)
% D      - Number of sources
% grid   - Search grid for spectrum (sine values)
% d      - Element spacing (wavelength units)
```

### Documentation Header Format

Each function includes:
```matlab
% Function description
%
% Variables Description
% Input:
%   param1 - description
% Output:
%   result1 - description
%
% References:
%   [1] Author, "Title", Journal, Year
%
% Author: Wesley S. Leite
% Date: YYYY
```

### Array Manifold Computation

Standard pattern used throughout:
```matlab
a = exp(1i * 2 * pi * d * array * sin(theta));
```

### Eigendecomposition Pattern

```matlab
[delta, lambda] = eig(R);
[~, ind] = sort(diag(lambda), 'descend');
delta = delta(:, ind);  % Sort by descending eigenvalue
```

## Supported Array Geometries

The `arraygen.m` function supports:
- **ULA**: Uniform Linear Array
- **NAQ2/NAQ3**: 2/3-level Nested Arrays
- **SNAQ2/SNAQ3**: Super Nested Arrays
- **CPA**: Coprime Arrays
- **MRA**: Minimum Redundancy Arrays
- **MHA**: Minimum Hole Arrays
- **GNA**: Generalized Nested Array
- **CAD**: Generalized Coprime Array with Displaced Subarrays

## Simulation Parameters (in main_2run.m)

Default configuration:
- **SNR range**: -15 to +5 dB
- **Snapshots**: 30-350
- **Number of sensors**: 10
- **Number of sources**: 3
- **Monte Carlo trials**: 10,000

## Common Development Tasks

### Adding a New Algorithm

1. Create `w<algorithm_name>.m` following the function signature pattern
2. Add algorithm validation if geometry-specific (use `isSpacedByOne`, `isCentroSymmetricArray`)
3. Add to algorithm selection logic in `main_2run.m`
4. Include appropriate academic references in the header

### Adding a New Array Geometry

1. Extend `arraygen.m` with new geometry case
2. Document required parameters
3. Verify compatibility with existing algorithms
4. Update compatibility matrix in documentation

### Modifying Simulation Parameters

Edit variables at the top of `main_2run.m`:
```matlab
nGrid = 512;                    % Spectrum grid resolution
gridLimits = [-.9 .9];          % Search grid limits
snrRange = -15:5:5;             % SNR values in dB
nSnapshots = [30 50 100 200];   % Snapshot quantities
nTrials = 10000;                % Monte Carlo trials
```

## Important Implementation Notes

1. **DoA values are in sine space**: Range approximately [-1, 1], not degrees
2. **Array spacing normalized**: To minimum inter-element spacing (wavelength units)
3. **Covariance matrix validation**: Use `chkcovmat.m` to verify Hermitian, PSD properties
4. **Parallel computing**: `parfor` loops in main script for Monte Carlo simulations

## Testing and Validation

- Pre-generated test data available in `data/` directory
- Run `main_2run.m` with different algorithm/geometry combinations
- Compare RMSE curves against published results in referenced papers

## References

Key academic papers implemented:
- H. L. Van Trees - "Optimum Array Processing"
- R. Schmidt - "Multiple Emitter Location and Signal Parameter Estimation" (MUSIC)
- J. Capon - "High-resolution frequency-wavenumber spectrum analysis" (MVDR)
- P. Pal & P. P. Vaidyanathan - Nested Arrays publications
- A. Barabell - Root-MUSIC (ICASSP)

## Files to Ignore

- `*.asv` - MATLAB auto-save backup files
- `data/*.mat` - Pre-generated test data (binary)

## Troubleshooting

### "Array geometry not compatible" error
Check the algorithm-geometry compatibility table above. Use validation functions to verify array properties.

### Slow simulation
Reduce `nTrials` (Monte Carlo iterations) or use smaller parameter ranges during development.

### Missing toolbox functions
Ensure Signal Processing Toolbox is installed for `findpeaks` function.
