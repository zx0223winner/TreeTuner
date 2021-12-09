#!/usr/bin/perl
#
# Script name: trim2untrim.pl
# Version 1.0 (Dec 8th, 2011)
# Author: Laura Eme
###################################################################################

#use FindBin qw($Bin);
#use lib "$Bin/";
use Bio::SeqIO::fasta; 

$USAGE = "\n trim2untrim.pl [trimmed alignement] [untrimmed alignment]\n\nWill remove sequences from the untrimmed alignement based on sequences present in the trimmed alignement\n\n" ;

# Prints usage if no argument is given
unless( @ARGV )
{
    print $USAGE ;
    exit ;
}

$trimmed = $ARGV[0];
$untrimmed = $ARGV[1];
$out = $untrimmed."_sub";

%h_seq_to_keep = ();

# First let's get the name of sequences present in the trimmed alignement 
$searchio = Bio::SeqIO->new(-format => 'fasta',
                            -file   => $trimmed);

open(OUT, ">$out")||die("writing error ...");

while( my $seqobj = $searchio->next_seq ) {
	
	# name of the sequence
	$id = $seqobj->display_id();
    chomp($id);
#	$desc = $seqobj->desc();
		
	$h_seq_to_keep{$id} = 1;
}


##### Removal of these sequences from the alignment ########
$searchio = Bio::SeqIO->new(-format => 'fasta',
                            -file   => $untrimmed);

open(OUT, ">$out")||die("writing error ...");

while( my $seqobj = $searchio->next_seq ) {
	
	# name of the sequence
	$id = $seqobj->display_id();
#	$desc = $seqobj->desc();
    
    $found = 0;

    if (exists($h_seq_to_keep{$id})){
        print OUT ">",$id." ".$desc,"\n";
        # sequence itself
        $sequence = $seqobj->seq();
        print OUT $sequence, "\n";
        delete($h_seq_to_keep{$id});
    }
        
#    	LOOP_A:foreach $trimmed_seq (keys (%h_seq_to_keep)){
#        if ($id =~ /$trimmed_seq/){
#			print OUT ">",$id." ".$desc,"\n";
#            # sequence itself
#            $sequence = $seqobj->seq();
#			print OUT $sequence, "\n";
#			delete($h_seq_to_keep{$trimmed_seq});
#			last LOOP_A;
#		}
#	}
}

close(OUT);

$command = "grep -c \">\" ".$trimmed;
print $command, "\n";
system($command);

$command = "grep -c \">\" ".$out;
print $command, "\n";
system($command);

foreach $trimmed_seq (keys (%h_seq_to_keep)){
    print $trimmed_seq," not found\n";
}

print "\n\n";

exit;


