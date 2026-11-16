process METAMDBG {
    tag "$sample"
    label 'process_high'
    publishDir "${params.outdir}/assembly/${sample}", mode: 'copy'

    input:  tuple val(sample), path(reads)
    output:
    tuple val(sample), path("${sample}.contigs.fasta.gz"), emit: contigs

    script:
    // metaMDBG for PacBio HiFi; use --in-ont for Nanopore
    def mode = params.platform == 'nanopore' ? '--in-ont' : '--in-hifi'
    """
    metaMDBG asm --out-dir asm --threads ${task.cpus} ${mode} ${reads}
    mv asm/contigs.fasta.gz ${sample}.contigs.fasta.gz
    """
}
