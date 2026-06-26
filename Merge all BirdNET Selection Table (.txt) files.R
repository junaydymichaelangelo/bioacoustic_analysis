###############################################################
# Merge all BirdNET Selection Table (.txt) files
# Author : ChatGPT
# Purpose: Safely merge all BirdNET selection tables
###############################################################

# =============================================================
# Load required packages
# =============================================================
library(readr)
library(dplyr)
library(purrr)

# =============================================================
# Set main folder
# Change ONLY this path when using another dataset
# =============================================================
main_folder <- "D:/BIOAKUSTIKA/DETECTOR SPECIES/4_OUTPUT/SUAQ BALIMBING/LARGIBBON"

# =============================================================
# Find all BirdNET selection table files recursively
# =============================================================
birdnet_files <- list.files(
  path = main_folder,
  pattern = "\\.BirdNET\\.selection\\.table\\.txt$",
  recursive = TRUE,
  full.names = TRUE
)

cat("=====================================\n")
cat("BirdNET Merge Tool\n")
cat("=====================================\n")
cat("Files found :", length(birdnet_files), "\n\n")

if(length(birdnet_files) == 0){
  stop("No BirdNET selection table files were found.")
}

# =============================================================
# Function to safely read a file
# =============================================================
read_birdnet <- function(file){
  
  # Skip empty files
  if(file.info(file)$size == 0){
    
    message("Skipped empty file: ", basename(file))
    return(NULL)
    
  }
  
  # Read file safely
  df <- tryCatch({
    
    read.delim(
      file,
      header = TRUE,
      sep = "\t",
      stringsAsFactors = FALSE,
      check.names = FALSE
    )
    
  }, error = function(e){
    
    message("Failed to read: ", basename(file))
    return(NULL)
    
  })
  
  if(is.null(df)) return(NULL)
  
  # Add source file information
  df$Source_File <- basename(file)
  df$Source_Path <- file
  
  return(df)
}

# =============================================================
# Read every file
# =============================================================
birdnet_data <- lapply(birdnet_files, read_birdnet)

# Remove failed files
birdnet_data <- birdnet_data[!sapply(birdnet_data, is.null)]

cat("Files successfully read :", length(birdnet_data), "\n\n")

# =============================================================
# Check column consistency
# =============================================================
column_lists <- lapply(birdnet_data, names)

reference_columns <- column_lists[[1]]

different_structure <- which(
  !sapply(column_lists, identical, reference_columns)
)

if(length(different_structure) == 0){
  
  cat("✓ All files have identical columns.\n\n")
  
}else{
  
  cat("WARNING:\n")
  cat(length(different_structure),
      "file(s) have different column structures.\n")
  cat("Missing columns will be filled with NA.\n\n")
  
}

# =============================================================
# Merge all files
# bind_rows automatically aligns columns
# =============================================================
merged_data <- bind_rows(birdnet_data)

# =============================================================
# Save output
# =============================================================
output_file <- file.path(
  main_folder,
  "Merged_BirdNET_Selection_Table.csv"
)

write.csv(
  merged_data,
  output_file,
  row.names = FALSE
)

# =============================================================
# Summary
# =============================================================
cat("=====================================\n")
cat("Merge completed successfully!\n")
cat("=====================================\n")

cat("Files found        :", length(birdnet_files), "\n")
cat("Files merged       :", length(birdnet_data), "\n")
cat("Rows merged        :", nrow(merged_data), "\n")
cat("Columns            :", ncol(merged_data), "\n")
cat("\nOutput saved to:\n")
cat(output_file, "\n")

