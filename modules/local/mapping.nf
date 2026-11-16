process MINIMAP2_MAP {
    tag "$sample"
    label 'process_medium'

    input:  tuple val(sample), path(contigs), path(reads)
    output: tuple val(sample), path("${sample}.sorted.bam"), path("${sample}.sorted.bam.bai"), emit: bam

    script:
    def preset = params.platform == 'nanopore' ? 'map-ont' : 'map-hifi'
    """
    minimap2 -ax ${preset} -t ${task.cpus} ${contigs} ${reads} \\
      | samtools sort -@ ${task.cpus} -o ${sample}.sorted.bam -
    samtools index ${sample}.sorted.bam
    """
}
