/*** HELP START ***//*
### Macro:
    %heatmap  

### Purpose:
    Generates a heatmap visualization of associations between variables.  
    This macro first calls `%association_matrix` to compute all pairwise
    associations (continuous, nominal, ordinal), then creates a heatmap plot
    with annotated values.

### Parameters:

- `data` (required)  
    Input dataset for association calculations.

- `continuous` (optional)  
    Space-separated list of continuous variables.

- `nominal` (optional)  
    Space-separated list of nominal variables.

- `ordinal` (optional)  
    Space-separated list of ordinal variables.

- `method` (optional, default = PEARSON)  
    Correlation method for continuous + ordinal vars.  
    - `PEARSON`  
    - `SPEARMAN`

- `text` (optional, default = Y)  
    Controls what text appears in each heatmap cell:  
    - `Y` ? Use formatted value text with marker 
    - `N` ? Use marker symbols only for non-correlation measures

- `out` (optional, default = association)  
    Base name of output datasets created by `%association_matrix`.

### Output:
- Heatmap graphic via `PROC SGPLOT`
- Long-format association dataset `&out.`  
- Wide-format association matrix `&out._wide`

### Display Conventions:
- `*` for **Cramer's V**  (range 0 to 1)  
- `+` for **Somers' D** (range -1 to 1)  
- `-` for **Eta (correlation ratio)**  (range 0 to 1)  
- Numeric values printed when `text=Y`.

### Sample code:
~~~sas
%heatmap(
    data          = adsl,
    continuous = AGE HEIGHT WEIGHT,
    nominal      = SEX ARMCD,
    ordinal       = VISITN,
    method     = SPEARMAN,
    text         = Y,
    out          = association
);
~~~

### Notes:
- The macro requires `%association_matrix` to be available.  

### URL:
https://github.com/Nakaya-Ryo/corr

---
Author:                     Ryo Nakaya
Latest update Date:     2025-12-01  
---

*//*** HELP END ***/

%macro heatmap(
    data=,
    continuous=,       
    nominal=,    
    ordinal=,   			
    method=pearson,
    text=Y,
    out = association
);

    /*============================*
     * 1. Creating association matrix data (long)
     *============================*/
	%association_matrix(
	    data       = &data.,
	    continuous = &continuous.,
	    nominal    = &nominal.,
	    ordinal    = &ordinal.,
	    method     = &method.,
	    out        = &out.
	);

    /*============================*
     * 2. Heatmap plot
     *============================*/

	data _rattr_corr;
	    length id $8 colormodel1-colormodel3 $8;
	    retain id "CORRMAP";
	    min = -1;
	    max =  1;
	    colormodel1 = "blue";
	    colormodel2 = "white";
	    colormodel3 = "red";
	run;

	footnote j=left "*: Cramer's V   +: Somers' D   -: Correlation ratio (Eta)";
	proc sgplot data=&out. rattrmap=_rattr_corr;
	    heatmapparm x=var1 y=var2 colorresponse=value /
	        rattrid=CORRMAP
	        outline
	        name="heatmap_name";

	    %if %upcase(&text.) = Y %then %do;
	        text x=var1 y=var2 text=valuetxt / strip;
	    %end;
	    %else %do;
	        text x=var1 y=var2 text=txt / strip;
	    %end;

	    gradlegend "heatmap_name" / title="Association";
	    xaxis display=(nolabel);
	    yaxis display=(nolabel);
	run;
	footnote ;

	proc datasets lib=work ;
		delete _rattr_corr ;
	run ; quit ;

%mend;
