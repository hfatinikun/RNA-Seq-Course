setwd("C:/Users/demil/OneDrive/Documents/MSc Bioinformatics and Computational Biology/Semester 1/RNA Seq/DeSeq Analysis")
source("utils.R")

# Load DESeq2 object
dds <- readRDS(DDS_FILE)

# Perform DE analysis
res <- results(dds, contrast = c("group", PAIR_INTEREST[1], PAIR_INTEREST[2]))

# Annotate results with gene symbols
res$geneName <- mapIds(org.Hs.eg.db,
                       keys = rownames(res),
                       column = "SYMBOL",
                       keytype = "ENSEMBL",
                       multiVals = "first")

# Save all DE results
save_DE_results(res, "results/DE_results_TNBC_vs_NonTNBC_full.csv")

# Filter significant genes (padj < 0.05)
res_sig <- filter_DE_genes(res)

# Save significant results
save_DE_results(res_sig, "results/DE_results_TNBC_vs_NonTNBC_sig.csv")

# Print summary
cat("Number of significant genes:", nrow(res_sig), "\n")
cat("Upregulated genes:", sum(res_sig$log2FoldChange > 0), "\n")
cat("Downregulated genes:", sum(res_sig$log2FoldChange < 0), "\n")

# Define genes of interest
top_genes <- head(rownames(res[order(res$padj), ]), 10) # Top genes with the lowest p-value
specific_genes <- rownames(res[res$geneName %in% c("SPARC", "RACK1", "APOE"), ]) # Manually chosen genes
genes_interest_ids <- unique(c(top_genes, specific_genes))

# Generate and display expression plots for genes of interest
counts_plots <- lapply(genes_interest_ids, generate_gene_counts_plot, dds = dds, res = res, pair_interest = PAIR_INTEREST)
grid.arrange(grobs = counts_plots, ncol = 2)

# Heatmap for selected genes
vsd_data <- vst(dds, blind = TRUE) # Variance-stabilized data
vsd_subset <- assay(vsd_data)[genes_interest_ids, ] # Subset for genes of interest
rownames(vsd_subset) <- res[genes_interest_ids, "geneName"]

# Column annotation for the heatmap
annotation_col <- data.frame(Group = colData(dds)[, "group"])
rownames(annotation_col) <- colnames(vsd_data)

# Generate and save heatmap
pheatmap(vsd_subset,
         cluster_rows = TRUE,
         show_rownames = TRUE,
         cluster_cols = TRUE,
         annotation_col = annotation_col,
         color = colorRampPalette(c("royalblue1", "ivory", "violetred"))(50),
         filename = "results/heatmap_TNBC_vs_NonTNBC.png")

cat("Heatmap saved to results/heatmap_TNBC_vs_NonTNBC.png\n")
print()