#/bin/bash
# clean all examples

script_dir=`dirname $0`
cd $script_dir

list_dirs="calcium1 calcium2 cpp1 cpp2 cppgui1 fort1 fort2 pydoc1 pygui1 pyth1 pyth2 types1"
#" mpi1 parahxx1 hxx1"

for dir in $list_dirs ; do
  cd $dir
  make clean
  cd ..
done
