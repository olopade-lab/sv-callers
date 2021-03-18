import argparse
import pandas as pd
import glob
import os
import subprocess

parser = argparse.ArgumentParser(
    description="Helper script to make input bam hard links (as required by sv-callers) for aligned files"
)
parser.add_argument(
    "--aligned_bams_dir",
    default="/cephfs/PROJECTS/annawoodard/alignment/wabcs/processed/",
    help="directory with aligned bams",
)
parser.add_argument(
    "--project_dir",
    default="/cephfs/PROJECTS/annawoodard/sv-callers/snakemake/wabcs-HumanG1Kv37/data",
    help="directory to make links in",
)
args = parser.parse_args()

samples = [
    os.path.basename(p) for p in glob.glob(os.path.join(args.aligned_bams_dir, "*"))
]
paths = []
for sample in samples:
    if (
        len(
            glob.glob(os.path.join(args.aligned_bams_dir, sample, "tumor", "*.bam.md5"))
        )
        > 0
        and len(
            glob.glob(
                os.path.join(args.aligned_bams_dir, sample, "normal", "*.bam.md5")
            )
        )
        > 0
    ):
        paths += [os.path.join(*args.project_dir.split("/")[-2:], sample)]
        os.makedirs(os.path.join(args.project_dir, sample), exist_ok=True)
        for tag, ext in [
            ("tumor", ".bam"),
            ("tumor", ".bai"),
            ("normal", ".bam"),
            ("normal", ".bai"),
        ]:
            target = os.path.join(
                args.aligned_bams_dir, sample, tag, sample + ".human_g1k_v37" + ext
            )
            link = os.path.join(args.project_dir, sample, tag + ext)
            if not os.path.isfile(link):
                print("linking ", target, link)
                subprocess.check_output("ln -s {} {}".format(target, link), shell=True)

df = pd.DataFrame(
    data={
        "PATH": paths,
        "SAMPLE1": ["tumor" for p in paths],
        "SAMPLE2": ["normal" for p in paths],
    }
)

df.to_csv("samples.csv", index=False)
