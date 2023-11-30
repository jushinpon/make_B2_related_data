#!/usr/bin/perl
use strict;
use warnings;
use Cwd;
use POSIX;
use lib './';#assign pm dir
use elements;#all setting package

###parameters to set first
my $lmp_exe = "/opt/lammps-mpich-4.0.3/lmpdeepmd_20230322";
my $currentPath = getcwd();
`rm -rf $currentPath/den_mod`;#remove old data
`mkdir -p  $currentPath/den_mod`;
my $data_dir = "$currentPath";#you may assign yours 
my @datafile = `find $currentPath -name "*.data"`;#find all data files
map { s/^\s+|\s+$//g; } @datafile;
die "No data files\n" unless(@datafile);

for (@datafile){
    my $dir = `dirname $_`;#get path
    my $filename =`basename $_`;#get path
    #1  atom types 
    my $typeNum = `grep "atom types" $_|awk '{print \$1}'`;
    $typeNum =~ s/^\s+|\s+$//g;
    #1   58.93319500             # Co
    my @ele = `grep -v '^[[:space:]]*\$' $_|grep -A $typeNum Masses|grep -v Masses|grep -v -- '--'|awk '{print \$NF}'`;
    map { s/^\s+|\s+$//g; } @ele;# id + 1 ---> lmp type id
    die "No element symbols in $_\n" unless(@ele);
    my @ele_mass = `grep -v '^[[:space:]]*\$' $_|grep -A $typeNum Masses|grep -v Masses|grep -v -- '--'|awk '{print \$2}'`;
    map { s/^\s+|\s+$//g; } @ele_mass;# id + 1 ---> lmp id
    die "No element masses in $_\n" unless(@ele_mass);

    my %element2den;#element symbol to its bulk density 
    for (@ele){#unique
        chomp;
        die "no information of element $_ in elements.pm\n" unless (&elements::eleObj("$_"));
        $element2den{$_} = ${&elements::eleObj("$_")}[0];#density
    }
    my $atomNum = `grep "atoms" $_|awk '{print \$1}'`;
    $atomNum =~ s/^\s+|\s+$//g;
    
    my @lmp_type = `grep -v '^[[:space:]]*\$' $_|grep -A $atomNum Atoms|grep -v Atoms|grep -v -- '--'|awk '{print \$2}'`;
    map { s/^\s+|\s+$//g; } @lmp_type;# id + 1 ---> lmp id
    my $densum = 0.0;
    for my $i (@lmp_type){
        my $ele = $ele[$i -1];
        $densum += $element2den{$ele};
    }
    my $aveDen = $densum/$atomNum;#average density
    my %lmp_para = (
           density => $aveDen,           
           input_data => "$_",#data path
           output_data => "$currentPath/den_mod/temp.data",
           output_script => "$currentPath/density.in",
    );     
        &lmp_script(\%lmp_para);
#
    `$lmp_exe -in $currentPath/density.in`;
    #system("$lmp_exe -in $currentPath/density.in");
    ###
    # modify mass
    my @data = `cat $lmp_para{output_data}`;
    map { s/^\s+|\s+$//g; } @data;# id + 1 ---> lmp id

    my $massln;
    for my $m (0..$#data){
        if( $data[$m] =~m/^Masses/){$massln = $m;}
    }
    for my $i (1..@ele){
        $data[$massln + 1 + $i ] = "$data[$massln + 1 + $i ] \# $ele[$i-1]";
    }
    my $datafile = join("\n",@data);
    open(FH, '>', "$currentPath/den_mod/$filename") or die $!;
    print FH $datafile;
    close(FH);
    unlink "$currentPath/den_mod/temp.data";
}#all data files

#####here doc for QE input##########
sub lmp_script
{

my ($lmp_hr) = @_;

my $lmp_script = <<"END_MESSAGE";
log none
units metal 
dimension 3 
boundary p p p 
atom_style atomic 
atom_modify map array

variable den_out equal $lmp_hr->{density} #target density

read_data $lmp_hr->{input_data}

pair_style none

variable den_in equal density #current density
variable den_ratio equal \${den_in}/\${den_out}
variable den_scale equal \${den_ratio}^(1.0/3.0)

print \$(density)
print \${den_scale}

change_box all x scale \${den_scale} y scale \${den_scale} z scale \${den_scale} remap units box
write_data $lmp_hr->{output_data}
print \$(density)

END_MESSAGE

#my $file = $lmp_hr->{output_script};
open(FH, '>', $lmp_hr->{output_script}) or die $!;
print FH $lmp_script;
close(FH);
}