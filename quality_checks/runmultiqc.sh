#!/bin/bash
#SBATCH --mail-type=fail
#SBATCH --nodes=1
#SBATCH --cpus-per-task=4
#SBATCH --output=data/users/hfatinikun/output_%j.o
#SBATCH --error=data/users/hfatinikun/error_%j.o
#SBATCH --mail-user=heritage.fatinikun@students.unibe.ch
#SBATCH --time=2:00:00
#SBATCH --mem=2G
#SBATCH --partition=pibu_el8
#SBATCH --job-name="RNA Seq Multiqc"

# Assign paths to variables
WORKDIR="/data/users/hfatinikun/RNA-Seq-Course/quality_checks/"
OUTDIR="$WORKDIR/multiqc_report/"
MULTIQC_IMG="/containers/apptainer/multiqc-1.19.sif"

# Create output directory
mkdir -p $OUTDIR

# Run MultiQC
apptainer $MULTIQC_IMG $WORKDIR -o $OUTDIR
apptainer exec $MULTIQC_IMG multiqc $WORKDIR -o $OUTDIR
