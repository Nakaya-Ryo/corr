# corr (latest version 0.0.1 on 4Dec2025)
A SAS package to provide macros for computing association measures between continuous, nominal, and ordinal variables. This package supports Pearson and Spearman correlations, Cramer's V, Somers' D, and Eta coefficient. Macro in the package outputs both long-format association tables and wide matrix-style datasets for further analysis. Includes a heatmap macro to visualize the strength and type of associations in a single plot. Tools for analysis or visualization related to correlation and association are to be added.  

<img src="https://github.com/Nakaya-Ryo/corr/blob/main/corr.png?raw=true" alt="corr" width="300"/>

Available macros for validations are as below.
- %association_matrix	: To generate association matrix dataset (long, wide)    
- %heatmap				: To generate heatmap    
- %scatter_matrix		: To generate scatter matrix plot (Kernel, Bar, Scatter, Mosaic, Cross Table, Box)  

---

## %association_matrix

### Purpose:
    Creates a unified association matrix between variables of different types  
    (continuous, nominal, ordinal).  
    It calculates:
    - Correlations for continuous + ordinal variables (PEARSON or SPEARMAN)  
    - Cramer's V for nominal x nominal  (range 0 to 1)  
    - Somers' D (C|R) for nominal x ordinal  (range -1 to 1)  
    - Eta coefficient for nominal x continuous  (range 0 to 1)  
    and combines them into a single "long" association dataset and a "wide" matrix.
            
### Parameters:
~~~sas
- `data` (required)  Input data set name.
- `continuous` (optional) Space-separated list of continuous variables.
- `nominal` (optional) Space-separated list of nominal (categorical) variables.
- `ordinal` (optional) Space-separated list of ordinal variables.
- `method` (optional, default = PEARSON)  
    Correlation method used for continuous + ordinal part.  
    - `PEARSON`  : Pearson correlation  
    - `SPEARMAN` : Spearman correlation  
- `out` (optional, default = association) Base name of output data sets.  
~~~

### Example usage:
~~~sas
%association_matrix(
    data       = adsl,
    continuous = AGE HEIGHT WEIGHT,
    nominal    = SEX ARMCD,
    ordinal    = VISITN,
    method     = PEARSON,
    out        = association_all
)
~~~

## %heatmap

### Purpose:
    Generates a heatmap visualization of associations between variables.  
    This macro first calls `%association_matrix` to compute all pairwise
    associations (continuous, nominal, ordinal), then creates a heatmap plot
    with annotated values.
	
<img src="https://github.com/Nakaya-Ryo/corr/blob/main/heatmap.png?raw=true" alt="heatmap" width="300"/>
        
### Parameters:
~~~sas
- `data` (required) Input dataset for association calculations.
- `continuous` (optional) Space-separated list of continuous variables.
- `nominal` (optional) Space-separated list of nominal variables.
- `ordinal` (optional) Space-separated list of ordinal variables.
- `method` (optional, default = PEARSON) Correlation method for continuous + ordinal vars.  
- `text` (optional, default = Y)  Controls what text appears in each heatmap cell:  
- `out` (optional, default = association) Base name of output datasets created by `%association_matrix`.
~~~

### Example usage:
~~~sas
%heatmap(
    data         = adsl,
    continuous   = AGE HEIGHT WEIGHT,
    nominal      = SEX ARMCD,
    ordinal      = VISITN,
    method       = SPEARMAN,
    text         = Y,
    out          = association
)
~~~

## %scatter_matrix

### Purpose:
	Macro `scatter_matrix` provides GTL-based graph or table generation for correlation or related visualizations.

<img src="https://github.com/Nakaya-Ryo/corr/blob/main/scatter_matrix.png?raw=true" alt="scatter_matrix" width="300"/>

### Parameters:
~~~sas
 - `data` (required) Input data set name  
 - `continuous` (optional) Variable names for continuous measures with blank separated  
 - `categorical` (optional) Variable names for categorical measures with blank separated  
 - `group` (optional) A variable name for coloring scatter plots  
~~~

### Example usage:
~~~sas
%scatter_matrix(
	data 		= adsl,
	continuous 	= age weight,
	categorical = sex,
	group 		= race
)
~~~

## Version history   
0.0.1(4December2025)	: Initial version

---

## What is SAS Packages?

The package is built on top of **SAS Packages Framework(SPF)** developed by Bartosz Jablonski.

For more information about the framework, see [SAS Packages Framework](https://github.com/yabwon/SAS_PACKAGES).

You can also find more SAS Packages (SASPacs) in the [SAS Packages Archive(SASPAC)](https://github.com/SASPAC).

## How to use SAS Packages? (quick start)

### 1. Set-up SAS Packages Framework

First, create a directory for your packages and assign a `packages` fileref to it.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~sas
filename packages "\path\to\your\packages";
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Secondly, enable the SAS Packages Framework.
(If you don't have SAS Packages Framework installed, follow the instruction in 
[SPF documentation](https://github.com/yabwon/SAS_PACKAGES/tree/main/SPF/Documentation) 
to install SAS Packages Framework.)

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~sas
%include packages(SPFinit.sas)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


### 2. Install SAS package

Install SAS package you want to use with the SPF's `%installPackage()` macro.

- For packages located in **SAS Packages Archive(SASPAC)** run:
  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~sas
  %installPackage(packageName)
  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

- For packages located in **PharmaForest** run:
  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~sas
  %installPackage(packageName, mirror=PharmaForest)
  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

- For packages located at some network location run:
  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~sas
  %installPackage(packageName, sourcePath=https://some/internet/location/for/packages)
  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  (e.g. `%installPackage(ABC, sourcePath=https://github.com/SomeRepo/ABC/raw/main/)`)


### 3. Load SAS package

Load SAS package you want to use with the SPF's `%loadPackage()` macro.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~sas
%loadPackage(packageName)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


### Enjoy!

---
