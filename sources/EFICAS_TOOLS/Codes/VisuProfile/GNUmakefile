.SUFFIXES: .xsd .py _driver.py _test_driver_0.comm _test_driver_1.comm _test_driver_0.xml _test_driver_1.xml _test_driver_0.py _test_driver_1.py .comm .xml 
#TODO : Supprimer les suffixes inutiles depuis l'utilisation des des règles pattern au lieu des règles suffixes
#TODO : Ajouter la dépendance entre le make .xml et la présence du driver
.PHONY: xsdAll driverAll
SHELL=bash

ifdef EFICAS4VIMMP_ROOT
srcdir?=${EFICAS4VIMMP_ROOT}
else
srcdir?=../..
endif

confdir?=$(srcdir)/config
tooldir=$(srcdir)/Tools

# Règle en tête de Makefile
all:  driverAll

#export PYXB_ROOT_DIR=/home/C65845/local/PyXB-1.2.6_Python-3.9.2.bin
export PYXB_ROOT_DIR=/home/C65845/local/PyXB-1.2.6.bin
include $(confdir)/GNUmakefile.env

#PYXB            ?=pyxbgen
#PYXB            ?=pyxbgen-py3

ifndef PYXB
  ifeq (, $(shell which pyxbgen))
   ifeq (, $(shell which pyxbgen-py3))
     $(error "No pyxbgen $(PATH), consider installing pyxb")
   else
    PYXB =pyxbgen-py3
   endif
  else
    PYXB =pyxbgen
  endif
endif

#################     REGLES DE CONSTRUCTION     ########################

#Dépendances entre catalogues :
define cata_dependencies =
# Exemple: cata_gromacs$1		: cata_Vimmp$1
endef

#Définition des dépendances pour le modèle .py
$(eval $(call cata_dependencies,.py))
#Définition des dépendances pour le modèle .xsd
$(eval $(call cata_dependencies,.xsd))

# $(subst .py,.xsd,cata_dependencies)

cata_files= \
cata_profile.py\
cata_profile_DB_XSLT.py

cata_basename=$(cata_files:%.py=%)
xsd_files   = $(cata_files:%.py=%.xsd)
driver_files= $(cata_files:%.py=%_driver.py)

xsdAll: $(xsd_files)
driverAll:  exec.sh environ.sh qtEficas.sh $(driver_files)
# qtEficasSlm.sh


# Exemple PyxB : $(PYXB) -m $(basename $@) -u $<  --location-prefix-rewrite http://chercheurs.edf.com/logiciels/vimmp=  --write-for-customization \
# L'utilisation de $? ne fonctionne pas si l'on ne modifie qu'un seul catalogue car il liste uniquement les fichiers modifiés et pyxb détecte 
# que l'autre fichier en dépend et qu'il n'a pas été regénéré en même temps: $^
.py.xsd:
	$(tooldir)/generateXSD.py -u -c $(abspath $<)

.xsd_driver.py:
	$(PYXB) -m $(basename $@) -u $^  --write-for-customization
	xmllint --path $(confdir) --schema XMLSchema11_local.xsd --noout $^

#Les Tools eficas ont besoins d'un chemin absolu
#ATTENTION : La .sufix rule n'autorise pas les dépendances après le : (sinon la ligne entière est un nom de fichier bizzare)
#_test_driver_$1.comm_test_driver_$1.xml: 
#            il faut les définir à part
# TODO : Gérer la dépendance au cata_..._driver.py et au fichier catalogue en utilisant la seconde expansion 
#.SECONDEXPANSION:
#%_test_driver_$1.xml : %_test_driver_$1.comm $$(realpath $$(*).py)  $$(*)_driver.py

define test_xml_rule =
%_test_driver_$1.xml : %_test_driver_$1.comm $$(realpath $$(*).py)
	@echo -e "\n\n------ Generate xml test file $$(@) ------\n"
	@[[ -f $$(*).py ]] || (echo "Le fichier catalogue $$(*).py est introuvable" && false)
	@[[ -f $$(*)_driver.py ]] || (echo "Le fichier driver $$(*)_driver.py est introuvable" && false)
	$(tooldir)/validateDataSet.py -c $$(abspath $$(*).py) $$< 
	$(tooldir)/generateXML.py -c $$(abspath $$(*).py) $$<
endef


#ATTENTION : La .sufix rule n'autorise pas les dépendances après le : (sinon la ligne entière est un nom de fichier bizzare)
#_test_driver_$1.comm_test_driver_$1.py:
#            il faut les définir à part
define test_driver_rule =
%_test_driver_$1.py : %_test_driver_$1.xml $(confdir)/test_driver_subst.py
	@echo -e "\n\n------ Generate xml test driver $$(@) ------\n"
	sed -e "s,@module@,$$(*)_driver,g" -e "s,@file@,$$(<:%.comm=%.xml),g" $$(confdir)/test_driver_subst.py > $$(@) && \
        chmod +x $$(<:%.comm=%.py);
endef

define test_comm_rule =
%_test_driver_$1_modified.comm : %_test_driver_$1.xml
	@echo -e "\n\n------ Generate modified.comm file $$(@) ------\n"
	@[[ -f $$(*).py ]] || (echo "Le fichier catalogue $$(*).py est introuvable" && false)
	@[[ -f $$(*)_driver.py ]] || (echo "Le fichier driver $$(*)_driver.py est introuvable" && false)
	$(tooldir)/generateUQComm.py -x -c $$(abspath $$(*).py) -o  $$(@)  $$<
	diff -w  -I '^#' -I '^ #' $$(@:%_modified.comm=%.comm) $$(@)
endef

#Définition des règles de construction pour les tests
#$(eval $(call test_driver_rule,0))
#$(eval $(call test_driver_rule,1))
$(foreach it,0 1 2 3 4 5 6 7 8 9, $(eval $(call test_xml_rule,$(it))) )
$(foreach it,0 1 2 3 4 5 6 7 8 9, $(eval $(call test_driver_rule,$(it))) )
$(foreach it,0 1 2 3 4 5 6 7 8 9, $(eval $(call test_comm_rule,$(it))) )

#test_driver_xml:= $(patsubst %.comm,%.xml,$(wildcard *_test_driver_?.comm))
#test_driver_py:= $(patsubst %.comm,%.py,$(wildcard *_test_driver_?.comm))

new_test_driver_xml:= $(foreach it,$(cata_basename), $(patsubst %.comm,%.xml,$(wildcard $(it)_test_driver_?.comm)) )
new_test_driver_py:= $(foreach it,$(cata_basename), $(patsubst %.comm,%.py,$(wildcard $(it)_test_driver_?.comm)) )
new_test_driver_comm:= $(foreach it,$(cata_basename), $(patsubst %.comm,%_modified.comm,$(wildcard $(it)_test_driver_?.comm)) )

#$(info $(new_test_driver_xml) "----" $(cata_basename) )
#$(info $(new_test_driver_py) "----" $(cata_basename) )

# xml:
# 	@echo "Reminder: a .comm file is needed for this step" 
# 	../tools/generateXML.py -c cata_1.py cata_1_test_1.comm

check test: testAll

#################     REGLES DE TESTS     ########################

testAll: exec.sh driverAll $(new_test_driver_py) $(new_test_driver_xml) $(new_test_driver_comm)
	@for i in $(new_test_driver_py)  ; do echo -e "\n\n------ Launching $$i ------" && ./exec.sh python3 $$i ; done
#	for i in `ls *_test_driver*.py`  ; do echo -e "\n\n------ Launching $$i ------" && ./exec.sh python $$i || break ; done

#################   REGLES DE NETTOYAGE   ########################

clean:
	rm -f *.pyc *~ qtEficas.sh exec.sh environ.sh
	rm -rf raw  binding.py __pycache__
	rm -f $(xsd_files) $(driver_files)  *test_driver_?.py *test_driver_?.xml *test_driver_?_modified.comm

cleantest:
	rm -f  *test_driver_?.py *test_driver_?.xml *test_driver_?_modified.comm

