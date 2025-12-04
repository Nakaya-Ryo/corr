/*** HELP START ***//*
### Macro:
    %gtl_ellipse

### Purpose:
    Internal macro `gtl_ellipse` provides GTL-based graph or table generation for correlation or related visualizations.

---
Author:                 Ryo Nakaya
Latest udpate Date:     2025-12-04
---
*//*** HELP END ***/

%macro gtl_ellipse(x=, y=, group=);
  layout overlay /
      xaxisopts=(label=" " tickvalueattrs=(size=2))
      yaxisopts=(label=" "  tickvalueattrs=(size=2));
    %if %length(&group)=0 %then %do;
      scatterplot x=&x y=&y;
      ellipse     x=&x y=&y / type=predicted;
    %end;
    %else %do;
      scatterplot x=&x y=&y / group=&group;
      ellipse     x=&x y=&y / group=&group type=predicted;
    %end;
  endlayout;
%mend;
