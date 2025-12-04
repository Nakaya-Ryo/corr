/*** HELP START ***//*
### Macro:
    %association_matrix  

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
- `data` (required)  
    Input data set name.

- `continuous` (optional)  
    Space-separated list of continuous variables.

- `nominal` (optional)  
    Space-separated list of nominal (categorical) variables.

- `ordinal` (optional)  
    Space-separated list of ordinal variables.

- `method` (optional, default = PEARSON)  
    Correlation method used for continuous + ordinal part.  
    - `PEARSON`  : Pearson correlation  
    - `SPEARMAN` : Spearman correlation  

- `out` (optional, default = association)  
    Base name of output data sets.  
    - Long-format association table: `&out.`  
    - Wide-format matrix:           `&out._wide`

### Outputs:
1. `&out.` (long format)
    - One row per pair (var1, var2) and association measure.
    - Key variables:
        - `var1`, `var2` : variable names
        - `value`        : numeric association measure
        - `type`         : association type  
            * `PEARSON` / `SPEARMAN` : correlation  
            * `CRAMERS_V`           : Cramer's V  
            * `SOMERS_D`            : Somers' D (C|R)  
            * `ETA`                 : eta coefficient  
            * `DIAG`                : diagonal (self-association = 1)  
        - `valuetxt`     : formatted value with marker  
        - `txt`          : marker for plot/heatmap  
            * `*` : Cramer's V  
            * `+` : Somers' D  
            * `-` : Eta  
            * ``(blank) : correlations

2. `&out._wide` (wide format)
    - Matrix-style dataset (wide) for numeric association values.  
    - `var1` is the row variable, columns are `var2`.

### Sample code:
~~~sas
%association_matrix(
    data       = adsl,
    continuous = AGE HEIGHT WEIGHT,
    nominal    = SEX ARMCD,
    ordinal    = VISITN,
    method     = PEARSON,
    out        = association_all
);
~~~

### Notes:
- Diagonal elements (`type = "DIAG"`) are set to 1 for all variables listed in
  `continuous`, `ordinal`, and `nominal`.
- Floating point values are rounded to `1e-6` to reduce minor numeric noise.
- Temporary work tables (e.g. `_corr_co`, `_chisq`, `_measures`, `_ov`) are
  created and cleaned up inside the macro.

### URL:
https://github.com/Nakaya-Ryo/corr

---
Author:                     Ryo Nakaya
Latest update Date:     2025-12-01  
---

*//*** HELP END ***/

%macro association_matrix( 
    data=,
    continuous=,        /* Continuous variables */
    nominal=,           /* Nominal variables */
    ordinal=,           /* Ordinal variables */
    method=pearson,     /* PEARSON or SPEARMAN */
    out=association   /* Name of output data set */
);

    %local allvars n_nom n_ord n_cont n_contord i j v1 v2;

    /* All variable list (for diagonal elements) */
    %let allvars = &continuous. &ordinal. &nominal.;

    /*============================*
     * 1. Correlation among continuous + ordinal
     *============================*/
    %let n_contord = %sysfunc(countw(&continuous &ordinal));
    %if &n_contord > 1 %then %do;

        proc corr data=&data noprint
            %if %upcase(&method)=PEARSON %then %do;
                outp=_corr_co;
            %end;
            %if %upcase(&method)=SPEARMAN %then %do;
                outs=_corr_co;
            %end;
            var &continuous &ordinal;
        run;

        data _corr_long;
            set _corr_co(where=(_TYPE_="CORR"));
            length var1 var2 $32 type $10;
            array vv {*} &continuous &ordinal;
            var1 = _NAME_;
            do i = 1 to dim(vv);
                var2 = vname(vv[i]);
                value = vv[i];
                type = "&method.";
                output;
            end;
            keep var1 var2 value type;
        run;
    %end;
    %else %do;
        data _corr_long;
            length var1 var2 $32 type $10 value 8;
            stop;
        run;
    %end;

    /*============================*
     * 2. Nominal x nominal : Cramer's V
     *============================*/
    %let n_nom = %sysfunc(countw(&nominal));

    data _nom_nom;
        length var1 var2 $32 type $10 value 8;
        stop;
    run;

    %if &n_nom >= 2 %then %do;
        %do i = 1 %to &n_nom;
            %do j = %eval(&i+1) %to &n_nom;
                %let v1 = %scan(&nominal, &i);
                %let v2 = %scan(&nominal, &j);

                ods output Chisq=_chisq;
                proc freq data=&data;
                    tables &v1 * &v2 / chisq ;
                run;
                ods output close;

                /* v1 - v2 */
                data _chisq2;
                    set _chisq;
                    where Statistic = "Cramer";
                    length var1 var2 $32 type $10 value 8;
                    var1 = "&v1";
                    var2 = "&v2";
                    value = Value;
                    type  = "CRAMERS_V";
                    keep var1 var2 value type;
                run;

                /* v2 - v1 (symmetric component) */
                data _chisq2_sym;
                    set _chisq2;
                    length tmp $32;
                    tmp  = var1;
                    var1 = var2;
                    var2 = tmp;
                    drop tmp ;
                run;

                data _nom_nom;
                    set _nom_nom _chisq2 _chisq2_sym;
                run;

                proc datasets nolist;
                    delete _chisq _chisq2 _chisq2_sym;
                run; quit;
            %end;
        %end;
    %end;

    /*================================*
     * 3. Nominal x ordinal : Somers' D (C|R)
     *================================*/
    %if %superq(ordinal)= %then %let n_ord = 0;
    %else %let n_ord = %sysfunc(countw(&ordinal));

    data _nom_ord;
        length var1 var2 $32 type $10 value 8;
        stop;
    run;

    %if (&n_nom >= 1 and &n_ord >= 1) %then %do;
        %do i = 1 %to &n_nom;
            %let v1 = %scan(&nominal, &i);  /* row: nominal */

            %do j = 1 %to &n_ord;
                %let v2 = %scan(&ordinal, &j);  /* col: ordinal */

                ods output Measures=_measures;
                proc freq data=&data;
                    tables &v1 * &v2 / measures;
                run;
                ods output close;

                data _measures2;
                    set _measures;
                    where index(Statistic,"Somer") > 0 
                          and index(Statistic,"C|R") > 0;
                    length var1 var2 $32 type $10;
                    var1 = "&v1";   /* Nominal (R) */
                    var2 = "&v2";   /* Ordinal (C) */
                    value = Value;
                    type  = "SOMERS_D";
                    keep var1 var2 value type;
                run;

                data _nom_ord;
                    set _nom_ord _measures2;
                run;

                proc datasets nolist;
                    delete _measures _measures2;
                run; quit;
            %end;
        %end;
    %end;

    /* Add symmetric components */
    data _nom_ord_sym;
        set _nom_ord;
        length tmp $32;
        tmp  = var1;
        var1 = var2;
        var2 = tmp;
        drop tmp;
    run;

    data _nom_ord;
        set _nom_ord _nom_ord_sym;
    run;

    /*====================================*
     * 4. Nominal x continuous : eta coefficient
     *====================================*/
    %let n_cont = %sysfunc(countw(&continuous));

    data _nom_con;
        length var1 var2 $32 type $10 value 8;
        stop;
    run;

    %if (&n_nom >= 1 and &n_cont >= 1) %then %do;
        %do i = 1 %to &n_nom;
            %let v1 = %scan(&nominal, &i);  /* Nominal */

            %do j = 1 %to &n_cont;
                %let v2 = %scan(&continuous, &j); /* Continuous */

                ods output OverallANOVA=_ov;
                proc anova data=&data plots=none;
                    class &v1;
                    model &v2 = &v1;
                run;
                quit;
                ods output close;

                data _eta_tmp;
                    set _ov end=last;
                    retain ss_model ss_total;
                    if Source = "Model" then ss_model = SS;
                    if Source = "Corrected Total" then ss_total = SS;
                    if last then do;
                        length var1 var2 $32 type $10 value 8;
                        var1 = "&v1";
                        var2 = "&v2";
                        if ss_total > 0 then value = sqrt(ss_model / ss_total);
                        else value = .;
                        type = "ETA";
                        output;
                    end;
                    keep var1 var2 value type;
                run;

                data _nom_con;
                    set _nom_con _eta_tmp;
                run;

                proc datasets nolist;
                    delete _ov _eta_tmp;
                run; quit;
            %end;
        %end;
    %end;

    /* Add symmetric components */
    data _nom_con_sym;
        set _nom_con;
        length tmp $32;
        tmp  = var1;
        var1 = var2;
        var2 = tmp;
        drop tmp;
    run;

    data _nom_con;
        set _nom_con _nom_con_sym;
    run;

    /*============================*
     * 5. Merge all and add diagonal
     *============================*/
    data _all_assoc;
        set _corr_long _nom_nom _nom_ord _nom_con;
    run;

    /* Diagonal elements */
    data _diag;
        length var1 var2 $32 type $10 value 8;
        do i = 1 to %sysfunc(countw(&allvars));
            var1 = scan("&allvars", i);
            var2 = var1;
            value = 1;
            type  = "DIAG";
            output;
        end;
    run;

    data _all_assoc2;
        set _all_assoc _diag;
    run;

    proc sort data=_all_assoc2 out=_heat nodupkey;
        by var1 var2;
    run;

    /* Attach formatted text for display (same spec as heatmap macro) */
    data _heat;
        length valuetxt $60 txt $10;
        set _heat;
        value = round(value, 1e-6); /* Protect against floating point issues */

        select (type);
            when ("CRAMERS_V")
                valuetxt = trim(left(cats(put(value, 5.2), '*')));
            when ("SOMERS_D")
                valuetxt = trim(left(cats(put(value, 5.2), '+')));
            when ("ETA")
                valuetxt = trim(left(cats(put(value, 5.2), '-')));
            when ("DIAG")
                valuetxt = trim(left(put(value, 5.1)));
            otherwise
                valuetxt = trim(left(put(value, 5.2)));
        end;

        select (type);
            when ("CRAMERS_V") txt = '*';
            when ("SOMERS_D")  txt = '+';
            when ("ETA")       txt = '-';
            otherwise          txt = '';
        end;
    run;

    /*============================*
     * 6. Output data sets
     *============================*/
    data &out;
        set _heat;
		drop i ;
    run;


	/*============================================*
	 * 7. Generate matrix-form (wide) data set
	 *============================================*/

	/* Convert to matrix (wide) format */
	proc transpose data=_heat out=&out._wide;
	    by var1;        /* row direction */
	    id var2;        /* column direction (var2 becomes column names) */
	    var value;      /* cell values */
	run;

	proc datasets lib=work ;
		delete _all_assoc _all_assoc2 _corr_co _corr_long _diag _heat _nom_con _nom_con_sym
			_nom_nom _nom_ord _nom_ord_sym ;
	run ; quit ;

%mend;
