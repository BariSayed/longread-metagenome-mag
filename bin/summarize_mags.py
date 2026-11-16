#!/usr/bin/env python3
"""Merge CheckM2, GUNC and GTDB-Tk outputs into one MAG summary table.

Usage:
    summarize_mags.py --checkm2 quality_report.tsv --gunc GUNC.*.tsv \
        --gtdbtk gtdbtk.bac120.summary.tsv --out mag_summary.tsv
"""
import argparse, pandas as pd

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--checkm2", required=True)
    ap.add_argument("--gunc", required=True)
    ap.add_argument("--gtdbtk", required=True)
    ap.add_argument("--out", default="mag_summary.tsv")
    a = ap.parse_args()

    cm = pd.read_csv(a.checkm2, sep="\t").rename(columns={"Name": "mag"})
    gu = pd.read_csv(a.gunc, sep="\t").rename(columns={"genome": "mag"})
    gt = pd.read_csv(a.gtdbtk, sep="\t").rename(columns={"user_genome": "mag"})

    df = (cm[["mag", "Completeness", "Contamination"]]
          .merge(gu[["mag", "pass.GUNC", "clade_separation_score"]], on="mag", how="left")
          .merge(gt[["mag", "classification"]], on="mag", how="left"))

    # MIMAG quality tiers
    def tier(r):
        if r.Completeness >= 90 and r.Contamination <= 5:
            return "high"
        if r.Completeness >= 50 and r.Contamination <= 10:
            return "medium"
        return "low"
    df["mimag_quality"] = df.apply(tier, axis=1)
    df.sort_values(["mimag_quality", "Completeness"], ascending=[True, False]).to_csv(a.out, sep="\t", index=False)
    print(f"Wrote {a.out}: {len(df)} MAGs")

if __name__ == "__main__":
    main()
