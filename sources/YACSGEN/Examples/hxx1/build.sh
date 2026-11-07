# build COMPONENTCPP lib
mkdir CALCUL_build
cd CALCUL_build
../../exec.sh cmake -DCMAKE_INSTALL_PREFIX:PATH=../COMPONENTCPP_INSTALL ../CALCUL/src/
../../exec.sh make
../../exec.sh make install
cd ..

mkdir ICOCO_build
cd ICOCO_build
../../exec.sh cmake -DCMAKE_INSTALL_PREFIX:PATH=../COMPONENTCPP_INSTALL ../ICOCO/src/
../../exec.sh make
../../exec.sh make install
cd ..

# build & test SALOME component 
../exec.sh python component.py

appli/salome start -t
appli/salome shell python test_compohxx.py
appli/salome killall
