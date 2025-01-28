setwd("C:/Users/demil/OneDrive/Documents/MSc Bioinformatics and Computational Biology/Semester 1/RNA Seq/DeSeq Analysis")
source("utils.R")

# Load count data
counts <- read_featurecounts_table(COUNTS_FILE)

# Generate metadata
metadata <- generate_sample_metadata(counts)

# Create DESeq2 dataset
dds <- DESeqDataSetFromMatrix(countData = counts, colData = metadata, design = ~ group)

# Normalize data by running DESeq
dds <- DESeq(dds)

# Save the DESeq2 object
saveRDS(dds, DDS_FILE)