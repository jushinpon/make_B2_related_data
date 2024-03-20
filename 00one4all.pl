use strict;
use warnings;

die "Don't use this script directly!!! ONly for guide you the whole sequenece of ".
"all required perl scripts for relax (part 1) and the following md (part 2)!!\n";
# makedir data4relax and move all your data files into it. Maybe you can use find_data4relax.pl to do it!

#part 1:
print "1.mkdir data4relax and move all your data files into it.\n";

#remove all folders
#system("rm -rf cifs data4relax cif2data data2QE4MatCld QEinByMatCld QE_trimmed");
#
#print "1. getting all cif files from materials project into cifs \n";
#system("python mp_get_cif.py");

#print "2. converting all cif files to data files into cif2data \n";
#system("perl cif2data.pl");

print "2. converting all data files in data4relax to QE input into data2QE4MatCld\n";
system("perl data2QE4MatCld.pl");

print "3. getting corresponding QE input from Materials Cloud into QEinByMatCld\n";
system("perl QEinputByMatCld.pl");


print "4. trim QE input files using MatCld input and place them in QE_trimmed4relax.\n";
system("perl QEinTrim4relax.pl");


print "5. make slurm files for vc-relax. You need to modify \$filefold for correct folders. (current: QE_trimmed4relax)\n";
system("perl make_slurm_sh.pl");

print "6. submit the vc-relax job in each subfolder under QE_trimmed4relax. \$filefold should be modified for correct folders. (current: QE_trimmed4relax)\n";
system("perl make_slurm_sh.pl");


print "6. Modify some QE setting for QE input files and place them in QEall_set\n";
system("perl ModQEsetting.pl");

#print "7. make sbatch file in each subfolder of QEall_set\n";
#system("perl make_slurm_sh.pl");
#
#print "8. submit the job in each subfolder of QEall_set\n";
#system("perl submit_allslurm_sh.pl");

#part 2
