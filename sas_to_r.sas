
/* Step 1: CSV into R */
proc iml;
/* Submit block to execute R code */
submit / R;

# Load the necessary library for reading CSV files
library(readr)

# Read the CSV file into an R dataframe
df <- read_csv('/nfsshare/sashls/custdata/PHUSE_HOW_2025/dm.csv')

# Print the dataframe
print(df)

# Save the R dataframe as an R object
saveRDS(df, file = "/nfsshare/sashls/custdata/PHUSE_HOW_2025/dm.RDS")

endsubmit;
quit;


/* Step 2: sasdataset into R */
proc iml;
/* Assume you have a SAS dataset named 'sas_dataset' */

/* Submit block to execute R code */
submit / R;
# Load the necessary library for saving R objects
library(haven)
#require(haven)

# Read SAS dataset into R
df <- read_sas('/nfsshare/sashls/custdata/PHUSE_HOW_2025/dm.sas7bdat')
print(df)

# Save the R dataframe as an RDS file
saveRDS(df, file = "/nfsshare/sashls/custdata/PHUSE_HOW_2025/dm.rds")

endsubmit;
quit;


/*Step 3*/
proc iml;
/* Assume you have a R dataframe */

/* Submit block to execute R code */
submit / R;

# Load the necessary library for reading CSV files
library(readr)

# Read the R dataframe from the R object file
df <- readRDS("/nfsshare/sashls/custdata/PHUSE_HOW_2025/dm.rds")

# Print the dataframe
print(df)

endsubmit;
quit;

