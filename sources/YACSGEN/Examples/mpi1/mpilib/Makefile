
all : myexe

myexe : lib/libmylibmpi.so src/myexempi.cxx include/mylibmpi.h
	mpic++ -o myexe -Iinclude src/myexempi.cxx -Llib -lmylibmpi

lib/libmylibmpi.so : src/mylibmpi.cxx include/mylibmpi.h
	mkdir -p lib; mpic++ -shared -fPIC -o lib/libmylibmpi.so -Iinclude src/mylibmpi.cxx

clean :
	rm -f myexe lib/libmylibmpi.so *~
