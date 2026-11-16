#!/usr/bin/env nextflow
nextflow.enable.dsl = 2

// ------------------------------------------------------------------ //
//  longread-metagenome-mag : HiFi/Nanopore metagenome -> MAGs -> function
// ------------------------------------------------------------------ //

include { NANOPLOT }        from './modules/local/nanoplot.nf'
include { MINIMAP2_HOST }   from './modules/local/host_removal.nf'
include { METAMDBG }        from './modules/local/assembly.nf'
include { MINIMAP2_MAP }    from './modules/local/mapping.nf'
include { METABAT2 }        from './modules/local/binning.nf'
include { SEMIBIN2 }        from './modules/local/binning.nf'
include { DASTOOL }         from './modules/local/binning.nf'
include { CHECKM2 }         from './modules/local/mag_qc.nf'
include { GUNC }            from './modules/local/mag_qc.nf'
include { DREP }            from './modules/local/derep.nf'
include { GTDBTK }          from './modules/local/taxonomy.nf'
include { BAKTA }           from './modules/local/annotation.nf'
include { DRAM }            from './modules/local/annotation.nf'
include { AMRFINDERPLUS }   from './modules/local/amr.nf'
include { GENOMAD }         from './modules/local/mge.nf'
include { SYLPH }           from './modules/local/profile.nf'

def helpMessage() {
    log.info """
    longread-metagenome-mag  v${workflow.manifest.version}

    Usage:
      nextflow run main.nf -profile apptainer,slurm \\
          --input assets/samplesheet.csv --platform hifi \\
          --outdir results --host_fasta host.fa \\
          --checkm2_db ... --gtdbtk_db ... --bakta_db ...

    Key params (see nextflow.config):
      --input          Sample sheet CSV (sample,run_accession,...,fastq)
      --platform       'hifi' | 'nanopore'
      --host_fasta     Host genome for minimap2 decontamination (optional)
      --*_db           Paths to reference databases on the server
    """.stripIndent()
}

workflow {
    if (params.help) { helpMessage(); exit 0 }

    // --- read sample sheet: expects a 'fastq' or 'fastq_ftp' column ---
    Channel.fromPath(params.input)
        .splitCsv(header:true)
        .map { row ->
            def reads = row.fastq ?: row.fastq_ftp
            tuple(row.sample, file(reads))
        }
        .set { ch_reads }

    // 1. Read QC
    NANOPLOT(ch_reads)

    // 2. Host removal (optional)
    if (params.host_fasta) {
        MINIMAP2_HOST(ch_reads, file(params.host_fasta))
        ch_clean = MINIMAP2_HOST.out.reads
    } else {
        ch_clean = ch_reads
    }

    // 3. Per-sample assembly (metaMDBG for HiFi)
    METAMDBG(ch_clean)

    // 4. Map reads back for coverage
    MINIMAP2_MAP(METAMDBG.out.contigs.join(ch_clean))

    // 5. Binning (two binners) + refinement
    METABAT2(METAMDBG.out.contigs.join(MINIMAP2_MAP.out.bam))
    SEMIBIN2(METAMDBG.out.contigs.join(MINIMAP2_MAP.out.bam))
    DASTOOL(METAMDBG.out.contigs
             .join(METABAT2.out.bins)
             .join(SEMIBIN2.out.bins))

    // 6. MAG QC
    CHECKM2(DASTOOL.out.bins)
    GUNC(DASTOOL.out.bins)

    // 7. Dereplicate across samples
    DREP(DASTOOL.out.bins.map{ it[1] }.collect())

    // 8. Taxonomy + annotation + function + mobility
    GTDBTK(DREP.out.mags)
    BAKTA(DREP.out.mags)
    DRAM(DREP.out.mags)
    AMRFINDERPLUS(DREP.out.mags)
    GENOMAD(DREP.out.mags)

    // 9. Read-level profile for comparison
    SYLPH(ch_clean)
}

workflow.onComplete {
    log.info ( workflow.success
        ? "\\n[OK] Pipeline finished. Results in: ${params.outdir}\\n"
        : "\\n[FAIL] See .nextflow.log\\n" )
}
