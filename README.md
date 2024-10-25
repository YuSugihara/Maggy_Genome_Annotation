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
           --species <ISOLATE_NAME> \
           --peak-threshold 0.6 \
           --fasta-path <ASSEMBLY_FASTA> \
           --gff-output-path <OUTPUT_GFF>
```

### Explanation of Key Parameters

- `--peak-threshold`: The default is 0.8. Here, we use 0.6 to increase the number of predicted effectors.
- `--species`: This is used only as a prefix for gene IDs in the output file.
- `--subsequence-length`: Set to 21384, which is the default value for fungi.
- `--overlap-offset`: Set to 10692, also the default for fungi.
- `--overlap-core-length`: Set to 16038, the default for fungi.
- `--fasta-path`: Specify the path to the reference genome assembly (FASTA format).
- `--gff-output-path`: Specify the path for saving the output GFF file.
