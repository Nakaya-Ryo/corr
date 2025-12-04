/*** HELP START ***//*
### Macro:
    %gtl_reg

### Purpose:
    Internal Macro `gtl_reg` provides GTL-based graph or table generation for correlation or related visualizations.

---
Author:                 Ryo Nakaya
Latest udpate Date:     2025-12-04
---
*//*** HELP END ***/

%macro gtl_reg(x=, y=, group=);
  layout overlay /
      xaxisopts=(display=(ticks tickvalues) label=" " tickvalueattrs=(size=2))
      yaxisopts=(display=(ticks tickvalues) label=" " tickvalueattrs=(size=2));
    %if %length(&group)=0 %then %do;
      scatterplot   x=&x y=&y;
      regressionplot x=&x y=&y / degree=1;
    %end;
    %else %do;
      scatterplot   x=&x y=&y / group=&group;
      regressionplot x=&x y=&y / degree=1 group=&group;
    %end;
  endlayout;
%mend;
