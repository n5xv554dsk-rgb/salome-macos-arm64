from builtins import object
import logging
import os

msgGetDico='d=monEficasConnecteur.getDicoForFancy(monEficasConnecteur.monEditeur.tree.racine)'
msgId='leMotClef={}'

class loggingEnvironnement(object):
    _instance = None

    def __new__(cls, *args, **kwargs):
        if not cls._instance:
            cls._instance = super(loggingEnvironnement, cls).__new__(cls, *args, **kwargs)
        return cls._instance

    def __init__(self):
        self.fichier=None

    def setFile(self,fichier, code='Essai'):
        loggerForTrace = logging.getLogger('loggingForTrace')
        if self.fichier != None      : print ('La log est deja ecrite dans  : ', self.fichier); return
        if (os.path.isfile(fichier)) : 
            print ('le fichier {} existe deja'.format(fichier))
            loggerForTrace.info('#_________________ redemarrage de la log _________________')
        fileHandler = logging.FileHandler(fichier)
        formatter   = logging.Formatter('%(message)s')
        fileHandler.setFormatter(formatter)
        loggerForTrace.addHandler(fileHandler)
        loggerForTrace.setLevel(logging.INFO)
        loggerForTrace.info('from connectEficas import accasConnecteur')
        loggerForTrace.info('monEficasConnecteur=accasConnecteur("{}")'.format(code))


def fonctionLoguee(laFonction, debug=False):
#-------------------------------------------
    from inspect  import  getfullargspec
    from functools import wraps
    listeArgs=getfullargspec(laFonction)
    @wraps(laFonction)
    def laFonctionLoguee(*args, **kwargs):
        if debug : print('Appel {} avec args={} et kwargs={}'.format( laFonction.__name__, args, kwargs))
        loggerForTrace = logging.getLogger('loggingForTrace')
        if 'id' in listeArgs.args : 
           indexId=listeArgs.args.index('id')
           id = args[indexId]
           if debug : print ('id est le parametre ', str(indexId), ' de la fonction :', laFonction.__name__)
           monConnecteur=args[0]
           loggerForTrace.info(msgGetDico)
           finMsgId = monConnecteur.reconstruitChaineDIndex(id)
           if debug : print ('finMsgId', finMsgId)
           loggerForTrace.info(msgId.format(finMsgId))
        else :
           if debug : print ('id n est pas un parametre de la fonction :', laFonction.__name__,)
           indexId=-1

        i=1
        chaineDArgs='('
        for monArg in args[1:] :
            #if debug : print ('chaineDArgs', chaineDArgs)
            #if debug : print ('monArg', monArg)
            if indexId == i:
               chaineDArgs+='leMotClef,'
               i=i+1
               continue
            if isinstance(monArg, str) : chaineDArgs+='"'+str(monArg)+'",'
            else  : chaineDArgs+=str(monArg)+','
            i=i+1
        for (k,v) in kwargs :
            if isinstance(v, str) : chaineDArgs+=str(k)+'="'+str(v)+'",'
            else : chaineDArgs+=str(k)+'='+str(v)+','
        chaineDArgs=chaineDArgs[:-1]+')'
        if debug : print ('chaineDArgs', chaineDArgs)
        msg='print (monEficasConnecteur.{}{})'.format(laFonction.__name__, chaineDArgs)
        if debug : print ('msg', msg)
        loggerForTrace.info(msg)
        return laFonction(*args, **kwargs)
    return laFonctionLoguee


if __name__=='__main__':
     monSingleton=loggingEnvironnement()
     monSingleton.setFile('/tmp/toto.txt')
     loggerForTrace = logging.getLogger('loggingForTrace')
     loggerForTrace.info('Our First Log Message')
