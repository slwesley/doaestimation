# Test Coverage Analysis Report

## Executive Summary

**Current Test Coverage: 0%**

This MATLAB codebase for Direction of Arrival (DoA) estimation has **no automated tests**. All validation is performed manually through Monte Carlo simulations in `main_2run.m` with visual inspection of results.

| Metric | Value |
|--------|-------|
| Total Source Files | 24 .m files |
| Total Lines of Code | ~1,696 |
| Test Files | 0 |
| Test Directories | 0 |
| Coverage Reports | None |
| Testing Framework | None configured |

---

## Codebase Overview

The project implements DoA estimation algorithms for narrowband, far-field sources on linear sensor arrays:

### Core Algorithms (7 total)
- **Spectrum-based**: `wmusic.m`, `wbart.m`, `wmvdr.m`
- **Search-free**: `wroot_music.m`, `wroot_mvdr.m`, `wroot_capon.m`, `wls_esprit.m`

### Supporting Functions
- **Array Geometry**: `arraygen.m`, `ularray.m`, `twonestarray.m`, `mutcoup.m`
- **Validation**: `chkcovmat.m`, `isCentroSymmetricArray.m`, `isSpacedByOne.m`, `isToeplitzMatrix.m`
- **Utilities**: `rawdata.m`, `corrdata.m`, `spect2doa.m`, `weigfunct.m`, `findula.m`, `beampatt.m`

---

## Priority Areas for Test Coverage Improvement

### Priority 1: Critical - Validation Functions

These functions are used to validate inputs and should have comprehensive unit tests.

#### `chkcovmat.m` (lines: 44)
**Purpose**: Validates that source covariance matrix is Hermitian PSD and dimensions match sources.

**Recommended Tests**:
```matlab
% test_chkcovmat.m
function tests = test_chkcovmat
    tests = functiontests(localfunctions);
end

% Test valid Hermitian PSD matrix
function testValidHermitianPSD(testCase)
    R = [2 1+1i; 1-1i 2];  % Valid Hermitian PSD
    result = chkcovmat(R, 2);
    verifyTrue(testCase, result);
end

% Test non-Hermitian matrix throws error
function testNonHermitian(testCase)
    R = [1 2; 3 4];  % Not Hermitian
    verifyError(testCase, @() chkcovmat(R, 2), '');
end

% Test dimension mismatch throws error
function testDimensionMismatch(testCase)
    R = eye(3);
    verifyError(testCase, @() chkcovmat(R, 2), '');
end

% Test negative eigenvalue matrix throws error
function testNegativeEigenvalue(testCase)
    R = [1 0; 0 -1];  % Has negative eigenvalue
    verifyError(testCase, @() chkcovmat(R, 2), '');
end
```

#### `isCentroSymmetricArray.m`, `isSpacedByOne.m`, `isToeplitzMatrix.m`
**Recommended Tests**: Input validation, edge cases (empty arrays, single element), known symmetric/asymmetric arrays.

---

### Priority 2: High - Core Algorithm Functions

#### `wmusic.m` (lines: 50)
**Purpose**: MUSIC algorithm for DoA estimation.

**Recommended Tests**:
```matlab
% test_wmusic.m
function tests = test_wmusic
    tests = functiontests(localfunctions);
end

% Test single source detection
function testSingleSource(testCase)
    % Setup: Known DoA at 0.3
    theta_true = 0.3;
    [~,~,~,~,~,R_est,~] = rawdata([0;1;2;3], 1000, theta_true, 1, 1, 20, 0.5);
    grid = linspace(-1, 1, 1000);
    [doa, ~] = wmusic(R_est, [0;1;2;3], 1, grid, 0.5);
    verifyEqual(testCase, doa, theta_true, 'AbsTol', 0.01);
end

% Test multiple sources detection
function testMultipleSources(testCase)
    theta_true = [0.2, 0.5];
    % ... similar setup
end

% Test known covariance matrix (regression test)
function testKnownCovariance(testCase)
    % Use pre-computed R with known expected DoAs
end

% Test spectrum shape (peaks at correct locations)
function testSpectrumPeaks(testCase)
    % Verify spectrum has peaks at expected DoA locations
end
```

#### Similar tests needed for: `wbart.m`, `wmvdr.m`, `wroot_music.m`, `wroot_mvdr.m`, `wls_esprit.m`

---

### Priority 3: High - Data Generation Functions

#### `rawdata.m` (lines: 57)
**Purpose**: Generates synthetic received signal data with noise.

**Recommended Tests**:
```matlab
% test_rawdata.m
function tests = test_rawdata
    tests = functiontests(localfunctions);
end

% Test output dimensions
function testOutputDimensions(testCase)
    arrayPos = [0;1;2;3];
    snaps = 100;
    theta = [0.3, 0.5];
    [X,S,A,~,~,R_est,~] = rawdata(arrayPos, snaps, theta, 1, eye(2), 10, 0.5);

    verifySize(testCase, X, [4, 100]);      % m x snaps
    verifySize(testCase, S, [2, 100]);      % D x snaps
    verifySize(testCase, A, [4, 2]);        % m x D
    verifySize(testCase, R_est, [4, 4]);    % m x m
end

% Test SNR calculation is correct
function testSNRCalculation(testCase)
    % Generate data at known SNR, verify actual SNR matches
end

% Test covariance matrix is Hermitian
function testCovarianceHermitian(testCase)
    [~,~,~,~,~,R_est,~] = rawdata([0;1;2;3], 1000, 0.3, 1, 1, 10, 0.5);
    verifyTrue(testCase, ishermitian(R_est));
end

% Test array manifold calculation
function testArrayManifold(testCase)
    % Verify A matrix matches expected steering vectors
end
```

---

### Priority 4: Medium - Array Geometry Functions

#### `arraygen.m` (lines: 369)
**Purpose**: Main array generation engine supporting 10+ array types.

**Recommended Tests**:
```matlab
% test_arraygen.m
function tests = test_arraygen
    tests = functiontests(localfunctions);
end

% Test ULA generation
function testULAGeneration(testCase)
    [positions, ~, ~, ~, ~] = arraygen('ula', 8);
    expected = (0:7)';
    verifyEqual(testCase, positions, expected);
end

% Test nested array generation
function testNestedArray(testCase)
    [positions, ~, ~, ~, ~] = arraygen('naq2', 4);
    % Verify positions match nested array formula
end

% Test coupling matrix generation
function testCouplingMatrix(testCase)
    [~, ~, C, ~, ~] = arraygen('ula', 4, 'coupling', true, 'coupcoeff', 0.1);
    verifySize(testCase, C, [4, 4]);
    verifyTrue(testCase, issymmetric(C));
end

% Test invalid array type throws error
function testInvalidArrayType(testCase)
    verifyError(testCase, @() arraygen('invalid_type', 4), '');
end
```

---

### Priority 5: Medium - Utility Functions

#### `spect2doa.m` (lines: 44)
**Purpose**: Extracts DoA estimates from spectrum peaks.

**Recommended Tests**:
- Test with single peak
- Test with multiple peaks
- Test with closely spaced peaks
- Test with no clear peaks (flat spectrum)
- Test grid boundary conditions

#### `weigfunct.m` (lines: 50)
**Purpose**: Computes weight functions for different algorithms.

**Recommended Tests**:
- Test each weight type ('music', 'bart', 'mvdr')
- Test output dimensions
- Test numerical stability

---

## Missing/Undefined Functions

The following functions are called in `arraygen.m` but **do not exist** in the codebase:

| Function | Called For Array Type |
|----------|----------------------|
| `coprimearray()` | CPA (Coprime Array) |
| `supernestarray()` | SNAQ2, SNAQ3 (Super Nested Arrays) |
| `genestarray()` | GNA (Generalized Nested Array) |
| `cadarray()` | CAD Array |
| `fract()` | Fractal Array |

**Recommendation**: Either implement these functions or add tests that verify appropriate error messages when these array types are selected.

---

## Proposed Test Directory Structure

```
doaestimation/
├── tests/
│   ├── unit/
│   │   ├── test_chkcovmat.m
│   │   ├── test_isCentroSymmetricArray.m
│   │   ├── test_isSpacedByOne.m
│   │   ├── test_isToeplitzMatrix.m
│   │   ├── test_rawdata.m
│   │   ├── test_corrdata.m
│   │   ├── test_spect2doa.m
│   │   ├── test_weigfunct.m
│   │   └── test_findula.m
│   ├── algorithms/
│   │   ├── test_wmusic.m
│   │   ├── test_wbart.m
│   │   ├── test_wmvdr.m
│   │   ├── test_wroot_music.m
│   │   ├── test_wroot_mvdr.m
│   │   └── test_wls_esprit.m
│   ├── arrays/
│   │   ├── test_arraygen.m
│   │   ├── test_ularray.m
│   │   ├── test_twonestarray.m
│   │   └── test_mutcoup.m
│   ├── integration/
│   │   ├── test_full_pipeline.m
│   │   └── test_algorithm_array_combinations.m
│   └── regression/
│       └── test_known_scenarios.m
├── run_tests.m  (test runner script)
└── ...
```

---

## Recommended Test Implementation Order

### Phase 1: Foundation (Week 1-2)
1. Set up MATLAB unit test framework
2. Create `tests/` directory structure
3. Implement tests for validation functions:
   - `test_chkcovmat.m`
   - `test_isCentroSymmetricArray.m`
   - `test_isSpacedByOne.m`
   - `test_isToeplitzMatrix.m`

### Phase 2: Data Layer (Week 3-4)
4. Implement tests for data generation:
   - `test_rawdata.m`
   - `test_corrdata.m`
5. Implement tests for array geometry:
   - `test_arraygen.m`
   - `test_ularray.m`
   - `test_twonestarray.m`

### Phase 3: Core Algorithms (Week 5-8)
6. Implement algorithm tests with known scenarios:
   - `test_wmusic.m`
   - `test_wbart.m`
   - `test_wmvdr.m`
   - `test_wroot_music.m`
   - `test_wroot_mvdr.m`
   - `test_wls_esprit.m`

### Phase 4: Integration (Week 9-10)
7. Create integration tests for full pipeline
8. Add regression tests with saved test data
9. Implement performance benchmarks

---

## Test Runner Script

```matlab
% run_tests.m - Run all tests in the test suite
function results = run_tests()
    import matlab.unittest.TestSuite
    import matlab.unittest.TestRunner
    import matlab.unittest.plugins.CodeCoveragePlugin
    import matlab.unittest.plugins.codecoverage.CoverageReport

    % Create test suite from tests folder
    suite = TestSuite.fromFolder('tests', 'IncludingSubfolders', true);

    % Create runner with coverage
    runner = TestRunner.withTextOutput;

    % Add coverage plugin (optional)
    coverageReport = CoverageReport('coverage_results');
    plugin = CodeCoveragePlugin.forFolder(pwd, 'Producing', coverageReport);
    runner.addPlugin(plugin);

    % Run tests
    results = runner.run(suite);

    % Display summary
    disp(results);
end
```

---

## Edge Cases Requiring Special Attention

1. **Single source vs multiple sources**: Algorithms behave differently
2. **Closely spaced sources**: Near the resolution limit
3. **Low SNR conditions**: Algorithm numerical stability
4. **Array type compatibility**: LS-ESPRIT requires centro-symmetric arrays
5. **Grid resolution**: Effects on DoA estimation accuracy
6. **Coherent vs uncorrelated sources**: Different covariance structures
7. **Boundary conditions**: DoAs at grid edges (-1, +1)

---

## Summary

| Priority | Area | Files | Effort |
|----------|------|-------|--------|
| 1 (Critical) | Validation Functions | 4 | Low |
| 2 (High) | Core Algorithms | 6 | Medium |
| 3 (High) | Data Generation | 2 | Low |
| 4 (Medium) | Array Geometry | 4 | Medium |
| 5 (Medium) | Utilities | 4 | Low |
| 6 (Low) | Integration | - | High |

**Total estimated test files needed**: ~20
**Recommended approach**: Start with validation functions (quick wins) then move to core algorithms.
