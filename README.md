# TreeTuner
A pipeline to coarse and fine-tuning large phylogenetic datasets via minimizing the redundancy and complexity

### 1. What's TreeTuner Pipeline?
The TreeTuner pipeline combines the software and tools required for both coarse- and fine-scale tuning. 

- For coarse tuning, TreeTrimmer (Maruyama et al., 2013) can be downloaded from the web (https://code.google.com/archive/p/treetrimmer/). To run TreeTrimmer locally, pre-installed Ruby (i.e., Ruby v2.5.1) is required. 

```
Usage: ruby treetrimmer.rb [Newick_tree_file] [Parameter_input_file] [Taxonomic_information_file] > output_file
```
- For fine tuning, the necessary custom Perl scripts (rm_inparal_rank.pl and trim2untrim.pl) and Python script (rename_ncbi_blastdb.py) can be found at the following GitHub website: https://github.com/zx0223winner/TreeTuner. Pre-installed Perl (e.g., Perl 5) is required to run these scripts. 

```
Usage: perl rm_inparal_rank.pl [tree file] [alignment file] [distance cutoff] [taxa not to remove] [taxa rank]
Usage: perl trim2untrim.pl [trimmed alignement] [untrimmed alignment]
```
- To color the Newick tree, the Environment for Tree Exploration (ETE3) toolkit (Huerta-Cepas et al., 2016) and associated Python scripts (e.g., color_coarse_tuning_tree.py and color_fine_tuning_tree.py) are needed. 

```
Usage: python3 color_coarse_tuning_tree.py <taxonomic_info_file> <newick_tree_file>
Usage: python3 color_fine_tuning_tree.py <newick_tree_file> 
```

### 2. Environmental Requirement
TreeTuner users will also need the Linux environment (e.g., Ubuntu 20.04 LTS) to run their BLAST searches (Altschul et al., 1997). The MAFFT v7(Katoh and Standley, 2013), BMGE v1.12 (Criscuolo and Gribaldo, 2010), trimAl v1.4 (Capella-Gutiérrez et al., 2009), FastTree v2.1 (Price et al., 2010) and IQ-TREE v1.6.12 (Nguyen et al., 2015)

```
#Linux environment (e.g., Ubuntu 20.04 LTS)
#Ruby v2.5.1
#Perl 5
#Python 3

# Install python3 
>pip3 install python

# Install ETE3 toolkit
>pip3 install ete

# Install ETE tree browser
>pip3 install PyQt5

```

### 3. File index

```
├── TreeTuner pipeline
├── Step1-9_preparing_input_files
│   ├── BLASTP_clps.tsv
│   ├── BLASTP_clps_without_header.tsv
│   ├── clps.fasta
│   ├── clps_hits.fasta
│   ├── clps_hits_id_trimmed.txt
│   ├── clps_hits_id.txt
│   ├── clps_hits_trimmed.fasta
│   └── clps_taxonomic_info.txt
├── Step10_building_preliminary_tree
│   ├── clps.aligned.fasta
│   ├── clps.aligned.trimmed.fasta
│   └── clps.aligned.trimmed.newick
├── Step11-14_**coarse_tuning**
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
└── Step15-24_**fine_tuning**
    ├── color_tree
    │   ├── color_fine_tuning_tree.py
    │   ├── renamed_clps_aligned_trimmed.fasta.fasttree
    │   └── renamed_clps_aligned_trimmed.fasta.fasttree.png
    ├── Laura_perl
    │   ├── FastTree
    │   ├── FastTree.c
    │   ├── Instructions.txt
    │   ├── lauralib.pm
    │   ├── renamed_clps_aligned_trimmed.fasta
    │   ├── renamed_clps_aligned_trimmed.fasta.fasttree
    │   ├── renamed_clps_aligned_trimmed.fasta.genus_trimmed
    │   ├── renamed_clps_aligned_trimmed.fasta_removedSeq
    │   ├── renamed_clps_aligned_trimmed.fasta_sub
    │   ├── renamed_clps_aligned_trimmed.newick
    │   ├── rm_inparal_rank.pl
    │   ├── taxa_not_remove.txt
    │   ├── taxa_rank.txt
    │   └── trim2untrim.pl
    └── rename
        ├── clps_acc2tax_prot_all.txt
        ├── clps_hits.fasta
        ├── clps_hits_no_description.fasta
        ├── new_renamed_clps_hits.fasta
        ├── renamed_clps_hits.fasta
        ├── rename_ncbi_blastdb.py
        ├── Sample
        │   ├── new_renamed_clps_hits.fasta
        │   ├── renamed_clps_aligned.fasta
        │   ├── renamed_clps_aligned_trimmed.fasta
        │   └── renamed_clps_aligned_trimmed.newick
        └── taxdump.tar.gz


10 directories, 52 files
```
### 3.Limitation
Taxonomy-based dataset trimming might result in biased OTU retention because highly diverse clades may be represented by more leaves than less diverse ones. Also, the TreeTuner pipeline is not fully automated and relies on user-defined OTUs. Nevertheless, we provide a step-by-step solution to guide users who need to trim down their large phylogenetic datasets for more rigorous downstream analysis.

### 4. Reference
- Zhang X., Hu Y., Eme L., Maruyama S.,Eveleigh R.JM, Curtis B.A., Sibbald S.J., Hopkins J.F., Filloramo1 G.V.,Wijk K.J.V., Archibald J.M., 2021.Protocol for TreeTuner: A pipeline for minimizing redundancy and complexity in large phylogenetic datasets. doi: upcoming
- Maruyama, S., Eveleigh, R. J. & Archibald, J. M. 2013. Treetrimmer: a method for phylogenetic dataset size reduction. BMC research notes, 6, 1-6.
- Sibbald, S. J., Hopkins, J. F., Filloramo, G. V. & Archibald, J. M. 2019. Ubiquitin fusion proteins in algae: implications for cell biology and the spread of photosynthesis. BMC genomics, 20, 1-13.

### 5. Copyright
Usage of this pipeline follows GPL-3.0 License. © Copyright (C) 2021. If you think this work is useful, please cite the related references above after using.
