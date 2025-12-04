/*** HELP START ***//*
### Macro:
    %gtl_crosstable

### Purpose:
    Internal macro `gtl_crosstable` provides GTL-based graph or table generation for correlation or related visualizations.

---
Author:                 Ryo Nakaya
Latest udpate Date:     2025-12-04
---
*//*** HELP END ***/

%macro gtl_crosstable(x=, y=, value=);
  layout overlay /
      xaxisopts=(display=(ticks tickvalues) tickvalueattrs=(size=2))
      yaxisopts=(display=(ticks tickvalues) tickvalueattrs=(size=2));

    /* frame */
    heatmapparm x=&x y=&y colorresponse=count / 
        colormodel=(white white)
        outlineattrs=(color=black);

    /* text */
    textplot x=&x y=&y text=&value /
        position=center;
  endlayout;
%mend;

