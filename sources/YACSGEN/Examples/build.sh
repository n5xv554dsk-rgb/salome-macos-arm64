#/bin/bash
# build all examples

cur_dir=`pwd`

script_dir=`dirname $0`

# activate stop on error
#set -e

cd $script_dir
$script_dir/clean.sh
list_dirs="calcium1 calcium2 cpp1 cpp2 cppgui1 fort1 fort2 pydoc1 pygui1 pyth1 pyth2 types1"
#" mpi1 parahxx1 hxx1"
for dir in $list_dirs ; do
  cd $dir
  echo Building $dir ...
  ./build.sh >build.log 2>&1
  ret=$?
  if [ $ret -ne 0 ] ; then
    echo "Stop on error. See:"
    echo "  "`pwd`/build.log
    exit 1 
  fi
  cd ..
done

echo Build finished!
