../exec.sh python components.py

# test
LD_LIBRARY_PATH=`pwd`/../mpi1/mpilib/lib/ appli/salome -t
LD_LIBRARY_PATH=`pwd`/../mpi1/mpilib/lib/ appli/salome shell ../test_compo.py
appli/salome killall
