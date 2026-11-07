# -*- coding: utf-8 -*-
#
# EFICAS
from Accas import  SIMP, PROC, FACT, JDC_CATA_SINGLETON

JdC = JDC_CATA_SINGLETON(code="ProfileNS")
VERSION_CATALOGUE = "V_0"

def def_function(profondeur, statut, max = 1):
# profondeur : profondeur de la recursivite
# statut : obligatoire ou facultatif
# le statut devient facultatif des le second appel
# on enleve la recursivite pour le Shema DB
   if profondeur > 0 :
      return FACT(statut=statut, nomXML='function',max=max,
        name      = SIMP(statut='o', typ='TXM'),
        cpu_time  = SIMP(statut='o', typ='R', val_min=0, unite='seconds'),
        total_fraction = SIMP(statut='o', typ='R', val_min=0, unite = 'percent'),
        calls = SIMP(statut='o', typ='I', val_min=0),
        depth = SIMP(statut='o', typ='I', val_min=0),
        caller_fraction = SIMP(statut='o', typ='R', val_min=0, unite = 'percent'),
        function = def_function( profondeur-1, 'f', '**')
      )
   else : 
      return FACT()

def def_run_id(version = 'ProfileNS') :
     if version == 'ProfileNS':
         return FACT(statut='o', max=1, min =1,
             #sha1 = SIMP(statut='o', typ='TXM', typeXSD = 'hexBinary' ),
             sha1 = SIMP(statut='o', typ='TXM', ),
             code_name = SIMP(statut='o', typ='TXM',),
             test_name = SIMP(statut='o', typ='TXM',),
             version = SIMP(statut='o', typ='TXM',), 
             timestamp = SIMP(statut='o', typ='I', val_min=0), 
             build_type = SIMP(statut='o', typ='TXM', into=('Release','Debug','RelWithDebInfo')), 
             execution = SIMP(statut='o', typ='TXM', into=('par','seq')), 
             procs = SIMP(statut='o', typ='I', val_min=0),
             # 0 si la valeur n est pas significative
             host = SIMP(statut='o', typ='TXM',),
             OS = SIMP(statut='o', typ='TXM',),
         )
     elif version == 'XSLT' :
         return FACT(statut='o', max=1, min =1, 
             sha1 = SIMP(statut='o', typ='TXM'),
             code_name = SIMP(statut='o', typ='TXM',),
             test_name = SIMP(statut='o', typ='TXM',),
             version = SIMP(statut='o', typ='TXM',), 
             timestamp = SIMP(statut='o', typ='I', val_min=0), 
             build_type = SIMP(statut='o', typ='TXM', into=('Release','Debug','RelWithDebInfo')), 
             execution = SIMP(statut='o', typ='TXM', into=('par','seq')), 
             procs = SIMP(statut='o', typ='I', val_min=0),
             # 0 si la valeur n est pas significative
             host = SIMP(statut='o', typ='TXM',),
             OS = SIMP(statut='o', typ='TXM',),
             total_cpu_time  = SIMP(statut='o', typ='R', val_min=0, unite='seconds'),
         )
     else : 
        print ('________________________________________________\n')
        print ('mauvais argument pour appeler def_run_id')
        print ('corrigez le catalogue')
        print ('________________________________________________')
    

def def_time_profile(version) :
     if version == 'ProfileNS':
        return FACT(statut = 'f', max = 1,
           total_cpu_time  = SIMP(statut='o', typ='R', val_min=0, unite='seconds'),
           function = def_function(10, 'o')
           )
     elif version == 'XSLT' :
        return FACT(statut = 'f', max = '**',
            name      = SIMP(statut='o', typ='TXM'),
            cpu_time  = SIMP(statut='o', typ='R', val_min=0, unite='seconds'),
            total_fraction = SIMP(statut='o', typ='R', val_min=0, unite = 'percent'),
            calls = SIMP(statut='o', typ='I', val_min=0),
        )
     else : 
        print ('________________________________________________\n')
        print ('mauvais argument pour appeler def_time_profile')
        print ('corrigez le catalogue')
        print ('________________________________________________')


def def_memory_profile(version = 'ProfileNS'):
     if version == 'XSLT' :
        return  FACT(statut ='f',
          malloc = SIMP(statut='o', typ='I', val_min=0, typeXSD='xs:long'),
          calloc = SIMP(statut='o', typ='I', val_min=0, typeXSD='xs:long'),
          realloc = SIMP(statut='o', typ='I',val_min=0, typeXSD='xs:long' ),
          free = SIMP(statut='o', typ='I', val_min=0, typeXSD='xs:long' ),
          malloc_size  = SIMP(statut='o', typ='I', unite ="bytes", val_min=0, typeXSD='xs:long'),
          realloc_size  = SIMP(statut='o', typ='I', unite ="bytes", val_min=0, typeXSD='xs:long'),
          calloc_size  = SIMP(statut='o', typ='I', unite ="bytes", val_min=0, typeXSD='xs:long'),
          peak_size  = SIMP(statut='o', typ='I', unite ="bytes", val_min=0, typeXSD='xs:long'),
        )
     elif version == 'ProfileNS' :
         return  FACT(statut ='f',
           count = FACT(statut ='o',
              malloc = SIMP(statut='o', typ='I', val_min=0, typeXSD='xs:long' ),
              calloc = SIMP(statut='o', typ='I', val_min=0, typeXSD='xs:long'),
              realloc = SIMP(statut='o', typ='I',val_min=0, typeXSD='xs:long' ),
              free = SIMP(statut='o', typ='I', val_min=0, typeXSD='xs:long' ),
            ),
           allocation = FACT(statut ='o',
              malloc_size  = SIMP(statut='o', typ='I', unite ="bytes", val_min=0, typeXSD='xs:long'),
              realloc_size  = SIMP(statut='o', typ='I', unite ="bytes", val_min=0, typeXSD='xs:long'),
              calloc_size  = SIMP(statut='o', typ='I', unite ="bytes", val_min=0, typeXSD='xs:long'),
              peak_size  = SIMP(statut='o', typ='I', unite ="bytes", val_min=0, typeXSD='xs:long'),
            ),
        )
     else : 
        print ('________________________________________________\n')
        print ('mauvais argument pour appeler def_memory_profile')
        print ('corrigez le catalogue')

if JdC.code in ( 'ProfileNS',) :
    Profile = PROC( nom = "Profile",
       run_id = def_run_id(),
       time_profile = def_time_profile('ProfileNS'),
       memory_profile = def_memory_profile ()
    )

dElementsRecursifs = {'function' : def_function }
