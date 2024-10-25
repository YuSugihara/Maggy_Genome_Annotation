# Maggy Genome Annotation

This repository provides a pipeline for annotating the genome of *Magnaporthe oryzae* (Maggy) using [Helixer](https://github.com/weberlab-hhu/Helixer).

### Running Helixer with Singularity

To run Helixer, use the following command with Singularity:

```bash
singularity run --nv /path_to_docker_image/helixer-docker_helixer_v0.3.3_cuda_11.8.0-cudnn8.sif \
Helixer.py --lineage fungi \
           --subsequence-length 21384 \
           --overlap-offset 10692 \
           --overlap-core-length 16038 \
           --species maggy_isolate \
           --peak-threshold 0.6 \
           --fasta-path ./assemblies/maggy_isolate.fa \
           --gff-output-path ./outputs/maggy_isolate.gff
```

### Explanation of Key Parameters

- `--peak-threshold`: The default is 0.8. Here, we use 0.6 to increase the number of predicted effectors.
- `--species`: This is used only as a prefix for gene IDs in the output file.
- `--subsequence-length`: Set to 21384, which is the default value for fungi.
- `--overlap-offset`: Set to 10692, also the default for fungi.
- `--overlap-core-length`: Set to 16038, the default for fungi.
- `--fasta-path`: Path to the reference genome assembly (`maggy_isolate.fa`).
- `--gff-output-path`: Path for saving the output GFF file (`maggy_isolate.gff`).

### Additional Processing Steps

After running Helixer, use the following commands to further process the GFF and FASTA files:

#### Extracting CDS from GFF

Use `gffread` to extract CDS sequences from the GFF file:

```bash
gffread -x ./outputs/maggy_isolate_cds.fa \
        -g ./assemblies/maggy_isolate.fa \
        ./outputs/maggy_isolate.gff
```

#### Annotation QC

`20_gff_qc.py` is a script that checks the quality of the GFF file based on the CDS sequences.

[biopython](https://biopython.org) is required to run this script.

```bash
./20_gff_qc.py ./outputs/maggy_isolate.gff \
               ./outputs/maggy_isolate_cds.fa \
               150,180,195 \
               10,25,50 \
               1> ./outputs/maggy_isolate_qc.gff \
               2> ./outputs/maggy_isolate_qc.txt
```

150,180,195 are the check points for minimum lengths for CDS.

10,25,50 are the check points for the percentage of masked bases in the CDS.

#### Filtering the QC GFF

Filter the proteome GFF file based on QC results:

```bash
grep -v 'not_multiple_of_3' ./outputs/maggy_isolate_qc.gff | \
grep -v 'stop_codon_in_cds' | \
grep -v 'no_start_codon' | \
grep -v 'no_stop_codon' | \
grep -v 'shorter_than_150nt' | \
grep -v 'masked_over_25' | \
cut -f 1-9 > ./outputs/maggy_isolate.filtered.gff
```
