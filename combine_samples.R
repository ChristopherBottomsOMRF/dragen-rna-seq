#!/bin/env -S Rscript --vanilla
library(dplyr) # make pipe %>% available

# Read in arguments from the command line, starting after this script's name
args <- commandArgs(trailingOnly = TRUE)

sample_list_filename <- args[1]  # e.g., samples.txt
symbols_for <- read.csv(args[2]) # e.g., gencode.v44.annotation.gene_name_mapping_no_dups.csv

# Get list of samples
samples <- scan(sample_list_filename, what = "character")

# Search pattern for matching directories: anchor to the left, sample name, underscore
patterns <- paste0("^", samples, "_")

# List all files, including directories
dirs <- list.files(include.dirs=TRUE)

# Just keep the ones that match the specified patterns
dirnames <- unlist(sapply(patterns, FUN = function(x) grepv(x, dirs)))

# Bail out if something else is in there
if (! length(samples) == length(dirnames)) {
    message(paste0("There are ", length(samples), " sample names, but ", length(dirnames), " directory names"))
    message("Those should be the same lengths")
    message("Sample names:")
    message(paste0(samples, collapse = ", "))
    message("Directory names: ")
    message(paste0(dirnames, collapse = ", "))
    q("no")
}

# Create initial dataframe with gene ID and counts for first sample
df <- read.table(paste0(dirnames[1], "/quant.genes.sf"), header = TRUE) %>% .[, c(1,5)]

names(df)[2] <- samples[1]

# It's Salmon output, so it's not necessary integers, but they will be now.
df[2] <- df[2] %>% round()

for (idx in c(2:length(dirnames))) {
    quant_filename <- paste0(dirnames[idx], "/quant.genes.sf")
    sample_col <- read.table(quant_filename, header = TRUE) %>% .[,5] %>% round()
    
    df <- cbind(df, new_col = sample_col)
    names(df)[idx+1] <- samples[idx]
}

df <- df %>%
      rename(gene_id = Name) %>%
      left_join(symbols_for, by = "gene_id") %>%
      relocate(gene_symbol, .after = gene_id)

write.csv(df, "all_samples.csv", quote = FALSE, row.names = FALSE)
