process MINIMAP2_HOST {
    tag "$sample"
    label 'process_medium'
    publishDir "${params.outdir}/host_removal/${sample}", mode: 'copy', pattern: "*.stats.txt"

    input:
    tuple val(sample), path(reads)
    path  host

    output:
    tuple val(sample), path("${sample}.clean.fastq.gz"), emit: reads
    path "${sample}.host_removal.stats.txt",             emit: stats

    script:
    def preset = params.platform == 'nanopore' ? 'map-ont' : 'map-hifi'
    """
    minimap2 -ax ${preset} -t ${task.cpus} ${host} ${reads} \\
      | samtools view -b -f 4 - \\
      | samtools fastq - | gzip > ${sample}.clean.fastq.gz
    echo "sample\t${sample}" > ${sample}.host_removal.stats.txt
    """
}
