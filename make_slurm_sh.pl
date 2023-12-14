=b
make lmp input files for all strucutres in labelled folders.
You need to use this script in the dir with all dpgen collections (in all_cfgs folder)
perl ../tool_scripts/cfg2lmpinput.pl 
=cut
use warnings;
use strict;
use JSON::PP;
use Data::Dumper;
use List::Util qw(min max);
use Cwd;
use POSIX;
use Parallel::ForkManager;
use List::Util qw/shuffle/;

my $filefold = "QEall_set";
my $submitJobs = "no";
my %sbatch_para = (
            nodes => 1,#how many nodes for your lmp job
            threads => 1,
            cpus_per_task => 1,
            partition => "All",#which partition you want to use
            runPath => "mpiexec /opt/thermoPW/bin/pw.x -ndiag 1",          
            );

my $currentPath = getcwd();# dir for all scripts

my $forkNo = 1;#although we don't have so many cores, only for submitting jobs into slurm
my $pm = Parallel::ForkManager->new("$forkNo");

my @all_files = `find $currentPath/$filefold -maxdepth 2 -mindepth 2 -type f -name "*.in" -exec readlink -f {} \\;|sort`;
map { s/^\s+|\s+$//g; } @all_files;

my $jobNo = 1;

for my $i (@all_files){
    print "Job Number $jobNo: $i\n";
    my $basename = `basename $i`;
    my $dirname = `dirname $i`;
    $basename =~ s/\.in//g; 
    chomp ($basename,$dirname);
    `rm -f $dirname/$basename.sh`;
    $jobNo++;
my $here_doc =<<"END_MESSAGE";
#!/bin/sh
#SBATCH --output=$basename.sout
#SBATCH --job-name=$basename
#SBATCH --nodes=$sbatch_para{nodes}
##SBATCH --cpus-per-task=$sbatch_para{cpus_per_task}
#SBATCH --partition=$sbatch_para{partition}
##SBATCH --ntasks-per-node=12
##SBATCH --exclude=node23

rm -rf pwscf*
threads=$sbatch_para{threads}
export OMP_NUM_THREADS=\$threads

$sbatch_para{runPath} -in $basename.in
rm -rf pwscf*

END_MESSAGE
    unlink "$dirname/$basename.sh";
    open(FH, "> $dirname/$basename.sh") or die $!;
    print FH $here_doc;
    close(FH);
    if($submitJobs eq "yes"){
        chdir($dirname);
        `sbatch $basename.sh`;
        chdir($currentPath);
    }    
}#  
