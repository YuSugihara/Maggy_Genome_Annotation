
# Running Helixer
FASTA_FILES=`find /home/sugihara/Desktop/genome/Frozen_assemblies/*.fa`
for FASTA_FILE in $FASTA_FILES
do
PREFIX=`basename $FASTA_FILE .fa`
singularity run --nv helixer-docker_helixer_v0.3.2_cuda_11.8.0-cudnn8.sif  \
Helixer.py --model-filepath ~/.local/share/Helixer/models/fungi/fungi_v0.3_a_0300.h5 \
           --subsequence-length 21384 \
           --overlap-offset 10692 \
           --overlap-core-length 16038 \
           --species Helixer \
           --fasta-path $FASTA_FILE \
           --gff-output-path ${PREFIX}_Helixer.gff \
           > ${PREFIX}_Helixer.log
done


# Extracting transcriptomes and proteomes from Helixer annotation
function get_helixer_fasta () {
  PREFIX=`basename $1 .fa`
  echo ${PREFIX}
  gffread -y ./Helixer/00_raw/Proteomes/${PREFIX}_Helixer.protein.fa \
          -g ./Frozen_assemblies/${PREFIX}.fa \
          ./Helixer/00_raw/GFF/${PREFIX}_Helixer.gff
  gffread -x ./Helixer/00_raw/Transcriptomes/${PREFIX}_Helixer.cds.fa \
          -g ./Frozen_assemblies/${PREFIX}.fa \
          ./Helixer/00_raw/GFF/${PREFIX}_Helixer.gff
}

export -f get_helixer_fasta

find ./Frozen_assemblies/*.fa | \
xargs -P 4 -I"%" bash -c "get_helixer_fasta %"


# Filter Helixer annotation
function filter_helixer_annotation () {
  PREFIX=`basename $1 .fa`
  echo ${PREFIX}
  ./00_filter_helixer_annotation.py ./Helixer/00_raw/GFF/${PREFIX}_Helixer.gff \
                                    ./Helixer/00_raw/Secretomes/${PREFIX}_Helixer_secretome.fa \
                                    2,3,4,6,11 \
                                    1> ./Helixer/10_gff_qc/${PREFIX}.helixer_pre_qc.gff \
                                    2> ./Helixer/10_gff_qc/${PREFIX}.helixer_pre_qc.txt

  grep 'secreted' ./Helixer/10_gff_qc/${PREFIX}.helixer_pre_qc.gff | \
  grep -v 'shorter_than_3bp' | \
  grep -v 'five_prime_UTR' | \
  grep -v 'three_prime_UTR' | \
  grep -v 'exon' | \
  cut -f 1-9 > \
  ./Helixer/20_filtered/GFF/${PREFIX}.helixer_pre_qc.secretome_filtered.gff

  gffread -y ./Helixer/20_filtered/Secretomes/${PREFIX}_Helixer.secretome_filtered.fa \
          -g ./Frozen_assemblies/${PREFIX}.fa \
          ./Helixer/20_filtered/GFF/${PREFIX}.helixer_pre_qc.secretome_filtered.gff

  grep -v 'shorter_than_3bp' ./Helixer/10_gff_qc/${PREFIX}.helixer_pre_qc.gff | \
  grep -v 'five_prime_UTR' | \
  grep -v 'three_prime_UTR' | \
  grep -v 'exon' | \
  cut -f 1-9 > \
  ./Helixer/20_filtered/GFF/${PREFIX}.helixer_pre_qc.proteome_filtered.gff

  gffread -y ./Helixer/20_filtered/Proteomes/${PREFIX}_Helixer.proteome_filtered.fa \
          -g ./Frozen_assemblies/${PREFIX}.fa \
          ./Helixer/20_filtered/GFF/${PREFIX}.helixer_pre_qc.proteome_filtered.gff
}

export -f filter_helixer_annotation

mkdir -p ./Helixer/10_gff_qc
mkdir -p ./Helixer/20_filtered/GFF
mkdir -p ./Helixer/20_filtered/Secretomes
mkdir -p ./Helixer/20_filtered/Proteomes

find ./Frozen_assemblies/*.fa | \
xargs -P 4 -I"%" bash -c "filter_helixer_annotation %"

