process GENOMAD {
    tag "$mag"
    label 'process_medium'
    publishDir "${params.outdir}/mge", mode: 'copy'

    input:  path(mag)
    output: path "${mag.baseName}_genomad", emit: mge

    script:
    """
    genomad end-to-end --cleanup --threads ${task.cpus} \\
        ${mag} ${mag.baseName}_genomad ${params.genomad_db}
    """
}
