Type: Package
Package: corr
Title: Correlation and Association Analysis
Version: 0.0.2
Author: Ryo Nakaya (nakaya.ryou@gmail.com)
Maintainer: Ryo Nakaya (nakaya.ryou@gmail.com)
License: MIT
Encoding: UTF8
Required: "Base SAS Software"
ReqPackages: 
DESCRIPTION START: 

Provides macros for computing association measures between continuous, nominal,
and ordinal variables. Supports Pearson and Spearman correlations, Cramer's V, Somers' D, and Eta
coefficients. Outputs both long-format association tables and wide matrix-style datasets for
further analysis. Includes a heatmap macro to visualize the strength and type of associations in
a single plot. 
Tools for analysis or visualization related to correlation and association are to be added.  

Available macros are as below.
- %association_matrix	: To generate association matrix dataset (long, wide)    
- %heatmap				: To generate heatmap    
- %scatter_matrix		: To generate scatter matrix plot (Kernel, Bar, Scatter, Mosaic, Cross Table, Box)  

DESCRIPTION END: