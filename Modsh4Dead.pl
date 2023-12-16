use warnings;
use strict;
use Cwd;

my $currentPath = getcwd();# dir for all scripts
my @all_files = `grep -v '^[[:space:]]*\$' $currentPath/QEjobs_status/Dead.txt| grep -v '#'|awk '{print \$2}'`;#all dead QE cases
map { s/^\s+|\s+$//g; } @all_files;
die "No Dead.txt in $currentPath/QEjobs_status" unless(@all_files);
my $submitJobs = "no";
my %sbatch_para = (
            nodes => 1,#how many nodes for your lmp job
            threads => 2,#modify it to 2, 4, 6 if oom problem appears
            cpus_per_task => 1,#useless if use "mpiexec -np"
            partition => "All",#which partition you want to use
            runPath => "/opt/thermoPW/bin/pw.x -ndiag 1",          
            );

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
processors=\$(nproc)
np=\$((\$processors/\$threads))
export OMP_NUM_THREADS=\$threads

mpiexec -np \$np $sbatch_para{runPath} -in $basename.in
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
