sub pfam_acc{

#### input: $nom_du_domaine, $banque_de_profils_hmm; output: identifiant Pfam ####
    
    my($nom_dom,$banque_hmm) = @_;

# Initialisation des variables

    my($shell_hmmfetch) = "";
    my($shell) = "";
    my($hmm_dir) = "";
    my(@hmm_fic) = ();
    my($ligne) = "";
    my(@split) = ();
    my($pfam_acc) = "";
    my($test) = "";
    
    # Récupération du profil hmm du domaine
    $shell_hmmfetch = "hmmfetch ".$banque_hmm." ".$nom_dom." > ".$nom_dom.".hmm";

    $nom_hmm = $nom_dom.".hmm";
    if(-e $nom_hmm){
	print $nom_hmm." existe deja\n";
    }else{
       $shell = `$shell_hmmfetch`;
    }


    # Récupération du numéro d'acces pfam dans la fiche .hmm
    $hmm_dir = $nom_dom.".hmm";

    # Parcours du .hmm
    open(hmm_fic, "$hmm_dir")||die("Error: cannot read $nom_dom.hmm file!\n");
    @hmm_fic = <hmm_fic>;
    close(hmm_fic);

    foreach $ligne (@hmm_fic){
	
	if($ligne =~ /^ACC.*$/){

	    @split = split(/ {1,}/, $ligne);
	    $pfam_acc = $split[1];
	}
    }
    
    return $pfam_acc;
}

################################################################################

sub read_file
{

    my($name) = @_ ;

# Test de l'existence du fichier source a lire

    unless ( -e $name )
    {
	print "\n\nLe fichier $name n'existe pas !!\n\n" ;
	exit ;
    }

# Ouverture du fichier source a lire

    unless ( open( FILE_DATA , $name ) )
    {
	print "\n\nErreur lors de l ouverture du fichier $name !!\n\n" ;
	exit ;
    }
    
    @data = <FILE_DATA> ;

# Fermeture du fichier 

    close FILE_DATA ;

    return @data ;

}
	
################################################################################

sub prt_to_dom
{

	my($prt_file, $hmm_bank, $dom_file) = @_;
	
# On rédige la requete	
	$shell_hmmpfam = "hmmpfam ".$hmm_bank." ".$prt_file." > ".$dom_file;
	print $shell_hmmpfam."\n";
		
# on execute la requete		
	$shell_hmmpfam = `$shell_hmmpfam`;

	return 1;
}	

################################################################################


sub dom_to_list
{

	my($threshold,@dom_data) = @_;

	# tableau de stockage des infos sur les domaines
	@tab_dom1 = ();
	@tab_dom2 = ();
	
	# Parcours du .dom
	for($ligne_dom=0; $ligne_dom<=$#dom_data ; $ligne_dom++){
	    $ligne = $dom_data[$ligne_dom];

	    # si le switch1 est ON et que la ligne n'est pas vide
	    if(( $switch1 == 1 )&&( $ligne =~ /[a_zA-Z0-9_]+/ )){
		push( @tab_dom1 , $ligne );
	    }
	    elsif(( $switch2 == 1 )&&( $ligne =~ /[a_zA-Z0-9_]+/ )){
		push( @tab_dom2 , $ligne );		
	    }
	    
	
	    # Si la ligne est celle qui précède la 1e zone de domaines, on active le switch1
	    if( $ligne =~ /\ ---\n$/ ){
		$switch1 = 1;
	    }
	    # Si le switch1 est ON et qu'on arrive à la fin du tableau des domaines (ligne vide)
	    elsif(( $ligne =~ /^\n$/ )&&( $switch1 == 1)){
		$switch1 = 0;
	    }
	    # Si la ligne est celle qui précède la 2e zone de domaines, on active le switch2
	    elsif( $ligne =~ /\ -------\n$/ ){
		$switch2 = 1;
	    }
	    # Si le switch2 est ON et qu'on arrive à la fin du tableau des domaines (ligne vide)
	    elsif(( $ligne =~ /^\n$/ )&&( $switch2 == 1)){
		$switch2 = 0;
		$ligne_dom = $#dom_data;
	    }
	}
	
	### Tri des domaines en fonction de la e-value seuil
	@tab_dom_ok = (); # tableau contenant les domaines avec des e-value < seuil 
	
	foreach(@tab_dom1){
	    $ligne1 = $_;
	    chomp($ligne1);
	    
	    # on sépare les colonnes (qui sont séparées par au moins 1 espace)
	    @tab_ligne1 = split(/ {1,}/,$ligne1);
	    
	    #on récupere le nom du domaine
	    $nom_dom1 = $tab_ligne1[0];
	    
	    # on recupere la description du domaine
	    $desc = "";
	    $ind_fin_desc = $#tab_ligne1-3;

	    for($i_tab_ligne1=1; $i_tab_ligne1<=$ind_fin_desc; $i_tab_ligne1++){
		$desc = $desc.$tab_ligne1[$i_tab_ligne1]." ";
	    }
	
	    # on recupere la evalue (incluant tous les domaines) associé au domaine
	    $evalue1= $tab_ligne1[$#tab_ligne1-1];
	
	    # si la evalue est inferieure au seuil dans le 1e tableau
	    if($evalue1 <= $threshold){
	
		# on regarde si elle l'est aussi dans le second
		for($j=0; $j<=$#tab_dom2; $j++){
		    $ligne2 = $tab_dom2[$j];
		    chomp($ligne2);
	
		    # on sépare les colonnes (qui sont séparées par au moins 2 espaces)
		    @tab_ligne2 = split(/ +/,$ligne2);
		    
		    # on recupere le nom du domaine 
		    $nom_dom2 = $tab_ligne2[0];
	
		    # on recupere la evalue (incluant tous les domaines) associé au domaine
		    $evalue2= $tab_ligne2[$#tab_ligne2];
	
		    if(( $evalue2 <= $threshold ) && ( $nom_dom1 =~ /^$nom_dom2$/ )){
				# position de début
				$pos_i = $tab_ligne2[2];
				# position de fin
				$pos_f = $tab_ligne2[3];
				push(@tab_dom_ok, [$nom_dom2, $evalue2, $pos_i, $pos_f,$desc]);
		    }# fin if
		}# fin for
	   }# fin if        
	}# fin foreach

	return @tab_dom_ok;
}

##############################################################################################

sub dom_name2hmm{

	my($nom_dom, $banque_hmm, $dir_hmm) = @_;

	# Récupération du profil hmm du domaine
	$shell_hmmfetch = "hmmfetch ".$banque_hmm." ".$nom_dom." > ".$dir_hmm;
	print $shell_hmmfetch."\n";

	$shell = `$shell_hmmfetch`;
	
	return 1;

}

##############################################################################################

sub hmm2hmms{

	
	my($hmm_file, $search_bank, $hmms_file) = @_;
	
	$shell_hmmsearch = "hmmsearch ".$hmm_file." ".$search_bank." > ".$dir_hmms;
	print $shell_hmmsearch."\n";

	$shell_hmmsearch = `$shell_hmmsearch`;

	return 1;

}


###############################################################################################

sub hmms2pro{

	my($hmms_file, $threshold2, $dir_pro) = @_;

	# on lit le contenu du fichier .hmms
	@fic_hmms = read_file($hmms_file);
	
	print "hmms2pro: $hmms_file\n";

	$switch = 0;

	@tab_id = ();
	@tab_eval = ();
	
	### Récupération du contenu des deux tableaux du .hmms ###
	foreach (@fic_hmms){
	    
	    ### stockage des infos dans des tableaux    
	    if(($switch==1)&&($_ =~ /[a-zA-Z0-9]/)){         # on détecte le premier tableau du .hmms 
		chomp($_);
	    	@tmp = split(/\ +/,$_);			# on sépare selon les espaces

		push(@tab_id, $tmp[0]);                        # on stocke l'identifiant
		push(@tab_eval, $tmp[$#tmp-1]);		      # on stocke la e-value

	    }

	    # variable qui sert à marquer le début et la fin des 2 tableaux contenus dans le .dom
	    if($_ =~ / ------- ---$/)         # détection de la ligne qui précède le 1e tableau
	    {
		$switch = 1;
	    }elsif($_ =~ / -----  -------$/) # détection de la ligne qui précède le 2e tableau
	    {
		$switch = 2;
	    }elsif($_ =~ /^\n$/)      # détection du \n qui marque la fin du tableau
	    {
		$switch = 0;
	    }# fin if

	}
	

	# Récupération du numéro d'acces
	for($i=0; $i<=$#tab_id; $i++){
	    @tmp = split(/\|/,$tab_id[$i]);		# on sépare selon les "pipes"
	    $tab_id[$i] = @tmp[1];
	}

	######## Création du _pro en fonction du seuil ########
	open(fic_pro, ">$dir_pro") || die("Error: cannot write _pro file $dir_pro!");
	
	for($i=0; $i<=$#tab_eval; $i++){ 		# on parcourt les e-value

	    if ( ($tab_eval[$i] <= $threshold2) && ($tab_eval[$1] =~ /\d/) ){ # On s'assure qu'il s'agit d'une valeur numérique (et non "No hits above threshold")
	
		print "Evalue du tableau: ".$tab_eval[$i]."\tEvalue seuil: ".$threshold2."\n";
	
		print fic_pro $tab_id[$i]."\n";
	    }
	}	
	close(fic_pro);	    

	print "\n!!!!!!PRO_file: ".$dir_pro." has been succesfully created\n";

}

##########################################################################################

# A partir d'une série de fichiers _pro, créé un fichier unique contenant les numéros d'acces une et une seule fois

sub pro2uniq{

	my( $pro_uniq, @tab_pro ) = @_;

	@tab_uniq = ();

	foreach $fic_tab_pro (@tab_pro){
	
		@data_fic_tab_pro = read_file($fic_tab_pro);

		foreach $num_fic_tab_pro (@data_fic_tab_pro){
			
			chomp($num_fic_tab_pro);
	
			# variable qui sert à tester si on doit ajouter le numéro d'acces à la liste des numéros uniques
			$sw_deja_present = 0;
			
			# on parcourt le tableau des domaines uniques
			for ( $i=0; $i<=$#tab_uniq ; $i++ ){

				$num_tab_uniq = $tab_uniq[$i];

				if($num_fic_tab_pro == $num_tab_uniq){

					$i = $#tab_uniq;
					$sw_deja_present = 1;
				}
			}	

			# Qd on a fini de parcourir le tableau des numéro d'acces uniques, si le switch est tjs à zéro, on ajoute le num d'acces
			if( $sw_deja_present == 0){
				push( @tab_uniq, $num_fic_tab_pro );
			}
		}	
	}

	open( UNIQ_PRO, ">$pro_uniq")||die("Error: cannot create unique_pro file!");
	
	foreach $num_uniq (@tab_uniq){
		print UNIQ_PRO $num_uniq."\n";
	}
	
	close( UNIQ_PRO );

	print "\n\n!! ".$pro_uniq." has been succesfully created !! \n\n";
}

##########################################################################################

sub pro2classif{

	my($dir_classif, $dir_taxo, @data_pro) = @_;

	# Récupération de la taxo de référence
	@tab_taxo_ref = read_file($dir_taxo);

	for $i( 0 .. $#tab_taxo_ref){

	    $ligne = $tab_taxo_ref[$i];
	    chomp($ligne);
	    
	    $tab_taxo_ref[$i] = $ligne;
	}

	$nb_pro_traites = 0;
	open(CLASSIF, ">$dir_classif")||die("Error: Cannot create classification file!");

	foreach $num_pro (@data_pro){

		chomp($num_pro);

		# si la ligne contient bien un numéro d'acces
		if($num_pro =~ /\d/){

			$nb_pro_traites++;
			print "nombre de numero traites: ".$nb_pro_traites."\tnumero d'acces : ".$num_pro."\n";

			$seq_object = undef;

			for $i_get_seq (0 .. 10){
				if ( $seq_object == undef ){
					$seq_object = get_sequence('genpept', $num_pro);
				}
				else{
					$i_get_seq = 10;
				}
			}

			$species = $seq_object->species;
			@classif = $species->classification;
		
			$long_classif = $#classif;
			
			if($classif[$long_classif-1] =~ /Proteobacteria/ ){
		
				$classif_standardise = $classif[$long_classif]."_".$classif[$long_classif-2];
			}
			else{
				$classif_standardise = $classif[$long_classif]."_".$classif[$long_classif-1];
			}	


			$sw_classif_trouve = 0;

			for $j ( 0 .. $#tab_taxo_ref){
				
				if( $classif_standardise =~ $tab_taxo_ref[$j] ){
				
					print "Classif trouve! :".$classif_standardise."\n";
					print CLASSIF $num_pro."\t".$classif_standardise."\n";
	
					$j = $#tab_taxo_ref;
					$sw_classif_trouve = 1;
				}
			}
			
			if ( $sw_classif_trouve == 0){
				
				if ( $classif_standardise =~ /^Bacteria/ ){		
					print "Classif autre: Bacteria\n";
					print CLASSIF $num_pro."\tBacteria_Others\n";

				}
				elsif ( $classif_standardise =~ /^Archaea/ ){	
					print "Classif autre: Archaea\n";
					print CLASSIF $num_pro."\tArchaea_Others\n";
				}	
				else {
					print "Classif autre: autre\n";
					print CLASSIF $num_pro."\tOthers\n";
				}

			}

		}		 		

	}

	close(CLASSIF);

	print "\n\n Complete classification file of $pro_file has been successfully created! \n\n";

	return 1;

}

##########################################################################################

sub classif2compt{

	my($dir_taxo, $fic_classif, $dir_classif_compt) = @_;

print $fic_classif."\n";
	
	# on récupère les infos du fichier .classif
	@data_classif = read_file( $fic_classif );
	
	# Récupération de la taxo de référence
	@tab_taxo_ref = read_file($dir_taxo);

	# on créé le fichier contenant les compteurs associés à chaque groupe taxonomique
	open(FIC_COMPT, ">$dir_classif_compt")||die("Error: cannot write $dir_classif_compt from classif2compt module!");

	for $i( 0 .. $#tab_taxo_ref){

		$ligne_taxo_ref = $tab_taxo_ref[$i];
		chomp($ligne_taxo_ref);

		print FIC_COMPT $ligne_taxo_ref;
		
		# pour ce groupe taxonomique on initialise le compteur à zéro
		$compteur_taxo = 0;
		$sw_classif_trouve = 0;
	
	    	for  $j ( 0 .. $#data_classif ){
			$ligne_classif = $data_classif[$j];
			chomp($ligne_classif);

			@split = split(/\t/, $ligne_classif);
			$ligne_classif = $split[1];

			if ($ligne_taxo_ref =~ /$ligne_classif/){
				$compteur_taxo++;
			}
		}	

		print FIC_COMPT "\t".$compteur_taxo."\n";
	}

	
	$compteur_bact = 0;
	$compteur_arch = 0;
	$compteur_oth = 0;

	for  $j ( 0 .. $#data_classif ){
		$ligne_classif = $data_classif[$j];
		chomp($ligne_classif);

		@split = split(/\t/, $ligne_classif);
		$ligne_classif = $split[1];

		if ( $ligne_classif =~ /Bacteria_Others/){
			$compteur_bact++;
		}
		elsif ( $ligne_classif =~ /Archaea_Others/){
			$compteur_arch++;
		}
		elsif ( $ligne_classif =~ /^Others$/){
			$compteur_oth++;
		}
	}	

	print FIC_COMPT "Bacteria others\t".$compteur_bact."\n";
	print FIC_COMPT "Archaea others\t".$compteur_arch."\n";
	print FIC_COMPT "Others\t".$compteur_oth."\n";

	print "Le fichier $dir_classif_compt a ete cree avec succes!! \n";
}

##########################################################################################

sub hmm2long_dom {
	
	my ($fic_hmm) = @_;

	@data_fic_hmm = read_file( $fic_hmm ) ;

#print $fic_hmm."\n";

#	for($i_fic_hmm=0; $i_fic_hmm<=$#data_fic_hmm; $i_fic_hmm++){
		
#		if($data_fic_hmm[$i_fic_hmm] =~ /^LENG.*/){
#			$longueur = $data_fic_hmm[$i_fic_hmm];
#			$i_fic_hmm = $#data_fic_hmm;
#		}	
#	}

	
	$longueur = $data_fic_hmm[4];
	chomp( $longueur );

	@split = split( / +/ , $longueur);
	
	$longueur = $split[1];

print $longueur."\n";

	return $longueur;

}

##########################################################################################

sub taxo2tab{

	my(@data_taxo_ref) = @_;

	foreach $ligne_taxo_ref (@data_taxo_ref){
		chomp($ligne_taxo_ref);
		
		@split = split( /\_/ , $ligne_taxo_ref );
		push(@tab_taxo_ref, [@split]);

	}

	return @tab_taxo_ref;
}

##########################################################################################

sub taxo2ref{

	my($dir_taxo_complete, $dir_out, @tab_taxo_ref);

	@data_taxo_complete = read_file($dir_taxo_complete);

	# on parcourt le fichier contenant la classif complete associée à chaque numéro d'acces
	foreach $ligne_taxo_complete (@data_taxo_complete){
	
		chomp( $ligne_taxo_complete );
	
		# Test de détection de la classif
		$sw_classif_trouve = 0;
		
		# on sépare selon les tabulations	
		@tab_ligne_taxo_complete = split( /\t/, $ligne_taxo_complete );
		
		# on récupère le numéro d'acces
		$id = $tab_ligne_taxo_complete[0];
		
		for $i ( 1 .. $#tab_ligne_taxo_complete ){

			# on parcourt la ligne 
			;
		}
	}
}

##########################################################################################

# Calcule le nombre moyen de domaines trouvés, à partir d'une liste de fichiers .dom et de la e-value seuil

sub dom2nombre {

	# Récupération de la e-value seuil, et du tableau contenant les chemins des fichiers .dom à moyenner
	my( $threshold, @dir_dom ) = @_;
	
	# initialisaton des variables
	my( $max_nb_dom ) = 0 ;	
	my( $fic_dom ) = "" ;
	my( @data_fic_dom ) = () ;
	my( @tab_nb_dom ) = () ;

	foreach $fic_dom ( @dir_dom ){
	
		@data_fic_dom = read_file( $fic_dom );

		# Récupération du tableau contenant tous les domaines en dessous du seuil de evalue
		@tab_dom_ok = dom_to_list( $threshold, @data_fic_dom );

		$nombre_dom = @tab_dom_ok;
	
		if( $nombre_dom > $max_nb_dom ){
			$max_nb_dom = $nombre_dom;	
		}
		
		# on ajoute le nombre de domaines dans une liste
		push(@tab_nb_dom, $nombre_dom);
	}

	# on initialise la hash table qui contiendra dans la 1e valeur le nombre de protéines qui n'ont aucun domaine, puis dans la 2e valeur le nb de celles qui en ont un, etc..
	my( %nb_prot_nb_dom ) = ();

	$nb_total = 0;

	for $i ( 0 .. $max_nb_dom ){

		$nb_prot_nb_dom{$i} = 0;

		for $j ( 0 .. $#tab_nb_dom){

			if( $tab_nb_dom[$j] == $i){
				$nb_prot_nb_dom{$i}++;
				$nb_total++;
			}	
		}

	}# end for

	return %nb_prot_nb_dom;
}

##########################################################################################

sub dom2mean{

	my( $threshold, @dir_dom ) = @_;

	# initialisation
	my ( $nb_dom ) = 0;
	my ( $cle ) = "";	

	%nb_prot_nb_dom = dom2nombre( $threshold, @dir_dom );

	foreach $cle (keys(%nb_prot_nb_dom)){

		$nb_local = $cle*($nb_prot_nb_dom{$cle});
	
		$nb_dom_total = $nb_dom_total + $nb_local;
	}

	return $nb_dom_total;
}


##########################################################################################

sub nb_par_dom{

	my( $threshold, @dir_dom ) = @_;

	# initialisation
	my( $fic_dom ) = "";
	my( @data_fic_dom ) = ();
	my( @data_fic_dom ) = ();
	my( @tab_dom_ok ) = ();
	my( @tab_dom_total ) = ();
	my( @tab_dom_uniq ) = ();

	foreach $fic_dom (@dir_dom){
		
		@data_fic_dom = read_file( $fic_dom );
		
		# Récupération du tableau contenant tous les domaines en dessous du seuil de evalue
		@tab_dom_ok = dom_to_list( $threshold, @data_fic_dom );
		
		for $i ( 0 .. $#tab_dom_ok ){	

			$domaine = $tab_dom_ok[$i][0];

			push( @tab_dom_total, $domaine );

			$sw_deja_present = 0;
						
			for $i_tab_dom_uniq (0 .. $#tab_dom_uniq ){

				$dom_tab_uniq = $tab_dom_uniq[$i_tab_dom_uniq];
	
				if ( $domaine =~ /$dom_tab_uniq/ ){
					$sw_deja_present = 1 ;
					$i_tab_dom_uniq = $#tab_dom_uniq;
				}
				else{
#					print "domaine teste: *".$domaine."*\t domaine unique: *".$dom_tab_uniq."\n";
				}
			}

			if ( $sw_deja_present == 0 ){
				push ( @tab_dom_uniq, $domaine );
			}
		}
	}
	

	my( @tab_compt ) = ();

	for $dom_uniq ( @tab_dom_uniq ){

		$compt_dom_uniq = 0;
	

		foreach $dom_total ( @tab_dom_total ){
			
			if ( $dom_total =~ $dom_uniq ) {
				$compt_dom_uniq++;				
			}
		}

		push( @tab_compt, [$dom_uniq, $compt_dom_uniq] );
	}

	return @tab_compt;	
	
}

##########################################################################################

sub nb_par_dom2redond {

	my( @tab_compt ) = @_;
	my( $max_detection ) = 0;
		

	for $i ( 0 .. $#tab_compt){
		
		if ($tab_compt[$i][1] > $max_detection){
			$max_detection = $tab_compt[$i][1] ;
		}
	}

	for $j ( 0 .. $max_detection ){
	
		$compt = 0;
		
		for $k ( 0 .. $#tab_compt ){

			if( $tab_compt[$k][1] == $j){ 
				$compt++;
			}
		}

		push(@tab_redond, [$j, $compt]);
	}

	return @tab_redond;
}

##########################################################################################


sub prot_par_dom{

	my( $threshold, @dir_dom ) = @_;

	# initialisation
	my( $fic_dom ) = "";
	my( @data_fic_dom ) = ();
	my( @data_fic_dom ) = ();
	my( @tab_dom_ok ) = ();

	### Tableau qui recense les domaines uniques pour UNE séquence
	my( @tab_dom_uniq_local ) = ();

	### Tableau qui cumule les domaines uniques de chaque séquences les uns à la suite des autres (le meme domaine peut donc etre présent plusieurs fois)
	my( @tab_dom_uniq_par_seq ) = ();

	foreach $fic_dom (@dir_dom){
		
		@data_fic_dom = read_file( $fic_dom );
		
		# Récupération du tableau contenant tous les domaines en dessous du seuil de evalue
		@tab_dom_ok = dom_to_list( $threshold, @data_fic_dom );

		@tab_dom_uniq_local = ();
		
		for $i ( 0 .. $#tab_dom_ok ){	

			$domaine = $tab_dom_ok[$i][0];

			$sw_deja_present = 0;
						
			for $j (0 .. $#tab_dom_uniq_local ){

				$dom_tab_uniq_local = $tab_dom_uniq_local[$j];
	
				if ( $domaine =~ /$dom_tab_uniq_local/ ){
					$sw_deja_present = 1 ;
					$j = $#tab_dom_uniq_local;
				}
			}

			if ( $sw_deja_present == 0 ){
				push ( @tab_dom_uniq_local, $domaine );
				push ( @tab_dom_uniq_par_seq, $domaine );
			}
		}
	}


	### Creation du tableau avec la liste des domaines uniques pour l'ensemble des séquences	
	my( @tab_dom_uniq ) = ();

	for $k ( 0 .. $#tab_dom_uniq_par_seq ){
		$domaine = $tab_dom_uniq_par_seq[$k]  ;
		
		$sw_deja_present = 0;		

		for $m ( 0 .. $#tab_dom_uniq ){
			$dom_uniq = $tab_dom_uniq[$m];
			
			if( $domaine =~ /$dom_uniq/ ){
				$sw_deja_present = 1;
				$m = $#tab_dom_uniq;
			}		
		}

		if ( $sw_deja_present == 0 ){
			push( @tab_dom_uniq, $domaine );
		}
	}



	### Creation d'un tableau qui recense pour chaque domaine, dans combien de protéines différentes on le trouve

	my( @tab_compt ) = ();

	foreach $dom_uniq ( @tab_dom_uniq ){

		$compt_dom_uniq = 0;	

		foreach $domaine ( @tab_dom_uniq_par_seq ){
			
			if ( $domaine =~ $dom_uniq ) {
				$compt_dom_uniq++;				
			}
		}

		push( @tab_compt, [$dom_uniq, $compt_dom_uniq] );
	}

	return @tab_compt;	
	
}


##########################################################################################


sub prot_par_dom2redond{

	my( @tab_compt_prot ) = @_;
	my( $max_detection ) = 0;
	my( @tab_redond ) = ();
		

	for $i ( 0 .. $#tab_compt_prot){
		
		if ($tab_compt_prot[$i][1] > $max_detection){
			$max_detection = $tab_compt_prot[$i][1] ;
		}
	}


	for $j ( 1 .. $max_detection ){
	
		$compt = 0;
		
		for $k ( 0 .. $#tab_compt_prot ){

			if( $tab_compt_prot[$k][1] == $j){ 
				$compt++;
			}
		}

		push(@tab_redond, [$j, $compt]);
	}

	return @tab_redond;
}


##########################################################################################

sub dom2nombre_diff{
	
	my( $threshold, @dir_dom ) = @_;
	my( @compt_dom_diff) = ();
	my( $max_nb_diff ) = 0;

	### création d'une liste contenant le nombre de domaines différent pour chaque séquence
	foreach $fic_dom (@dir_dom){
		
		@data_fic_dom = read_file( $fic_dom );
		
		# Récupération du tableau contenant tous les domaines en dessous du seuil de evalue
		@tab_dom_ok = dom_to_list( $threshold, @data_fic_dom );

		my(@tab_dom_uniq_local) = ();

		for $j ( 0 .. $#tab_dom_ok){

			$domaine = $tab_dom_ok[$j][0];
			$sw_deja_present = 0;

			for $i ( 0 .. $#tab_dom_uniq_local ){

				$dom_uniq_local = $tab_dom_uniq_local[$i];

				if( $domaine =~ /$dom_uniq_local/){
					$sw_deja_present = 1;
					$i = $#tab_dom_uniq_local;
				}
			}

			if( $sw_deja_present == 0){
				push( @tab_dom_uniq_local, $domaine ) ;
			}
		}

		$nb_dom_diff_pr_cette_seq = @tab_dom_uniq_local;
		push( @compt_dom_diff, $nb_dom_diff_pr_cette_seq );

		if( $nb_dom_diff_pr_cette_seq > $max_nb_diff ){
			$max_nb_diff = $nb_dom_diff_pr_cette_seq;
		}
	}


	### Création d'un tableau recensant le nombre de protéines en fonction du nb de domaines différents qui les composent
		
	my( @tab_nb_prot ) = ();
	
	for $i ( 0 .. $max_nb_diff){

		$compteur = 0;
		
		foreach $nb_dom (@compt_dom_diff){

			if( $nb_dom == $i ){
				$compteur++;
			}
		}

		push(@tab_nb_prot, [$i,$compteur]);															
	}
	
	return @tab_nb_prot;
}

##########################################################################################

sub dom_mat2cons{

	my( @dir_dom_mat ) = @_;

	my( @tab_prot_dom_cons_chez_tlm ) = ();

	foreach $fic_dom_mat ( @dir_dom_mat ){

		$nom_fic = substr($fic_dom_mat, 0, -8);

		## récupération du contenu du fichier .dom_mat
		@data_fic_dom_mat = read_file( $fic_dom_mat );

		@mat_fic = ();
		
		## on récupère la matrice sans les entetes
		for $i ( 1 .. $#data_fic_dom_mat ){

			$ligne = $data_fic_dom_mat[$i];	
			chomp($ligne);		

			@split = split( /\t/, $ligne );
	
			@ligne_mat_fic = ();			

			for $j ( 1 .. $#split ){
				push( @ligne_mat_fic, $split[$j]) ;
			}

			push( @mat_fic, [@ligne_mat_fic]);
		}


		## on teste si on trouve un zéro dans la matrice ==> dans ce cas ts les domaines ne sont pas conservés chez tout le monde		
	
		$sw_present_chez_tlm = 0;

		for $i ( 0 .. $#mat_fic ){
			for $j ( 0 .. $#{$mat_fic[$i]} ){

				if( $mat_fic[$i][$j] == 0){
					$sw_present_chez_tlm = 1;
					$i = $#mat_fic;
					$j = $#{$mat_fic[$i]};
				}
			}
		}


		## si on a pas trouvé de zéro, on met le nom du fichier, ainsi que le nb de domaines qui le composent, dans une liste
		if ( $sw_present_chez_tlm == 0 ){

			$nb_domaines = @ligne_mat_fic;
		
			push( @tab_prot_dom_cons_chez_tlm, [$nom_fic, $nb_domaines] );
		}
	}

	return @tab_prot_dom_cons_chez_tlm;
} 

##########################################################################################

sub dom_mat2nb_cons{

	my( @dir_dom_mat ) = @_;

	my( @tab_nb_dom_cons_chez_tlm ) = ();

	foreach $fic_dom_mat ( @dir_dom_mat ){

		$nom_fic = substr($fic_dom_mat, 0, -8);

		## récupération du contenu du fichier .dom_mat
		@data_fic_dom_mat = read_file( $fic_dom_mat );

		@mat_fic = ();
		
		## on récupère la matrice sans les entetes
		for $i ( 1 .. $#data_fic_dom_mat ){

			$ligne = $data_fic_dom_mat[$i];	
			chomp($ligne);		

			@split = split( /\t/, $ligne );
	
			@ligne_mat_fic = ();			

			for $j ( 1 .. $#split ){
				push( @ligne_mat_fic, $split[$j]) ;
			}

			push( @mat_fic, [@ligne_mat_fic]);
		}


		## on teste si on trouve un zéro dans la matrice ==> dans ce cas ts les domaines ne sont pas conservés chez tout le monde		
	
		$sw_present_chez_tlm = 0;

		for $j ( 0 .. $#{$mat_fic[0]} ){
			for $i ( 0 .. $#mat_fic ){

				if( $mat_fic[$i][$j] != $mat_fic[0][$j]){
					$sw_present_chez_tlm = 1;
					$i = $#mat_fic;
					$j = $#{$mat_fic[$i]};
				}
			}
		}


		## si on a pas trouvé de zéro, on met le nom du fichier, ainsi que le nb de domaines qui le composent, dans une liste
		if ( $sw_present_chez_tlm == 0 ){

			$nb_domaines = @ligne_mat_fic;
		
			push( @tab_nb_dom_cons_chez_tlm, [$nom_fic, $nb_domaines] );
		}
	}

	return @tab_nb_dom_cons_chez_tlm;
} 

##########################################################################################

sub dom_mat2standard{

	my( $fic_taxa_ref , @dir_dom_mat ) = @_;

	# récupération de la taxonomie de référence
	

	foreach $fic_dir_dom ( @dir_dom_mat ){
	
		# récupération du contenu du fichier .dom_mat
		@data_fic_dir_dom = read_file( $fic_dir_dom );

		foreach $ligne_data_fic_dir_dom (@data_fic_dir_dom){
			;
		}	
	}

}

##########################################################################################

### Transforme un tableau en un tableau à deux dimensions en effectuant un split de chaque ligne sur l'expression régulière donnée en paramètre

sub split_exreg {

	my( $exreg, @data ) = @_;

	my( @data_tab ) = ();
	my( $ligne ) = "";

	foreach $ligne ( @data ){

		@split = split(/$exreg/, $ligne);
		
		push(@data_tab, [@split]);
	}

	return @data_tab;
}

###########################################################################################

1;


