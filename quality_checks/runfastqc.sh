#!/bin/bash
#SBATCH --mail-type=fail
#SBATCH --nodes=1
#SBATCH --cpus-per-task=8
#SBATCH --output=data/users/hfatinikun/output_%j.o
#SBATCH --error=data/users/hfatinikun/error_%j.o
#SBATCH --mail-user=heritage.fatinikun@students.unibe.ch
#SBATCH --time=36:00:00
#SBATCH --mem=20G
#SBATCH --partition=pibu_el8
#SBATCH --job-name="RNASeq FastQC"
#SBATCH --time=02:00:00
#SBATCH --mem-per-cpu=20G

load module apptainer

INPUT_DIR="/data/courses/rnaseq_course/breastcancer_de/reads/*.fastq.gz"
OUTPUT_DIR="/data/users/hfatinikun/RNA-Seq-Course/quality_checks/"

apptainer exec /containers/apptainer/fastqc-0.12.1.sif fastqc -o $OUTPUT_DIR $INPUT_DIR

