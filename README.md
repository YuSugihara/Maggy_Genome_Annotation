# Maggy Genome Annotation

[Helixer](https://github.com/weberlab-hhu/Helixer)

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


`--peak-threshold`: The default value is 0.8. The value of 0.6 is used here to increase the number of predicted effectors. 
`--species`: The species name is just used as a gene id prefix in the output file. 
`--subsequence-length`: 21384 is default for fungi.
`--overlap-offset`: 10692 is default for fungi.
`--overlap-core-length`: 16038 is default for fungi. 
`--fasta-path`: The path to the reference genome. 
`--gff-output-path`: The path to the output GFF file.

