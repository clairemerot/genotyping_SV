#!/bin/bash
#SBATCH -J "mpileup_parall"
#SBATCH -o 98_log_files/log_%j
#SBATCH -c 1
#SBATCH -p medium
#SBATCH --mail-type=ALL
#SBATCH --mail-user=claire.merot@gmail.com
#SBATCH --time=6-00:00
#SBATCH --mem-per-cpu=10G
#SBATCH --array=1-40


# Move to directory where job was submitted
cd $SLURM_SUBMIT_DIR


###this script parallelise 
mkdir 98_log_files
chmod +x ./01_scripts/utility/mpileup_indels.sh
./01_scripts/utility/mpileup_indels.sh $SLURM_ARRAY_TASK_ID

