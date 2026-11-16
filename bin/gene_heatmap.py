#!/usr/bin/env python3
"""Presence/absence heatmap of target functional genes across MAGs.

Expects a long table (mag, gene, present) e.g. derived from DRAM distillate
or KofamScan. Target sets below map to the project's questions:
  - chemosynthesis: methane & sulfur oxidation (pmoABC, soxABCXYZ, aprAB, dsrAB)
  - vitamins:       cobalamin (B12) biosynthesis (cobS, cobT, cbiA, btuB)
  - mobility/AMR:    carried separately from geNomad / AMRFinderPlus outputs
"""
import argparse, pandas as pd, matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt, seaborn as sns

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--table", required=True, help="long TSV: mag,gene,present")
    ap.add_argument("--out", default="results/gene_heatmap.png")
    a = ap.parse_args()
    df = pd.read_csv(a.table, sep="\t")
    mat = df.pivot_table(index="mag", columns="gene", values="present", fill_value=0)
    fig, ax = plt.subplots(figsize=(max(6, 0.4*mat.shape[1]), max(4, 0.3*mat.shape[0])))
    sns.heatmap(mat, cmap="Blues", cbar=False, linewidths=.5, linecolor="grey", ax=ax)
    ax.set_title("Target gene presence across MAGs")
    fig.tight_layout(); fig.savefig(a.out, dpi=300)
    print("Wrote", a.out)

if __name__ == "__main__":
    main()
