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

> **Note on read type (resolved).** ENA holds **no subreads BAM** for these
> runs (`submitted_ftp` empty), so `ccs` cannot be run. The deposited FASTQ
> reads were inspected and are long (~13 kb median), high-accuracy consensus
> reads — used **directly as HiFi** (`--platform hifi`). The `--platform clr`
> (metaFlye) path is available as a general fallback. See the README.

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
