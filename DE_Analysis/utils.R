# Install required packages if not already installed
if (!requireNamespace("BiocManager", quietly = TRUE)) install.packages("BiocManager")
if (!requireNamespace("DESeq2", quietly = TRUE)) BiocManager::install("DESeq2")
if (!requireNamespace("org.Hs.eg.db", quietly = TRUE)) BiocManager::install("org.Hs.eg.db")
if (!requireNamespace("clusterProfiler", quietly = TRUE)) BiocManager::install("clusterProfiler")
if (!requireNamespace("enrichplot", quietly = TRUE)) BiocManager::install("enrichplot")
if (!requireNamespace("pheatmap", quietly = TRUE)) install.packages("pheatmap")
if (!requireNamespace("ggplot2", quietly = TRUE)) install.packages("ggplot2")
if (!requireNamespace("gridExtra", quietly = TRUE)) install.packages("gridExtra")

# Load commonly used libraries
library(DESeq2)
library(org.Hs.eg.db)
library(clusterProfiler)
library(enrichplot)
library(pheatmap)
library(ggplot2)
library(gridExtra)
library(stringr)

# ------ Constants ------
COUNTS_FILE <- "gene_count_table.txt"
DDS_FILE <- "results/dds.rds"
PAIR_INTEREST <- c("TNBC", "NonTNBC")

# ------ Functions ------

# Read and preprocess count table
read_featurecounts_table <- function(path) {
  # Read the count table
  counts <- read.table(path, header = TRUE, row.names = 1)
  # Select columns with sample-specific data (.bam files)
  counts <- counts[, grep("\\.bam$", colnames(counts))]
  # Extract sample names from column names (removing .bam suffix)
  colnames(counts) <- ifelse(
    is.na(str_extract(colnames(counts), "(?<=BAM_Files\\.)[^\\.]+")),
    colnames(counts),  # Keep original name if pattern doesn't match
    str_extract(colnames(counts), "(?<=BAM_Files\\.)[^\\.]+")
  )
  # Remove rows with missing values
  counts <- na.omit(counts)
  return(counts)
}

# Generate metadata for samples
generate_sample_metadata <- function(counts) {
  group <- rep(c("HER2", "NonTNBC", "Normal", "TNBC"), each = 3)
  return(data.frame(group = group, row.names = colnames(counts)))
}

# Filter significant DE genes based on adjusted p-value threshold
filter_DE_genes <- function(res, padj_threshold = 0.05) {
  return(res[!is.na(res$padj) & res$padj < padj_threshold, ])
}

# Custom PCA plot
custom_pca_plot <- function(pca_data, title) {
  percents <- round(100 * attr(pca_data, "percentVar"))
  plot <- ggplot(pca_data, aes(PC1, PC2, color = group)) +
    geom_point(size = 3) +
    labs(title = title) +
    xlab(paste0("PC1: ", percents[1], "% variance")) +
    ylab(paste0("PC2: ", percents[2], "% variance")) +
    theme_minimal()
  return(plot)
}

# Save DE results to a file
save_DE_results <- function(res, filename) {
  write.csv(res, filename, row.names = TRUE)
}

# Generate expression plot for a specific gene
generate_gene_counts_plot <- function(gene_id, dds, res, pair_interest = c()) {
  gene_name <- res[gene_id, "geneName"] # Retrieve gene name
  plot_data <- plotCounts(dds, gene = gene_id, intgroup = "group", returnData = TRUE)
  
  # Filter data for groups of interest
  if (length(pair_interest) > 0) {
    plot_data <- plot_data[plot_data$group %in% pair_interest, ]
  }
  
  # Create ggplot for the gene
  return(
    ggplot(plot_data, aes(x = group, y = count)) +
      geom_point(position = position_jitter(width = 0.1, height = 0)) +
      labs(title = gene_name) +
      xlab("Group") +
      ylab("Normalized Counts") +
      theme_minimal()
  )
}