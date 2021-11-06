#!/usr/bin/perl
#
# Script name: 
# Version 1.0 (Nov 14th, 2011)
# Author: Laura Eme
###################################################################################

use lib '/paste/your/directory/Laura_perl';
# change the lib directory to where contain "lauralib.pm" perl module
use lauralib;
use Bio::TreeIO;
use Bio::SearchIO; 
use Bio::SeqIO::fasta; 
use Statistics::Descriptive;

$USAGE = "\n perl rm_inparal_rank.pl [tree file] [alignment file] [distance cutoff] [taxa not to remove] [taxa rank]\n\nWill remove sister sequences from the same rank. Will ignore taxa in the list \"taxa not to remove\".\n\n" ;

# Prints usage if no argument is given
unless( @ARGV )
{
    print $USAGE ;
    exit ;
}


$stat = Statistics::Descriptive::Full->new();

$intree = $ARGV[0];
$inalign = $ARGV[1];
$cutoff = $ARGV[2];
@taxa_list = read_file($ARGV[3]);
@rank_file = read_file($ARGV[4]);
$deletedTaxa = $inalign."_removedSeq";

print " ------- Tree ongoing: ",$intree," -------\n";

foreach $line (@rank_file){
	chomp($line);
	($clade, $rank) = split(/ /,$line);
	$h_rank{$clade} = $rank;
}

###identifiants sequences
%h_seq_to_keep = ();

$nb_removed = 1;

while ($nb_removed > 0){

	##### parse tree in newick format #####
	my $input = new Bio::TreeIO(-file => $intree, -format => 'newick');
	my $tree = $input->next_tree;
	my @taxa = $tree->get_leaf_nodes;

	$nb_removed = 0;

	foreach $node1 (@taxa){
		$inparal = 0;
		$seq_name1 = $node1->id();
		$to_keep = 0;

		LOOP_A:foreach $taxon(@taxa_list){ #checking if this is a taxon to keep
			chomp($taxon);
			if($seq_name1 =~ /$taxon/){
				$to_keep = 1;
				#print "taxa to keep: ";
				#print $seq_name1;
				#print "\n";
				$h_seq_to_keep{$seq_name1} = 1;
				last LOOP_A;
			}
		}#END OF LOOP_A (check all taxalist to see if matches node taxa)
		
		if ($to_keep == 0){
		
		
			#print "taxa not to keep: ";
			#print $seq_name1, "\n";
			@tmp_name1 = split(/_/,$seq_name1);
			$special_rank1 = 0;
			
			LOOP_A:foreach $clade (keys %h_rank){
				if ($seq_name1 =~ /$clade/){
					$rank = $h_rank{$clade};
					$special_rank1 = 1;
                    
					for $i_tmp_name1 (0..$#tmp_name1){
                        if ( ( $tmp_name1[$i_tmp_name1] eq 'Bacteria' ) || ( $tmp_name1[$i_tmp_name1] eq 'Archaea' ) || ( $tmp_name1[$i_tmp_name1] eq 'Eukaryota' ) ) {
                            if (($seq_name1 =~ 'uncultured') || ($seq_name1 =~ 'archaeon')){
                                $special_rank1 = 0;
                            }
                            else{
                                $new_zero1 = $i_tmp_name1;
                                $rank_to_compare1 = $tmp_name1[$new_zero1+$rank];
                                
                                if ($rank_to_compare1 eq ''){
                                    $special_rank1 = 0;
                                }
                                
                                last LOOP_A;
                            } #close else loop
						} #close if ( ( $tmp_name1[$i_tmp_name1] eq 'Bacteria' ) || ( $tmp_name1[$i_tmp_name1] eq 'Archaea' ) || ( $tmp_name1[$i_tmp_name1] eq 'Eukaryota' ) ) {
					}# close for $i_tmp_name1 (0..$#tmp_name1)
				} # close if ($seq_name1 =~ /$clade/){
			}# close LOOP_A:foreach $clade (keys %h_rank){
            
			unless ($special_rank1 == 1){
				$rank_to_compare1 = $tmp_name1[0];
            } # close unless 
			
            ### Now to compare to a second noe
			unless ( $rank_to_compare1 eq '') {
				$parent = $node1->ancestor;

				LOOP_D:for my $node2 ($parent->each_Descendent) {
                    
					unless ($node2 == $node1){
                                
						if( $node2->is_Leaf ){
							$seq_name2 = $node2->id();
							@tmp_name2 = split(/_/,$seq_name2);
                            $special_rank2 = 0;
                            
                            LOOP_E:foreach $clade (keys %h_rank){
                                if ($seq_name2 =~ /$clade/){
                                    $rank = $h_rank{$clade};
                                    $special_rank2 = 1;
                                    
                                    for $i_tmp_name2 (0..$#tmp_name2){
                                        
                                        if ( ( $tmp_name2[$i_tmp_name2] eq 'Bacteria' ) || ( $tmp_name2[$i_tmp_name2] eq 'Archaea' ) || ( $tmp_name2[$i_tmp_name2] eq 'Eukaryota' ) ) {
                                            
                                            if (($seq_name2 =~ 'uncultured') || ($seq_name2 =~ 'archaeon')){
                                                $special_rank2 = 0;
                                            }
                                            else{
                                                $new_zero2 = $i_tmp_name2;
                                                $rank_to_compare2 = $tmp_name2[$new_zero2+$rank];
                                                
                                                if ($rank_to_compare2 eq ''){
                                                    $special_rank2 = 0;
                                                }
                                                
                                                last LOOP_E;
                                            }
                                        }
                                    }
                                }
                            }
                            
                            unless ($special_rank2 == 1){
                                $rank_to_compare2 = $tmp_name2[0];
                            }
                            
                            if ($rank_to_compare1 =~ /^$rank_to_compare2$/){
									
								# distance between node1 and node2
								$distance = $tree->distance(-nodes => [$node1,$node2]);
                                #print "distance : ", $distance, "\n" ;

								if ($distance < $cutoff) {
									if ( exists($h_seq_to_keep{$seq_name2}) ){
										$inparal = 1;
										$nb_removed++;
										print $seq_name1, " will be removed because ", $seq_name2, " is closer to it than ", $cutoff, " (", $distance, ")\nBoth belong to ".$rank_to_compare2."\n\n";
										last LOOP_D;
									}
								}#end if ($distance < $cutoff)
							}
						}
					}#unless $node2 == $node1
				}# end loop_D
			}# end unless
		}# end case where that taxon is not in the list of taxa to keep

		if ($inparal == 0){
			#print 'adding seq to keep be/c inparal =0: ';
			#print $seq_name1, '\n';
			$h_seq_to_keep{$seq_name1} = 1;
		}
		else {
		    open(DELETED,">>$deletedTaxa")||die;
		    print DELETED $seq_name1,"\n";
		    print "deleted: ";
		    print $seq_name1,"\n";
		    close(DELETED);
		}	
	}# End foreach node in the tree 
	
	#### everything is added to $h_seq_to_keep{$seq_name1} correctly. so something wrong is going on
	#### after this point
	
	##### Removal of these sequences from the alignment ########
	$out_align = $inalign.".genus_trimmed";

	$searchio = Bio::SeqIO->new(-format => 'fasta',
								 -file   => $inalign);

	open(OUT, ">$out_align")||die("writing error ...");
	#print "\n \n \n";
	while( my $seqobj = $searchio->next_seq ) {

	# name of the sequence
	$id = $seqobj->display_id();
	$desc = $seqobj->desc();
	#print $id;
	#print "\n";
	
	if ( exists($h_seq_to_keep{$id}) ){
		#print "write to output: ";
		#print $id;
		#print "\n";
		print OUT ">",$id." ".$desc,"\n";
		# sequence itself
		$sequence = $seqobj->seq();
			print OUT $sequence, "\n";
#            print $sequence, "\n";
		}
	else{
		#print "don't write b/c not in hseq: ";
		#print $id;
		#print "\n";
		}
	}
	close(OUT);

	print $nb_removed, " sequences have been removed ... \n\n";

	if($nb_removed > 0){

		##### Reconstruction of the tree ######
		$commande = "/paste/your/directory/Laura_perl/FastTree ".$out_align." > ".$inalign.".fasttree";
		#$commande = "/home/leme/bin/FastTree ".$out_align." > ".$inalign.".fasttree";
		# change the lib directory to where contain FastTree.c
		print "\n\nTree reconstruction : \n",$commande,"\n";
		system `$commande`;


		#### Other rounds of removal
		$intree = $inalign.".fasttree";
		%h_seq_to_keep = (); # Re-initialize
	}
}

exit;


