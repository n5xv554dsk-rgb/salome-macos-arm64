texteDebut = '<?xml version="1.0" encoding="UTF-8"?>\n<xs:schema xmlns:xs="http://www.w3.org/2001/XMLSchema"\nxmlns="http://chercheurs.edf.com/logiciels/{}"\nxmlns:{}="http://chercheurs.edf.com/logiciels/{}"\ntargetNamespace="http://chercheurs.edf.com/logiciels/{}"\nelementFormDefault="qualified" attributeFormDefault="unqualified" version="0">\n'
texteDebutNiveau2 = '<?xml version="1.0" encoding="UTF-8"?>\n<xs:schema xmlns:xs="http://www.w3.org/2001/XMLSchema"\nxmlns="http://chercheurs.edf.com/logiciels/{}"\nxmlns:{}="http://chercheurs.edf.com/logiciels/{}"\nxmlns:{}="http://chercheurs.edf.com/logiciels/{}"\ntargetNamespace="http://chercheurs.edf.com/logiciels/{}"\nelementFormDefault="qualified" attributeFormDefault="unqualified" version="0">\n'
texteDebutNiveau3 = '<?xml version="1.0" encoding="UTF-8"?>\n<xs:schema xmlns:xs="http://www.w3.org/2001/XMLSchema"\nxmlns="http://chercheurs.edf.com/logiciels/{}"\nxmlns:{}="http://chercheurs.edf.com/logiciels/{}"\nxmlns:{}="http://chercheurs.edf.com/logiciels/{}"\nxmlns:{}="http://chercheurs.edf.com/logiciels/{}"\ntargetNamespace="http://chercheurs.edf.com/logiciels/{}"\nelementFormDefault="qualified" attributeFormDefault="unqualified" version="0">\n'

#texteDebut = '<?xml version="1.0" encoding="UTF-8"?>\n<xs:schema xmlns:xs="http://www.w3.org/2001/XMLSchema"\nxmlns="odyssee/cocagne/{}"\nxmlns:{}="odyssee/cocagne/{}"\ntargetNamespace="odyssee/cocagne/{}"\nelementFormDefault="qualified" attributeFormDefault="unqualified" version="0">\n'
#texteDebutNiveau2 = '<?xml version="1.0" encoding="UTF-8"?>\n<xs:schema xmlns:xs="http://www.w3.org/2001/XMLSchema"\nxmlns="odyssee/cocagne/{}"\nxmlns:{}="odyssee/cocagne/{}"\nxmlns:{}="odyssee/cocagne/{}"\ntargetNamespace="odyssee/cocagne/{}"\nelementFormDefault="qualified" attributeFormDefault="unqualified" version="0">\n'
#texteDebutNiveau3 = '<?xml version="1.0" encoding="UTF-8"?>\n<xs:schema xmlns:xs="http://www.w3.org/2001/XMLSchema"\nxmlns="odyssee/cocagne/{}"\nxmlns:{}="odyssee/cocagne/{}"\nxmlns:{}="odyssee/cocagne/{}"\nxmlns:{}="odyssee/cocagne/{}"\ntargetNamespace="odyssee/cocagne/{}"\nelementFormDefault="qualified" attributeFormDefault="unqualified" version="0">\n'

texteFin = '</xs:schema>'
texteDicoNomEltNomTypeDifferent = '<xs:simpleType name="PNEFdico">\n<xs:annotation>\n<xs:documentation>{}\n\n</xs:documentation>\n</xs:annotation>\n<xs:restriction base="xs:string"></xs:restriction>\n</xs:simpleType>\n'
texteListeTypeWithUnit = '<xs:simpleType name="listeTypeWithUnit">\n<xs:annotation>\n<xs:documentation>{}\n\n</xs:documentation>\n</xs:annotation>\n<xs:restriction base="xs:string"></xs:restriction>\n</xs:simpleType>\n'


# SIMP
debutSimpleType = '<xs:simpleType name="{}">\n'
debutSimpleTypeSsNom = '<xs:simpleType>\n'
fermeSimpleType = '</xs:simpleType>\n'
debutRestrictionBase = '<xs:restriction base="{}">\n'
fermeRestrictionBase = '</xs:restriction>\n'
enumeration = '<xs:enumeration value="{}"/>\n'
maxInclusiveBorne = '<xs:maxInclusive value = "{}"/>\n'
minInclusiveBorne = '<xs:minInclusive value = "{}"/>\n'

typeAvecAttributUnite = '<xs:complexType name="{}">\n<xs:simpleContent>\n<xs:extension base="{}:{}_NoUnit">\n<xs:attribute name="unite_{}" type="xs:string"  fixed = "{}"/>\n</xs:extension>\n</xs:simpleContent>\n</xs:complexType>\n'
debutTypeSimpleListe = '<xs:restriction>\n<xs:simpleType>\n<xs:list>\n<xs:simpleType>\n'
finTypeSimpleListe = '</xs:restriction>\n</xs:simpleType>\n</xs:list>\n</xs:simpleType>\n'
fermeBalisesMileu = '</xs:restriction>\n</xs:simpleType>\n</xs:list>\n</xs:simpleType>\n'

maxLengthTypeSimple = '<xs:maxLength value = "{}"/>\n'
minLengthTypeSimple = '<xs:minLength value = "{}"/>\n'
eltDsSequence = '<xs:element name="{}" type="{}:{}" minOccurs="{}" maxOccurs="{}"/>\n'
eltDsSequenceWithHelp = '<xs:element name="{}" type="{}:{}" minOccurs="{}" maxOccurs="{}">\n<xs:annotation>\n<xs:documentation>\n  {}\n</xs:documentation>\n</xs:annotation>\n</xs:element>\n'
eltDsSequenceWithDefautAndHelp = '<xs:element name="{}" type="{}:{}" minOccurs="{}" maxOccurs="{}" default="{}">\n<xs:annotation>\n<xs:documentation>\n  {}\n</xs:documentation>\n</xs:annotation>\n</xs:element>\n'
eltDsSequenceWithDefaut = '<xs:element name="{}" type="{}:{}" minOccurs="{}" maxOccurs="{}" default="{}"/>\n'
UsingASSDkeyRefDeclaration = '\n<xs:keyref name="{}_Name_ref_a{}" refer="{}:Key_Name_For_{}"> \n<xs:selector xpath="{}"/>\n<xs:field xpath="."/>\n</xs:keyref>\n'


# COMPO
debutTypeCompo = '<xs:complexType name="{}" >\n'
debutTypeCompoEtape = '<xs:complexContent>\n<xs:extension base="T_step_{}">\n'
finTypeCompoEtape = '</xs:extension>\n</xs:complexContent>\n'
debutTypeCompoSeq = '<xs:sequence>\n'
finTypeCompoSeq = '</xs:sequence>\n'
finTypeCompo = '</xs:complexType>\n'
eltCompoDsSequence = '<xs:element name="{}" type="{}:{}" minOccurs="{}" maxOccurs="{}"/>\n'
eltCompoDsSequenceWithHelp = '<xs:element name="{}" type="{}:{}" minOccurs="{}" maxOccurs="{}"/>\n'

# ETAPE
eltEtape = '<xs:element name="{}" type="{}:{}" substitutionGroup="step_{}"/>\n'
eltEtapeWithHelp = '<xs:element name="{}" type="{}:{}" substitutionGroup="step_{}">\n<xs:annotation>\n<xs:documentation>\n  {}\n</xs:documentation>\n</xs:annotation>\n</xs:element>\n'
eltEtapeSimple = '<xs:element name="{}" type="{}:{}" minOccurs="{}" maxOccurs="{}"/>\n'
eltEtapeSimpleWithHelp = '<xs:element name="{}" type="{}:{}" minOccurs="{}" maxOccurs="{}">\n<xs:annotation>\n<xs:documentation>\n  {}\n</xs:documentation>\n</xs:annotation>\n</xs:element>\n'


# BLOC
debutTypeSubst = '<xs:group name="{}">   \n<xs:sequence>\n'
finTypeSubst = '</xs:sequence>\n</xs:group>\n'
substDsSequence = '<xs:group ref="{}:{}"  minOccurs="{}" maxOccurs="{}">\n<xs:annotation>\n<xs:documentation>\n  {}\n</xs:documentation>\n</xs:annotation>\n</xs:group>\n'
debutChoiceDsBloc = '<xs:choice>\n'
debutChoiceMultiple = '<xs:choice minOccurs="0" maxOccurs="unbounded">\n'
debutChoiceDsBlocAvecMin = '<xs:choice minOccurs="{}">\n'
finChoiceDsBloc = '</xs:choice>\n'
debSequenceDsBloc = '<xs:sequence>\n'
finSequenceDsBloc = '</xs:sequence>\n'
debutTypeSubstDsBlocFactorise = '<xs:group name="{}">\n'
finTypeSubstDsBlocFactorise = '</xs:group>\n'
debutUnion = '<xs:union>\n'
finUnion   = '</xs:union>\n'
reconstitueUnion = '{} maxOccurs="1">\n<xs:annotation>\n<xs:documentation>\n  {}\n</xs:documentation>\n</xs:annotation>\n</xs:element>\n'

# User OR ASSD
attributeNameName = '<xs:attribute name="sdName" type="xs:string"/>\n'
attributeTypeForASSD = '<xs:attribute name="sdType" type="xs:string" fixed="ASSD"/>\n'
attributeTypeUtilisateurName = '<xs:attribute name="typeUtilisateur" type="xs:string" fixed="{}"/>\n'
producingASSDkeyRefDeclaration = '<xs:key name="Key_Name_For_{}">\n<xs:selector xpath="."/>\n<xs:field xpath="{}"/>\n</xs:key>\n'
texteFieldUnitaire = "./{}:{}/@name |"
defBaseXSDASSD = '\t<xs:simpleType name="AccasAssd">\n\t\t<xs:restriction base="xs:string">\n\t\t</xs:restriction>\n\t</xs:simpleType>\n'
defBaseXSDUserASSD = '\t<xs:simpleType name="AccasUserAssd">\n\t\t<xs:restriction base="xs:string">\n\t\t</xs:restriction>\n\t</xs:simpleType>\n'
defBaseXSDUserASSDMultiple = '\t<xs:simpleType name="AccasUserAssdMultiple">\n\t\t<xs:restriction base="xs:string">\n\t\t</xs:restriction>\n\t</xs:simpleType>\n'

defUserASSDMultiple = '\t<xs:simpleType name="{}">\n\t\t<xs:restriction base="AccasUserAssdMultiple">\n\t\t</xs:restriction>\n</xs:simpleType>\n'
defUserASSD = '\t<xs:simpleType name="{}">\n\t\t<xs:restriction base="AccasUserAssd">\n\t\t</xs:restriction>\n\t</xs:simpleType>\n'
defUserASSDOrUserASSDMultiple = '\t<xs:simpleType name="{}_{}">\n\t\t<xs:restriction base="{}">\n\t\t</xs:restriction>\n\t</xs:simpleType>\n'

# CATA
# debutTypeCata = '<xs:complexType name="T_{}">\n<xs:choice minOccurs="0" maxOccurs="unbounded">\n'
debutTypeCata = '<xs:complexType name="T_{}">\n<xs:choice minOccurs="0" maxOccurs="1">\n'
debutTypeCataExtension = '<xs:complexType name="T_{}">\n'
finTypeCata = '</xs:choice>\n</xs:complexType>\n'
finSchema = '</xs:schema>'
includeCata = '<xs:include schemaLocation="cata_{}.xsd" />\n\n'

# EXTENSION
debutExtension = '<xs:complexContent>\n<xs:extension base="{}:T_{}_Abstract">\n<xs:choice minOccurs="0" maxOccurs="unbounded">\n'
finExtension = '</xs:choice>\n</xs:extension>\n</xs:complexContent>\n'

# TYPE ABSTRAIT
eltAbstraitCataPPal = '<xs:complexType name="T_step_{}" abstract="true"/>\n'
eltAbstraitCataFils = '<xs:complexType name="T_step_{}" abstract="true">\n<xs:complexContent>\n<xs:extension base="{}:T_step_{}"/>\n</xs:complexContent>\n</xs:complexType>\n'
eltCataPPal = '<xs:element name="step_{}" type="{}:T_step_{}"/>\n'
eltCataPPalWithHelp = '<xs:element name="step_{}" type="{}:T_step_{}"/>\n<xs:annotation>\n<xs:documentation>\n  {}\n</xs:documentation>\n</xs:annotation>\n</xs:element>\n'
eltCataFils = '<xs:element name="step_{}" type="{}:T_step_{}" substitutionGroup="step_{}"/>\n'
eltCataFilsWithHelp = '<xs:element name="step_{}" type="{}:T_step_{}" substitutionGroup="step_{}"/>\n<xs:annotation>\n<xs:documentation>\n  {}\n</xs:documentation>\n</xs:annotation>\n</xs:element>\n'

eltCata = '<xs:element name="{}" type="{}:T_{}"/>\n<xs:complexType name="T_{}">\n<xs:choice minOccurs="0" maxOccurs="unbounded">\n<xs:element ref="step_{}" minOccurs="0" maxOccurs="1"/>\n</xs:choice>\n</xs:complexType>\n'

eltCataSimple = '<xs:element name="{}" type="{}:T_{}"/>\n<xs:complexType name="T_{}">\n<xs:choice minOccurs="0" maxOccurs="unbounded">\n'
finEltCataSimple = '</xs:choice>\n</xs:complexType>\n'


# TUPLE
tupleNonHomogeneSimpleType = '<xs:simpleType name="{}_n{}_tuple">\n<xs:restriction base="{}"/>\n</xs:simpleType>\n'
tupleNonHomogeneElt = '<xs:element name="{}" type="{}:{}" minOccurs="{}" maxOccurs="{}"/>\n'
tupleDebutComplexeType = '<xs:complexType name="{}">\n<xs:sequence>'
tupleMilieuComplexeType = '\n<xs:element name="n{}" type="{}_n{}_tuple" minOccurs="1" maxOccurs="1"/>'
tupleFinComplexeType = '\n</xs:sequence>\n<xs:attribute name="sdType" type="xs:string" fixed="Tuple"/>\n</xs:complexType>\n'
tupleDebutComplexeTypeMinZero = '<xs:complexType name="{}">\n<xs:choice>\n<xs:sequence>\n</xs:sequence>\n<xs:sequence maxOccurs={}>'
tupleFinComplexeTypeMinZero = '\n</xs:sequence>\n</xs:choice>\n<xs:attribute name="sdType" type="xs:string" fixed="Tuple"/>\n</xs:complexType>\n'

# MATRICE
eltMatrice = '<xs:element name="{}" type="{}:{}" minOccurs="{}" maxOccurs="{}"/>\n'
matriceSimpleType = '<xs:simpleType name="{}_line">\n<xs:restriction>\n<xs:simpleType>\n<xs:list>\n<xs:simpleType>\n<xs:restriction base="{}_element"/>\n</xs:simpleType>\n</xs:list>\n</xs:simpleType>\n<xs:minLength value="{}"/>\n<xs:maxLength value="{}"/>\n</xs:restriction>\n</xs:simpleType>\n'
matriceSimpleType += '<xs:group name="{}_matrix">\n<xs:sequence>\n<xs:element name="line" type="{}:{}_line" minOccurs="{}" maxOccurs="{}"/>\n</xs:sequence>\n</xs:group>\n'
matriceSimpleType += '<xs:complexType name="{}"> \n<xs:group ref="{}:{}_matrix" minOccurs="1" maxOccurs="1"/>\n<xs:attribute name="sdType" type="xs:string" fixed="Matrice"/>\n</xs:complexType>\n'

# CHAINES AVEC BLANC
debutChaineAvecBlancsInto = '<xs:simpleType name="{}_enum">\n<xs:restriction base="xs:string">\n'
milieuChaineAvecBlancsInto = '<xs:enumeration value="{}"/>\n'
finChaineAvecBlancsInto = '</xs:restriction>\n</xs:simpleType>\n'

complexChaineAvecBlancs = '<xs:complexType name="{}">\n<xs:sequence maxOccurs="{}">\n<xs:element name="s__" type="{}_enum"/>\n</xs:sequence>\n</xs:complexType>\n'

typeEltChaineAvecBlancSansInto = '<xs:simpleType name="{}_enum">\n<xs:restriction base="xs:string">\n</xs:restriction>\n</xs:simpleType>'
if __name__ == "__main__":
    print("ne fait rien")
