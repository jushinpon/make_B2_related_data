use strict;
use warnings;
use POSIX;
use Algorithm::Combinatorics qw(variations_with_repetition);
use List::Util qw(sum);

`rm -rf $currentPath/ele4ratio`;
`mkdir -p  $currentPath/ele4ratio`;

my @dlp_element = ("Sn", "Pb", "Te");
my @sorted = sort @dlp_element;#for the same formula element order  
my %setting = (
    template_file => "B2.lmp",
    dlp_element => [@sorted], 
    subgrpNum => 2,
    subgrp1_ele => ["Te"],
    subgrp2_ele => ["Sn", "Pb"],
    atom4subgrp => 27,
    max_dataNo => 15 #upper bound number of generated data files
) 
my @ele4atomNo_set;#array ref for different element numbers of a subgroup
my $dataNuCount = 1000000;#super large value for while loop works first
incr = 0;# increment to 
whille (1){
    my incr++;
    my @template;#all possible atom number of an element, same for all subgrp
    my @subgrp_ratioset;#all ratio set for a subgrp
    for(my $i = 0; $i < $setting{atom4subgrp};$i = $i + incr;){
        push @template,$i;
    }

    for my $grp (1..$setting{subgrpNum}){
        my $grpname_ele = "subgrp$grp"."_ele",
        my $eleNo = @{$setting{$grpname_ele}};
        my $grp_id = $grp - 1;#array from 0
        if($eleNo == 1){#only one element in this group
            push @{@subgrp_ratioset[$grp_id]},[$setting{atom4subgrp}];
        
        }
        else{#more than one elements in the subgrp
        

        }
     }


}
#
#    else{#more than 1 element in this subgroup
#
#
#    }
#
#    $setting{subgrpNum}
#    my $subnum = 0;
#    
#    while ($subnum > $setting{atom4subgrp}){
#
#        $subnum += $setting{incre};
#    }#end of while loop
#}
#
#my $subgrpNo = %setting{subgrpNum};
#
#
#my @subgrp_info;
#for my $i (1..$subgrpNo){
#
#
#}
#
#my $here_doc =<<"END_MESSAGE";
##You have to follow the following format!space after ":"
#
#template_file:
#%setting{template_file}
#
##element sequence in DLP
#dlp_element:
#@{%setting{dlp_element}}
#
##subgroup information,element group, numbers
#subgrpNum:
#%setting{subgrpNum}
#
#
#
#END_MESSAGE
#
#unlink "./input.txt";
#open(FH, "> ./input.txt") or die $!;
#print FH $here_doc;
#close(FH);