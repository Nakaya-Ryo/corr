/*** HELP START ***//*
### Macro:
    %gtl_bar

### Purpose:
    Internal macro `gtl_bar` provides GTL-based graph or table generation for correlation or related visualizations.

---
Author:                 Ryo Nakaya
Latest udpate Date:     2025-12-04
---
*//*** HELP END ***/

%macro gtl_bar(var=, group=);
  layout overlay /
      xaxisopts=(display=(ticks tickvalues) tickvalueattrs=(size=2) label=" ")
      yaxisopts=(display=(ticks tickvalues) tickvalueattrs=(size=2) label=" ");
    %if %length(&group)=0 %then %do;
      barchart category=&var / stat=pct orient=horizontal;
    %end;
    %else %do;
      barchart category=&var / stat=pct orient=horizontal group=&group;
    %end;
  endlayout;
%mend;
