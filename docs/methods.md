# Methods

All steps run in pinned Apptainer containers (`conf/base.config`), one
process per tool, so the exact software versions are recorded with the run.

| Stage            | Tool (version tag)              | Notes |
|------------------|---------------------------------|-------|
| Read QC          | NanoPlot 1.42                   | length/quality, N50 |
| (HiFi generation)| pbccs 6.4                       | only if starting from subreads |
| Host removal     | minimap2 2.28 + samtools        | `map-hifi`; unmapped reads kept |
| Assembly (HiFi)  | metaMDBG 1.0                    | HiFi metagenome assembler (`--in-hifi`) |
| Assembly (CLR)   | metaFlye 2.9.5                  | fallback for raw PacBio subreads / Nanopore (`--platform clr`) |
| Read mapping     | minimap2 2.28                   | coverage for binning |
| Binning          | MetaBAT2 2.15 + SemiBin2 2.1    | long-read mode |
| Bin refinement   | DAS Tool 1.1.7                  | consensus of both binners |
| MAG QC           | CheckM2 1.0.2, GUNC 1.0.6       | report to MIMAG standards |
| Dereplication    | dRep 3.5                        | across samples |
| Taxonomy         | GTDB-Tk 2.4 (R220)              | classify_wf |
| Annotation       | Bakta 1.9.4                     | per-MAG gene calling |
| Function         | DRAM 1.5                        | KEGG module completeness |
| AMR              | AMRFinderPlus 3.12              | resistance genes |
| Mobility         | geNomad 1.8                     | plasmids / proviruses |
| Read profile     | sylph 0.6.1                     | MAG-independent cross-check |

## Biological questions
1. Which MAGs represent the chemosynthetic endosymbionts (methane- and
   sulfur-oxidising) of *Gigantidas platifrons*, and at what quality?
2. What is their metabolic potential — C1 metabolism, sulfur oxidation,
   nitrogen, and vitamin (B12) biosynthesis?
3. Do any MAGs carry AMR genes or mobile elements (plasmids/proviruses)?

## Reproducibility
- Exact commands live in `modules/local/*.nf`.
- Container tags are pinned in `conf/base.config`.
- Nextflow writes `results/pipeline_info/` (timeline, report, trace, DAG)
  per run; these document runtime and resource use.

## Limitations
- 5 samples, single host population — a methods demonstration, not a survey.
- ENA serves subreads; HiFi CCS may need to be regenerated (see usage).
- No biological replicate statistics; MAG presence/absence is descriptive.
