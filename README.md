# Equipe 10, Sampling : SWING
Template based protein docking written in Python3. The program is developed by Kévin De Azevedo, Marine Duhamel, and Hua-Ting Yao (Paris 11)
## Abstract
SWING stands for Sampling With INteroloG and aims at producing ligand conformations for complex structure identification. Our program use the [InterAlign](http://biodev.cea.fr/interevol/) website in order to find interologs, meaning protein complexes containing homologous chains of the two proteins we aim to know the interaction of. Interologs are used to determine a starting point around which the program will do the sampling.

## Installation
Python dependent packages can be found in `requirements.txt`.
Use `pip3` to install.
```
pip3 install -r requirements.txt
```
### The third party software
`Minimiser` and `Pymol` (https://pymol.org/2/) are used in this program.

Please copy `minimiser` folder (from [here](https://github.com/meetU-MasterStudents/2017-2018_partage/tree/master/Codes/Minimizer)) into `Minimiser` folder.

Then, install `Pymol` following instructions from its official page ([here](http://www.pymol.org/install))

## Quick start:
A command example to run the program from A to Z :
```bash
python3 main.py run -rec test/1AY7_r.pdb -lig test/1AY7_l_sep.pdb -n 10
```
This command will do the sampling with the two pdb files in the test directory, use the minimizer and generate 10 conformations.

Some of steps will take times to complete, especially for interologs downloading. Fortunately, the request of [InterEvol](http://biodev.cea.fr/interevol/) and pymol alignement could only be executed once for a given pair of receptor and ligand. Hence, three parts of program can be run separately with proper positional arguments.

The command above is equivalent to the followings :
```bash
python3 main.py download -rec test/1AY7_r.pdb -lig test/1AY7_1_sep.pdb
python3 main.py align -rec test/1AY7_r.pdb -lig test/1AY7_l_sep.pdb -c test/Inter_1AY7_r.conf
python3 main.py samples -rec test/1AY7_r.pdb -lig test/1AY7_l_sep.pdb -n 10 -c test/Samples_1AY7_r.conf
```

For more arguments' and usage's detail:
```bash
python3 main.py -h
```

### Regarding the minimizer
It is highly recommended to use the minimizer along with our program. By default, the minimizer will be launched with the command lines above, and the numer of ligands after minimization will be lower that before. However, should you wish to launch our program without the minimizer, it is possible with the flag --no-minimizer. An example :

```bash
python3 main.py run -rec test/1AY7_r.pdb -lig test/1AY7_l_sep.pdb -n 10 --no-minimizer
```
## For more information
If you wish more information regarding the specifications of the program (detailed informations on how to run the program, output configuration, optional InterEvol parameters tuning...), you can read the [wiki on Github](https://github.com/meetU-MasterStudents/2017-2018_Equipe10/wiki).
