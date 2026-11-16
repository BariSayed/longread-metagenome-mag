process GTDBTK {
    label 'process_high'
    publishDir "${params.outdir}/taxonomy", mode: 'copy'

    input:  path(mags)
    output: path "gtdbtk_out", emit: tax

    script:
    """
    export GTDBTK_DATA_PATH=${params.gtdbtk_db}
    mkdir mags && cp ${mags} mags/
    gtdbtk classify_wf --genome_dir mags -x fa \\
        --out_dir gtdbtk_out --cpus ${task.cpus} --skip_ani_screen
    """
}
