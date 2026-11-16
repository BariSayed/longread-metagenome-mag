# Containers

Each process pins an Apptainer/Singularity image tag in `conf/base.config`
(mostly `quay.io/biocontainers`). On first run with `-profile apptainer`,
images are pulled into `containers/cache/` (git-ignored).

To pre-pull on the server:

```bash
nextflow run main.nf -profile apptainer -preview   # resolves images
# or pull manually, e.g.
apptainer pull containers/cache/checkm2.sif docker://quay.io/biocontainers/checkm2:1.0.2--pyh7cba7a3_0
```

Record the resolved digests after the run for full reproducibility.
