process AMRFINDERPLUS {
    tag "$mag"
    label 'process_low'
    publishDir "${params.outdir}/amr", mode: 'copy'

    input:  path(mag)
    output: path "${mag.baseName}.amrfinder.tsv", emit: amr

    script:
    """
    amrfinder -n ${mag} --plus --threads ${task.cpus} \\
        -d ${params.amrfinder_db} > ${mag.baseName}.amrfinder.tsv
    """
}
