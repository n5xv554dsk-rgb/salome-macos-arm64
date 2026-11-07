def EficasProcessXLS(listeparam) :
    print "dans processXLS"
    item=listeparam[0]
    dico=item.process_N1()
    print dico

    print "version pour Pascale --> decommenter les 2 lignes suivantes pour Laura"
    #from Processor import processXLS
    #processXLS(dico)
    

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
   'CONTINGENCY_PROCESSING': ( (EficasProcessXLS,"process",('editor','item',),False,True,"process values "),),
               }
