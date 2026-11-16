process SYLPH {
    tag "$sample"
    label 'process_medium'
    publishDir "${params.outdir}/read_profile", mode: 'copy'

    input:  tuple val(sample), path(reads)
    output: path "${sample}.sylph.tsv", emit: profile

    script:
    """
    sylph sketch -r ${reads} -t ${task.cpus} -o ${sample}
    sylph profile ${params.sylph_db} ${sample}.sylsp -t ${task.cpus} > ${sample}.sylph.tsv
    """
}
