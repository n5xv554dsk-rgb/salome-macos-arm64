#! /usr/bin/env python3
# -*- coding:utf-8 -*-
# /*  This file is part of MED.
#  *
#  *  COPYRIGHT (C) 1999-2026  EDF R&D, CEA/DEN
#  *  MED is free software: you can redistribute it and/or modify
#  *  it under the terms of the GNU Lesser General Public License as published by
#  *  the Free Software Foundation, either version 3 of the License, or
#  *  (at your option) any later version.
#  *
#  *  MED is distributed in the hope that it will be useful,
#  *  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  *  GNU Lesser General Public License for more details.
#  *
#  *  You should have received a copy of the GNU Lesser General Public License
#  *  along with MED.  If not, see <http://www.gnu.org/licenses/>.
#  */


import sys
sys.path.append('/home/A96028/Salome/V7_main/tools/install/Medfichier-307-hdf51810/lib/python2.7/site-packages')

from med.medfile import *
from med.medmesh import *
from med.medfamily import *
from med.medfilter import *


def getGroupes(filename,debug=0) :
    listeGroupes=[]
    maa=""
    
    dicoNumFam={}

    try :
        fid = MEDfileOpen(filename,MED_ACC_RDONLY)
    except :
        return ("Pb a la lecture du fichier", listeGroupes,maa)

   
    # /* Lecture des infos concernant le premier maillage */
    maa, sdim, mdim, type, desc, dtunit, sort, nstep, rep, nomcoo,unicoo = MEDmeshInfo(fid, 1)
    if debug :
   	print "Maillage de nom : |%s| de dimension : %ld , et de type %s\n"%(maa,mdim,type)
   	print "Maillage de nom : |%s| , de dimension : %ld , et de type %s\n"%(maa,mdim,type)
   	print "\t -Dimension de l'espace : %ld\n"%(sdim)
   	print "\t -Description du maillage : %s\n"%(desc)
   	print "\t -Noms des axes : |%s|\n"%(nomcoo)
   	print "\t -Unités des axes : |%s|\n"%(unicoo)
   	print "\t -Type de repère : %s\n"%(rep)
   	print "\t -Nombre d'étape de calcul : %ld\n"%(nstep)
   	print "\t -Unité des dates : |%s|\n"%(dtunit)
   
    # /* Lecture du nombre de familles */
    nfam = MEDnFamily(fid,maa)
    if debug :
   	print "Nombre de familles : %d \n"%(nfam)
   
    # /* Lecture de chaque famille */
    for i in xrange(0,nfam):
   
        # /* Lecture du nombre de groupe */
        ngro = MEDnFamilyGroup(fid,maa,i+1)
        if debug :
     	    print "Famille %d a %d groupes \n"%(i+1,ngro)
   
        gro  = MEDCHAR(MED_LNAME_SIZE*ngro+1)
         
        nomfam,numfam,gro = MEDfamilyInfo(fid,maa,i+1,gro)
        if debug :
            print "Famille de nom %s et de numero %d : \n"%(nomfam,numfam)
            print "Attributs : \n"
    
        for j in xrange(0,ngro):
        # print "gro = %s\n"%(gro[j*MED_LNAME_SIZE:j*MED_LNAME_SIZE+MED_LNAME_SIZE])
            groupSplit=gro[j*MED_LNAME_SIZE:j*MED_LNAME_SIZE+MED_LNAME_SIZE]
            groupeName="".join(groupSplit).split("\x00")[0]
            groupeName=groupeName.replace(' ','')
            if groupeName[0:7]=="CENTRE_" : dicoNumFam[groupeName]=numfam
            if groupeName not in listeGroupes : listeGroupes.append(groupeName) 


    #print dicoNumFam
    #print listeGroupes 
    
    # /* Lecture des Numeros de Familles */ 
    
    nnoe, chgt, trsf = MEDmeshnEntity(fid,maa,MED_NO_DT,MED_NO_IT, MED_NODE,MED_NONE,MED_COORDINATE,MED_NO_CMODE)
    nufano = MEDINT(nnoe)
    MEDmeshEntityFamilyNumberRd(fid,maa, MED_NO_DT, MED_NO_IT, MED_NODE,MED_NONE,nufano)
    dicoNumNode={}
    for groupe in dicoNumFam.keys():
        famille=dicoNumFam[groupe]
        i=0
        while i < nufano.size():
           if nufano[i]==famille :
              dicoNumNode[groupe]=i+1
              break
           i=i+1
   
   
    #print dicoNumNode
    dicoCoord={}
    for groupe in dicoNumNode.keys() :
        flt=MEDINT(1)
        flt[0]=dicoNumNode[groupe]
        coo1=MEDFLOAT(3)
        filter=med_filter()
        err=MEDfilterEntityCr( fid, nnoe, 1, sdim, MED_ALL_CONSTITUENT, MED_FULL_INTERLACE, MED_COMPACT_PFLMODE, MED_NO_PROFILE,1 , flt, filter)
        MEDmeshNodeCoordinateAdvancedRd(fid, maa, MED_NO_DT, MED_NO_IT, filter, coo1)
        MEDfilterClose(filter)
        dicoCoord[groupe]=coo1
#   dicoCoord['CENTRE_saxBas']=(0,0,28.5e-3)
#   dicoCoord['CENTRE_saxHaut']=(0,0,31.5e-3)

    MEDfileClose(fid)
    return ("",listeGroupes,maa,dicoCoord)

if __name__ == "__main__":
    filename="/home/A96028/Carmel/Pascale/Domaine_Bidouille.med"
    #filename="/home/A96028/Carmel/nouveauMed/Domaine.med"
    print getGroupes(filename)
