
#### For fine tuning, the necessary custom Perl scripts (rm_inparal_rank.pl and trim2untrim.pl) and Python script (rename_ncbi_blastdb.py, color_fine_tuning_tree.py) are needed. 

1. Renaming the header of protein ID so as to pull out the taxonomic terms in the header.
```
#in the folder "rename"
Usage:python3 rename_ncbi_blastdb.py <FASTA File> <Taxon Id FILE> <Renamed FASTA File>
e.g., python3 rename_ncbi_blastdb.py clps_hits_no_description.fasta clps_acc2tax_prot_all.txt renamed_clps_hits.fasta
```

2. Fine-tuning scripts and the guide for setting the parameters in `fine-tuning pepiline
```
#in the folder "Laura_perl"
Usage: perl rm_inparal_rank.pl [tree file] [alignment file] [distance cutoff] [taxa not to remove] [taxa rank]
Usage: perl trim2untrim.pl [trimmed alignement] [untrimmed alignment]
```

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





3. To color the Newick tree, the Environment for Tree Exploration (ETE3) toolkit (Huerta-Cepas et al., 2016) and associated Python scripts (e.g.,  color_fine_tuning_tree.py) are needed. 

```
#in the folder "color-tree"
Usage: python3 color_fine_tuning_tree.py <newick_tree_file> 
```
