# -*- coding: iso-8859-1 -*-

import re # module interne utilisé pour vérifier la validité du nom du maillage

concept_re=re.compile(r'[a-zA-Z_]\w*$') # nom de maillage valide s'il correspond à un identifiant (variable) Python possible. Basé sur Ihm/I_Etape.py:nomme_sd, qui fait foi

def ajoutGroupeSansFiltre(editor,listeGroup):
        """code_Carmel temporel : obtention des groupes de maille du maillage selectionne dans Salome
        Les groupes de mailles ne sont pas filtrés.
        La creation du MESH_GROUPE n'est donc pas typé.
        ATTENTION! Le nom devenant un concept, i.e. une variable Python, certains signes sont interdits dans le nom du groupe,
        e.g. les signes moins (-), plus (+), etc. Une erreur est retournee en ce cas.
        """
        # retourne le dernier element du JdC, ou None si le JdC est vide, afin de savoir a quelle place ajouter les MESH_GROUPE (en dernier)
        debug = True
        try:
            dernier=editor.tree.racine.children[-1]
        except:
            dernier=None
        for groupe in listeGroup: # parcours de la liste de tous les groupes de maille trouves (volumiques et les autres), puis ecriture du MESHGROUP systématique sans analyse de nom multiple
            if debug: print 'groupe=', groupe
            if not concept_re.match(groupe): # Le nom du groupe de maillage doit etre un identificateur Python
                raise ValueError, "Ce nom de groupe ("+groupe+") ne peut pas etre utilise car il ne peut pas servir de concept a cause de caracteres interdits, e.g. signes moins (-), plus (+), etc."
            try: # test de conformite du nom pour un concept, i.e. une variable Python
                #exec(groupe+'=None') # le test consiste a tenter de creer une variable, initialisee a None, a partir du nom, e.g. toto=None est bon mais toto-foo=None ne fonctionne pas.
                # creation du groupe MESH_GROUPE
                if dernier != None:
                    new_node = dernier.append_brother("MESHGROUP",'after')
                else:
                    new_node=editor.tree.racine.append_child("MESHGROUP",pos='first')
                test,mess = new_node.item.nomme_sd(groupe) # precision du nom (de concept) du groupe
                if debug: print u"ce nom de groupe ("+groupe+") est utilise..."
                dernier=new_node # mise a jour du dernier noeud du JdC, afin de rajouter les autres MESH_GROUPE eventuels a sa suite
            except:
                raise ValueError,  "Ce nom de groupe ("+groupe+") pose un probleme inconnu"

def ajoutGroupeAvecFiltre(editor,listeGroup):
        """CARMEL3D : obtention des groupes de maille du maillage selectionne dans Salome
        Les groupes de mailles sont filtres en utilisant une liste des  prefixes autorises pour code Code_Carmel3D,
        i.e. un nom de groupe de mailles est DIEL_toto_foo par exemple, qui deviendra toto_foo.
        La creation du MESH_GROUPE est type (materiau ou source), d'après le prefixe.
        ATTENTION! Le nom devenant un concept, i.e. une variable Python, certains signes sont interdits dans le nom du groupe,
        e.g. les signes moins (-), plus (+), etc. Une erreur est retournee en ce cas.
        """
        from string import join
        debug = False #True
        listePrefixesMateriaux = ('DIEL', 'NOCOND','COND', 'ZS', 'ZJ', 'NILMAT') # liste des prefixes pour les materiaux
        listePrefixesSourcesHorsInducteur = ('EPORT', 'HPORT') # liste des prefixes pour les sources
        listePrefixesInducteurBobine = ('CURRENT', ) # listes des prefixes autorises pour definir la geometrie d'un inducteur bobiné complet ou en morceaux
        listePrefixesTrous = ('TOPO', ) # listes des prefixes autorises pour definir la geometrie d'un trou complet ou en morceaux
        listePrefixesBBK = ('BBK', ) # listes des prefixes autorises pour definir le groupe d'éléments servant de boîte englobante dans laquelle est calculée K (inducteur bobiné ou topo).
        listePrefixes = listePrefixesMateriaux + listePrefixesSourcesHorsInducteur +listePrefixesInducteurBobine + listePrefixesTrous + listePrefixesBBK # liste de tous les prefixes autorises
        listePrefixesGroupesMultiples = ('CURRENT', 'TOPO' ) # listes des prefixes autorises pour groupes multiples, i.e. plusieurs groupes de mailles associes en une seule caracteistique materiau ou source
        if debug:
            print "listePrefixes=", listePrefixes
            print "listePrefixesGroupesMultiples=", listePrefixesGroupesMultiples
        sep = '_' # separateur entre le prefixe et le nom reel du groupe (qui peut lui aussi contenir ce separateur)
        dictGroupesMultiples = {} # dictionnaire contenant les noms reels possibles de groupes multiples et leur occurence dans la liste, i.e. 1 par defaut et > 1 pour une groupe multiple, e.g. pour un inducteur bobine en plusieurs morceaux CURRENT_toto_1, CURRENT_toto_2, ce dictionnaire contiendra 'toto':2 
        for groupe in listeGroup:
            partiesGroupe = groupe.split(sep) # parties du nom, separees initialement par le separateur du prefixe, e.g. 'CURRENT_toto_foo' devient ['CURRENT','toto','foo'] et 'toto' devient ['toto']
            prefix = partiesGroupe[0] # prefixe possible de ce nom, ou nom lui-meme
            if len(partiesGroupe) >= 3 and prefix in listePrefixesGroupesMultiples: # prefixe existant et autorise
                nomGroupeMultiple = partiesGroupe[1] # nom possible d'un groupe multiple
                if dictGroupesMultiples.has_key(nomGroupeMultiple): # comptage du nombre d'occurrences de ce nom de groupe multiple possible
                    dictGroupesMultiples[nomGroupeMultiple]['nombre'] += 1
                    dictGroupesMultiples[nomGroupeMultiple]['membres'].append(join(partiesGroupe[1:], sep))
                else:
                    dictGroupesMultiples[nomGroupeMultiple] = {'type': prefix,'nombre':1, 'membres':[join(partiesGroupe[1:], sep)]}
        for groupe in dictGroupesMultiples.keys(): # recherche de tous les groupes multiples. Boucle ignorée si aucun groupe multiple.
            dictGroupesMultiples[groupe]['membres'].sort() # tri alphabétique des membres du groupe multiple, qui est l'ordre lu par gendof.exe/MED (ordre lexicographique).
            dictGroupesMultiples[groupe]['membres'] = tuple(dictGroupesMultiples[groupe]['membres']) # transformation en tuple, qui est le format attendu par le catalogue (LISTE_MESHGROUP)
        if debug:
            print "dictGroupesMultiples=", dictGroupesMultiples
        # retourne le dernier element du JdC, ou None si le JdC est vide, afin de savoir a quelle place ajouter les MESH_GROUPE (en dernier)
        try:
            dernier=editor.tree.racine.children[-1]
        except:
            dernier=None
        for groupe in listeGroup: # parcours de la liste de tous les groupes de maille trouves (volumiques et les autres), puis ecriture du MESHGROUP systématique sans analyse de nom multiple
            if debug: print 'groupe=', groupe
            partiesGroupe = groupe.split(sep) # parties du nom, separees initialement par le separateur du prefixe, e.g. 'CURRENT_toto_foo' devient ['CURRENT','toto','foo'] et 'toto' devient ['toto']
            if len(partiesGroupe) == 1: # pas de prefixe
                print u"ERREUR: ce nom de groupe ("+groupe+") ne peut pas etre utilise car il n'a pas de prefixe"
            elif len(partiesGroupe) >= 2 and partiesGroupe[0] in listePrefixes: # prefixe existant et autorise
                prefix = partiesGroupe[0] # prefixe possible de ce nom, ou nom lui-meme
                nom = partiesGroupe[1] # nom du groupe ou du macro-groupe si défini.
                nomReel = join(partiesGroupe[1:], sep) # reconstruction du nom reel, i.e. sans le prefixe, pour la plupart des groupes
                if prefix in listePrefixesBBK: nomReel = groupe # pour la boite englobante, il faut le nom avec préfixe
                if not concept_re.match(nomReel): # Le nom du groupe de maillage doit etre un identificateur Python
                    raise ValueError, "Ce nom de groupe ("+nomReel+") ne peut pas etre utilise car il ne peut pas servir de concept a cause de caracteres interdits, e.g. signes moins (-), plus (+), etc."
                try: # test de conformite du nom pour un concept, i.e. une variable Python
                    #exec(nomReel+'=None') # le test consiste a tenter de creer une variable, initialisee a None, a partir du nom, e.g. toto=None est bon mais toto-foo=None ne fonctionne pas.
                    # creation du groupe MESH_GROUPE
                    if dernier != None:
                        new_node = dernier.append_brother("MESHGROUP",'after')
                    else:
                        new_node=editor.tree.racine.append_child("MESHGROUP",pos='first')
                    test,mess = new_node.item.nomme_sd(nomReel) # precision du nom (de concept) du groupe
                    if debug: print u"ce nom de groupe ("+nomReel+") est utilise..."
                    if prefix in listePrefixesMateriaux: # ce groupe est associe a un materiau
                        new_node.append_child('MATERIAL') # on rajoute la propriete de materiau, qu'il suffit d'associer ensuite a la liste des materiaux presents
                        if debug: print u" et c'est un materiau."
                    elif prefix in listePrefixesSourcesHorsInducteur: # ce groupe est associe a une source
                        new_node.append_child('SOURCE') # on rajoute la propriete de la source, qu'il suffit d'associer ensuite a la liste des sources presentes
                        if debug: print u" et c'est une source."
                    elif prefix in listePrefixesInducteurBobine: # ce groupe est associe a une source
                        new_node.append_child('STRANDED_INDUCTOR_GEOMETRY') # on rajoute la propriete de géométrie de l'inducteur bobiné
                        if debug: print u" et c'est un inducteur bobine dont on definit la geometrie."
                        if nom not in dictGroupesMultiples.keys(): # il ne fait pas partie d'un macro-groupe. La source est définie ici, ainsi que le domaine.
                            new_node.append_child('SOURCE') # on rajoute la propriete de la source, qu'il suffit d'associer ensuite a la liste des sources presentes
                            new_node.append_child('Domaine') # on rajoute la propriete du domaine (default automatique), qu'il suffit d'associer ensuite a la liste des domaines présents
                            if debug: print u" et c'est une source en un seul morceau."
                    else: # ce cas ne devrait pas se produire
                        pass
                    dernier=new_node # mise a jour du dernier noeud du JdC, afin de rajouter les autres MESH_GROUPE eventuels a sa suite
                except:
                    raise ValueError,  "Ce nom de groupe ("+nomReel+") pose un probleme inconnu"
                    #print u"ERREUR: ce nom de groupe ("+nomReel+") ne peut pas etre utilise car il ne peut pas servir de concept a cause de caractères interdits, e.g. signes moins (-), plus (+), etc."
            else: # prefixe existant mais non autorise
                print u"ERREUR: ce nom de groupe ("+groupe+") ne peut pas etre utilise car son prefixe ("+partiesGroupe[0]+") n'est pas dans la liste autorisee "+str(listePrefixes)
        if len(dictGroupesMultiples) > 0: # on a des groupes à nom multiples, e.g., inducteur bobiné en morceaux.
            for groupe, contenu in dictGroupesMultiples.iteritems(): # parcours de la liste de tous les groupes de maille trouves (volumiques et les autres), et sélection des groupes à nom multiple
                if debug: print 'groupe, contenu=', groupe, contenu
                nomReel = groupe
                prefix = contenu['type']
                try: # test de conformite du nom pour un concept, i.e. une variable Python
                    exec(nomReel+'=None') # le test consiste a tenter de creer une variable, initialisee a None, a partir du nom, e.g. toto=None est bon mais toto-foo=None ne fonctionne pas.
                    # creation du groupe MACRO_GROUPE
                    if dernier != None:
                        new_node = dernier.append_brother("MACRO_GROUPE",'after')
                    else:
                        new_node=editor.tree.racine.append_child("MACRO_GROUPE",pos='first')
                    test,mess = new_node.item.nomme_sd(nomReel) # precision du nom (de concept) du groupe
                    if debug: print u"ce nom de groupe ("+nomReel+") est utilise..."
                    if debug: print u" et on ajoute la liste LISTE_MESHGROUP."
                    node_list=new_node.append_child('LISTE_MESHGROUP') # Ajout de la liste des membres du groupe multiple
                    if debug:
                        print 'Liste possible pour LISTE_MESHGROUP :'
                        print '_____________________'
                        print node_list.item.get_liste_possible(())
                        print '_____________________'
                        print dir(node_list.item)
                    listeNom=node_list.item.get_sd_avant_du_bon_type()
                    listeObjet=[]
                    for nom in listeNom: 
                        if nom in dictGroupesMultiples[groupe]['membres']:
                           #--> transformation du nom en objet
                           obj,valide=node_list.item.eval_valeur(nom)
                           listeObjet.append(obj)
                    node_list.item.set_valeur(listeObjet) 
                    node_list.affichePanneau()             
                    if prefix in listePrefixesMateriaux: # ce groupe est associe a un materiau
                        new_node.append_child('MATERIAL') # on rajoute la propriete de materiau, qu'il suffit d'associer ensuite a la liste des materiaux presents
                        if debug: print u" et c'est un materiau."
                    elif prefix in listePrefixesSourcesHorsInducteur: # ce groupe est associe a une source
                        new_node.append_child('SOURCE') # on rajoute la propriete de la source, qu'il suffit d'associer ensuite a la liste des sources presentes
                        if debug: print u" et c'est une source hors inducteur."
                    elif prefix in listePrefixesInducteurBobine: # ce groupe est associe a une source
                        new_node.append_child('SOURCE') # on rajoute la propriete de la source, qu'il suffit d'associer ensuite a la liste des sources presentes
                        new_node.append_child('Domaine') # on rajoute la propriete du domaine (default automatique), qu'il suffit d'associer ensuite a la liste des domaines présents
                        if debug: print u" et c'est une source inducteur."
                    elif prefix in listePrefixesTrous: # ce groupe est associe a un trou
                        new_node.append_child('Domaine') # on rajoute la propriete du domaine (default automatique), qu'il suffit d'associer ensuite a la liste des domaines présents
                        if debug: print u" et c'est un trou."
                    else: # ce cas ne devrait pas se produire
                        pass
                    dernier=new_node # mise a jour du dernier noeud du JdC, afin de rajouter les autres MESH_GROUPE eventuels a sa suite
                except:
                    print u"ERREUR: ce nom de groupe ("+nomReel+") ne peut pas etre utilise car il ne peut pas servir de concept a cause de caractères interdits, e.g. signes moins (-), plus (+), etc."

def ajoutGroupeFiltre(editor,listeGroup):
        """CARMEL3D : obtention des groupes de maille du maillage selectionne dans Salome
        Les groupes de mailles sont filtres en utilisant une liste des  prefixes autorises pour code Code_Carmel3D,
        i.e. un nom de groupe de mailles est DIEL_toto_foo par exemple, qui deviendra toto_foo.
        La creation du MESH_GROUPE est type (materiau ou source), d'après le prefixe.
        ATTENTION! Le nom devenant un concept, i.e. une variable Python, certains signes sont interdits dans le nom du groupe,
        e.g. les signes moins (-), plus (+), etc. Une erreur est retournee en ce cas.
        """
        from string import join
        debug = True
        #print 'DEBUG listeGroup manuel' # Il faut aussi commenter la ligne Msg,listeGroup=self.ChercheGrpMailleInSalome() dans la routine  ChercheGrpMaille de qtEficas.py
        #listeGroup = ['DIEL_air', 'COND_plaque', 'CURRENT_bobine'  ] # cas-test plaque Rodger avec DIEL_
        #listeGroup = ['NOCOND_air', 'COND_plaque', 'CURRENT_bobine'  ] # cas-test plaque Rodger
        #listeGroup = ['DIEL_air', 'COND_plaque', 'NOCOND_processing', 'CURRENT_bobine_1', 'CURRENT_bobine_2', 'CURRENT_bobine_3' ]
        #listeGroup = ['DIEL_air', 'COND_plaque', 'NOCOND_processing', 'CURRENT_bobine'  ]
        #listeGroup = ['BBK_bobine', 'DIEL_air', 'COND_plaque', 'NOCOND_processing', 'CURRENT_bobine'  ] # avec BBK
        #listeGroup = ['EPORT+_dom', 'EPORT-_dom', 'H', 'COND_cyl', 'EPORT_dom'] # cas-test CSS_Tempimpo
        #listeGroup= ['BBK_spire', 'CURRENT_spire_4', 'NOCOND_air', 'CURRENT_spire_3', 'CURRENT_spire_1', 'CURRENT_spire_2'] # cas-test spire_dans l'air en 4 morceaux
        #listeGroup= ['BBK_bobine', 'CURRENT_ind_2', 'DIEL_air', 'CURRENT_ind_8', 'CURRENT_ind_6', 'CURRENT_ind_1', 'CURRENT_ind_3', 'CURRENT_ind_7', 'CURRENT_ind_5', 'CURRENT_ind_4', 'BBK_topo', 'COND_plaque', 'TOPO_trou_1', 'TOPO_trou_3', 'TOPO_trou_2', 'TOPO_trou_8', 'TOPO_trou_4', 'TOPO_trou_7', 'TOPO_trou_5', 'TOPO_trou_6'] # cas-test T.E.A.M. Workshop 7
        if debug:
            print "listeGroup=", listeGroup
        version_catalogue = editor.CONFIGURATION.appli.readercata.version_code # détermination si le catalogue est fréquentiel ou temporel, d'après la deuxième entrée de la liste catalogues dans prefs_CARMEL3D.py
        if debug:
            print "Version catalogue=", version_catalogue
        type_code = version_catalogue.split(' ')[0] # on garde le premier mot de la version du catalogue : 'frequentiel' ou 'temporel'
        if debug:
            print "Type de code=", type_code
        if type_code not in ('frequentiel', 'temporel'): # test de cohérence du type de code
            raise ValueError("Ce catalogue n'est ni frequentiel ni temporel")
        if type_code == 'frequentiel':
            ajoutGroupeAvecFiltre(editor, listeGroup)
        if type_code == 'temporel':
            ajoutGroupeSansFiltre(editor, listeGroup)
