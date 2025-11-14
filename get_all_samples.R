library(dplyr)
samples <- scan("sample_list.txt", what = "character")
patterns <- paste0("^", samples, "_")
dirs <- list.files(include.dirs=TRUE)
dirnames <- unlist(sapply(patterns, FUN = function(x) grepv(x, dirs)))

df <- read.table(paste0(dirnames[1], "/quant.genes.sf"), header = TRUE) %>% .[, c(1,5)]
names(df)[2] <- samples[1]

for (idx in c(2:length(dirnames))) {
    quant_filename <- paste0(dirnames[idx], "/quant.genes.sf")
    sample_col <- read.table(quant_filename, header = TRUE) %>% .[,5]
    
    df <- cbind(df, new_col = sample_col)
    names(df)[idx+1] <- samples[idx]
}

head(df)

write.csv(df, "all_samples.csv", quote = FALSE, row.names = FALSE)
