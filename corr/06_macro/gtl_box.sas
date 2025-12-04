/*** HELP START ***//*
### Macro:
    %gtl_box

### Purpose:
    Internal macro `gtl_box` provides GTL-based graph or table generation for correlation or related visualizations.

---
Author:                 Ryo Nakaya
Latest udpate Date:     2025-12-04
---
*//*** HELP END ***/

%macro gtl_box(x=, y=);
  layout overlay /
      xaxisopts=(display=(ticks tickvalues) label=" " tickvalueattrs=(size=2))
      yaxisopts=(display=(ticks tickvalues) label=" " tickvalueattrs=(size=2));
      boxplot x=&x y=&y / display=(caps mean median) ;
  endlayout;
%mend;
