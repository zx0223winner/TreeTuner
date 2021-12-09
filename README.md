[![run with conda](http://img.shields.io/badge/run%20with-conda-3EB049?labelColor=000000&logo=anaconda)](https://docs.conda.io/en/latest/)
[![License](https://img.shields.io/badge/licence-GPLv3-blue)](https://www.gnu.org/licenses/gpl-3.0.en.html)

# TreeTuner
A pipeline to coarse and fine-tuning large phylogenetic datasets via minimizing the redundancy and complexity
<img src="https://github.com/zx0223winner/TreeTuner/blob/main/TreeTuner_workflow.jpg" alt="TreeTuner" width="3200px" height="">

### 1. What is TreeTuner Pipeline?
The TreeTuner pipeline combines the software and tools required for both coarse- and fine-scale tuning. 

- For coarse tuning, TreeTrimmer (Maruyama et al., 2013) can be downloaded from the web (https://code.google.com/archive/p/treetrimmer/). To run TreeTrimmer locally, pre-installed Ruby (i.e., Ruby v2.5.1) is required. 

```ruby
Usage: ruby treetrimmer.rb [Newick_tree_file] [Parameter_input_file] [Taxonomic_information_file] > output_file
```
- For fine tuning, the necessary custom Perl scripts (rm_inparal_rank.pl and trim2untrim.pl) and Python script (rename_ncbi_blastdb.py) can be found at the following GitHub website: https://github.com/zx0223winner/TreeTuner/tree/main/Tutorial/TreeTuner_file_examples/Step15-24_fine_tuning/Laura_perl. Pre-installed Perl (e.g., Perl 5) is required to run these scripts. 

```perl
#Renaming the header of protein ID so as to pull out the taxonomic terms in the header.
Usage:python3 rename_ncbi_blastdb.py <FASTA File> <Taxon Id FILE> <Renamed FASTA File>

Usage: perl rm_inparal_rank.pl [tree file] [alignment file] [distance cutoff] [taxa not to remove] [taxa rank]
Usage: perl trim2untrim.pl [trimmed alignement] [untrimmed alignment]
```
- To color the Newick tree, the Environment for Tree Exploration (ETE3) toolkit (Huerta-Cepas et al., 2016) and associated Python scripts (e.g., color_coarse_tuning_tree.py and color_fine_tuning_tree.py) are needed. 

```python
Usage: python3 color_coarse_tuning_tree.py <taxonomic_info_file> <newick_tree_file>
Usage: python3 color_fine_tuning_tree.py <newick_tree_file> 
```

### 2. Computational Requirement
TreeTuner users will also need the Linux environment (e.g., Ubuntu 20.04 LTS) to run their BLAST searches (Altschul et al., 1997). The MAFFT v7(Katoh and Standley, 2013), BMGE v1.12 (Criscuolo and Gribaldo, 2010), trimAl v1.4 (Capella-Gutiérrez et al., 2009), FastTree v2.1 (Price et al., 2010) and IQ-TREE v1.6.12 (Nguyen et al., 2015)


#### 2.1 Dependencies and versions

`Preparing the BLAST results`:
1. [Linux environment (e.g., Ubuntu 20.04 LTS)](https://ubuntu.com/download/desktop)
2. [BLAST searches (e.g., ncbi-blast-2.12.0)](https://ftp.ncbi.nlm.nih.gov/blast/executables/blast+/LATEST/)
3. [NCBI-nr BLAST v5 database](https://ftp.ncbi.nlm.nih.gov/blast/db) 
4. [Batch Entrez](https://www.ncbi.nlm.nih.gov/sites/batchentrez) 
5. [SeqKit](https://bioinf.shenwei.me/seqkit/) 

`Coarse-tuning pipeline`:
1. [Ruby v2.5.1](https://www.ruby-lang.org/en/downloads/)
2. [acc2tax](https://github.com/richardmleggett/acc2tax) 
3. [NCBI taxonomy database](https://ftp.ncbi.nih.gov/pub/taxonomy/)
4. [TreeTrimmer](https://github.com/zx0223winner/TreeTuner/tree/main/Tutorial/TreeTuner_file_examples/Step11-14_coarse_tuning)

`Fine-tuning pipeline`:
1. [Perl 5](https://www.perl.org/get.html)
2. [Python 3](https://www.python.org/downloads/)
3. [Laura_perl](https://github.com/zx0223winner/TreeTuner/tree/main/Tutorial/TreeTuner_file_examples/Step15-24_fine_tuning/Laura_perl)
4. [rename_ncbi_blastdb.py](https://github.com/zx0223winner/TreeTuner/tree/main/Tutorial/TreeTuner_file_examples/Step15-24_fine_tuning/rename)

`Build a preliminary tree`: 
1. [MAFFT v7](https://mafft.cbrc.jp/alignment/software/) 
2. [BMGE v1.12](https://bio.tools/bmge) 
3. [trimAl v1.4](http://trimal.cgenomics.org)
4. [FastTree v2.1](http://www.microbesonline.org/fasttree/)
5. [IQ-TREE v1.6.12](http://www.iqtree.org)

`Color the Newick Tree`:
1. [python3](https://www.python.org/downloads/)
2. [ETE3 toolkit](http://etetoolkit.org/download/)
3. [color_coarse_tuning_tree.py](https://github.com/zx0223winner/TreeTuner/tree/main/Tutorial/TreeTuner_file_examples/Step11-14_coarse_tuning/color_tree)
4. [color_fine_tuning_tree.py](https://github.com/zx0223winner/TreeTuner/tree/main/Tutorial/TreeTuner_file_examples/Step15-24_fine_tuning/color_tree)

### 3. Instructions for adjusting parameters in Coarse- and fine-tuning pipeline

Here is an example file (i.e., clps_paramer_input.in) for the parameters in `coarse-tuning pepiline`
```
### TreeTrimmer parameter input file

### The cutoff value for de-replication (greater than this and will assess for removal)
# Specify a cutoff of support values (e.g. bootstrap values, posterior probability)
# either in integer (0-100) or decimal (0.0-1.0).
# Leave it blank or use default (0.0) for trees with no branch supports.

cutoff=0.0

### Query tag (optional: default is "query_tag=QUERY")
# If a tree includes a 'query' OTU, which is used as a reference 
# and is supposed to be retained after the de-replication process, 
# a string in the OTU name can be specified as a tag to avoid removal 

query_tag=564937

### Delimiter for categories of the taxonomic information
# (default: "taxon_delimiter=;\s" [semicolon plus single space])
# Only use regular expression for a space character

taxon_delimiter=;\s 

### Which taxonomic categories should be pruned? How many OTUs should be retained?
# The category information can be provided in Taxonomic_information_file,
# otherwise OTU names are used as labels of taxonomic information.
# example: Bacteria	2 (tab-delimited)

Bacteria	4
Archaea	3
Eukaryota	1

### How many OTUs should be retained in each supported branch of the tree unless specified above?

num_retained=1
```

Here is the guide for setting the parameters in `fine-tuning pepiline`
```
#### Trim your tree specifically to reduce taxonomic redundancy

## 'taxa_not_remove.txt' contains a list of taxa/phyla you don't want to reduce 
#(script looks for match to strings provided here)
564937.1
Rhodophyta
Haptista

## 'taxa_rank.txt' contains information on how to reduce specific genera/phyla/kingdoms...
#the way I have it, it will reduce at the phyla/class  (0 = domain, 1 = kingdom, 2 = phyla, 3 = subclade/class etc.)
#(e.g.,Eukaryota(0),Viridiplantae(1),Streptophyta(2),Streptophytina(3),etc..)
Bacteria 3
Archaea 2
Eukaryota 3

# The taxa rank is determined based on specific header formats as follows:
>Arabidopsis_thaliana@NCBI_NP_564937.1_Eukaryota_Viridiplantae_Streptophyta_Streptophytina_Embryophyta_Tracheophyta_Euphyllophyt a_Spermatophyta_Magnoliopsida_Mesangiospermae_eudicotyledons_Gunneridae_Pentapetalae_rosids_malvids_Brassicales_Brassicaceae_Ca

	
## 1.0 is the distance cutoff you want to consider 
#(less than this and will assess for removal)
>rm_inparal_rank.pl $FASTTREE $ALIGNEMNET 1.0 taxa_not_remove.txt taxa_rank.txt
>perl rm_inparal_rank.pl renamed_clps_aligned_trimmed.newick renamed_clps_aligned_trimmed.fasta 1.0 taxa_not_remove.txt taxa_rank.txt

## Then you run the following script to go from Will remove sequences 
#from the untrimmed alignement based on sequences present in the trimmed alignement
>trim2untrim.pl $GENE.qalign.genus_trimmed $GENE.qalign
# OR
>trim2untrim.pl $GENE.qalign.genus_trimmed $GENE.original.fasta

# e.g.,
>perl trim2untrim.pl renamed_clps_aligned_trimmed.fasta.genus_trimmed renamed_clps_aligned_trimmed.fasta
```

### 4. File index

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
│   ├── clps_aligned_trimmed.newick__AT1G68660.1_parameter_input.in.tt0.0.tre
│   ├── clps_treetrimmer.out
│   ├── color_tree
│   │   ├── AT1G68660.1_aligned_trimmed.newick__AT1G68660.1_parameter_input.in.tt0.0.tre.png
│   │   ├── clps_aligned_trimmed.newick__AT1G68660.1_parameter_input.in.tt0.0.tre
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
### 5.Limitations
Taxonomy-based dataset trimming might result in biased OTU retention because highly diverse clades may be represented by more leaves than less diverse ones. Also, the TreeTuner pipeline is not fully automated and relies on user-defined OTUs. Nevertheless, we provide a step-by-step solution to guide users who need to trim down their large phylogenetic datasets for more rigorous downstream analysis.

### 6. References
- Zhang X., Hu Y., Eme L., Maruyama S.,Eveleigh R.JM, Curtis B.A., Sibbald S.J., Hopkins J.F., Filloramo1 G.V.,Wijk K.J.V., Archibald J.M., 2021.Protocol for TreeTuner: A pipeline for minimizing redundancy and complexity in large phylogenetic datasets. doi: upcoming
- Maruyama, S., Eveleigh, R. J. & Archibald, J. M. 2013. Treetrimmer: a method for phylogenetic dataset size reduction. BMC research notes, 6, 1-6.
- Sibbald, S. J., Hopkins, J. F., Filloramo, G. V. & Archibald, J. M. 2019. Ubiquitin fusion proteins in algae: implications for cell biology and the spread of photosynthesis. BMC genomics, 20, 1-13.

### 7. Copyright
Usage of this pipeline follows GPL-3.0 License. © Copyright (C) 2021. If you think this work is useful, please cite the related references above after using.
