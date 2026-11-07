# You first have to set the shell environment for medcoupling
# (see medcoupling/env.sh)

all:
	python projection.py

clean:
	rm MeshTarget.vtu MeshSource.vtu FieldTarget.vtu *~
