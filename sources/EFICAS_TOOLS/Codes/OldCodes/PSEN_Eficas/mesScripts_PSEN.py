def exportToCsv(listeparam) :
    texte=""
    editor= listeparam[0]
    item  = listeparam[1]
    fn=None
    try :
      from PyQt4.QtGui import QFileDialog, QMessageBox
      fichier = QFileDialog.getOpenFileName()
      if fichier == None : return
    except :
      try :
        from PyQt5.QtWidgets import QFileDialog, QMessageBox
        fichier = QFileDialog.getOpenFileName()
        if fichier[0] == None : return
        fichier=fichier[0]
      except:
        pass

    nouvelleVal=[]
    prob=item.object.get_child('Probability')
    valeur=prob.get_valeur()
    texte=""
    for v in valeur :
        texte+=v[0].nom+";"+str(v[1]).replace('.',',')+"\n"

    try :
      fn=open(fichier,'wb')
      fn.write(texte)
      fn.close()
    except Exception, why:
      QMessageBox.critical(editor, ("Save file failed"),
      ('unable to save ')+str(fn) + str(why))


def importFromCsv(listeparam) :
    texte=""
    editor= listeparam[0]
    item  = listeparam[1]
    node  = listeparam[2]
    fn=None
    try :
      from PyQt4.QtGui import QFileDialog
      fichier = QFileDialog.getOpenFileName()
      if fichier == None : return
      fn=open(fichier)
    except :
      try :
        from PyQt5.QtWidgets import QFileDialog
        fichier = QFileDialog.getOpenFileName()
        if fichier[0] == None : return
        fn=open(fichier[0])
      except:
        pass
    #fn=open('Classeur1.csv')
    if not fn : return
    nouvelleVal=[]
    prob=item.object.get_child('Probability')
    monType=prob.definition.validators.typeDesTuples[0]
    listeObjet=item.object.etape.parent.get_sd_avant_du_bon_type(item.object.etape,(monType,))
    for ligne in fn.readlines():
      try :
        nom,valeur = ligne.split(';')
      except :
        texte += "not able to process: "+ ligne
        continue
      if nom not in listeObjet :
        texte += nom + " : ignored (not known in Eficas) \n "
        continue
      try :
        concept=item.jdc.get_concept(nom)
      except :
        texte += nom + ": ignored (not known in Eficas) \n "
        continue
      try :
        valNum=valeur.replace (',','.')
        valeur=eval (valNum, {})
      except :
        texte += valeur + " : unable to eval \n "
        continue
      nouvelleVal.append((concept,valeur))
      #  exec nom in self.jdc

    if nouvelleVal != [] : prob.set_valeur(nouvelleVal)
    if texte != "" :
       try :
         from  PyQt5.QtWidgets  import QMessageBox
       except :
         from  PyQt4.QtGui  import QMessageBox
       QMessageBox.information( None,'unable to append values',texte,) 

    node.affichePanneau()
        
    print "et ici"

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
   'N_1_GENERATORS':( 
           (exportToCsv,"exportToCsv",('editor','item'),False,False,"export values to cvs File"),
           (importFromCsv,"importFromCsv",('editor','item','self'),False,False,"import values from cvs File"),
                    ),
   'N_1_LINES':( 
           (exportToCsv,"exportToCsv",('editor','item'),False,False,"export values to cvs File"),
           (importFromCsv,"importFromCsv",('editor','item','self'),False,False,"import values from cvs File"),
                    )
               }
