#!/bin/bash
#SBATCH --array=1-12
#SBATCH --mail-type=fail
#SBATCH --nodes=1
#SBATCH --cpus-per-task=4
#SBATCH --output=data/users/hfatinikun/output_%j.o
#SBATCH --error=data/users/hfatinikun/error_%j.o
#SBATCH --mail-user=heritage.fatinikun@students.unibe.ch
#SBATCH --time=3:00:00
#SBATCH --mem=2G
#SBATCH --partition=pibu_el8
#SBATCH --job-name="RNA Seq FastQC Array"

#Assign paths to variables
WORKDIR="/data/users/hfatinikun/RNA-Seq-Course/quality_checks/"
OUTDIR="$WORKDIR"
SAMPLELIST="$WORKDIR/samplelist.txt"

#Paths to the Reads samplenames
SAMPLE=`awk -v line=$SLURM_ARRAY_TASK_ID 'NR==line{print $1; exit}' $SAMPLELIST`
READ1=`awk -v line=$SLURM_ARRAY_TASK_ID 'NR==line{print $2; exit}' $SAMPLELIST`
READ2=`awk -v line=$SLURM_ARRAY_TASK_ID 'NR==line{print $3; exit}' $SAMPLELIST`

#Quality control output
OUTFILE="$OUTDIR/${SAMPLE}"

############################

#Make directories for results
mkdir -p $OUTFILE

#Load the modules
module load FastQC/0.11.9-Java-11

#Run FastQC on two input files
fastqc $READ1 $READ2 -o $OUTFILE