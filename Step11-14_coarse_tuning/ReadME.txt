This is the readme file for TreeTrimmer.

TreeTrimmer, a bioinformatics procedure that removes unnecessary redundancy in large phylogenetic datasets, reducing the size effect on more rigorous downstream analyses. The method identifies and removes user-defined ‘redundant’ sequences, e.g., orthologous sequences from closely related organisms and ‘recently’ evolved lineage-specific paralogs. Representative OTUs are retained for more rigorous re-analysis.

To run this script you will need a working installation of Ruby (www.ruby-lang.org; tested with v1.8.7) and BioRuby (www.bioruby.org; tested with v1.3.0).

Type " ruby treetrimmer.rb " to see the usage. A typical command might look like: " ruby treetrimmer.rb [Newick_tree_file] [Parameter_input_file] [Taxonomic_information_file (option)] > output_file".

Notes:
1) Branches with support values (e.g. bootstrap value, posterior probability) equal to or greater than a user-specified cutoff are pruned. Specify a cutoff of support values (e.g. bootstrap values, posterior probability) either in integer (0-100) or decimal (0.0-1.0). In case trees without support values are used, leave it blank or use the default value (0.0), then the tree is pruned by using taxonomic infomation only.

2) If a tree includes a 'query' OTU, which is used as a reference and is supposed to be retained after the de-replication process, a string in the OTU name can be specified as a tag to avoid removal

3) Please use regular expression for a space character for "Delimiter for categories of the taxonomic information" (default: "taxon_delimiter=;\s" [semicolon plus single space]).

4) The category information can be provided in Taxonomic_information_file, otherwise OTU names are used as labels of taxonomic information. Taxonomic_information_file might look like:

AB01234	Eukaryota; Metazoa; Chordata; Homo sapiens
Note:   [ 1st column: OTU name ]
           [ tab-delimited ]
           [ 2nd column: taxonomic categories delimited with the specified delimiter (see above) ]

The list of categories is supposed to contain any number of levels of categories, which can vary from species to species. Also use tab-delimited format in Parameter_input_file (example: Eukaryota	2).

5) Output_file is written in standard output (stdout)‎. In addition, a reference tree file is created at working directory, the file name of which might look like "Newick_tree_file__Parameter_input_file.tt0.8.tre".


COPYRIGHT AND LICENCE

Copyright (C) 2013 Shinichiro Maruyama / Robert J. M. Eveleigh / John M. Archibald

TreeTrimmer is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details, available at http://www.gnu.org/licenses/gpl.html.


REFERENCE

Maruyama et al. TreeTrimmer: a method for phylogenetic dataset size reduction. BMC Research Notes 2013, 6:145.


ACKNOWLEDGEMENTS

Many thanks go to:
Fabien Burki, Laura Eme, Bruce A. Curtis, the Bigelowiella natans and Guillardia theta nuclear genome sequencing project members 


CONTACT

John M. Archibald, Ph.D. 
Professor and Graduate Coordinator
Fellow, CIFAR Program in Integrated Microbial Biodiversity
Department of Biochemistry & Molecular Biology
Dalhousie University
Sir Charles Tupper Medical Building
5850 College Street
PO BOX 15000
Halifax, Nova Scotia, B3H 4R2, Canada

E-mail: jmarchib@dal.ca
Webpage: http://myweb.dal.ca/jmarchib/
