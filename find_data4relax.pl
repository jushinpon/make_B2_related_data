=b
filter required data files and collect them into data4relax folder.
=cut
use strict;
use warnings;
use Cwd;
use POSIX;
#
my $currentPath = getcwd();
my $source_folder = "QEall_set";
my $data_folder = "data_files";

my @QEout_folders = `find $currentPath/$source_folder -maxdepth 1 -type d -name "*-T50-*"`;#find cases at the low temperature
#my @QEout_folders = `find $currentPath/$source_folder -type d -name "*"`;#find all folders
map { s/^\s+|\s+$//g; } @QEout_folders;
die "No folders were found under the source folder, $source_folder\n" unless(@QEout_folders);
#print "@QEout_folders\n";
`rm -rf data4relax`;
`mkdir data4relax`;

for my $f (@QEout_folders){
    my @data_files = `ls $f/$data_folder/*.data`;
    map { s/^\s+|\s+$//g; } @data_files;
    if(@data_files){
        my $prefix = `basename $f`;
        $prefix =~ s/^\s+|\s+$//g;
        #!
        $prefix =~ s/\-T\d+-P\d+//g;
        `cp $data_files[-1] $currentPath/data4relax/$prefix.data`;
    }
    else{
        print "no data files in $f\n";
    }   
}