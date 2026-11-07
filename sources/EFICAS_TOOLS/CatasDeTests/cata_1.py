#  coding: utf-8 -*-
#

#import os
#import types
#monFile=os.path.abspath(__file__)

from Accas import *
import types

#type UserASSD
class User_Data(UserASSD): pass
#type ASSD
class Mesh(ASSD): pass
class MeshU(UserASSD): pass

#Be careful when modidying the order/names od the test_simp since they are used bye the documentation xsd_mapping.rst
#beginJdC
JdC   = JDC_CATA(code='Test1',)

#Usecase 1abis : Le contenu de l'objet est completement déterminé par les paramètres suivants
#CreateMesh    = OPER(nom = 'CreateMesh', sd_prod=Mesh,
#                     meshname       = SIMP(typ='TXM'),
#                     dimension      = SIMP(typ='I', into=[1,2,3]),
#                     listOfEntities = SIMP(typ='I', max='**'),)
##Usecase 1ater : Il est possible de créer plusieurs
#CreateBoth   =  OPER(nom = 'CreateBoth', sd_prod=Mesh,
#                     meshname       = SIMP(typ=(MeshU,'createObject')),
#                     dimension      = SIMP(typ='I', into=[1,2,3]),
#                     listOfEntities = SIMP(typ='I', max='**'),)
#
##Usecase 1b : Chaque champ (crée à la racine) utilise l'objet maillage précedement construit (à la racine)
## statut='o', ??
MyField  =   PROC(nom='MyField',
                 onMesh = SIMP(statut='o',typ=Mesh),)

#
#############################
##Usecase 2a : Il est possible de créer plusieurs maillages dans une structure nommée meshes
## La définition du nom du maillage dans le JDD sert de référence à un notre mesh (un objet python du type UserASSD Mesh
## est également crée pour l'occasion (sans paramètre au constructeur) ).
## le typ <réel> du SIMP est en fait une chaîne pour laquelle il est possible d'ajouter un validateur.
#Meshes   =   PROC(nom = 'Meshes',
#                   mesh = FACT(max='**',
#                               name           = SIMP(typ=(MeshU,'createObject')),
#                               dimension      = SIMP(typ='I', into=[1,2,3]),
#                               listOfEntities = SIMP(typ='I', max='**'),
#                           ),
#              )#Meshes

#MyFieldBis  =   PROC(nom='MyFieldBis',
#                 onMesh = SIMP(statut='o',typ=MeshU),)
#
