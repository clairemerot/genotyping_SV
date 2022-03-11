#!/bin/bash
#SBATCH -J "09c_pca"
#SBATCH -o log_%j
#SBATCH -c 3
#SBATCH -p medium
#SBATCH --mail-type=ALL
#SBATCH --mail-user=claire.merot@gmail.com
#SBATCH --time=7-00:00
#SBATCH --mem=70G

###this script will work on all individuals using the beagle genotype likelihood and calculate a covariance matrix with angsd & a pca with R
#this requires pcangsd to be cloned and a version of Python v2 with alias python2

#maybe edit
NB_CPU=3 #change accordingly in SLURM header

# Important: Move to directory where job was submitted
cd $SLURM_SUBMIT_DIR

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/home/camer78/miniconda3/bin/conda' 'shell.bash' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/home/camer78/miniconda3/etc/profile.d/conda.sh" ]; then
        . "/home/camer78/miniconda3/etc/profile.d/conda.sh"
    else
        export PATH="/home/camer78/miniconda3/bin:$PATH"
    fi
fi
unset __conda_setup
#<<< conda initialize <<<


##activate a conda environnement in which you have install the necessary library and python version
#conda create --name pcangsd_test python=2.7 
#conda activate pcangsd_test 
#conda install ipython numpy scipy six pandas python-dateutil cython numba

#you may need to edit the name of the environnemnt depending on what you chose
conda activate pcangsd_test 

#prepare variables - avoid to modify
source 01_scripts/01_config.sh

#this is the list of file we are working on
BAM_LIST=02_info/id_vcforder.list

#this is the input file for the pca
INPUT=09_angsd/ALLDP1_MISS50_2all_maf0.05.ready.beagle.gz
OUTPUT=09_angsd/ALLDP1_MISS50_2all_maf0.05

echo "analyse covariance matrix on all individuals"
python2 $PCA_ANGSD_PATH/pcangsd.py -threads $NB_CPU \
	-beagle $INPUT -o $OUTPUT

echo "transform covariance matrix into PCA"
COV_MAT="$OUTPUT".cov
Rscript 01_scripts/Rscripts/make_pca_simple.r "$COV_MAT" "$BAM_LIST"

