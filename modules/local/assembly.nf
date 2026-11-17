process METAMDBG {
    tag "$sample"
    label 'process_high'
    publishDir "${params.outdir}/assembly/${sample}", mode: 'copy'

    input:  tuple val(sample), path(reads)
    output: tuple val(sample), path("${sample}.contigs.fasta.gz"), emit: contigs

    script:
    // metaMDBG for PacBio HiFi; use --in-ont for Nanopore
    def mode = params.platform == 'nanopore' ? '--in-ont' : '--in-hifi'
    """
    metaMDBG asm --out-dir asm --threads ${task.cpus} ${mode} ${reads}
    mv asm/contigs.fasta.gz ${sample}.contigs.fasta.gz
    """
}

process METAFLYE {
    tag "$sample"
    label 'process_high'
    publishDir "${params.outdir}/assembly/${sample}", mode: 'copy'

    input:  tuple val(sample), path(reads)
    output: tuple val(sample), path("${sample}.contigs.fasta.gz"), emit: contigs

    script:
    // Fallback assembler for noisy long reads: PacBio CLR / raw subreads or Nanopore.
    def mode = params.platform == 'nanopore' ? '--nano-raw' : '--pacbio-raw'
    """
    flye --meta ${mode} ${reads} --out-dir flye --threads ${task.cpus}
    gzip -c flye/assembly.fasta > ${sample}.contigs.fasta.gz
    """
}
