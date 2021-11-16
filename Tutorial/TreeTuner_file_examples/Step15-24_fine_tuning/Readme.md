


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
