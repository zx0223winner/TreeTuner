**Background**

This is definitely a big topic, I sticked around the topic for nearly a month trying to figure out an easy and straight way for future ICG trainees. Although there are some online tools available, such as Treemmer written in python (2018); TreeTrimmer(2013) written in ruby; Laura Eme (2012-14) written in Perl, the pros and cons of them are obvious. As (Menardo et.al 2018) who developed Treemmer summarized:

  - **Tree pruner** is a tool to manually select and prune leaves/branches from a phylogenetic tree. Tree pruner can be very useful for manual curation, however it is not an automatic method, and it relies on subjective decisions by the users.
  - **Treetrimmer** automatically reduces the number of leaves in a tree to few representatives for each user-defined operational taxonomical unit (OTU), like genus or species. However it is based on user-defined OTU.
  - **Treemmer**, a simple tool based on an iterative algorithm to reduce size and evaluate redundancy of phylogenetic datasets. However, it is not related to hierarchical taxonomic terms, because he thought taxonomic categories are only a very rough proxy for genetic diversity. (The third one is what I added)
  - **SHOOT.bio** a single gene family tree. Shoot only offers a range of curated databases. Because they believe: the motivation for encouraging the use of curated databases over defaulting to the BLAST nr database is that these curated databases should make it easier to picture the evolution of the whole gene family rather than overwhelming the tree with thousands of near-identical hits.(I added)

So, I am thinking is there a better way to balance the methods/tools, I am not trying to re-programming and deny what they did. Actually, they did good job on some specific questions. An idea ,suddenly, coming into my mind, which might looks stupid, YES, I decided to name a new pipeline called TreeTuner which aims to combe some of the above methods and realize the coarse and fine-tuning of large phylogenetic datasets via reducing the redundancy and complexity. This might relief my goal on balancing the multiple available methods/tools a little bit.

**References:**

- Tree pruner: An efficient tool for selecting data from a biased genetic database (Krishnamoorthy et.al 2012)

- TreeTrimmer: A method for phylogenetic dataset size reduction (Maruyama et.al 2013)

- Treemmer: A tool to reduce large phylogenetic datasets with minimal loss of diversity (Menardo et.al 2018)

- SHOOT.bio: sprout a branch on the tree of life (David Emms et.al.2021) Preprint. https://shoot.bio

- TreeTuner: A pipeline to coarse and fine-tuning large phylogenetic datasets via reducing the redundancy and complexity (Zhang et.al 2021) 

**Before you begin**

It was tricky than I thought even at the first step. Do I blast the data before renaming the header or after? That does matter. If I blast before renaming the header, I need to pull out the BLAST hits sequence and rename them in a hierarchical taxonomic way. If I blast after the process of renaming the header, I need to rename all the database header in a hierarchical taxonomic way. Lost your mind? never mind! I will show you the difference here.

Here, We will deal with two databases: MMETSP and NCBI-nr. Why MMETSP? Because it included the marine microbial eukaryotic transcripts where NCBI-nr don't have all i.e., lots of algae, lots of Haptophytes, Rhodoophytes. It is also annoying for the different formats of headers. For example:

```
#MMETSP(nucleotide):
head /db1/extra-data-sets/MMETSP/MMETSP_db/MMETSP_DB_clean.v2018.fa
>MMETSP1065-20121228|15685 Amphiprora_paludosa_Strain_CCMP125
CATCGAGTTCATCATCATCGGTGGAATTATCACTGTGATG

#MMETSP(translated protein):
head /misc/scratch3/sibbald/DATABASES/CAM_P_0001000.pep.renamed_nr_db_temp.fas
>CP_0114609912_95228_Vannella_sp_DIVA3_517_6_12
XEIVKGFKKVADLPDAVFGRFVTATFNIVL
``` 

```
#NCBI-nr
#/db1/blastdb-sep1-2021/nr.pal (V5 format, updated Sep 2021)(Blast)
# The latest full nr I used: /misc/scratch3/xizhang/nr-fasta-sep-2021/nr.gz
head /db1/nr-nt-fasta-oct-2020/nr
>PYI97175.1 lysine 2,3-aminomutase [Verrucomicrobia bacterium]PYJ33862.1 lysine 2,3-aminomutase [Verrucomicrobia bacterium]
MITPVSEEGNGKRFVSHAPGFWPQTPTELWNDWKWQLKNRVTSLAHLEQHLDLSDEERSGVLLSGDKLALAVTPHFFNLV
```

I know, it is complicated for each datasets, like the underscore line between the species name (Vannella_sp_DIVA3_517_6_12)is to make sure the BLAST can regard them as a whole for gene name.So that your gene header can contain the taxa information, so that you can pull out the hierarchical taxonomic information. If you look like NCBI-nr, they even don't contain taxa information and the header is even not connected with underscore. **That is the purpose of why we have to do the renaming step.** 

No matter blasting before renaming the header or after, the purpose is the same to acquire the BLAST hits (homolog seqs) from two databases(MMETSP and NCBI). Check the real example below:
```
>Compsopogon_coeruleus@CP_0184679990_Eukaryota_Rhodophyta_Compsopogonophyceae_Compsopogonales_Compsopogonaceae_Compsopogon_Compsopogon_caeruleus_31354_Compsopogon_coeruleus
XNKTVGEKEKVDVGKKGGGGEEREMVGFVSDVFISLNLEWSRVGVGVVNSRGKRKVYAVGEFPGSSPGRTSVLVPQKEKVQKESKEKKRSHGGGKYKVLILNDAFNSMEYVAATLLRLIPGMTTELAWKVMKEAHENGAAVVGVWVFELAEAYCDAIQSAGIGSRIEPE

>Tarenaya_hassleriana@NCBI_XP_010551290.1_Eukaryota_Viridiplantae_Streptophyta_Streptophytina_Embryophyta_Tracheophyta_Euphyllophyta_Spermatophyta_Magnoliopsida_Mesangiospermae_eudicotyledons_Gunneridae_Pentapetalae_rosids_malvids_Brassicales_Cleomaceae_New_World_clade_Tarenaya_Tarenaya_hassleriana_28532
MESAICGRLALSPSTVFNSKPGEKHSLYKGPCGNHGFVMSLCASAVGKGGGLLDKPVIEKTTPGRESEFDLRKSRKMAPPYRVILHNDNFNRREYVVQVLMKVIPGMTLDNAVNIMQEAHHNGLAVVIICAQADAEEHCMQLRGNGLLSSIEPASGGGC
```

**1. Method One: blasting before renaming the header**


  * Step one: BLAST

If you decide to blast before renaming, you can follow the other Perun blast guide (e.g.,http://129.173.88.134:81/dokuwiki/doku.php?id=blast_protocol) to either BLAST the MMETSP database separately or as a whole. Due to the size of the NCBI-nr database (~100 GB), if you merge the NCBI with MMETSP (~10GB), you need to rebuild the Database file such as: 

```
nr.14.phd         nr.14.pin         nr.14.ppi         
nr.14.phi         nr.14.pog         nr.14.psq         
nr.14.phr         nr.14.ppd         nr.14.tar.gz.md5
```

This will be terrible long time doing that, 'cause I have not tested it. I also think it is not worth it unless you want to stick with one version to do intense studies in a period of time. The NCBI-nr version is updated quickly with time. So I prefer to download the latest version of NCBI-Nr, where they have the pre-compiled database files. User can BLASTp against the database without using makeblastdb command. 

Let's say now you have finished the NCBI BLAST and MMETSP blast without renaming the database file at first. You will acquire a bunch of BLAST hits like this (by default, you are using tabular format output):

```
#MMETSP
ATCG00670.1	CP_0184350226_38269_Gloeochaete_wittrockiana	3.32e-76	54.922	98	193	292	196	1	193	98	289	N/A	N/A
ATCG00670.1	CP_0184350226_38269_Gloeochaete_wittrockiana	3.32e-76	54.922	98	193
``` 

```
#NCBI
ATCG00670.1	ref|YP_009356046.1|	8.33e-142	98.980	100	196	196	196	1	196	1	196	ATP-dependent protease subunit [Matthiola incana]	ATP-dependent protease subunit [Matthiola incana]<>ATP-dependent protease subunit [Matthiola longipetala]<>ATP-dependent protease subunit [Matthiola incana]<>ATP-dependent protease subunit [Matthiola longipetala]
ATCG00670.1	ref|YP_009261721.1|	9.51e-142	98.980	100	196	196	196	1	196	1	196	ATP-dependent Clp protease proteolytic subunit [Pugionium dolabratum]	ATP-dependent Clp protease proteolytic subunit [Pugionium dolabratum]<>ATP-dependent Clp protease proteolytic subunit [Pugionium cornutum]<>ATP-dependent Clp protease proteolytic subunit [Pugionium dolabratum]<>ATP-dependent Clp protease proteolytic subunit [Pugionium cornutum]<>ATP-dependent protease subunit [Pugionium pterocarpum]
ATCG00670.1	gb|QKK48680.1|	9.72e-142	98.980	100	196	196	196	1	196	1	196	ATP-dependent protease subunit [Robeschia schimperii]	ATP-dependent protease subunit [Robeschia schimperii]
```

**Note:** It is tricky to blast multiple sequences against database, where you can first split up the fasta file into sub-files to speed up and improve the CPU usage efficiency. Please find more here:http://129.173.88.134:81/dokuwiki/doku.php?id=bioinformatics_tools2

  * Step TWO: retrieve the Fasta sequence from the hits

Why need to do this step, because without the hits sequence at hand, the downstream MAFFT,BMGE, Fasttree,iqtree analysis is not available. As for MMETSP, you can use the python3 script: index_header_to_seq.py. I introduced in (http://129.173.88.134:81/dokuwiki/doku.php?id=phylogeny_protocol)

```
python3 index_header_to_seq.py /misc/scratch3/sibbald/DATABASES/CAM_P_0001000.pep.renamed_nr_db_temp.fas name_list.txt output.fa
#The name list file includes a list of gene name like this: CP_0184350226_38269_Gloeochaete_wittrockiana
```

As for the NCBI, which is huge(~100gb), so the python script does not work well on it. Instead, we can use the powerful NCBI built-in tool. seqkit to do this (a cross-platform and ultrafast toolkit for FASTA/Q file manipulation). 

```
#!/bin/bash
#$ -S /bin/bash
. /etc/profile
#$ -cwd
#$ -pe threaded 2
export PATH=/opt/perun/bin/:$PATH
seqtk subseq /db1/nr-nt-fasta-oct-2020/nr ncbi_id.txt >###_ncbi.fasta

```

Note: If you only have hundreds of hits in a list, you can instead use the NCBI Batch entrez. Please read more from here: http://129.173.88.134:81/dokuwiki/doku.php?id=phylogeny_protocol

  * Step Three: retrieve the taxa information from the protein sequence header

As for the MMETSP gene header which already contain the taxa information. e.g. "CP_0184350226_38269_Gloeochaete_wittrockiana" taxa ID: 38269. But for NCBI ID, it only contains the protein ID like this: ref|YP_009356046.1|. So you have to use the YP_009356046.1 to retrieve the taxa ID for this species. 

  - Please find the usage of acc2tax here: http://129.173.88.134:81/dokuwiki/doku.php?id=taxonomy_recovery
  - acc2tax :Given a file of accessions or Genbank IDs (one per line), this program will return a taxonomy string for each. https://github.com/richardmleggett/acc2tax
  - The directory of the tool: /misc/db1/extra-data-sets/Acc2tax/Acc2tax_092021 (Up to date Sep 20, 2021) 
  - The taxa information is updated by NCBI weekly via https://ftp.ncbi.nih.gov/pub/taxonomy/; https://ftp.ncbi.nlm.nih.gov/pub/taxonomy/

```
acc2tax -i /db1/extra-data-sets/Acc2tax/name_list.txt -p -d /misc/db1/extra-data-sets/Acc2tax/Acc2tax_092021 -o taxonomy.out
```

```
# name_list.txt
XP_011133305
KMU79707
XP_002963095
XP_021355212
WP_058500112
XP_009035520
WP_072908694
WP_057954045
```

```
# taxonomy.out
XP_011133305	cellular organisms,Eukaryota,Alveolata,Apicomplexa,Conoidasida,Gregarinasina,Eugregarinorida,Gregarinidae,Gregarina,Gregarina niphandrodes
KMU79707	cellular organisms,Eukaryota,Opisthokonta,Fungi,Dikarya,Ascomycota,saccharomyceta,Pezizomycotina,leotiomyceta,Eurotiomycetes,Eurotiomycetidae,Onygenales,Onygenales incertae sedis,Coccidioides,Coccidioides immitis,Coccidioides immitis RMSCC 3703
```

Note: If you only have hundreds of hits in a list, you can instead use the Taxonomy Common Tree - NCBI. Please read more from here: (http://129.173.88.134:81/dokuwiki/doku.php?id=phylogeny_protocol3)(https://www.ncbi.nlm.nih.gov/Taxonomy/CommonTree/wwwcmt.cgi)

Thanks for keeping reading until here, LOL don't forget our goal is to acquire the header like this:

```
>Compsopogon_coeruleus@CP_0184679990_Eukaryota_Rhodophyta_Compsopogonophyceae_Compsopogonales_Compsopogonaceae_Compsopogon_Compsopogon_caeruleus_31354_Compsopogon_coeruleus
XNKTVGEKEKVDVGKKGGGGEEREMVGFVSDVFISLNLEWSRVGVGVVNSRGKRKVYAVGEFPGSSPGRTSVLVPQKEKVQKESKEKKRSHGGGKYKVLILNDAFNSMEYVAATLLRLIPGMTTELAWKVMKEAHENGAAVVGVWVFELAEAYCDAIQSAGIGSRIEPE

>Tarenaya_hassleriana@NCBI_XP_010551290.1_Eukaryota_Viridiplantae_Streptophyta_Streptophytina_Embryophyta_Tracheophyta_Euphyllophyta_Spermatophyta_Magnoliopsida_Mesangiospermae_eudicotyledons_Gunneridae_Pentapetalae_rosids_malvids_Brassicales_Cleomaceae_New_World_clade_Tarenaya_Tarenaya_hassleriana_28532
MESAICGRLALSPSTVFNSKPGEKHSLYKGPCGNHGFVMSLCASAVGKGGGLLDKPVIEKTTPGRESEFDLRKSRKMAPPYRVILHNDNFNRREYVVQVLMKVIPGMTLDNAVNIMQEAHHNGLAVVIICAQADAEEHCMQLRGNGLLSSIEPASGGGC
```

So two python scripts(renaming_MMETSP.py and renaming_NCBI.py) are needed to proceed MMETSP and NCBI-nr,respectively, because they have very different naming format. 

Now I will introduce the usage of two Python scripts working on the naming issues. Let me clarify what you need to proceed this step again.

 * Input files for MMETSP:
    - A tabular file merged with all the genes' blast hits: merged_blast_mmetsp.txt
    - The fasta seq for all the hits: out_mmetsp.fasta
    - taxdump.tar.gz: https://ftp.ncbi.nlm.nih.gov/pub/taxonomy/

``` 
# merged_blast_mmetsp.txt
ATCG00670.1	CP_0184350226_38269_Gloeochaete_wittrockiana	3.32e-76	54.922	98	193	292	196	1	193	98	289	N/A	N/A
ATCG00670.1	CP_0184350226_38269_Gloeochaete_wittrockiana	3.32e-76	54.922	98	193	292	196	1	193	98	289	N/A	N/A
ATCG00670.1	CP_0184656932_38269_Gloeochaete_witrockiana	4.26e-76	54.922	98	193
```

```
# out_mmetsp.fasta
>CP_0113232432_97485_Prymnesium_parvum
XLRCLTRTPSLPSRLLATATPSRACPALSSALHRXASSAAFLRPSASASSCPSRCLSSTSRAPGASGSTQRAIPSXGGANGGWVNPLARPKGESLKKYGTDLNELARAGRLDPVIGRDEEIRRMVQVLSRRRKNNPVLIGEPGVGKTAIVEGLAQRIVDKEVPDSMRDARVIALDVGALVAGAKYRGEFE
```

```
#taxdump.tar.gz
citations.dmp	division.dmp	gencode.dmp	names.dmp	readme.txt
delnodes.dmp	gc.prt		merged.dmp	nodes.dmp
```

Then run the python script renaming_MMETSP.py(link upcoming soon).

```
python3 renaming_MMETSP.py
```

The output fasta file will be like this:

```
>Compsopogon_coeruleus@CP_0184679990_Eukaryota_Rhodophyta_Compsopogonophyceae_Compsopogonales_Compsopogonaceae_Compsopogon_Compsopogon_caeruleus_31354_Compsopogon_coeruleus
XNKTVGEKEKVDVGKKGGGGEEREMVGFVSDVFISLNLEWSRVGVGVVNSRGKRKVYAVGEFPGSSPGRTSVLVPQKEKVQKESKEKKRSHGGGKYKVLILNDAFNSMEYVAATLLRLIPGMTTELAWKVMKEAHENGAAVVGVWVFELAEAYCDAIQSAGIGSRIEPE
```


 * Input files for NCBI:
   - A tabular file merged with all the genes' blast hits: merged_ncbi.txt
   - The fasta seq for all the hits: new.merged_ncbi.fasta
   - taxdump.tar.gz: https://ftp.ncbi.nlm.nih.gov/pub/taxonomy/
   - merged_taxon.txt

Since NCBI has different header, so the merged_taxon.txt is needed. It was acquired via retrieve the all the hits' gene names from /misc/db1/extra-data-sets/Acc2tax/Acc2tax_092021/acc2tax_prot_all.txt file.

```
# merged_taxon.txt
A1BI15	A1BI15.1	290317	166201813
A1WR17	A1WR17.1	391735	166214720
A4J7L9	A4J7L9.1	349161	172044337
A5D447	A5D447.1	370438	259585961
A6SY74	A6SY74.1	375286	226706516
A8F754	A8F754.1	416591	167008651
A8WPG6	A8WPG6.2	6238	300681014
```

Then run the script (link upcoming):
```
python3 renaming_NCBI.py
```

The output file will be look like this:
```
>Tarenaya_hassleriana@NCBI_XP_010551290.1_Eukaryota_Viridiplantae_Streptophyta_Streptophytina_Embryophyta_Tracheophyta_Euphyllophyta_Spermatophyta_Magnoliopsida_Mesangiospermae_eudicotyledons_Gunneridae_Pentapetalae_rosids_malvids_Brassicales_Cleomaceae_New_World_clade_Tarenaya_Tarenaya_hassleriana_28532
MESAICGRLALSPSTVFNSKPGEKHSLYKGPCGNHGFVMSLCASAVGKGGGLLDKPVIEKTTPGRESEFDLRKSRKMAPPYRVILHNDNFNRREYVVQVLMKVIPGMTLDNAVNIMQEAHHNGLAVVIICAQADAEEHCMQLRGNGLLSSIEPASGGGC
```

Finally, (～￣▽￣)～ we have the desired BLAST hits headers from both MMETSP and NCBI-nr containing the hierarchical taxonomic terms. You can then merge the two files to play around what you are most familiar with seq aligning, seq trimming, and tree building. please read more http://129.173.88.134:81/dokuwiki/doku.php?id=phylogeny_protocol

But after all of these, you will need the step to color your newick tree. Please find this script color_newick_tree.py via http://129.173.88.134:81/dokuwiki/doku.php?id=phylogeny_protocol4

**2. Method Two: blasting after renaming the header**

Still remember we mentioned earlier due to the different naming strategy, we have to decide to blast before renaming the header or after? If you have read the Method One, you might feel it is from simple to complex. However, the Method TWO is from complex to simple, because it will take much longer than you thought to prepare the input files. But once you done, the rest of things could be much easier. Ok, let me stop eating around the corner. Our goal is to actually recreate the NCBI and MMETSP database headers like this:

```
>Compsopogon_coeruleus@CP_0184679990_Eukaryota_Rhodophyta_Compsopogonophyceae_Compsopogonales_Compsopogonaceae_Compsopogon_Compsopogon_caeruleus_31354_Compsopogon_coeruleus
XNKTVGEKEKVDVGKKGGGGEEREMVGFVSDVFISLNLEWSRVGVGVVNSRGKRKVYAVGEFPGSSPGRTSVLVPQKEKVQKESKEKKRSHGGGKYKVLILNDAFNSMEYVAATLLRLIPGMTTELAWKVMKEAHENGAAVVGVWVFELAEAYCDAIQSAGIGSRIEPE

>Tarenaya_hassleriana@NCBI_XP_010551290.1_Eukaryota_Viridiplantae_Streptophyta_Streptophytina_Embryophyta_Tracheophyta_Euphyllophyta_Spermatophyta_Magnoliopsida_Mesangiospermae_eudicotyledons_Gunneridae_Pentapetalae_rosids_malvids_Brassicales_Cleomaceae_New_World_clade_Tarenaya_Tarenaya_hassleriana_28532
MESAICGRLALSPSTVFNSKPGEKHSLYKGPCGNHGFVMSLCASAVGKGGGLLDKPVIEKTTPGRESEFDLRKSRKMAPPYRVILHNDNFNRREYVVQVLMKVIPGMTLDNAVNIMQEAHHNGLAVVIICAQADAEEHCMQLRGNGLLSSIEPASGGGC
```

Then use makeblastdb command to make the database compiled files. Considering the size of NCBI ~100Gb and the MMETSP (~10GB), I have not really tested myself. But i assume it might take at least three days running. Here, I will simply provide the method for you to feel free to use.

* As for MMETSP, the translated database header is like this: 

```
>CP_0113232432_97485_Prymnesium_parvum
```

To pull out the taxa information, use the new python script rename_mmetsp_blastdb.py (links upcoming soon)

```
python3 rename_mmetsp_blastdb.py
```

Error1:
```
#Note: if not python v3, it will be error 
ImportError: No module named ete3
```

Error2:
```
from PyQt5 import QtGui, QtCore
RuntimeError: the PyQt5.QtCore and PyQt4.QtCore modules both wrap the QObject class
```

To solve above error:use python3
```
source activate Unicycler-python3
pip install six
```

Fist time running the script on MacOS, it might generate an error. (https://stackoverflow.com/questions/50236117/scraping-ssl-certificate-verify-failed-error-for-http-en-wikipedia-org) This will need you to allow the Macintosh HD > Applications > Python3.8 > double click on "Install Certificates.command"

```
####@TE809 ~ % /Applications/Python\ 3.9/Install\ Certificates.command ; exit;
 -- pip install --upgrade certifi
Requirement already satisfied: certifi in /Library/Frameworks/Python.framework/Versions/3.9/lib/python3.9/site-packages (2021.10.8)
 -- removing any existing file or link
 -- creating symlink to certifi certificate bundle
 -- setting permissions
 -- update complete
Saving session...
...copying shared history...
...saving history...truncating history files...
...completed.
```

```
#running
/misc/scratch2/###/arabidopsis/CAM_MMETSP@perun3> python3 rename_mmetsp_blastdb.py 
NCBI database not present yet (first time used?)
Updating taxdump.tar.gz from NCBI FTP site (via HTTP)...
Done. Parsing...
Loading node names...
2369147 names loaded.
253927 synonyms loaded.
Loading nodes...
```

Then the latest taxdump.tar.gz will be downloaded via ETE3 package. The output file will be like this:

```
>Prymnesium_parvum@CP_0113232432_Eukaryota_Haptista_Haptophyta_Prymnesiophyceae_Prymnesiales_Prymnesiaceae_Prymnesium_Prymnesium_parvum_97485_Prymnesium_parvum
XLRCLTRTPSLPSRLLATATPSRACPALSSALHRXASSAAFLRPSASASSCPSRCLSSTSRAPGASGSTQRAIPSXGGANGGWVNPLARPKGESLKKYGTDLNELARAGRLDPVIGRDEEIRRMVQVLSRRRKNNPVLIGEPGVGKTAIVEGLAQRIVDKEVPDSMRDARVIALDVGALVAGAKYRGEFEXRLKAVLADVSEAAGDVILFIDELHTVIGAGAADGAMDASNLLKPQLARGELSCVGATTLX
>Prymnesium_parvum@CP_0113233658_Eukaryota_Haptista_Haptophyta_Prymnesiophyceae_Prymnesiales_Prymnesiaceae_Prymnesium_Prymnesium_parvum_97485_Prymnesium_parvum
VASRXCEADDXAAAEGTRAVAMLPRLAIYLFAPLASASLVQLPQWPQRRLSPAGRLGLRPLPAAPRGSGQVQMVFDRFDRDAMRLVMDAQVEARKLGGSAVGTEHLLLAGTMQADAIQQALDRAGVKASGVRDAIRGPGGGSIPSLDGLFGLKAKDELLP
```

* As for NCBI-NR, the translated database header is like this:

```
>WP_048801694.1	ATP-dependent Clp protease ATP-binding subunit [Leuconostoc citreum]GEK62024.1 ATP-dependent Clp protease ATP-binding subunit ClpC [Leuconostoc citreum]
MDNKYTSSAQNVLVLAQEQAKYFKHQAVGTEHLLLALAIEKEGIASKILGQFNVTDDDIREEIEHFTGYGM
```

```
#So simply run 
python3 rename_ncbi_blastdb.py (link upcoming soon). 
#The input file will include:
        fastaFile = '/db1/nr-nt-fasta-oct-2020/nr'
        taxidFile = '/misc/db1/extra-data-sets/Acc2tax/Acc2tax_092021/acc2tax_prot_all.txt'
```

Then the desired output will be:

```
>Leuconostoc_citreum@NCBI_WP_048801694.1_Bacteria_Terrabacteria_group_Firmicutes_Bacilli_Lactobacillales_Lactobacillaceae_Leuconostoc_Leuconostoc_citreum_33964
MDNKYTSSAQNVLVLAQEQAKYFKHQAVGTEHLLLALAIEKEGIASKILGQ
```

Directory to renamed MMETSP: /misc/scratch2/###/###/mmetsp

Then with the two renamed database available, you could merge then by 'cat'. Then build the new merged database via 'makeblastdb'. Then Blast them again.8-)

**3.Minimizing the redundancy and complexity of large phylogenetic datasets**

Finally, after using two different methods, we can touch on the topic we raised up at very beginning. Coarse and fine-tuning large phylogenetic datasets via reducing the redundancy and complexity. 

1. **Coarse-tuning**: Let's start with the relatively simple one coarse-tuning via Treetrimmer (Maruyama et.al 2013)

```
ruby treetrimmer.rb sample/####_aligned_trimmed.newick sample/###_parameter_input.in sample/taxonomic_info.txt > ###_treetrimmer.newick
```

The "##..newick" and "###input.in" files can easily be prepared. The taxonomic_info.txt;however need to reformatted.

```
taxonomic_info.txt
NP_563657	Eukaryota; Viridiplantae; Streptophyta; Streptophytina; Embryophyta; Tracheophyta; Euphyllophyta; Spermatophyta; Magnoliopsida; Mesangiospermae; eudicotyledons; Gunneridae; Pentapetalae; rosids; malvids; Brassicales; Brassicaceae; Camelineae; Arabidopsis; Arabidopsis thaliana
XP_002889406	Eukaryota; Viridiplantae; Streptophyta; Streptophytina; Embryophyta; Tracheophyta; Euphyllophyta; Spermatophyta; Magnoliopsida; Mesangiospermae; eudicotyledons; Gunneridae; Pentapetalae; rosids; malvids; Brassicales; Brassicaceae; Camelineae; Arabidopsis; Arabidopsis lyrata; Arabidopsis lyrata subsp. lyrata
```

The taxonomic_info.txt can be created by acc2tax program. please read more from here:http://129.173.88.134:81/dokuwiki/doku.php?id=phylogeny_protocol3

__Note: The acc2tax need the gene ID without version (e.g.NP_563657), so as the NCBI ID.__ Please find the usage of the program: http://129.173.88.134:81/dokuwiki/doku.php?id=taxonomy_recovery; http://129.173.88.134:81/dokuwiki/doku.php?id=phylogeny_protocol3

```
>WP_048801694.1	ATP-dependent Clp protease ATP-binding subunit [Leuconostoc citreum]GEK62024.1 ATP-dependent Clp protease ATP-binding subunit ClpC [Leuconostoc citreum]
MDNKYTSSAQNVLVLAQEQAKYFKHQAVGTEHLLLALAIEKEGIASKILGQFNVTDDDIREEIEHFTGYGM
```

With the taxonomic_info.txt ready, you can get the tree file and another taxa file:
```
XP_026407875	Eukaryota; Viridiplantae; Streptophyta; Streptophytina; Embryophyta; Tracheophyta; Euphyllophyta; Spermatophyta; Magnoliopsida; Mesangiospermae; Ranunculales; Papaveraceae; Papaveroideae; Papaver; Papaver somniferum	2	4
XP_034682772	Eukaryota; Viridiplantae; Streptophyta; Streptophytina; Embryophyta; Tracheophyta; Euphyllophyta; Spermatophyta; Magnoliopsida; Mesangiospermae; eudicotyledons; Gunneridae; Pentapetalae; rosids; rosids incertae sedis; Vitales; Vitaceae; Viteae; Vitis; Vitis riparia	2
```

This tree give a rough tree diversity estimation.


2. **Fine-tuning**  Laura Eme (2012-14) written in Perl

```

#!/bin/bash
#$ -S /bin/bash
. /etc/profile
#$ -cwd
#$ -o logfile
#$ -pe threaded 20
#export PATH=/scratch2/software/anaconda/bin:$PATH

while read line
do

mafft --auto --thread 20 /misc/scratch2/####/$line.fasta >/misc/scratch2/####/aligned/$line.aligned.fasta

/scratch2/software/anaconda/envs/bmge/bin/bmge -i /misc/scratch2/####/aligned/$line.aligned.fasta -t AA -m BLOSUM30 -of /misc/scratch2/xizhang/####/trimmed/$line.aligned.trimmed.fasta

FastTree /misc/scratch2/####/trimmed/$line.aligned.trimmed.fasta > /misc/scratch2/####/fasttree/$line.aligned.trimmed.newick

done <$1
```

let's say after the mafft,bmge,fasttree steps. You have the trimmed alignment and new wick tree. Now let's use the perl script to prune the leaves or trim the branches.

```
# These are files you will need. (links upcoming soon)
# rm_inparal_rank.pl	taxa_rank.txt
# taxa_not_remove.txt	trim2untrim.pl Instructions.txt lauralib.pm

>perl rm_imparalogs <tree file> <alignment file> <distance cutoff> [taxa not to remove> <taxa rank>
#Will remove sister sequences from the same rank. Will ignore taxa in the list "taxa not to remove".
```

It will yield the documents "###.removedSeq" and "###.fasttree".

```
> perl trim2untrim.pl [trimmed alignement] [untrimmed alignment]
#Will remove sequences from the untrimmed alignement based on sequences present in the trimmed alignement
```

Based on the trimmed aligned seq, you can re-analysis more rigorous downstream IQ-tree analysis.

Note: not all genes' species have taxa.This have nothing to do with the updates of NCBI taxonomy.

The '0' in Gene name 'CP_0177652116_0_Stygamoeba_regulata_BSH-02190019' is not a NCBI taxid. 


<Last updated by Xi Zhang on Oct 6th,2021>
