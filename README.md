# Adaptive Filters MATLAB Implementation for Speech Noise Cancellation

This repository contains MATLAB implementations and experiments for adaptive filtering algorithms applied to noise cancellation in speech signals. The project was developed as part of the **EE8104 - Advanced Digital Signal Processing** course at Toronto Metropolitan University under the supervision of **Dr. Sridhar Krishnan**.

## Project Overview

Speech signals are often corrupted by real-world background noises such as airport, train, and exhibition hall noises, which significantly degrade intelligibility. Adaptive filters offer a powerful method to reduce such noise while preserving the desired speech signal.

This project implements and compares four adaptive filtering algorithms:

- **Least Mean Square (LMS) Filter**  
- **Normalized Least Mean Square (NLMS) Filter**  
- **Recursive Least Squares (RLS) Filter**  
- **Sliding Window Recursive Least Squares (SWRLS) Filter**  

The algorithms were tested using the **NOIZEUS dataset**, which contains speech samples from 30 speakers corrupted by various noise types at 0 dB Signal-to-Noise Ratio (SNR).

## Key Features

- Evaluation of adaptive filters with varying parameters such as filter order, step size, forgetting factor, and window size.  
- Quantitative analysis of filter performance using Signal-to-Noise Ratio (SNR), Mean Squared Error (MSE), and execution time metrics.  
- Convergence analysis showing the speed and stability of each adaptive filter.  
- Scripts are modular and allow easy replication of experiments across different noise types and parameter settings.  
- Results are saved and summarized for comparative analysis.

## Repository Contents

- `LMS_filter.m`, `NLMS_filter.m`, `rls_filter.m`, `swrls_filter.m` — Implementation of individual adaptive filters.  
- `LMS_train.m`, `NLMS_train.m`, `RLS_results_train.m`, `SWRLs_Results_train.m` — Scripts running experiments on the NOIZEUS dataset and saving performance metrics.  
- Additional scripts and result files generated during experimentation.

## Background

The implemented algorithms balance the trade-off between computational complexity and noise cancellation effectiveness. The LMS and NLMS filters offer faster execution but lower noise reduction capability. RLS and SWRLS filters achieve higher SNR improvements and faster convergence at the cost of increased computational effort.

## Usage

1. Place the NOIZEUS dataset files in the expected directory structure (see scripts for file path details).  
2. Run the training scripts corresponding to the filter you wish to test.  
3. Analyze the output metrics saved or displayed for performance evaluation.

## Acknowledgments

This work was completed for the **EE8104 Advanced Digital Signal Processing** course at Toronto Metropolitan University.  
Instructor: **Dr. Sridhar Krishnan**.

## References

Please see the PDF report included in this repository for a full literature review, theoretical background, and detailed results.

[Adaptive_filter_NOIZEUS.pdf](https://github.com/user-attachments/files/20898759/Adaptive_filter_NOIZEUS.pdf)
