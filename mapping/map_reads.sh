#!/bin/bash

#SBATCH --array=1-12
#SBATCH --mail-type=fail
#SBATCH --nodes=1
#SBATCH --cpus-per-task=8
#SBATCH --output=data/users/hfatinikun/output_%j.o
#SBATCH --error=data/users/hfatinikun/error_%j.o
#SBATCH --mail-user=heritage.fatinikun@students.unibe.ch
#SBATCH --time=13:00:00
#SBATCH --mem=64G
#SBATCH --partition=pibu_el8
#SBATCH --job-name="RNA Seq Mapping Reads"

#Define Variables
SAMPLELIST='/data/users/hfatinikun/RNA-Seq-Course/quality_checks/samplelist.txt'
APPTAINER_IMG='/containers/apptainer/hisat2_samtools_408dfd02f175cd88.sif'
INDEX_BASENAME='/data/users/hfatinikun/RNA-Seq-Course/Reference_genome/genome_index'
INDEX_DIR='/data/users/hfatinikun/RNA-Seq-Course/Reference_genome'
READS_DIR="/data/courses/rnaseq_course/breastcancer_de/reads"
MAPPED_READS='/data/users/hfatinikun/RNA-Seq-Course/mapping' #Path to save mapped reads

#Paths to the Reads samplenames for the mapping
SAMPLE=`awk -v line=$SLURM_ARRAY_TASK_ID 'NR==line{print $1; exit}' $SAMPLELIST`
READ1=`awk -v line=$SLURM_ARRAY_TASK_ID 'NR==line{print $2; exit}' $SAMPLELIST`
READ2=`awk -v line=$SLURM_ARRAY_TASK_ID 'NR==line{print $3; exit}' $SAMPLELIST`

#Map reads
apptainer exec --bind /data/ $APPTAINER_IMG hisat2 -x $INDEX_BASENAME -1 $READ1 -2 $READ2 -S $MAPPED_READS/$SAMPLE.sam -p 4

BAM_DIR='/data/users/hfatinikun/RNA-Seq-Course/mapping/BAM_Files'
mkdir -p $BAM_DIR

echo "Converting SAM to BAM for $SAMPLE">&2
#Convert SAM to BAM
apptainer exec --bind /data/ $APPTAINER_IMG samtools view -hbS $MAPPED_READS/$SAMPLE.sam > $BAM_DIR/$SAMPLE"_unsorted.bam"

echo "Sorting bam file for $SAMPLE">&2
#Sorting the BAM Files
apptainer exec --bind /data/ $APPTAINER_IMG samtools sort -m 35G -@ 4 -o $BAM_DIR/$SAMPLE.bam -T temp $BAM_DIR/$SAMPLE"_unsorted.bam"

echo "Indexing $SAMPLE.bam">&2
#Indexing the sorted BAM Files
apptainer exec --bind /data/ $APPTAINER_IMG samtools index $BAM_DIR/$SAMPLE.bam

echo "Mapping of read completed"