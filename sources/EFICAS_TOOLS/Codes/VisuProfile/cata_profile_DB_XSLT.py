# -*- coding: utf-8 -*-
#
# EFICAS
# Attention a l ordre des lignes pour avoir le bon JdC actif
#
from Accas import SIMP, PROC, FACT, JDC_CATA_SINGLETON

JdC = JDC_CATA_SINGLETON(code="ProfileDB")
VERSION_CATALOGUE = "V_0"

from cata_profile import def_run_id
from cata_profile import def_time_profile
from cata_profile import def_memory_profile

if JdC.code in ( 'ProfileDB') :
    
    Profile = PROC( nom = "Profile",
        profile = def_run_id('XSLT'),
        time_profile = def_time_profile('XSLT'),
        memory_profile = def_memory_profile ('XSLT'),
        raw_profile = FACT(
           raw_profile_xml = FACT (
                run_id = def_run_id(),
                time_profile = def_time_profile('ProfileNS'),
                memory_profile = def_memory_profile ()
            )
        ),
    )

from cata_profile import dElementsRecursifs

# force le type a XML dans le schéma de base
dElementsRecursifs['raw_profile_xml']=True
dPrimaryKey = {'raw_profile' : 'run_id','profile' : 'run_id', 'time_profile' : 'run_id', 'memory_profile' : 'run_id' }

# la clef de dForeignKey est Nom de la table
# la valeur est  nom de la colonne foreign key de cette table, 
#                nom de la colonne referencee  
#                nom de la table a laquelle appartient cette colonne
dForeignKey = {'time_profile' : ('run_id', 'run_id', 'profile'),'memory_profile' : ('run_id', 'run_id', 'profile'), 'raw_profile' : ('run_id', 'run_id', 'profile')}
dUnique = {'profile' : ('sha1','code_name','test_name','version','timestamp','build_type', 'execution', 'procs', 'host', 'OS') }
