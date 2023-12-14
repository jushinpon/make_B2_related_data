use warnings;
use strict;
use Cwd;

my $currentPath = getcwd();

my %para =(#you may set QE parameters you want to modify here. Keys should be the same as used in QE
    #calculation => '"vc-md"',
    cell_dofree => '"all"',
    cell_dynamics => '"pr"',
    #vdw_corr => '"DFT-D3"', #use Van der Waals
    dt => 50,
    nstep => 50,
    etot_conv_thr => "1.0d-5",#perl not know d-5, make it a string 
    forc_conv_thr => "1.0d-4",
    disk_io => '"/dev/null"',
    degauss =>   0.035,
    smearing => '"gaussian"',
    conv_thr =>   "2.d-6",
    mixing_beta =>   0.2,
    mixing_mode => '"plain"',# !'local-TF'
    mixing_ndim => 4,# !set 4 or 3 if OOM-killer exists (out of memory), default 8
    diagonalization => '"david"',#!set cg if if OOM-killer exists (out of memory). other types can be used for scf problem.
    diago_david_ndim => 2,#default
    electron_maxstep => 300
);

my @keys = keys %para;#get all keys 
#/home/jsp/make_B2_related_data/QEjobs_status/Dead.txt;
my @allQEin = `grep -v '^[[:space:]]*\$' $currentPath/QEjobs_status/Dead.txt| grep -v '#'|awk '{print \$2}'`;#all dead QE cases
map { s/^\s+|\s+$//g; } @allQEin;
my $count = 0;
for my $f (@allQEin){
    $count++;
    print "*** No. $count: Modifying $f\n";
    my $data_path = `dirname $f`;
    $data_path  =~ s/^\s+|\s+$//g;
    
    #load QE_template file to trim
    open my $in ,"< $f" or die "No $f";      
    my @QE_template =<$in>;
    close $in;
    map { s/^\s+|\s+$//g; } @QE_template;   

    #modify settings
    for my $k (@keys){
        for my $kl (0..$#QE_template){
            if($QE_template[$kl] =~ /^\!?$k/){
                $QE_template[$kl] = "$k = $para{$k}";
                last;
            }
        }
    }
    my $qein = join("\n",@QE_template);
    chomp $qein;

    unlink "$f.bak";
    `mv $f $f.bak`;
    open my $new ,"> $f";      
    print $new $qein;
    close $in;   
}



