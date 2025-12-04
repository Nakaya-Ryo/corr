/*** HELP START ***//*
### Macro:
    %gtl_kernel

### Purpose:
    Internal macro `gtl_kernel` provides GTL-based graph or table generation for correlation or related visualizations.

---
Author:                 Ryo Nakaya 
Latest udpate Date:     2025-12-04
---
*//*** HELP END ***/

%macro gtl_kernel(var=, group=);
  layout overlay /
    xaxisopts=(label=" "  tickvalueattrs=(size=2))
    yaxisopts=(label=" "  tickvalueattrs=(size=2));
    %if %length(&group)=0 %then %do;
      densityplot &var / kernel() lineattrs=(thickness=1);
    %end;
    %else %do;
      densityplot &var / group=&group kernel() lineattrs=(thickness=1);
    %end;
  endlayout;
%mend;
