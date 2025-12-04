/*** HELP START ***//*

### Purpose:
- Unit test for the %heatmap() macro

### Expected result:  
- TEMP.corr_test dataset will be created with test_result=CHECK

*//*** HELP END ***/

%loadPackage(valivali)
%set_tmp_lib(lib=TEMP, winpath=C:\Temp, otherpath=/tmp, newfolder=corr)

ods listing gpath="C:\Temp\SAS_PACKAGES\packages\corr\validation\output";
ods graphics / reset=all
                   imagename="heatmap"
                   imagefmt=png
                   width=600px
                   height=600px;

/* Test Dataset */
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

/* Plot */
%heatmap(
    data			= dummy,
    continuous	= x01,
    nominal		= nominal1c,
    ordinal		= ordinal1,
    method		= spearman,
	text			= Y,
    out			= test
);

/* Assert graph */
%mp_assertgraph(
  gpath2 = C:\Temp\SAS_PACKAGES\packages\corr\validation\output\heatmap.png,
  desc   =  (%nrstr(%heatmap))[test01] Creating a heatmap with test data ,
  outds  = TEMP.corr_test
);
