# Usage

## 1. Requirements
- Nextflow >= 23.10
- Apptainer (or Singularity)
- Reference databases on the server: CheckM2, GUNC, GTDB-Tk (R220),
  Bakta, geNomad, AMRFinderPlus, a sylph database (e.g. GTDB-r220).

## 2. Get the data
This repo re-analyses **public** data; no reads are committed. Download the
5 PacBio runs of BioProject **PRJNA891367** on the server, e.g. with the
ENA FTP paths in `assets/samplesheet.csv`, or:

```bash
# example (prefetch/fasterq-dump or ENA aspera/ftp)
while IFS=, read -r sample run rest; do
    [ "$sample" = sample ] && continue
    wget -c "ftp://ftp.sra.ebi.ac.uk/vol1/fastq/${run:0:6}/0${run: -2}/${run}/${run}_subreads.fastq.gz"
done < assets/samplesheet.csv
```

> **Note on read type.** ENA serves these runs as PacBio **subreads**. The
> source study used CCS/HiFi reads. If HiFi (`ccs`) reads are required,
> generate them from the subread BAMs with `pbccs`, or obtain the CCS reads
> from the submitter. The `CCS` process label and `pbccs` container are
> wired in `conf/base.config` for this step. See `docs/methods.md`.

## 3. Configure databases
Edit paths in `nextflow.config` (the `--*_db` params) or pass on the CLI.

## 4. Run
```bash
nextflow run main.nf \
    -profile apptainer,slurm \
    --input assets/samplesheet.csv \
    --platform hifi \
    --host_fasta /path/to/Gigantidas_platifrons_genome.fa \
    --outdir results
```

A small smoke test:
```bash
nextflow run main.nf -profile apptainer,test
```
