(cd mpilib; make)
../exec.sh python components.py

# test
appli/salome -t
appli/salome shell ../test_compo.py
appli/salome killall
