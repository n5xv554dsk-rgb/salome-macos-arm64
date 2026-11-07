# You first have to set the shell environment for medcoupling
# (see medcoupling/env.sh)

all:
	python demo_loadsource.py
	python demo_createsource.py

clean:
	rm -f createsource_fieldtarget.med loadsource_fieldtarget.med *~
