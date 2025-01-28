#!/bin/bash

#SBATCH --mail-type=fail
#SBATCH --nodes=1
#SBATCH --cpus-per-task=4
#SBATCH --output=data/users/hfatinikun/output_%j.o
#SBATCH --error=data/users/hfatinikun/error_%j.o
#SBATCH --mail-user=heritage.fatinikun@students.unibe.ch
#SBATCH --time=13:00:00
#SBATCH --mem=8G
#SBATCH --partition=pibu_el8
#SBATCH --job-name="RNA Seq Download and Index Ref Genome "

#Define Variables
REF_GENOME_LINK='https://ftp.ensembl.org/pub/release-113/fasta/homo_sapiens/dna/Homo_sapiens.GRCh38.dna.primary_assembly.fa.gz'
REF_ANNOTATION_LINK='https://ftp.ensembl.org/pub/release-113/gtf/homo_sapiens/Homo_sapiens.GRCh38.113.gtf.gz'
REFERENCE_DIR='/data/users/hfatinikun/RNA-Seq-Course/Reference_genome'
HISAT2_IMG='/containers/apptainer/hisat2_samtools_408dfd02f175cd88.sif'
GENOME_CHECKSUM_LINK='https://ftp.ensembl.org/pub/release-113/fasta/homo_sapiens/dna/CHECKSUMS'
ANNOTATION_CHECKSUM_LINK='https://ftp.ensembl.org/pub/release-113/gtf/homo_sapiens/CHECKSUMS'

#Extract filename by removing the path
reference_genome=$(basename $REF_GENOME_LINK)
reference_annotation=$(basename $REF_ANNOTATION_LINK)

#Create diectory for Reference genome and indexes
mkdir -p $REFERENCE_DIR
cd $REFERENCE_DIR

#Download the latest reference genome and associated annotation from the Ensembl ftp site
wget $REF_GENOME_LINK
wget $REF_ANNOTATION_LINK 

# Download checksum file without saving it, get the line corresponding to the files we use, and keep the 2 first columns
genome_expected_checksum=$(wget -O - $GENOME_CHECKSUM_LINK | grep $reference_genome | awk '{print $1,$2}')
annotation_expected_checksum=$(wget -O - $ANNOTATION_CHECKSUM_LINK | grep $reference_annotation | awk '{print $1,$2}')

# Testing if checksums calculated on downloaded files are as expected
if [ "$genome_expected_checksum" != "$(sum $reference_genome)" ] || [ "$annotation_expected_checksum" != "$(sum $reference_annotation)" ]; then 
    # throw an error and exit
    echo "Checksums are not as expected !">&2
    rm $reference_genome
    rm $reference_annotation 
    exit 1
fi

# Unzipping the reference genome
if [[ "$reference_genome" == *.gz ]]
then
    echo "Unzipping the reference genome..."
    gunzip $reference_genome
    reference_genome=${reference_genome%.*} # After unzipping, remove the .gz extension from the file name
fi

# Indexing the reference genome
apptainer exec --bind /data/ $HISAT2_IMG hisat2-build $REFERENCE_DIR/$reference_genome $REFERENCE_DIR/genome_index

echo "RNA Seq reference genome preparation complete."