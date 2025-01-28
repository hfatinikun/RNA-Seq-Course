#!/bin/bash

#SBATCH --mail-type=fail
#SBATCH --nodes=1
#SBATCH --cpus-per-task=4
#SBATCH --output=data/users/hfatinikun/output_%j.o
#SBATCH --error=data/users/hfatinikun/error_%j.o
#SBATCH --mail-user=heritage.fatinikun@students.unibe.ch
#SBATCH --time=13:00:00
#SBATCH --mem=4G
#SBATCH --partition=pibu_el8
#SBATCH --job-name="RNA Seq Count Reads "
#SBATCH --nodelist=binfservas13

#Define Variables
ANNOTATION_DIR='/data/users/hfatinikun/RNA-Seq-Course/Reference_genome/Homo_sapiens.GRCh38.113.gtf.gz'
BAM_DIR='/data/users/hfatinikun/RNA-Seq-Course/mapping/BAM_Files'
SAMPLELIST='/data/users/hfatinikun/RNA-Seq-Course/quality_checks/samplelist.txt'
COUNT_DIR='/data/users/hfatinikun/RNA-Seq-Course/counting'
APPTAINER_IMG='/containers/apptainer/subread_2.0.1--hed695b0_0.sif'

#Create the file for the result 
mkdir -p $(dirname $COUNT_DIR)

# Create a list of BAM file paths by combining the BAM directory, sample name, and the .bam extension
BAM_FILES_LIST=$(awk -v dir="$BAM_DIR" '{print dir "/" $1 ".bam"}' $SAMPLELIST)


#Use featureCounts to create a table of the read count per gene with the list of bam files
#apptainer exec --bind $BAM_DIR,$(dirname $COUNT_DIR),$(dirname $ANNOTATION_DIR) $APPTAINER_IMG featureCounts -T 4 -a $ANNOTATION_DIR -o $COUNT_DIR $BAM_FILES_LIST


# Use featureCounts to create a table of the read count per gene with the list of BAM files
#The -p option is used to indicate that the input data contains paired-end reads.
#The -Q option sets the mapping quality threshold.
#If the script parameter is "multi", multi-mapped reads will be included in the count.
#The -M option takes multi-mapped reads into account.
#The --fraction option counts multi-mapped reads fractionally hence if a read is mapped twice, 1 count will be 0.5
if [ "$1" == "multi" ]; then
    echo "Taking multi-mapped reads into account" >&2
    results_file=$COUNT_DIR/gene_counts_multi_table.txt
    apptainer exec --bind $BAM_DIR,$(dirname $COUNT_DIR),$(dirname $ANNOTATION_DIR) $APPTAINER_IMG featureCounts -M --fraction -p -Q 10 -T 4 -a $ANNOTATION_DIR -o $results_file $BAM_FILES_LIST
else
    results_file=$COUNT_DIR/gene_counts_table.txt
    apptainer exec --bind $BAM_DIR,$(dirname $COUNT_DIR),$(dirname $ANNOTATION_DIR) $APPTAINER_IMG featureCounts -p -Q 10 -T 4 -a $ANNOTATION_DIR -o $results_file $BAM_FILES_LIST
fi