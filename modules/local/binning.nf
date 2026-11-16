process METABAT2 {
    tag "$sample"
    label 'process_medium'

    input:  tuple val(sample), path(contigs), path(bam), path(bai)
    output: tuple val(sample), path("metabat2_bins"), emit: bins

    script:
    """
    jgi_summarize_bam_contig_depths --outputDepth depth.txt ${bam}
    mkdir metabat2_bins
    metabat2 -i ${contigs} -a depth.txt -o metabat2_bins/bin -t ${task.cpus} -m 1500
    """
}

process SEMIBIN2 {
    tag "$sample"
    label 'process_medium'

    input:  tuple val(sample), path(contigs), path(bam), path(bai)
    output: tuple val(sample), path("semibin2_bins"), emit: bins

    script:
    """
    SemiBin2 single_easy_bin --sequencing-type=long_read \\
        -i ${contigs} -b ${bam} -o semibin_out -t ${task.cpus} --environment=global
    mkdir semibin2_bins && cp semibin_out/output_bins/*.fa semibin2_bins/ || true
    """
}

process DASTOOL {
    tag "$sample"
    label 'process_medium'
    publishDir "${params.outdir}/bins/${sample}", mode: 'copy'

    input:  tuple val(sample), path(contigs), path(metabat_bins), path(semibin_bins)
    output: tuple val(sample), path("dastool_out_DASTool_bins"), emit: bins

    script:
    """
    Fasta_to_Contig2Bin.sh -i ${metabat_bins} -e fa  > metabat.tsv
    Fasta_to_Contig2Bin.sh -i ${semibin_bins} -e fa  > semibin.tsv
    DAS_Tool -i metabat.tsv,semibin.tsv -l metabat2,semibin2 \\
        -c ${contigs} -o dastool_out --write_bins -t ${task.cpus} --score_threshold 0.5
    """
}
