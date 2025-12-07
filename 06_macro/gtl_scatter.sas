/*** HELP START ***//*
### Macro:
    %gtl_scatter

### Purpose:
    Internal macro `gtl_scatter` provides GTL-based graph or table generation for correlation or related visualizations.

---
Author:                 Ryo Nakaya
Latest udpate Date:     2025-12-04
---
*//*** HELP END ***/

%macro gtl_scatter(x=, y=, group=);
  layout overlay /
      xaxisopts=(type=discrete label=" " tickvalueattrs=(size=2))
      yaxisopts=(label=" " tickvalueattrs=(size=2));
    %if %length(&group)=0 %then %do;
      scatterplot x=&x y=&y;
    %end;
    %else %do;
      scatterplot x=&x y=&y / group=&group;
    %end;
  endlayout;
%mend;
