/*** HELP START ***//*

### Purpose:
- Create validation report using %create_report()

*//*** HELP END ***/

%loadPackage(valivali)
%set_tmp_lib(lib=TEMP, winpath=C:\Temp, otherpath=/tmp, newfolder=corr)

/*Create report*/
%create_report(
  sourcelocation = C:\Temp\SAS_PACKAGES\packages\corr,  /* for package information */
  reporter = Ryo Nakaya,

  general = %nrstr(
Corr package provides macros for computing association measures between continuous, nominal,
and ordinal variables. Supports Pearson and Spearman correlations, Cramer's V, Somers' D, and eta
coefficients. Outputs both long-format association tables and wide matrix-style datasets for
further analysis. Includes a heatmap macro to visualize the strength and type of associations in
a single plot.
  ),  /* for general description of package */

  requirements = %nrstr(
- %association_matrix	:  ^{newline}
  To generate association matrix dataset (long, wide). Association matrix consists of correlation coefficients for
  continuous/ordinal x continuous/ordinal, Cramer's V for nominal x nominal, Somer's D for nominal x ordinal,
  Eta coefficients for nominal x continuous.   ^{newline}^{newline}
- %heatmap :  ^{newline}
  To generate heatmap based on association matrix dataset created by %association_matrix within heatmap macro.  
  ^{newline}^{newline}
- %scatter_matrix :  ^{newline}
  To generate scatter matrix plot (Kernel, Bar, Scatter, Mosaic, Cross Table, Box)    
  ),
  results = TEMP.corr_test, /* validation results dataset */
  additional = %nrstr(
	NA
  ),  /* Any additional information */
  references = %nrstr(
	https://github.com/Nakaya-Ryo/corr
  ),  /* reference information */
  outfilelocation = C:\Temp\SAS_PACKAGES\packages\corr\validation  /* location for output RTF */
) ;
