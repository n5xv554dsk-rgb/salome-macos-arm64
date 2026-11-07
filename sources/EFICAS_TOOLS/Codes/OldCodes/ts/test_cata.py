from Accas import *
import types

JdC = JDC_CATA (code = 'MAP',
                execmodul = None,
                )
# ======================================================================
# Catalog entry for the MAP function : c_pre_interfaceBody_mesh
# ======================================================================
INITIALIZATION=PROC(nom="INITIALIZATION",op=None,
Control_Of_Limits = SIMP( statut='o',typ='bool',
    defaut=False ,
    fr = 'UTILISER AVEC LE MOT-CLE : VALEURS LIMITES, LE PROGRAMME SARRETE SI LES LIMITES SUR U,V,H OU T SONT DEPASSEES',
    ang= 'USE WITH THE KEY-WORD : LIMIT VALUES, THE PROGRAM IS STOPPED IF THE LIMITS ON U,V,H, OR T ARE TRESPASSED',
     ),

Limit_Values = SIMP( statut='o',typ='R',
    defaut=(-1000.0, 9000.0, -1000.0, 1000.0, -1000.0, 1000.0, -1000.0, 1000.0) ,
    max=8 ,
    fr = 'Utilise avec le mot-cle CONTROLE DES LIMITES  valeurs mini et maxi acceptables pour H,U,V et T dans lordre suivant : min(H) max(H) min(U) max(U) min(V) max(V) min(T) max(T)',
    ang= 'To be used with the key-word CONTROL OF LIMITS min and max acceptable values for H,U,V et T in the following order   : min(H) max(H) min(U) max(U) min(V) max(V) min(T) max(T)',
     ) )
