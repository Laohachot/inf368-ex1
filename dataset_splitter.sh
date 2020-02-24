#!/bin/bash
if [ "$#" -ne 2 ]; then
    echo "Usage: ./dataset_splitter.sh path_input_dataset global_path_output_dataset"
    echo "Make sure 'split_and_resize.py' is in the same directory as this bash script !"
    exit 1
fi
here=$(pwd)
if [ ! -f ${here}/split_and_resize.py ]; then
    echo "You must place 'split_and_resize.py' in the same directory as this bash script !"
    exit 1
fi
input_dir=$1
output_dir=$2
if [ -d ${output_dir} ]; then
  rm -rf ${output_dir}
fi
mkdir ${output_dir}
SECONDS=0
cd ${input_dir}
classes_dict=${output_dir}/classes_dict
if [ -f ${classes_dict} ]; then
  rm ${classes_dict}
fi
touch ${classes_dict}
echo ""
square_size=224 # resize value set to 224 for ResNet compatibility
cmpt=0
for f in *; do
        if [ -d ${f} ]; then
        printf "${f} : ${cmpt}\n" >> ${classes_dict}
        ((++cmpt))
        python3 ${here}/split_and_resize.py --data_dir ./${f} --output_dir ${output_dir} --category ${f} --square_size ${square_size}
        fi
done
info_dataset=${output_dir}/info_dataset
if [ -f ${info_dataset} ]; then
  rm ${info_dataset}
fi
touch ${info_dataset}
cd ${output_dir}/train
num_train_samples=0
for f in *; do
        if [ -d ${f} ]; then
        cd ./${f}
        ((num_train_samples+=$(ls -Uba1 | grep ^train | wc -l)))
        cd ../
        fi
done
cd ../val
num_val_samples=0
for f in *; do
        if [ -d ${f} ]; then
        cd ./${f}
        ((num_val_samples+=$(ls -Uba1 | grep ^val | wc -l)))
        cd ../
        fi
done
cd ../test
num_test_samples=0
for f in *; do
        if [ -d ${f} ]; then
        cd ./${f}
        ((num_test_samples+=$(ls -Uba1 | grep ^test | wc -l)))
        cd ../
        fi
done
printf "num_train_samples: ${num_train_samples}\n" >> ${info_dataset}
printf "num_val_samples: ${num_val_samples}\n" >> ${info_dataset}
printf "num_test_samples: ${num_test_samples}\n" >> ${info_dataset}
printf "num_classes: ${cmpt}\n" >> ${info_dataset}
echo "Splitting dataset and resizing images took:" 
date +%T -d "1/1 + $SECONDS sec"
echo "--------------------------------------------------------------------------------"
echo "Generating images paths files"
SECONDS=0
train_paths="${output_dir}/train_images_paths"
if [ -f ${train_paths} ]; then
  rm ${train_paths}
fi
touch ${train_paths}
cd ../train
for f in *; do
        if [ -d ${f} ]; then
        cd ./${f}
        for g in $(ls *.jpg); do
            printf "${output_dir}/train/${f}/${g}\n" >> ${train_paths}
        done
        cd ../
        fi
done
val_paths="${output_dir}/val_images_paths"
if [ -f ${val_paths} ]; then
  rm ${val_paths}
fi
touch ${val_paths}
cd ../val
for f in *; do
        if [ -d ${f} ]; then
        cd ./${f}
        for g in $(ls *.jpg); do
            printf "${output_dir}/val/${f}/${g}\n" >> ${val_paths}
        done
        cd ../
        fi
done
test_paths="${output_dir}/test_images_paths"
if [ -f ${test_paths} ]; then
  rm ${test_paths}
fi
touch ${test_paths}
cd ../test
for f in *; do
        if [ -d ${f} ]; then
        cd ./${f}
        for g in $(ls *.jpg); do
            printf "${output_dir}/test/${f}/${g}\n" >> ${test_paths}
        done
        cd ../
        fi
done
cd ../../
all_paths="${output_dir}/paths_to_parsable_files"
if [ -f ${all_paths} ]; then
  rm ${all_paths}
fi
touch ${all_paths}
printf "info_dataset: ${output_dir}/info_dataset\n" >> ${all_paths}
printf "dictionary: ${output_dir}/classes_dict\n" >> ${all_paths}
printf "train: ${output_dir}/train_images_paths\n" >> ${all_paths}
printf "val: ${output_dir}/val_images_paths\n" >> ${all_paths}
printf "test: ${output_dir}/test_images_paths\n" >> ${all_paths}
echo "This took:"
date +%T -d "1/1 + $SECONDS sec"
echo "--------------------------------------------------------------------------------"
echo "Procedure complete!"
echo ""


