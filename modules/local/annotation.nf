process BAKTA {
    tag "$mag"
    label 'process_medium'
    publishDir "${params.outdir}/annotation/bakta", mode: 'copy'

    input:  path(mag)
    output: path "${mag.baseName}/*", emit: anno

    script:
    """
    bakta --db ${params.bakta_db} --threads ${task.cpus} \\
        --output ${mag.baseName} --prefix ${mag.baseName} ${mag}
    """
}

process DRAM {
    label 'process_high'
    publishDir "${params.outdir}/function/dram", mode: 'copy'

    input:  path(mags)
    output: path "dram_out", emit: dram

    script:
    """
    mkdir mags && cp ${mags} mags/
    DRAM.py annotate -i 'mags/*.fa' -o dram_out --threads ${task.cpus}
    DRAM.py distill -i dram_out/annotations.tsv -o dram_distill
    cp -r dram_distill dram_out/
    """
}
