# -*- coding: utf-8 -*-
# Copyright (C) 2007-2026   EDF R&D
#
# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation; either
# version 2.1 of the License.
#
# This library is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public
# License along with this library; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307 USA
#
# See http://www.salome-platform.org/ or email : webmaster.salome@opencascade.com
#
"""
   Ce module contient le plugin generateur de fichier au format
   CARMEL3D pour EFICAS.

"""
from __future__ import print_function
from __future__ import absolute_import
try :
    from builtins import str
except : pass

import traceback
import types,re,os
import Accas

from .generator_python import PythonGenerator

listeCalParName = ('Time' , 'Temperature', 'DoseRate', 'Thickness')        #'calculation_parameter_names'


def entryPoint():
    """
       Retourne les informations necessaires pour le chargeur de plugins

       Ces informations sont retournees dans un dictionnaire
    """
    return {
         # Le nom du plugin
           'name' : 'MAPVp',
         # La factory pour creer une instance du plugin
           'factory' : MapGenerator,
           }


class MapGenerator(PythonGenerator):
    """
       Ce generateur parcourt un objet de type JDC et produit
       un texte au format eficas et
       un texte au format py

    """

    def gener(self,obj,format='brut',config=None,appliEficas=None):
        self.appliEficas=appliEficas
        self.cata=self.appliEficas.readercata.cata
        self.initDico()
        self.text=PythonGenerator.gener(self,obj,format)
        if obj.isValid() :self.genereTexte(obj)
        return self.text

    def initDico(self) :
        self.texteInput = ""
        self.dictParam={}
        self.dictValeur={}
        self.listeEquations=[]
        self.typeEtude = ""


    def genereTexte(self,obj) :
        print ('genereTexte', self.typeEtude)
        if self.typeEtude == "Calculation" : self.genereCalculation()


    def generPROC_ETAPE(self,obj):
        s=PythonGenerator.generPROC_ETAPE(self,obj)
        if obj.nom == "Calculation_for_Mechanistic" : print ('hjkhjkh');self.typeEtude="Calculation"
        return s

    def genereCalculation(self) :
        '''
        Prepare le contenu du fichier de parametres python
        '''
        self.texteInput = ""
        self.texteInput += self.genereCsv()
        self.texteInput += self.genereCalculationParams()
        self.texteInput += self.txtNomCst
        self.texteInput += self.txtVal
        self.texteInput += self.txtValAct
        self.texteInput += self.txtNomCstNA
        self.texteInput += self.txtValNA
        self.texteInput += self.txtInitName
        self.texteInput += self.txtInitVal
        self.texteInput += self.genereEquations()
        print (self.texteInput)

    def writeDefault(self, fn):
        # normalement c_solver_polymer_kinetics_myStudy.input ou myStudy est le nom de l etude
        fileInput = fn[:fn.rfind(".")] + '.input'
        f = open( str(fileInput), 'wb')
        f.write( self.texteInput )
        f.close()


    def genereCalculationParams(self) :
        txtNom  = "calculation_parameter_names = [ "
        txtVal = "calculation_parameters = [ "
        for param in ('Time' , 'Temperature', 'DoseRate', 'Thickness')  :
            if param in self.dictValeur.keys() :
                txtNom  += "'"+param +  "', "
                txtVal += str(self.dictValeur[param]) + ", "
        # on enleve les dernieres , et on ferme
        txtNom = txtNom[0:-2]
        txtNom += "]\n"
        txtVal = txtVal[0:-2]
        txtVal += "]\n"
        txt = txtNom + txtVal
        return txt

    def genereEquations(self) :
        txt="equation =["
        index=0
        TechnicalUse = self.dictValeur['TechnicalUse']
        ModelName    = self.dictValeur['ModelName']
        for param in  self.listInitialParameters:
            print ('*******************************************')
            print (' je  traite ', param , 'index : ', index)
            trouveParam=False

            if index != 0 : txtParam = 'Dy[j*5 + '+str(index)+ '] = '
            else :          txtParam = 'Dy[j*5] = '

            for equation in  self.listeEquations :
                if param in (self.cata.dicoEquations[TechnicalUse][ModelName]['equa_diff'][equation].keys()):
                    print ('____________ trouve : ', param , 'in ', equation, ' ',  self.cata.dicoEquations[TechnicalUse][ModelName]['equa_diff'][equation][param])
                    trouveParam = True
                    if self.cata.dicoEquations[TechnicalUse][ModelName]['equa_diff'][equation][param][0] == '-' :
                        txtParam += ' ' + self.cata.dicoEquations[TechnicalUse][ModelName]['equa_diff'][equation][param]
                    else :
                        if index != 0 :
                            txtParam += ' + ' + self.cata.dicoEquations[TechnicalUse][ModelName]['equa_diff'][equation][param]
                        else :
                            txtParam +=  self.cata.dicoEquations[TechnicalUse][ModelName]['equa_diff'][equation][param]
                    print ('         txtParam   intermediaire ', txtParam)

            if trouveParam :
                txtParam = txtParam + ", "
                txt += txtParam
                index = index+1
            print (txtParam)
            print ('fin param', param, 'trouve ', trouveParam, '___________________________')
            print ('*************************************************')
            print (' ')
        print ('_________________fin for')
        txt=txt[0:-3]
        txt+="]\n"
        return txt

    def genereCsv(self) :
        txt =  'study_name = ' +self.dictValeur['SimulationName'] +  "\n"
        txt += 'csv_output_file_name = ' + self.dictValeur['OutPutFolder'] + '/c_solver_stiff_ode_1d_' + self.dictValeur['SimulationName']+ '.csv\n'
        return txt


    def generMCList(self,obj):
        s=PythonGenerator.generMCList(self,obj)
        if obj.nom == 'ConstantesArrhenius' :
            self.txtNomCst  = "Arrhenius_Name = [ "
            self.txtVal     = "Arrhenius_A = [ "
            self.txtValAct  = "Arrhenius_Ea = [ "
            for objFils in obj.data:
                for mc in objFils.mcListe :
                    self.txtNomCst +=  "'" + mc.nom + "', "
                    self.txtVal    +=  str(mc.valeur[0]) + ", "
                    self.txtValAct +=  str(mc.valeur[1]) + ", "
            self.txtNomCst = self.txtNomCst[0:-2]
            self.txtVal    = self.txtVal[0:-2]
            self.txtValAct = self.txtValAct [0:-2]
            self.txtNomCst += ']\n'
            self.txtVal    += ']\n'
            self.txtValAct += ']\n'

        if obj.nom == 'ConstantesNonArrhenius' :
            self.txtNomCstNA  = "non_Arrhenius_coefs_names = [ "
            self.txtValNA     = "non_Arrhenius_coefs = [ "
            for objFils in obj.data:
                for mc in objFils.mcListe :
                    self.txtNomCstNA +=  "'" + mc.nom + "', "
                    self.txtValNA    +=  str(mc.valeur) + ", "
            self.txtNomCstNA  = self.txtNomCstNA[0:-2]
            self.txtValNA     = self.txtValNA[0:-2]
            self.txtNomCstNA += ']\n'
            self.txtValNA    += ']\n'

        if obj.nom == 'InitialParameters' :
            self.listInitialParameters =[]
            self.txtInitName  = "initial_Value_names = [ "
            self.txtInitVal   = "initial_Values = [ "
            for objFils in obj.data:
                for mc in objFils.mcListe :
                    self.txtInitName +=  "'" + mc.nom + "', "
                    self.txtInitVal  +=  str(mc.valeur) + ", "
                    self.listInitialParameters.append(mc.nom)
            self.txtInitName  = self.txtInitName[0:-2]
            self.txtInitVal   = self.txtInitVal[0:-2]
            self.txtInitName += ']\n'
            self.txtInitVal  += ']\n'

        if obj.nom in( 'initiation','propagation','termination','stabilization') :
            for o in obj :
                for mc  in o.mcListe :
                    nom=mc.nom.replace (' ','').replace ('+','_').replace ('-','_').replace ('>','_').replace('(','').replace(')','').replace('*','').replace('[','').replace(']','')
                    nom=obj.nom+'_'+nom
                    self.listeEquations.append(nom )
        return s

    def generMCSIMP(self,obj) :
        """
        Convertit un objet MCSIMP en texte python
        Remplit le dictionnaire des MCSIMP
        """
        s=PythonGenerator.generMCSIMP(self,obj)
        if obj.nom=='Consigne' : return s

        if obj.getGenealogie()[0][-6:-1]=="_PARA":
            self.dictParam[obj.nom]=obj.valeur
        else :
            self.dictValeur[obj.nom]=obj.valeur
        return s
