#!/usr/bin/bash -l 

# Remove possible old result file
rm -f all_samples.w_gene_symbols.csv

# Load slurm and R modules
module load slurm
module load R/4.5.1-mkl

# Run test
sbatch --wait ../combine_samples.R samples.txt refs/gencode.v44.annotation.gene_name_mapping_no_dups.csv

# compare result to expected
md5sum all_samples.w_gene_symbols.csv expected/all_samples.w_gene_symbols.csv
