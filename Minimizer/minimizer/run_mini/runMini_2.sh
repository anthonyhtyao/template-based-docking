#!/bin/csh

# preparing var, dir...
#======================
set SEPDIR =  ../../Proteins  #/home/anne/Proteins/


# loop on REC
#============ 
foreach PROT ('\ls $SEPDIR/1JP3_A.pdb')
set PROT1={$PROT:t:r}
echo $PROT1
set PROTNAME1=$PROT1

# loop on LIG
#============
foreach PROTT ('\ls $SEPDIR/Trans2_1JP3_B.pdb')
set PROT2={$PROTT:t:r}
set PROTNAME2=$PROT2

############################################
# Meet-U WARGNING: NE PAS TOUCHER !!!!
############################################

#numero des POSITIONS de depart du ligand 
set Nsep1 = 1 
set Nsep2 = 1 

#Densite de points pour les positions de depart du ligand et du recepteur 
set Dens=70.0

#numero des ORIENTATIONS de depart du ligand 
set Nrot1 = 1 
set Nrot2 = 1 

#nombre d'evenements pour la methode ART
set Neven=500

rm global.dat
rm proteins.dat
rm input.dat
rm density.dat
rm temp_pos.dat
echo $Dens > density.dat
cp input input.dat
echo $Nsep1 >> input.dat
echo $Nsep2 >> input.dat
echo $Nrot1 >> input.dat
echo $Nrot2 >> input.dat
    echo $Neven >> input.dat
echo "'"$SEPDIR/$PROT1.pdb"'">proteins.dat
echo "'"$PROTNAME1"'">>proteins.dat
echo "'"$SEPDIR/$PROT2.pdb"'">>proteins.dat
echo "'"$PROTNAME2"'">>proteins.dat

############################################
# END Meet-U WARGNING: NE PAS TOUCHER !!!!
############################################


# sampling conformational space 
#===============================
../progs_MAXDo/Getarea2.out #/scratch/cnt0026/gmb7460/alopes/bin/ 
echo $PROT1 $PROT2


# !!!!!!!
# run modified version for Meet-U (MAXDo1 (PlosCB 2013 version) !!! modified 05/10/2016 --> minimization only)
#=============================================================================================================
../progs_MAXDo/simulmain.out #/scratch/cnt0026/gmb7460/alopes/bin/
end
end


echo ' long BDZach done'








