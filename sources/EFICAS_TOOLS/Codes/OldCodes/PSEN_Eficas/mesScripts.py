def view_zone(listeparam) :
    item=listeparam[0]
    import visu_geom
    visu_zone = visu_geom.VisuGeom(from_eficas=True,
                          eficas_item=item,
                          ligne_arbre=False)
    visu_zone.visualize()

def view_ligne_arbre(listeparam) :
    item=listeparam[0]
    import visu_geom
    visu_arbre = visu_geom.VisuGeom(from_eficas=True,
                           eficas_item=item,
                           ligne_arbre=True)
    visu_arbre.visualize()

def import_zone(listeparam,appli) :
    item=listeparam[0]
    # simulation de la recuperation zone
    #import eficasSalome
    #eficasSalome.runEficas(code='MT',fichier='/home/I29518/test_zone.comm')
    appli.editorManager.openFile(fichier='/home/A96028/Install_EficasV1/EficasV1/MT/MT_include.comm')

def import_zone2(listeparam,appli) :
    editor=listeparam[0]
    itemWidget=listeparam[1]
    texte="sansnom=ZONE(NOEUDS=(_F(NOM='N1', X=0.0,), _F(NOM='N2', X=0.19,),), ELEMENTS=(_F(NOM='E1', DEBUT='N1', FIN='N2', RAFFINAGE='NON', MATERIAU=MAT_R01, SECTION_MASSE=_F(TYPE_SECTION='CONSTANTE', DIAM_EXTERN_DEBUT=0.1, DIAM_INTERN_DEBUT=0,), SECTION_RIGIDITE=_F(TYPE_SECTION='CONSTANTE', DIAM_EXTERN_DEBUT=0.1, DIAM_INTERN_DEBUT=0.0,),), _F(NOM='E2', DEBUT='N2', FIN='N3', RAFFINAGE='NON', MATERIAU=MAT_R01, SECTION_MASSE=_F(TYPE_SECTION='VARIABLE', DIAM_EXTERN_DEBUT=0.1, DIAM_INTERN_DEBUT=0, DIAM_EXTERN_SORTIE=0.2, DIAM_INTERN_SORTIE=0.0,), SECTION_RIGIDITE=_F(TYPE_SECTION='VARIABLE', DIAM_EXTERN_DEBUT=0.1, DIAM_INTERN_DEBUT=0.0, DIAM_EXTERN_SORTIE=0.2, DIAM_INTERN_SORTIE=0.0,),),),);"
    editor.updateJdc(itemWidget,texte)

def Source():
    print "jjjjjjjjjjjjjjjjjjj"

dict_commandes={
	'GENDOF':(Source,"Source",(),False,True,"affiche un message"),
               }
