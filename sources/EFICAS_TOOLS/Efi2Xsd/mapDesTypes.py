class Tuple:
    def __init__(self, ntuple):
        self.ntuple = ntuple

    def __convert__(self, valeur):
        if type(valeur) == types.StringType:
            return None
        if len(valeur) != self.ntuple:
            return None
        return valeur

    def info(self):
        return "Tuple de %s elements" % self.ntuple

    __repr__ = info
    __str__ = info


def inverseDico(dicoSource):
    # ---------------------------
    dicoInverse = {}
    for clef, valeur in dicoSource.items():
        if not (type(valeur) is tuple):
            dicoInverse[valeur] = clef
            continue
        (elt, att) = valeur
        if elt not in dicoInverse:
            dicoInverse[elt] = {}
        dicoInverse[elt][att] = clef
    return dicoInverse


dictSIMPEficasXML = {
    "typ": "nomTypeAttendu",
    "statut": "statut",
    "min": "minOccurences",
    "max": "maxOccurences",
    "homo": "homo",
    "position": "portee",
    "validators": "validators",
    "sug": "valeurSugg",
    "defaut": "valeurDef",
    "into": ("plageValeur", "into"),
    "val_min": ("plageValeur", "borneInf"),
    "val_max": ("plageValeur", "borneSup"),
    "ang": ("doc", "ang"),
    "fr": (
        "doc",
        "fr",
    ),
    "docu": ("doc", "docu"),
}

dictSIMPXMLEficas = inverseDico(dictSIMPEficasXML)


dictFACTEficasXML = {
    "statut": "statut",
    "min": "minOccurences",
    "max": "maxOccurences",
    "ang": ("doc", "ang"),
    "fr": (
        "doc",
        "fr",
    ),
    "docu": ("doc", "docu"),
    "regles": "regles",
    "validators": "validators",
}

dictFACTXMLEficas = inverseDico(dictFACTEficasXML)

dictBLOCEficasXML = {
    "statut": "statut",
    "ang": ("doc", "ang"),
    "fr": (
        "doc",
        "fr",
    ),
    "regles": "regles",
    "condition": "condition",
}

dictBLOCXMLEficas = inverseDico(dictBLOCEficasXML)

dictPROCEficasXML = {
    "nom": "nom",
    "regles": "regles",
    "ang": ("doc", "ang"),
    "fr": (
        "doc",
        "fr",
    ),
    "docu": ("doc", "docu"),
}

dictPROCXMLEficas = inverseDico(dictPROCEficasXML)

dictOPEREficasXML = dictPROCEficasXML
dictOPERXMLEficas = dictPROCXMLEficas

dictPourCast = {
    "I": int,
    "R": float,
    "bool": bool,
}
dictNomsDesTypes = {
    "I": "xs:int",
    "R": "xs:float",
    bool: "xs:boolean",
    "TXM": "xs:string",
    "Fichier": "xs:string",
    "Repertoire": "xs:string",
    "FichierNoAbs": "xs:string",
    "FichierOuRepertoire": "xs:string",
}
dictTypesAccasToPostgres = {
    "I": "smallint",
    "R": "float8",
    bool: "boolean",
    "TXM": "text",
    "Fichier": "text",
    "Repertoire": "text",
    "FichierNoAbs": "text",
    "FichierOuRepertoire": "text",
    "date": "date",
}
# en eficas date %Y-%m-%d

listeParamDeTypeTypeAttendu = ("defaut", "sug", "val_min", "val_max", "into", "intoSug")
listeParamDeTypeStr = ("fr", "docu", "ang", "nom")

listeParamTjsSequence = ("into", "intoSug")
listeParamSelonType = ("defaut", "sug", "into", "intoSug")

if __name__ == "__main__":
    import pprint

    pp = pprint.PrettyPrinter(indent=4)
    print("dictSIMPEficasXML")
    pp.pprint(dictSIMPEficasXML)
    print("\n\n")
    print("dictSIMPXMLEficas")
    pp.pprint(dictSIMPXMLEficas)
    print("\n\n")
    print("dictFACTEficasXML")
    pp.pprint(dictFACTEficasXML)
    print("\n\n")
    print("dictFACTXMLEficas")
    pp.pprint(dictFACTXMLEficas)
    print("\n\n")
    print("dictPROCEficasXML")
    pp.pprint(dictPROCEficasXML)
    print("\n\n")
    print("dictPROCXMLEficas")
    pp.pprint(dictPROCXMLEficas)
    print("\n\n")
    print("dictNomsDesTypes")
    pp.pprint(dictNomsDesTypes)
