%* Define a SAS macro variable in SAS code;
%let language = 'python';

proc python;
submit;

print("Python in the SAS Log:")

# %*use symget to read a SAS macro variable into a python variable;
lang = SAS.symget('language')
ver = 3.8

# %* Submit SAS code inside python, using python syntax.  This dataset will live in WORK library;
SAS.submit("data work.test; language={}; version={}; run;".format(lang,ver))


# %* Execute SAS functions with sasfnc;
var3 = SAS.sasfnc("upcase","hello world")
print( var3)

# %*Use symput to assign the value of a Python variable to a SAS macro;
py_var = 'Inside python'
SAS.symput('macrovar', py_var)


endsubmit;
run;

%* Show that the SAS macro variable persists and is populated;
%put &=macrovar;


%* Show that the test dataset created in the python code lives in SAS;
proc print data=test;
run;

