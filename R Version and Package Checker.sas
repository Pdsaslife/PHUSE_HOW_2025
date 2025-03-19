/*  

R_Test.SAS
MAR 10 2025

Runs a linear regression model using two separate profiles of R (4.2.3 and 4.3.3) 
and SAS9.4 on the same platform using SASHELP.HEART data on smokers to
predict Systolic blood pressure from height and weight of participants.  Prints 
estimates from each run.  

This program is intended for demonstration purposes only and is not intended
to verify or validate the computational accuracy of different versions of R or
of either R version and SAS9.4.

*/ 


/*  Identify the locations of the R environments, given by the admin */

%LET R0 = default_r;
%LET R1 =r433;


/* Use the DEFAULT R BASE 4.2.3 (note:  Any version can be set to DEFAULT */
options set=R_HOME="/opt/sas/viya/home/sas-pyconfig/&R0./lib64/R";

/*Get information about the packages */
proc iml;
    submit / R;
      ver = R.version.string
      vdf = data.frame(version = ver)
      pkg = installed.packages()[,c(1,3)]
    endsubmit;
call ImportDataSetFromR("R0_pkg", "pkg");
call ImportDataSetFromR("R0_ver", "vdf");
quit;

data _null_;
set R0_ver;
CALL SYMPUTX("V0",version);
RUN;



/* Run a linear model */

title "Linear Model Using &R0 Environment: &V0";
proc iml;
  * Uses a built-in IML function to read SAS data set into R data frame;	
  call ExportDataSetToR("Sashelp.heart", "dframe" );
  submit / R;
		model423=lm(Systolic ~ Height + Weight, data=dframe)
		summary(model423)
  endsubmit;
quit;


/* Use a second R profilt BASE 4.3.3 */
options set=R_HOME="/opt/sas/viya/home/sas-pyconfig/&R1./lib64/R";
/*Get information about the packages */
proc iml;
    submit / R;
      ver = R.version.string
      vdf = data.frame(version = ver)
      pkg = installed.packages()[,c(1,3)]
      
    endsubmit;
call ImportDataSetFromR("R1_pkg", "pkg");
call ImportDataSetFromR("R1_ver", "vdf");
quit;

data _null_;
set R1_ver;
CALL SYMPUTX("V1",version);
RUN;



/* Run a linear model */

title "Linear Model Using &R1 Environment: &V1";
proc iml;
  call ExportDataSetToR("Sashelp.Heart", "dframe" );
  submit / R;
		model433=lm(Systolic ~ Height + Weight, data=dframe)
		summary(model433)
  endsubmit;
quit;


/* Run the model in SAS */

options nocenter;
title 'Linear Model Using SAS9.4';
ods html;
ods select ParameterEstimates;  * print only the parameter estimates;
proc glm data = sashelp.heart;
	model Systolic = Height Weight;
run;
quit;
ods html close;

/* Do a package Comparison */

TITLE "Package Comparison of Environemnts";
TITLE2 "&R0 on &V0";
TITLE3 "&R1 on &V1";


PROC SQL;
CREATE TABLE PKGS AS
SELECT COALESCE(R0.package, R1.package) AS Package "R Package"
       , R0.VERSION AS R0_VERSION "&R0 Environment"
       , R1.VERSION AS R1_VERSION "&R1 Environment"
       
FROM R0_PKG as R0 FULL JOIN R1_PKG as R1
ON R0.Package = R1.Package;
QUIT;

data packages;
set PKGS;
  IF R0_VERSION = "" or R1_VERSION  = "" then Status = "Singular ";
   ELSE IF R0_VERSION = R1_VERSION then Status = "Same     ";
    ELSE IF R0_VERSION NE R1_VERSION then Status = "Different";
RUN;

PROC SQL;
SELECT * FROM PACKAGES;
QUIT;

%MACRO Move_to_CAS (saslib,sasname,caslib,casname);
proc casutil;
	droptable casdata="&casname" incaslib="&caslib" quiet;
	load data=&saslib..&sasname outcaslib="&caslib"
	casout="&casname" replace;
    promote incaslib="&caslib" casdata="&casname" outcaslib="&caslib";
run;

%MEND;

%Move_to_CAS(work,packages,public,R_Packages);



