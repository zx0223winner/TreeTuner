#!/usr/bin/env perl
# TreeTuner v1.0
# Script name: 
# Version 1.0 (Dec 9th, 2021)
# Author: Laura Eme

# Copyright 2021 Zhang X., Hu Y., Eme L., Maruyama S.,Eveleigh R.JM, Curtis B.A., Sibbald S.J., Hopkins J.F., Filloramo1 G.V.,Wijk K.J.V., Archibald J.M.
# Zhang X., Hu Y., Eme L., Maruyama S.,Eveleigh R.JM, Curtis B.A., Sibbald S.J., Hopkins J.F., Filloramo1 G.V.,Wijk K.J.V., Archibald J.M., 2021.Protocol for TreeTuner: A pipeline for minimizing redundancy and complexity in large phylogenetic datasets
# Usage of this pipeline follows GPL-3.0 License. © Copyright (C) 2021. If you think this work is useful, please cite the related references above after using.

#   This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.

#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.

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


