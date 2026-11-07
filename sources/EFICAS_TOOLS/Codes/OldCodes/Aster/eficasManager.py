#!/usr/bin/env python
# -*- coding: iso-8859-1 -*-
#
# This module helps you to dynamically add a catalog in the list of
# Aster catalogs and then start Eficas with this catalog
#
# WARN: this requires that <EFICAS_ROOT> and <EFICAS_ROOT>/Aster are
# both in the PYTHONPATH
#
# WARN: This python module is a prototype. For industrial usage, it
# should be integrated in a package outside from the Aster specific
# package ==> define a generic prefs 
#
# (gboulant - 23/03/2012)

import sys
sys.path.append("..")

# ===================================================================
# This part is to manage the catalog that defines the data structure 
import prefs_ASTER
def addCatalog(catalogName, catalogPath):
    """
    Function to add a catalog caraterized by a name (for the -c option
    of the command line) and a path (the location of the python module
    that corresponds to the catalog).
    """
    prefs_ASTER.addCatalog(catalogName, catalogPath)

import sys
import prefs
from InterfaceQT4 import eficas_go
def start(catalogName=None):
    """
    This simply start Eficas as usual, and passing the catalog name as
    an argument if not already present on the command line.
    """
    if catalogName is not None and not "-c" in sys.argv:
        # The catalogName can be consider as the -c option
        sys.argv.append("-c")
        sys.argv.append(catalogName)
    eficas_go.lance_eficas(code=prefs.code)

# ===================================================================
# This part is to manage the data saved from Eficas to comm file.
# The text contained in a comm file defines a JdC ("Jeu de Commandes").

def loadJdc(filename):
    """
    This function loads the text from the specified JdC file. A JdC
    file is the persistence file of Eficas (*.comm).
    """
    fcomm=open(filename,'r')
    jdc = ""
    for line in fcomm.readlines():
        jdc+="%s"%line

    # Warning, we have to make sure that the jdc comes as a simple
    # string without any extra spaces/newlines
    return jdc.strip()

def getJdcParameters(jdc,macro):
    """
    This function converts the data from the specified macro of the
    specified jdc text to a python dictionnary whose keys are the
    names of the data of the macro.
    """
    context = {}
    source = "def args_to_dict(**kwargs): return kwargs \n"
    source+= "%s = _F = args_to_dict          \n"%macro
    source+= "parameters="+jdc+"                        \n"
    source+= "context['parameters'] = parameters         \n"
    #print source
    code = compile(source, 'file.py', 'exec')
    eval(code)
    parameters = context['parameters']
    return parameters

#
# ===========================================================
# Unit tests
# ===========================================================
#
def TEST_start():
    addCatalog(catalogName="demo", catalogPath="mycata.py")
    #start()
    start("demo")

def TEST_getJdcParameters_fromString():
    jdc="S_EP_INTERNE(dir_name='/tmp',                      \n \
           TYPE_SEP='TUBE_SOUS_EPAISSEUR',                \n \
           MAIL_TUBE=_F(UNITE_LONGUEUR='MM',              \n \
                        R_EXT=130.,                       \n \
                        EP_NOMINALE=22.0,                 \n \
                        NB_SEG_AMORTISSEMENT=11,          \n \
                        NB_SEG_TRANSITION=4,              \n \
                        NB_SEG_GENERATRICES=5,            \n \
                        DIST_PTS_GEN_MIN=100.0,           \n \
                        NB_SEG_GEN_MIN=3,                 \n \
                        NB_SEG_ARC=5,                     \n \
                        NB_SEG_EP=3,),);"

    parameters=getJdcParameters(jdc,"S_EP_INTERNE")
    print "parameters = ",parameters
    print parameters['MAIL_TUBE']['R_EXT']
    
    
def TEST_getJdcParameters_fromFile():
    jdc = loadJdc('data.comm')
    parameters=getJdcParameters(jdc,"EPREUVE_ENCEINTE")
    print parameters


if __name__ == "__main__":
    TEST_start()
    TEST_getJdcParameters_fromString()
    TEST_getJdcParameters_fromFile()
