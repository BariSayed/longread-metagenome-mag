process CHECKM2 {
    tag "$sample"
    label 'process_medium'
    publishDir "${params.outdir}/mag_qc/checkm2/${sample}", mode: 'copy'

    input:  tuple val(sample), path(bins)
    output: path "quality_report.tsv", emit: report

    script:
    """
    checkm2 predict --threads ${task.cpus} --database_path ${params.checkm2_db} \\
        -x fa --input ${bins} --output-directory checkm2_out
    cp checkm2_out/quality_report.tsv .
    """
}

process GUNC {
    tag "$sample"
    label 'process_medium'
    publishDir "${params.outdir}/mag_qc/gunc/${sample}", mode: 'copy'

    input:  tuple val(sample), path(bins)
    output: path "GUNC.*.tsv", emit: report

    script:
    """
    mkdir gunc_out
    gunc run --input_dir ${bins} --file_suffix .fa \\
        --db_file ${params.gunc_db} --threads ${task.cpus} --out_dir gunc_out
    cp gunc_out/GUNC.*.tsv .
    """
}
