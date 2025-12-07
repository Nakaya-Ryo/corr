/*** HELP START ***//*
### Macro:
    %gtl_mosaic

### Purpose:
    Internal macro `gtl_mosaic` provides GTL-based graph or table generation for correlation or related visualizations.

---
Author:                 Ryo Nakaya
Latest udpate Date:     2025-12-04
---
*//*** HELP END ***/

%macro gtl_mosaic(x=, y=, value=);/* It seems control of axis font size is difficult */
  layout region ;
    mosaicplotparm category=(&x &y) count=&value /*Variable for count*/
		/ display=(ticks values) ;
  endlayout;
%mend;
