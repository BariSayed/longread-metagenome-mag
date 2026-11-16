process DREP {
    label 'process_medium'
    publishDir "${params.outdir}/dereplicated", mode: 'copy'

    input:  path(all_bins)
    output: path "drep_out/dereplicated_genomes/*.fa", emit: mags

    script:
    """
    mkdir genomes
    for d in ${all_bins}; do cp \$d/*.fa genomes/ 2>/dev/null || true; done
    dRep dereplicate drep_out -g genomes/*.fa -p ${task.cpus} \\
        -comp ${params.min_completeness} -con ${params.max_contamination}
    """
}
