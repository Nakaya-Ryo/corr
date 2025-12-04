/*** HELP START ***//*

### Purpose:
- Unit test for the %association_matrix() macro   

*//*** HELP END ***/


%loadPackage(valivali)
%set_tmp_lib(lib=TEMP, winpath=C:\Temp, otherpath=/tmp, newfolder=corr)

/*Expected Dataset*/
data expected;
  length valuetxt $60 txt $10 var1 $32 var2 $32 type $10 ;
  input valuetxt $ txt $ var1 $ var2 $ type $ value;
  cards;
1.0 . nominal1c nominal1c DIAG 1.0000
0.62+ + nominal1c ordinal1 SOMERS_D 0.6190
0.46- - nominal1c x01 ETA 0.4573
0.62+ + ordinal1 nominal1c SOMERS_D 0.6190
1.00 . ordinal1 ordinal1 spearman 1.0000
0.29 . ordinal1 x01 spearman 0.2913
0.46- - x01 nominal1c ETA 0.4573
0.29 . x01 ordinal1 spearman 0.2913
1.00 . x01 x01 spearman 1.0000
  ;
run;

/*Test Dataset*/
proc format;
    value x11fmt
        1 = "Low"
        2 = "Medium"
        3 = "High";
    value sexfmt
        1 = "Male"
        2 = "Female";
run;

data dummy;
    call streaminit(12345);
    do id = 1 to 10;
        /* Continuous */
        x01  = rand("Normal", 50, 10);

        /* Ordinal (Low / Medium / High) */
        ordinal1 = rand("Table", 0.3, 0.5, 0.2);

        /* Nominal (Male/Female) */
        nominal1 = rand("Table", 0.5, 0.5);
		nominal1c = put(nominal1,sexfmt.) ;

        output;
    end;

    format ordinal1 x11fmt. nominal1 sexfmt. ;
run;

%association_matrix(
    data      = dummy,
    continuous= x01,
    nominal   = nominal1c,
    ordinal   = ordinal1,
    method    = spearman,
    out = test
);

/*Compare*/
%mp_assertdataset(
  base			= expected,					/* parameter in proc compare */
  compare	= test,					/* parameter in proc compare */
  desc		=  (%nrstr(%association_matrix))[test01] Compare expected and test datasets of association matrix, 	/* description */
  id =,						/* parameter in proc compare(e.g. id=USUBJID) */
  by =,      	            /* parameter in proc compare(e.g. by=USUBJID VISIT) */
  criterion 	= 1e-4,       		/* parameter in proc compare */
  method 	= absolute,    /* parameter in proc compare */
  outds 		= TEMP.corr_test
);
