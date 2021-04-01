rule survivor_filter:  # used by both modes
    input:
        os.path.join("{path}", "{tumor}--{normal}", "{outdir}", "{prefix}" + get_filext("vcf"))
        if config["mode"].startswith("p") is True else
        os.path.join("{path}", "{sample}", "{outdir}", "{prefix}" + get_filext("vcf"))
    output:
        os.path.join("{path}", "{tumor}--{normal}", "{outdir}", "survivor", "{prefix}" + get_filext("vcf"))
        if config["mode"].startswith("p") is True else
        os.path.join("{path}", "{sample}", "{outdir}", "survivor", "{prefix}" + get_filext("vcf"))
    params:
        excl = exclude_regions(),
        args = survivor_args("filter"),
	blacklist = config["exclusion_list"],
	segdups = config["segdups_list"]
    conda:
        "../environment.yaml"
    threads:
        get_nthreads("survivor")
    resources:
        mem_mb = get_memory("survivor"),
        tmp_mb = get_tmpspace("survivor")
    shell:
        """
        set -x

        # run dummy or real job
        if [ "{config[echo_run]}" -eq "1" ]; then
            cat "{input}" > "{output}"
        else
            if [ "{params.excl}" -eq "1" ]; then
                SURVIVOR filter "{input}" "{params.blacklist}" {params.args} "{output}"
                SURVIVOR filter "{input}" "{params.segdups}" {params.args} "{output}"
            else
                ln -sr "{input}" "{output}"
            fi
        fi
        """

rule survivor_merge:  # used by both modes
    input:
        [os.path.join("{path}", "{tumor}--{normal}", get_outdir(c), "survivor", c + get_filext("vcf"))
         for c in get_callers()]
        if config["mode"].startswith("p") is True else
        [os.path.join("{path}", "{sample}", get_outdir(c), "survivor", c + get_filext("vcf"))
         for c in get_callers()]
    params:
        args = survivor_args("merge")[1:-1]
    output:
        [os.path.join("{path}", "{tumor}--{normal}", survivor_args("merge")[0]),
         os.path.join("{path}", "{tumor}--{normal}", survivor_args("merge")[-1])]
        if config["mode"].startswith("p") is True else
        [os.path.join("{path}", "{sample}", survivor_args("merge")[0]),
         os.path.join("{path}", "{sample}", survivor_args("merge")[-1])]
    conda:
        "../environment.yaml"
    threads:
        get_nthreads("survivor")
    resources:
        mem_mb = get_memory("survivor"),
        tmp_mb = get_tmpspace("survivor")
    shell:
        """
        set -x

        # create a list of VCF files
        for f in $(echo "{input}")
        do
            echo "$f" >> "{output[0]}"
        done

        # run dummy or real job
        if [ "{config[echo_run]}" -eq "1" ]; then
            cat "{output[0]}" > "{output[1]}"
        else
            SURVIVOR merge "{output[0]}" {params.args} "{output[1]}"
        fi
        """
