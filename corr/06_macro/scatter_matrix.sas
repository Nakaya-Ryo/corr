/*** HELP START ***//*
### Macro:

    %scatter_matrix

### Purpose:

    Macro `scatter_matrix` provides GTL-based graph or table generation for correlation or related visualizations.

### Parameters:

 - `data` (required)  
    Input data set name  

 - `continuous` (optional)  
    Variable names for continuous measures with blank separated  

 - `categorical` (optional)  
    Variable names for categorical measures with blank separated  

 - `group` (optional)  
    A variable name for coloring scatter plots  

### Sample code:

~~~sas
%scatter_matrix(
	data = adsl,
	continuous = age weight,
	categorical = sex,
	group = race
)
~~~

### Note:

- Up to five variables are enough for visibility of lattice graphs  

### URL:
https://github.com/Nakaya-Ryo/corr

---
Author:                 Ryo Nakaya (nakaya.ryou@gmail.com)
Latest udpate Date:     2025-12-04
---
*//*** HELP END ***/

%macro scatter_matrix(data=, continuous=, categorical=, group=);

  %local ncont ncat total i j varlist varname rowtype coltype;
  
  /* Number of variables */
  %let ncont = %sysfunc(countw(&continuous, %str( )));
  %let ncat  = %sysfunc(countw(&categorical, %str( )));
  %let total = %eval(&ncont + &ncat);

  /* Any value of group (taking the first obs)
      This will be used for filling blank in mosaic records(not used but to avoid warnings)*/
  %if %length(&group) ne 0 %then %do ;
  	data _null_ ;
		set &data (obs=1) ;
		call symput("groupval", &group) ;
	run ;
  %end ;

  /* Sort if group is identified */
	 %if %length(&group) ne 0 %then %do ;
	 proc sort data=&data out=_data ; by &group ; run ;
	 %end ;
	 %else %do ;
	 data _data ; set &data ; run ;
	 %end ;

	 /*---------------------------------------------*/
	/*  Categorical x Categorical (freq)       */
	/*  Derive pari-wise variables (a_b, b_a) because just having a,b,c will have missing
	 	in case of pair=(a,b) (c is missing) and SAS judges that (a,c) has category with c as missing.
	   This missing judgement will produce missing category in mosaic and warning. 
	 */
	/*---------------------------------------------*/
	%if %length(&categorical) ne 0 %then %do ;

	  %local ncat i j x y;
	  %let ncat = %sysfunc(countw(&categorical,%str( )));

	  data _mosaic_all;
	    length pair $64;
	    stop;
	  run;

	  /* categorical pair (i < j) for freq */
	  %do i = 1 %to &ncat;
	    %let x = %scan(&categorical,&i,%str( ));
	    %do j = %eval(&i+1) %to &ncat;
	      %let y = %scan(&categorical,&j,%str( ));

	      /* Paired name (a_b, b_a) */
	      %let xpair = &x._&y;
	      %let ypair = &y._&x;
		  %let cntvar = cnt_&x._&y;

	      proc freq data=_data noprint;
	        tables &x * &y / list missing out=_freq_pair;
	      run;

	      data _freq_pair2;
	        set _freq_pair;
	        length pair $64;
	        pair = cats("&x","*","&y");   /* flag */
			if count ne . then count_txt = strip(put(count, 4.)); /*txt of count*/

	        &xpair = &x;
	        &ypair = &y;
			&cntvar = count; 

		    %if %length(&group) ne 0 %then %do;
			  &group = &groupval ; /* To avoid warnings (not used in analysis) */
		    %end;

	      run;

	      data _mosaic_all;
	        set _mosaic_all _freq_pair2;
	      run;

	    %end;  /* j */
	  %end;    /* i */

	%end;  /* if categorical */



  /* Set Data */
  data _gtl_all;
    length source $8;

    set _data(in=in_raw)
        %if %length(&categorical) ne 0 %then _mosaic_all(in=in_mos);
    ;

    if in_raw then do;
      source = "RAW";
      %if %length(&group) ne 0 %then %do;
        &group._raw = &group;   /* To plot raw dataset */
      %end;

      /* *_raw by each categorical */
      %if %length(&categorical) ne 0 %then %do;
        %do i = 1 %to %sysfunc(countw(&categorical,%str( )));
          %let this = %scan(&categorical,&i,%str( ));
          &this._raw = &this;
        %end;
      %end;
    end;

    else if in_mos then do;
      source = "MOSAIC";
      %if %length(&group) ne 0 %then %do;
        &group._mos = &group;
      %end;
    end;
  run;

  %if %length(&group) ne 0 %then %do;
    proc sort data=_gtl_all;
      by &group;
    run;
  %end;

  /* Variable list used in matrix */
  %let varlist = &continuous &categorical ;

  /*======================================================*/
  /*  GTL  */
  /*======================================================*/
  proc template;
    define statgraph scatter_matrix;
      begingraph;
/*        entrytitle "Scatter Matrix";*/

        layout lattice /
          rows=&total columns=&total
          order=rowmajor rowgutter=0;

          /*------------------------------*/
          /* Left Sidebar */
          /*------------------------------*/
          sidebar / align=left;
            layout lattice /
              rows=&total columns=1
              order=rowmajor rowgutter=0
              pad=(right=3px);
              %do i=1 %to &total; /*create entry by variable*/
                %let varname = %scan(&varlist, &i, %str( ));
                entry halign=center "&varname" /
                  rotate=90
                  backgroundcolor=lightgray
                  opaque=true;
              %end;
            endlayout;
          endsidebar;

          /*------------------------------*/
          /* Top Sidebar */
          /*------------------------------*/
          sidebar / align=top;
            layout lattice /
              rows=1 columns=&total
              order=rowmajor rowgutter=0
              pad=(bottom=10px);
              %do i=1 %to &total;	/*create entry by variable*/
                %let varname = %scan(&varlist, &i, %str( ));
                entry halign=center "&varname" /
                  backgroundcolor=lightgray
                  opaque=true;
              %end;
            endlayout;
          endsidebar;

          /*------------------------------*/
          /* Matrix */
          /*------------------------------*/
          %do i=1 %to &total;
            %let rowvar = %scan(&varlist,&i,%str( ));
            %if &i <= &ncont %then %let rowtype = C;
            %else               %let rowtype = K;

            %do j=1 %to &total;
              %let colvar = %scan(&varlist,&j,%str( ));
              %if &j <= &ncont %then %let coltype = C;
              %else               %let coltype = K;

              /* Diagonal */
              %if &i = &j %then %do;
                %if &rowtype = C %then %do;
				  %if %length(&group) ne 0 %then %do ;
	                  %gtl_kernel(var=&rowvar, group=&group)
				  %end ;
				  %else %do ;
	                  %gtl_kernel(var=&rowvar)
				  %end ;
                %end;
                %else %if &rowtype=K %then %do;
				  %if %length(&group) ne 0 %then %do ;				  
                  	%gtl_bar(var=&rowvar, group=&group)
				  %end ;
				  %else %do ;
                  	%gtl_bar(var=&rowvar)
				  %end ;
                %end;
              %end;

              /* Non-Diagonal */
              %else %do;

                /* Continuous x Continuous (R < C)  x=col, y=row */
                %if &rowtype = C and &coltype = C and &i < &j %then %do;
				  %if %length(&group) ne 0 %then %do ;	
                  	%gtl_ellipse(x=&colvar, y=&rowvar, group=&group)
				  %end ;
				  %else %do ;	
                  	%gtl_ellipse(x=&colvar, y=&rowvar)
				  %end ;
                %end;
                /* Continuous x Continuous (R > C) x=row, y=col */
                %if &rowtype = C and &coltype = C and &i > &j %then %do;
				  %if %length(&group) ne 0 %then %do ;	
                  	%gtl_reg(x=&colvar, y=&rowvar, group=&group)
				  %end ;
				  %else %do ;	
                  	%gtl_reg(x=&colvar, y=&rowvar)
				  %end ;
                %end;

                /* Continuous x Categorical (R < C) */
                %else %if &rowtype = C and &coltype = K %then %do;
     	             %gtl_box(x=&colvar, y=&rowvar)
                %end;

                /* Categorical x Continuous (R > C) */
                %else %if &rowtype = K and &coltype = C %then %do;
				  %if %length(&group) ne 0 %then %do ;	
                  %gtl_scatter(x=&rowvar, y=&colvar, group=&group)
				  %end ;
				  %else %do ;	
                  %gtl_scatter(x=&rowvar, y=&colvar)
				  %end ;
                %end;

                /* Categorical x Categorical (Cross table / Mosaic) */
                %else %if &rowtype = K and &coltype = K %then %do;

				  %let rowmos = &rowvar._&colvar;   /* e.g.: ord2_grpn */
				  %let colmos = &colvar._&rowvar;   /* e.g.: grpn_ord2 */
				  %let cntmos = cnt_&colvar._&rowvar.; /* count variable for pairs */

                  %if &i < &j %then %do;
                    %gtl_crosstable(x=&rowmos, y=&colmos, value=count_txt) /* crostable uses original count variable */
                  %end;
                  %else %if &i > &j %then %do;
		                %gtl_mosaic(x=&rowmos, y=&colmos, value=&cntmos)
                  %end;
                %end;
              %end;
            %end;    /* j */
          %end;      /* i */
        endlayout;
      endgraph;
    end;
  run;

  proc sgrender data=_gtl_all template=scatter_matrix;
  run;

%mend;
