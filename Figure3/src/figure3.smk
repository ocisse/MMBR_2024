###
rule get_cluster_components:
    input:
        group="data/raw/Orthogroups.tsv",
        a="data/raw/cluster-A.txt",
        b="data/raw/cluster-B.txt",
        c="data/raw/cluster-C.txt",
        d="data/raw/cluster-D.txt",
        e="data/raw/cluster-E.txt",
        f="data/raw/cluster-F.txt",
    output:
        a=temp("data/processed/cluster-A.id"),
        b=temp("data/processed/cluster-B.id"),
        c=temp("data/processed/cluster-C.id"),
        d=temp("data/processed/cluster-D.id"),
        e=temp("data/processed/cluster-E.id"),
        f=temp("data/processed/cluster-F.id"),
    run:
        shell("perl scripts/extract_proteins.pl {input.a} {input.group} | grep -v \"^$\" |  grep -v \"^\s\" > {output.a}")
        shell("perl scripts/extract_proteins.pl {input.b} {input.group} | grep -v \"^$\" |  grep -v \"^\s\" > {output.b}")
        shell("perl scripts/extract_proteins.pl {input.c} {input.group} | grep -v \"^$\" |  grep -v \"^\s\" > {output.c}")
        shell("perl scripts/extract_proteins.pl {input.d} {input.group} | grep -v \"^$\" |  grep -v \"^\s\" > {output.d}")
        shell("perl scripts/extract_proteins.pl {input.e} {input.group} | grep -v \"^$\" |  grep -v \"^\s\" > {output.e}")
        shell("perl scripts/extract_proteins.pl {input.f} {input.group} | grep -v \"^$\" |  grep -v \"^\s\" > {output.f}")

rule get_seq:
        input:
            clustA=rules.get_cluster_components.output.a, 
            clustB=rules.get_cluster_components.output.b,
            clustC=rules.get_cluster_components.output.c,
            clustD=rules.get_cluster_components.output.d,
            clustE=rules.get_cluster_components.output.e,
            clustF=rules.get_cluster_components.output.f,

            bd="data/raw/full_proteomes/bd_protein.faa",
            cneo="data/raw/full_proteomes/cneo_protein.faa",
            ncra="data/raw/full_proteomes/ncra_protein.faa",
            nirr="data/raw/full_proteomes/nirr.faa",
            pino="data/raw/full_proteomes/pino.faa",
            pcar="data/raw/full_proteomes/pcar.faa",
            rhior="data/raw/full_proteomes/rhior_protein.faa",
            saico="data/raw/full_proteomes/saico.faa",
            tdef="data/raw/full_proteomes/tdef.faa",
            spom="data/raw/full_proteomes/spom.faa"

        output:
            db=temp("data/raw/full_proteomes/db.tmp"),
            a="data/processed/cluster-A.faa",
            b="data/processed/cluster-B.faa",
            c="data/processed/cluster-C.faa",
            d="data/processed/cluster-D.faa",
            e="data/processed/cluster-E.faa",
            f="data/processed/cluster-F.faa",
        run:
            shell("cat {input.bd} {input.cneo} {input.ncra} {input.nirr} {input.pino} {input.pcar} {input.rhior} {input.saico} {input.tdef} {input.spom} > {output.db}")
            shell("seqtk subseq {output.db} {input.clustA} > {output.a}")
            shell("seqtk subseq {output.db} {input.clustB} > {output.b}")
            shell("seqtk subseq {output.db} {input.clustC} > {output.c}")
            shell("seqtk subseq {output.db} {input.clustD} > {output.d}")
            shell("seqtk subseq {output.db} {input.clustE} > {output.e}")
            shell("seqtk subseq {output.db} {input.clustF} > {output.f}")

# -Z represent the number of sequences
# grep -c '^ACC'  ~/DATA/DB/PFAM/current_release/Pfam-A.hmm 16712

rule pfam:
    input:
            db="/nethome/cisseoh/DATA/DB/PFAM/current_release/Pfam-A.hmm",
            
            clustA=rules.get_seq.output.a,
            clustB=rules.get_seq.output.b,
            clustC=rules.get_seq.output.c,
            clustD=rules.get_seq.output.d,
            clustE=rules.get_seq.output.e,
            clustF=rules.get_seq.output.f,
    params:
            z="16712", e="1e-5"
    output:
            a="data/processed/cluster-A.pfamtab",
            b="data/processed/cluster-B.pfamtab",
            c="data/processed/cluster-C.pfamtab",
            d="data/processed/cluster-D.pfamtab",
            e="data/processed/cluster-E.pfamtab",
            f="data/processed/cluster-F.pfamtab",
    threads: 12
    run:
        shell("hmmsearch -E {params.e} -Z {params.z} --cpu {threads} --noali --tblout {output.a} {input.db} {input.clustA}")
        shell("hmmsearch -E {params.e} -Z {params.z} --cpu {threads} --noali --tblout {output.b} {input.db} {input.clustB}")
        shell("hmmsearch -E {params.e} -Z {params.z} --cpu {threads} --noali --tblout {output.c} {input.db} {input.clustC}")
        shell("hmmsearch -E {params.e} -Z {params.z} --cpu {threads} --noali --tblout {output.d} {input.db} {input.clustD}")
        shell("hmmsearch -E {params.e} -Z {params.z} --cpu {threads} --noali --tblout {output.e} {input.db} {input.clustE}")
        shell("hmmsearch -E {params.e} -Z {params.z} --cpu {threads} --noali --tblout {output.f} {input.db} {input.clustF}")
            
rule post_process_pfam:
    input:
        clustA=rules.pfam.output.a,
        clustB=rules.pfam.output.b,
        clustC=rules.pfam.output.c,
        clustD=rules.pfam.output.d,
        clustE=rules.pfam.output.e,
        clustF=rules.pfam.output.f,
    output:
        a="data/processed/cluster-A_domains.txt",
        b="data/processed/cluster-B_domains.txt",
        c="data/processed/cluster-C_domains.txt",
        d="data/processed/cluster-D_domains.txt",
        e="data/processed/cluster-E_domains.txt",
        f="data/processed/cluster-F_domains.txt",
    run:
        shell("perl scripts/grap_pfam_id.pl {input.clustA} | sort -u > {output.a}")
        shell("perl scripts/grap_pfam_id.pl {input.clustB} | sort -u > {output.b}")
        shell("perl scripts/grap_pfam_id.pl {input.clustC} | sort -u > {output.c}")
        shell("perl scripts/grap_pfam_id.pl {input.clustD} | sort -u > {output.d}")
        shell("perl scripts/grap_pfam_id.pl {input.clustE} | sort -u > {output.e}")
        shell("perl scripts/grap_pfam_id.pl {input.clustF} | sort -u > {output.f}")

        
