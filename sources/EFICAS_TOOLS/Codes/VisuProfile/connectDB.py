#! /usr/bin/env python3
# -*- coding:utf-8 -*-
import sys
import psycopg2


#connecteurTexte = "dbname=odyssee_test user=admin_odyssee_test"
connecteurTexte = "host = odyssee3.retd.edf.fr dbname=cocagne_perf user=admin_perf_cocagne"


from Accas.processing.P_utils import Singleton
class connectDB(Singleton):
    """
    code exit : 1 erreur database, 2 autres erreur
    """

    def __init__(self, debug = 0):
    #----------------------------#
        """
           connexion a la database
           ouverture du curseur
        """
        if hasattr(self, 'pseudoCache'): return
        if debug : print ('----------------- init du connect')
        if not (hasattr(self, 'pseudoCache')) : self.pseudoCache = {}
        try:
            self.connecteur = psycopg2.connect(connecteurTexte)
        except Exception as e:
            print("impossible de se connecter avec connecteur", connecteurTexte)
            print("exception", e)
            self.closeDB()
            exit(1)
        if debug : print ('connecteur', self.connecteur)
        try:
            self.curseur = self.connecteur.cursor()
        except Exception as e:
            print("impossible de creer un curseur")
            print("exception", e)
            self.closeDB()
            exit(1)
        if debug : print ('curseur', self.curseur)

    def __del__(self):
    #----------------#
    # PN est ce que closeDB est vraiment utile ou est-ce 
    # que cette fonction devrait être del comme le connect est dans le init?
        self.closeDB()

    # la difference entre select et insert est le pseudo cache
    # dont je ne suis pas sure qu il soit utile
    def executeSelect(self, instruction, toCache= 0, debug = 0):
    #------------------------------------------------------------#
        if debug: print("executeSelect avec ", instruction )

        inPseudoCache = self.findInPseudoCache(instruction)
        if inPseudoCache : return inPseudoCache
        if debug : print ('____________acces DB _______________________')
        
        try:
            if debug : print ('avant execute')
            self.curseur.execute(instruction)
            if debug : print ('apres excute')
            try :
                resultat = self.curseur.fetchall() 
                if debug : print ('resultat fetch', resultat)
            except Exception as e:
                print("probleme au fetch  l execution de", instruction)
                print("exception", e)
                return None 
        except Exception as e:
            print("probleme a l execution de", instruction)
            print("exception", e)
            return None 
        if toCache :
            self.setInPseudoCache(instruction, resultat)
        return resultat

    def executeInsert(self, instruction, debug = 0):
    #------------------------------------------------#
        if debug: print("executeInsertDB avec ", instruction)
        try:
            self.curseur.execute(instruction)
            try :
                resultat = self.curseur.fetchall() 
            except : 
                resultat = None
            if debug : print ('resultat fetch', resultat)
            return resultat
        except Exception as e:
            print("impossible d executer", instruction)
            print("exception", e)

    def commitDB(self):
    #-----------------#
        try:
            self.connecteur.commit()
        except Exception as e:
            print("impossible d executer le commit")
            print("exception", e)
            exit(1)

    def closeDB(self):
    #----------------#
        try:
            self.curseur.close()
        except Exception as e:
            print("impossible d executer le close du curseur")
            print("exception", e)
            exit(1)
        try:
            self.connecteur.close()
        except Exception as e:
            print("impossible d executer le close du connecteur")
            print("exception", e)
            exit(1)

    def setInPseudoCache(self, instruction, resultat):
    #--------------------------------------------#
    # PN : pour l instant
    # Que faut il pas stocker pour affiner plus facilement
        self.pseudoCache[instruction] = resultat

    def findInPseudoCache(self, instruction) :
    #---------------------------------------#
        if instruction in self.pseudoCache :
           return self.pseudoCache[instruction]
        else : return None

if __name__ == "__main__":
     pass

