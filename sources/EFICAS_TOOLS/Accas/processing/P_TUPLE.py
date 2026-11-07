import types
import Accas
import inspect


class P_Tuple:
    def __init__(self, ntuple):
        self.ntuple = ntuple

    def __convert__(self, valeur):
        try:
            if isinstance(valeur, basestring):
                return None
        except NameError:
            if isinstance(valeur, str):
                return None
        if len(valeur) != self.ntuple:
            return None
        return valeur

    def info(self):
        return "Tuple de %s elements" % self.ntuple


class P_Matrice:
    def __init__( self, nbLigs=None, nbCols=None, methodeCalculTaille=None, formatSortie="ligne",
        valSup=None, valMin=None, structure=None, typElt="R", typEltInto=None,
        listeHeaders=None, coloree=False, defaut=None,):
        self.nbLigs = nbLigs
        self.nbCols = nbCols
        self.methodeCalculTaille = methodeCalculTaille
        self.formatSortie = formatSortie
        self.valSup = valSup
        self.valMin = valMin
        self.structure = structure
        self.typElt = typElt
        self.listeHeaders = listeHeaders
        self.typEltInto = typEltInto
        self.jdc = None
        self.coloree = coloree
        self.defaut = defaut
        if self.coloree: self.activeCouleur()

    def __convert__(self, valeur):
        # Attention ne verifie pas grand chose
        if not isinstance(valeur, types.ListType):
            return None
        return valeur

    def verifItem(self, texte, mc):
        val = ""
        if self.typElt == "R":
            try:
                val = float(str(texte))
                ok = True
            except:
                return (False, "Entrer un float SVP")
        if self.typElt == "I":
            try:
                val = int(str(texte))
                ok = True
            except:
                return (False, "Entrer un float SVP")
        if self.typElt in ("R", "I") and self.valSup != None:
            if val > self.valSup:
                return (False, "Entrer un nombre inferieur a " + repr(self.valSup))
        if self.typElt in ("R", "I") and self.valMin != None:
            if val < self.valMin:
                return (False, "Entrer un nombre superieur a " + repr(self.valMin))
        if val == "":
            val = texte
        if self.typEltInto != None and val not in self.typEltInto:
            return "Entrer une valeur contenue dans " + str(self.typEltInto)
        try:
            if issubclass(self.typElt, Accas.ASSD):
                if not self.jdc:
                    self.jdc = CONTEXT.getCurrentJdC()
                if not (val in self.jdc.sdsDict.keys()):
                    return (False, "Concept inexistant")
                if not (isinstance(self.jdc.sdsDict[val], self.typElt)):
                    return (False, "Concept d un autre type")
                a = self.jdc.getSdAvantDuBonType(mc.etape, (self.typElt,))
                if texte not in self.jdc.getSdAvantDuBonType(mc.etape, (self.typElt,)):
                    return (False, "Le concept doit etre defini avant")
        except:
            pass
        return (True, "")

    def convertItem(self, texte):
        if self.typElt == "R":
            val = float(str(texte))
        if self.typElt == "I":
            val = int(str(texte))
        try:
            if issubclass(self.typElt, Accas.ASSD):
                return self.jdc.sdsDict[texte]
        except:
            pass

    def info(self):
        return "Matrice %s x %s" % (self.nbLigs, self.nbCols)

    __repr__ = info
    __str__ = info


class P_Matrice_Correlation(P_Matrice):
    pass
