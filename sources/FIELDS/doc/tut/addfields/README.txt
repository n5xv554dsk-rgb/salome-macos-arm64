# You first have to set the shell environment for medcoupling

all:
	python addition.py
	python operations.py

clean:
	rm -f addition.med scaling.med addition_01.med addition_02.med *~
