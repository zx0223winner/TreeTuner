#### Trim your tree to reduce taxonomic redundancy  ####

	## 'taxa_not_remove.txt' contains a list of taxa/phyla you don't want to reduce (script looks for match to strings provided here)

	## 'taxa_rank.txt' contains information on how to reduce specific genera/phyla/kingdoms... the way I have it, it will reduce at the phyla/class  (0 = domain, 1 = kingdom, 2 = phyla/class etc.)


	# the taxa rank is determined based on specific header formats as follows and the perl script will need to be modified if your header differs 

	# >Symbiodinium_sp@CP_0181467638_Eukaryota_Alveolata_Dinophyceae_Suessiales_Symbiodiniaceae_Symbiodinium_zzz_CP_0181467638_174948_Symbiodinium_sp_CCMP421
	
	# 1.0 is the distance cutoff you want to consider (greater than this and won't assess for removal)
	rm_inparal_rank.pl $FASTTREE $ALIGNEMNET 1.0 taxa_not_remove.txt taxa_rank.txt
	
	
	## Then you run the following script to go from Will remove sequences from the untrimmed alignement based on sequences present in the trimmed alignement

	#trim2untrim.pl [trimmed alignement (.genus_trimmed)] [untrimmed alignment (original alignment or unaligned FASTA File)]

	trim2untrim.pl $GENE.qalign.genus_trimmed $GENE.qalign
	# OR
	trim2untrim.pl $GENE.qalign.genus_trimmed $GENE.original.fasta



perl rm_inparal_rank.pl renamed_clps_aligned_trimmed.newick renamed_clps_aligned_trimmed.fasta 10 taxa_not_remove.txt taxa_rank.txt

perl trim2untrim.pl renamed_clps_aligned_trimmed.fasta.genus_trimmed renamed_clps_aligned_trimmed.fasta
