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







 >Rhodomonas@CP_0177693722_Eukaryota_Alveolata_Dinophyceae_Suessiales_Symbiodiniaceae_Symbiodinium_zzz_CP_0181467638_174948_Symbiodinium_sp_CCMP421_354590_Rhodomonas_lens_RHODO

354590 = Eukaryota_Alveolata_Dinophyceae_Suessiales_Symbiodiniaceae_Symbiodinium_zzz_CP_0181467638_174948_Symbiodinium_sp_CCMP421


>Symbiodinium_sp@CP_0181467638_Eukaryota_Alveolata_Dinophyceae_Suessiales_Symbiodiniaceae_Symbiodinium_zzz_CP_0181467638_174948_Symbiodinium_sp_CCMP421







For example from MMETPSP:
>Symbiodinium_sp@Eukaryota_Alveolata_Dinophyceae_Suessiales_Symbiodiniaceae_Symbiodinium_zzz_CP_0181467638_174948_Symbiodinium_sp_CCMP421

Rhodomonas_ap@354590_CP_0177693722_354590_Rhodomonas_lens_RHODO

354590 

For example from nr:
>Bradyrhizobium_sp.@_Bacteria_Proteobacteria_Alphaproteobacteria_Rhizobiales_Bradyrhizobiaceae_zzz_WP_106942509.1_carnitine_dehydratase



So your header >MMETSP0484-20121128|722 Rhodomonas_lens_Strain_RHODO
In my renamed, translated database is: >CP_0177693722_354590_Rhodomonas_lens_RHODO

CP identifies that it is from MMETPS, 354590 is the NCBI taxID. The number 722 is related to the actual MMETSP sample identification I believe. 


>NP_563657_cellular_organisms_Eukaryota_Viridiplantae_Streptophyta_Streptophytina_Embryophyta_Tracheophyta_Euphyllophyta_Spermatophyta_Magnoliopsida_Mesangiospermae_eudicotyledons_Gunneridae_Pentapetalae_rosids_malvids_Brassicales_Brassicaceae_Camelineae_Arabidopsis_Arabidopsis thaliana
