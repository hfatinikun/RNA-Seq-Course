setwd("C:/Users/demil/OneDrive/Documents/MSc Bioinformatics and Computational Biology/Semester 1/RNA Seq/DeSeq Analysis")
source("utils.R")

# Load DE results
res_sig <- read.csv("results/DE_results_TNBC_vs_NonTNBC_sig.csv", row.names = 1)

# Perform GO enrichment
ego <- enrichGO(gene = rownames(res_sig), 
                universe = rownames(read_featurecounts_table(COUNTS_FILE)),
                OrgDb = org.Hs.eg.db, 
                ont = "BP", 
                keyType = "ENSEMBL")

# Save GO results
write.csv(as.data.frame(ego), "results/GO_results_TNBC_vs_NonTNBC.csv")

# Plot GO results
# Visualization: Bar Plot
barplot(ego, showCategory = 15, title = "Top 15 GO Terms (Bar Plot)")

# Visualization: Dot Plot
dotplot(ego, showCategory = 15, title = "Top 15 GO Terms (Dot Plot)")

# Cnetplot (Category Network Plot)
cnetplot(
  ego,
  categorySize = "pvalue",
  showCategory = 10,
  title = "GO Terms and Genes (Network Plot)",
  max.overlaps = 100 # Increase to avoid warnings
)

ego_termsim <- pairwise_termsim(ego)

# Tree Plot
treeplot(
  ego_termsim,
  hclust_method = "average",
  title = "GO Terms Clustering (Tree Plot)"
)
