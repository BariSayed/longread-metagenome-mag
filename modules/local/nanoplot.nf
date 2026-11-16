process NANOPLOT {
    tag "$sample"
    label 'process_low'
    publishDir "${params.outdir}/qc/${sample}", mode: 'copy'

    input:  tuple val(sample), path(reads)
    output: path "*", emit: report

    script:
    """
    NanoPlot --fastq ${reads} --threads ${task.cpus} \\
        --prefix ${sample}_ --N50 --tsv_stats -o .
    """
}
