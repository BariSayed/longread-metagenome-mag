#!/usr/bin/env Rscript
# Completeness vs contamination scatter, coloured by MIMAG tier.
suppressMessages({library(ggplot2); library(readr)})
args <- commandArgs(trailingOnly = TRUE)
infile  <- ifelse(length(args) >= 1, args[1], "results/mag_summary.tsv")
outfile <- ifelse(length(args) >= 2, args[2], "results/mag_quality.png")

d <- read_tsv(infile, show_col_types = FALSE)
p <- ggplot(d, aes(Completeness, Contamination, colour = mimag_quality)) +
    geom_point(size = 3, alpha = 0.85) +
    geom_hline(yintercept = c(5, 10), linetype = "dashed", colour = "grey60") +
    geom_vline(xintercept = c(50, 90), linetype = "dashed", colour = "grey60") +
    labs(x = "Completeness (%)", y = "Contamination (%)",
         colour = "MIMAG", title = "MAG quality (CheckM2)") +
    theme_bw(base_size = 12)
ggsave(outfile, p, width = 7, height = 5, dpi = 300)
cat("Wrote", outfile, "\n")
