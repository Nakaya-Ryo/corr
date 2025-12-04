/*** HELP START ***//*

### Purpose:
- Unit test for the %scatter_matrix() macro

### Expected result:  
- TEMP.corr_test dataset will be created with test_result=CHECK

*//*** HELP END ***/

%loadPackage(valivali)
%set_tmp_lib(lib=TEMP, winpath=C:\Temp, otherpath=/tmp, newfolder=corr)

ods listing gpath="C:\Temp\SAS_PACKAGES\packages\corr\validation\output" ;
ods graphics / reset=all
                   imagename="scatter_matrix"
                   imagefmt=png
                   width=600px
                   height=600px;


/* Test data */
proc format ;
	value abc
	1 = "A" 
	2 = "B"
	3 = "C"
	;
	value lmh
	1 = "low"
	2 = "mid"
	3 = "high"
	;
run ;
data have;
  call streaminit(12345);
  do id = 1 to 100;

    /* Continuous */
    x1 = rand("Normal", 50, 10);
    x2 = 0.5 * x1 + rand("Normal", 0, 8);
    x3 = 0.3 * x1 + 0.4 * x2 + rand("Normal", 0, 12);

    /* Nominal : A/B/C */
    grpn = rand("Table", 0.3, 0.4, 0.3);
    length grp $1;
    if grpn = 1 then grp = "A";
    else if grpn = 2 then grp = "B";
    else grp = "C";

    /* Nominal2 : D/E/F */
    grpn2 = rand("Table", 0.2, 0.5, 0.3);
    length grp2 $1;
    if grpn2 = 1 then grp2 = "D";
    else if grpn2 = 2 then grp2 = "E";
    else grp2 = "F";

    /* Ordinal : Low/Mid/High */
    ordn = ceil(3 * rand("Uniform"));
    length ord $5;
    if ordn = 1 then ord = "Low";
    else if ordn = 2 then ord = "Mid";
    else ord = "High";

    output;
  end;
run;


/* Plot */
%scatter_matrix(data=have, continuous=x1 x2 x3, categorical=grpn ordn, group=grpn2);

/* Assert graph */
%mp_assertgraph(
  gpath2 = C:\Temp\SAS_PACKAGES\packages\corr\validation\output\scatter_matrix.png,
  desc   =  (%nrstr(%scatter_matrix))[test01] Creating a scatter_matrix plot with test data ,
  outds  = TEMP.corr_test
);
