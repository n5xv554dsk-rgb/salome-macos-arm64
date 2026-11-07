def processXLS(listeparam) :
    print "dans processXLS"
    item=listeparam[0]
    fileNameObj=item.object.get_child('XLS_file')
    if fileNameObj : fileName=fileNameObj.get_valeur()
    else : fileName = ""
    if fileName == "" : return 0, 'Nom de fichier invalide'

    ongletListObj=item.object.get_child('Onglets')
    if ongletListObj : ongletList= ongletListObj.get_valeur()
    else : ongletList = [] 
    if ongletList == [] : return 0, 'ongletList invalide'

    busListObj=item.object.get_child('BusList')
    if busListObj : busList= busListObj.get_valeur()
    else : busList = [] 
    if busList == [] : return 0, 'BusList invalide'

    contListObj=item.object.get_child('ContList')
    if contListObj : contList=contListObj.get_valeur()
    else : contList = []
    if contList == [] : return 0, 'ContList invalide'

    dicoBus={}
    dicoCont={}
    for onglet in ongletList:
        recherche=str(" ("+ str(onglet) +" )")
        listeBusPourOnglet=[]
        listeContPourOnglet=[]
        for bus  in busList :  
            nomBusSplit=str(bus).split(recherche)
            if len(nomBusSplit) == 2 : listeBusPourOnglet.append(nomBusSplit[0])
        for cont in contList : 
            nomContSplit=str(cont).split(recherche)
            if len(nomContSplit) == 2 : listeContPourOnglet.append(nomContSplit[0])
        if listeBusPourOnglet != []  : dicoBus[onglet]=listeBusPourOnglet
        if listeContPourOnglet != [] : dicoCont[onglet]=listeContPourOnglet

    from Processor import processXLS
    processXLS(fileName,dicoBus,dicoCont)
    #if nouvelleVal != [] : prob.set_valeur(nouvelleVal)

# le dictionnaire des commandes a la structure suivante :
# la clef est la commande qui va proposer l action
# puis un tuple qui contient
#	- la fonction a appeler
#       - le label dans le menu du clic droit
#	- un tuple contenant les parametres attendus par la fonction
#	- appelable depuis Salome uniquement -)
#	- appelable depuis un item valide uniquement 
#	- toolTip
dict_commandes={
   'DATA_PROCESSING': ( 
       (processXLS,"process",('item',),False,True,"process values "),
                      ),
  }
