# TreeTuner
A pipeline to coarse and fine-tuning large phylogenetic datasets via minimizing the redundancy and complexity

```
├── blastdbv5_user_guide.pdf
├── Online_TreeTuner Tutorial.pdf
├── Step10_building_preliminary_tree
│   ├── clps.aligned.fasta
│   ├── clps.aligned.trimmed.fasta
│   └── clps.aligned.trimmed.newick
├── Step11-14_coarse_tuning
│   ├── clps_aligned_trimmed.newick__AT1G68660.1_parameter_input.in.tt0.01.tre
│   ├── clps_treetrimmer.out
│   ├── color_tree
│   │   ├── AT1G68660.1_aligned_trimmed.newick__AT1G68660.1_parameter_input.in.tt0.01.tre.png
│   │   ├── clps_aligned_trimmed.newick__AT1G68660.1_parameter_input.in.tt0.01.tre
│   │   ├── clps_taxonomic_info_clean.txt
│   │   └── color_coarse_tuning_tree.py
│   ├── ReadME.txt
│   ├── Sample
│   │   ├── clps.aligned.trimmed.newick
│   │   ├── clps_paramer_input.in
│   │   └── clps_taxonomic_info_clean.txt
│   └── treetrimmer.rb
├── Step15-24_fine_tuning
│   ├── color_tree
│   │   ├── color_fine_tuning_tree.py
│   │   ├── renamed_clps_aligned_trimmed.fasta.fasttree
│   │   └── renamed_clps_aligned_trimmed.fasta.fasttree.png
│   ├── Laura_perl
│   │   ├── FastTree
│   │   ├── FastTree.c
│   │   ├── Instructions.txt
│   │   ├── lauralib.pm
│   │   ├── renamed_clps_aligned_trimmed.fasta
│   │   ├── renamed_clps_aligned_trimmed.fasta.fasttree
│   │   ├── renamed_clps_aligned_trimmed.fasta.genus_trimmed
│   │   ├── renamed_clps_aligned_trimmed.fasta_removedSeq
│   │   ├── renamed_clps_aligned_trimmed.fasta_sub
│   │   ├── renamed_clps_aligned_trimmed.newick
│   │   ├── rm_inparal_rank.pl
│   │   ├── taxa_not_remove.txt
│   │   ├── taxa_rank.txt
│   │   └── trim2untrim.pl
│   └── rename
│       ├── clps_acc2tax_prot_all.txt
│       ├── clps_hits.fasta
│       ├── clps_hits_no_description.fasta
│       ├── new_renamed_clps_hits.fasta
│       ├── renamed_clps_hits.fasta
│       ├── rename_ncbi_blastdb.py
│       ├── Sample
│       │   ├── new_renamed_clps_hits.fasta
│       │   ├── renamed_clps_aligned.fasta
│       │   ├── renamed_clps_aligned_trimmed.fasta
│       │   └── renamed_clps_aligned_trimmed.newick
│       └── taxdump.tar.gz
└── Step1-9_preparing_input_files
    ├── BLASTP_clps.tsv
    ├── BLASTP_clps_without_header.tsv
    ├── clps.fasta
    ├── clps_hits.fasta
    ├── clps_hits_id_trimmed.txt
    ├── clps_hits_id.txt
    ├── clps_hits_trimmed.fasta
    └── clps_taxonomic_info.txt

10 directories, 52 files
```
