setwd("C:/Users/demil/OneDrive/Documents/MSc Bioinformatics and Computational Biology/Semester 1/RNA Seq/DeSeq Analysis")
source("utils.R")

# Load DESeq2 object
dds <- readRDS(DDS_FILE)

# Variance-stabilizing transformation
vst_data <- vst(dds, blind = TRUE)

# PCA plot
pca_data <- plotPCA(vst_data, intgroup = "group", returnData = TRUE)

# Custom PCA plot using ggplot function
pca_plot <- custom_pca_plot(pca_data, "PCA - Gene Expression")

# Display the PCA plot
print(pca_plot)
