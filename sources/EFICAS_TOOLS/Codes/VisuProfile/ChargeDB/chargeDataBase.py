#! /usr/bin/env python3
# -*- coding:utf-8 -*-
import sys, os, pathlib

sys.path.insert(0, (os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)),'..'))))
sys.path.insert(0, (os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)),'../..'))))
sys.path.insert(0, (os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)),'../../..'))))

from argparse import ArgumentParser, FileType
import cata_profile_DB_XSLT_driver as mdm
from connectDB import connectDB


debutXML = '<?xml version="1.0" ?>\n<ns1:ProfileNS xmlns:ns1="http://chercheurs.edf.com/logiciels/ProfileNS">\n <ns1:Profile>'
finXML ='\n  </ns1:Profile>\n</ns1:ProfileNS>'


# on enleve run_id des colonnes de profile car il est increente automatiquement
dictColumns = {
   'profile' : ('sha1', 'code_name', 'test_name', 'version', 'timestamp', 'build_type', 'execution', 'procs', 'host', 'OS', 'total_cpu_time'),
   'raw_profile' : ('raw_profile_xml',),
   'time_profile' : ('name', 'cpu_time', 'total_fraction', 'calls'),
   'memory_profile' : ('malloc', 'calloc', 'realloc', 'free', 'malloc_size', 'realloc_size', 'calloc_size', 'peak_size')
}
dictEquivalentTable = {}
dictNomKey = {'profile' : 'run_id','raw_profile' : 'run_id', 'time_profile' :'run_id', 'memory_profile': 'run_id'}
creeKey = { 'profile' : 'run_id'}
listTables  =  ('profile',  'memory_profile', 'time_profile', 'raw_profile')

connecteurTexte = "dbname=odyssee_test user=odyssee_test_admin"


class parseur(ArgumentParser):
# ----------------------------#

    def __init__(self):
    #-----------------#
        program = "chargeDataBase"
        description = "lit un fichier XML de performance et le charge dans la database"
        super().__init__(prog=program, description=description)
        self.add_argument( "-f", "--fileName", nargs="*", required=True,
            help="name of performance file(s) , aboslute ou relative to directory specified with -d option",
        )
        self.add_argument( "-d", "--directoryName", type=pathlib.Path,
            help="directory containing file if path is relative",
        )
        self.add_argument( "-r", "--rangeFile", type=int,
            help="range of files in order to process file1.xml, file2.xml. The file name has then to be file.xml",
        )

    def parse_args(self):
    #-------------------#
        args = super().parse_args()
        if args.rangeFile:
            newFileNameList = []
            splitF = args.fileName[0].split(".xml")
            if len(splitF) != 2 and splitF[1] != "":
                print("FileName has to be as file.xml")
                self.print_usage()
                exit(2)
            baseFile = splitF[0]
            for i in range(args.rangeFile):
               newFileNameList.append(baseFile + str(i) + ".xml")
            args.fileName = newFileNameList
        if args.directoryName:
            if not(os.path.isdir(args.directoryName)):
                print("Directory {} does not exist".format(args.directoryName))
                self.print_usage()
                exit(2)
            newFileNameList = []
            for f in args.fileName:
                newFileNameList.append(os.path.join(args.directoryName, f))
            args.fileName = newFileNameList

        newFileNameList = []
        for f in args.fileName:
            if not os.path.isfile(f):
                print("cannot access file {}".format(f))
                continue
            newFileNameList.append(f)
        args.fileName = newFileNameList
        if args.fileName==[]:
            print ('no file to process')
            self.print_usage()
            exit(2)
        return args


# -------------------------------#
class connectDBCharge(connectDB):
# -------------------------------#
    """
    lit un fichier XML de perfomance et le charge dans la database
    code exit : 1 erreur database, 2 autres erreurs
    herite de connectDB qui gere les connexions à la database
    la chaine de connexion  connecteurTexte est definie au global
    Attention, si dans un lot de fichier, un est en erreur dans la database, le job s arrete
    """

    def chargeXMLFile(self, fileName, debug=1):
    #-----------------------------------------#
        """
         appelle les fonctions qui
         1) lisent le fichier XML passe en argument
         2) preparent le insert
         3) executent le insert grace a connectDB
         4) commit
        """
        self.litXMLFile(fileName)
        self.ident = None
        # debug = 1
        # on admet qu on a un seul enregistrement par XML
        for table in  listTables :
            if table == 'raw_profile':
                self.prepareTableRaw()
            else :
                self.prepareValeurs(table)
            for textInstruction in self.listeInstruction:
                if debug : print (textInstruction)
                resultat = self.executeInsert(textInstruction)
                if resultat != None and resultat != []:
                   self.ident = resultat[0][0]
                if debug :  print (self.ident)
        self.commitDB()
        exit()
   

    def litXMLFile(self, fileName):
    #-----------------------------#
        """
        lit le fichier XML grace a pyxb
        """
        debug=0
        #try:
        if 1 :
            self.jdd = mdm.CreateFromDocument(open(fileName).read())
            self.rootElt = self.jdd.Profile[0]
            if debug : print ( self.jdd.toDOM().toprettyxml())
        #except Exception as e:
        #    print("impossible de lire le fichier", fileName)
        #    print("exception", e)
        #    exit(2)


    def prepareTableRaw(self):
    #------------------------#
        self.listeInstruction = []
        textColumn = "INSERT INTO raw_profile (run_id, raw_profile_xml) VALUES ("
        textColumn += str(self.ident) + ", '"
        raw = self.rootElt.raw_profile
        raw_profile = raw.raw_profile_xml 
        texteXML = raw_profile.toDOM(element_name='ProfileNS').toprettyxml()
        texteXML = '\n'.join(texteXML.split('\n')[2:-2])
        texteInstruction = textColumn + debutXML + texteXML + finXML + "');"
        self.listeInstruction.append(texteInstruction)

    def prepareValeurs(self, table, debug=0):
    #---------------------------------------#
        """
       Cherche les valeurs dans l objet Pyxb selon la liste dans le dictColumns
       Attention aux valeurs optionnelles non traitees
       Attention aux elements multiples
       """
        #debug = 1
        if debug: print("prepareValeur ", table)
        debutTextColumn = "INSERT INTO {} (". format (table)
        debutTextValues = " VALUES ("
        self.listeInstruction = [] 
        if table not in dictColumns.keys():
            print( "conversion du type {} vers la database non prévue ".format(table))
            exit(2)
        if table in dictEquivalentTable.keys() : nomElt = dictEquivalentTable[table]
        else : nomElt = table

        if table in creeKey  :
            textTrigger = ") RETURNING {} ".format(creeKey[table])
        else : 
            debutTextColumn += dictNomKey[table] + ", "
            debutTextValues += str(self.ident) + ", "
            textTrigger = ")" 

        eltPyxb = getattr(self.rootElt, nomElt)
        if debug : print ('eltTable ', eltPyxb)
        if isinstance(eltPyxb,mdm.pyxb.binding.content._PluralBinding) : 
          eltTable=[]
          for e in eltPyxb : eltTable.append(e)
        else : 
          eltTable=(eltPyxb,)
        if debug : print ('eltTable ', eltTable)

        for elt in eltTable :
            textColumn = debutTextColumn
            textValues = debutTextValues
            for colonne in dictColumns[table]:

                # En dur sur le nom de la colonne
                # pour ne pas trop penaliser le code
                if colonne == "name" : remplaceQuote = 1
                else : remplaceQuote = 0
                if debug : print ('on traite ', colonne)
                textColumn += colonne + ', '
                eltCol = getattr(elt,colonne)
                #if not(isinstance(eltCol, list)) : 
                if not isinstance(eltCol,mdm.pyxb.binding.content._PluralBinding) : 
                    if debug : print ('la valeur est : ', eltCol)
                    if eltCol._AttributeMap == {} :
                        if debug : print ('type avac attribut')
                        if remplaceQuote and eltCol.find("'") :
                           eltTemp = eltCol.replace ("'", "''")
                           textValues += "'"+str(eltTemp)+"', "
                        else : 
                           textValues += repr(eltCol)+", "
                    else :
                        if debug : print ('on prend la value')
                        if remplaceQuote and eltCol.value().find("'"):
                           eltTemp = eltCol.value().replace ("'", "''")
                           textValues += "'"+str(eltTemp)+"', "
                        else : 
                           textValues += repr(eltCol.value())+", "
                else :
                    print ('il faut traiter ce cas')
            textColumn = textColumn[0:-2] + ")"
            textValues = textValues[0:-2]  
            textInstruction = textColumn + textValues + textTrigger +  ";"
            self.listeInstruction.append(textInstruction)
        if debug : print ('textColumn', textColumn)
        if debug : print ('textValues', textValues)
        if debug : print ('textInstruction', textInstruction)
        if debug: print("\n\n\n")



if __name__ == "__main__":
# -----------------------#
    fileNameBase = ( "/home/A96028/QT5Dev/eficasMerge/Codes/cinqC/data")
    monParseur = parseur()
    args = monParseur.parse_args()
    monConnecteur = connectDBCharge()
    for fileName in args.fileName:
        try:
        #if 1 :
            monConnecteur.chargeXMLFile(fileName)
            print ('file {} processed'.format(fileName))
        except Exception as e:
            print ('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!')
            print("impossible de charger", fileName)
            print ('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!')
            print("exception", e)

    monConnecteur.closeDB()
