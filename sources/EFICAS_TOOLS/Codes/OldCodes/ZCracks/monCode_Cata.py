from Accas import *

JdC = JDC_CATA (code = 'ZCrack',
                execmodul = None,
                )

class grma(GEOM):
  pass

class grno(GEOM):
  pass

ONGLET="oui"

MAILLAGES = PROC(nom='MAILLAGES',op=None,
  MAILLAGE_SAIN=FACT(statut='o',
     sane_name=SIMP(typ=('Fichier', 'Med Files(*.med);;All Files (*)'),fr= "",ang= "Name of the initial uncracked mesh",statut= "o"),
     if_quad=SIMP(typ="I",fr="",ang="1 for quadratic mesh",defaut=0,statut='o',into=[0,1]),
     scale=SIMP(typ="R",fr="",ang="",statut='o',defaut=1),
     ),
  FISSURE=FACT(statut='o',
     crack_name=SIMP(typ=('Fichier', 'Med Files(*.med);;All Files (*)',),fr= "",ang= "Name of the crack surface mesh",statut= "o"),
     GENERE_FISSURE=FACT(
         regles=(AU_MOINS_UN('ELLIPSE','DISQUE'),),
         ELLIPSE=FACT(
            center=SIMP(typ="R",fr="",ang="",statut='o',min=3,max=3),
            normal=SIMP(typ="R",fr="",ang="",statut='o',min=3,max=3),
            ra=SIMP(typ="R",fr="",ang="",statut='o'),
            rb=SIMP(typ="R",fr="",ang="",statut='o'), 
            dir=SIMP(typ="R",fr="",ang="",statut='o',min=3,max=3),
            ),
         DISQUE=FACT(
            center=SIMP(typ="R",fr="",ang="",statut='o',min=3,max=3),
            normal=SIMP(typ="R",fr="",ang="",statut='o',min=3,max=3),
            rayon=SIMP(typ="R",fr="",ang="",statut='o'),
            ),
            ),
          ),
  MAILLAGE_RESULTAT=FACT(statut='o',
       cracked_name=SIMP(typ=('Fichier', 'Med Files(med);;All Files (*)','Sauvegarde'),fr= "",ang= "Name of the final mesh",statut= "o"),
       crack_id=SIMP(typ="I",fr="",val_min=0, defaut=1),
       repertoire=SIMP(typ='Repertoire',fr= "Repertoire ",ang= " Directory",statut= "f",),
    ),
  GROUPES=FACT(statut='f',
       regles=(AU_MOINS_UN('elset_names','faset_names','liset_names','nset_names'),),
       elset_names=SIMP(typ=grma,fr="",ang="names of volume element groups to be kept",min=1,max="**",statut="f"),
       faset_names=SIMP(typ=grma,fr="",ang="names of surface element groups to be kept",min=1,max="**",statut="f"),
       liset_names=SIMP(typ=grma,fr="",ang="names of line element groups to be kept",min=1,max="**",statut="f"),
       nset_names=SIMP(typ=grno,fr="" ,ang="names of node element groups to be kept",min=1,max="**",statut="f"),
)
)

REMESHING=PROC(nom='REMESHING',op=None,
  yams_options=SIMP(typ='TXM',fr="",ang="parameters for yams command line",statut="f"),
  gradation=SIMP(typ="R",fr="",ang="gradation remeshing parameter",val_max=2.3,defaut=1.3,statut='o'),
  min_size=SIMP(typ="R",fr="",ang="minimal element edges length",statut='o'),
  max_size=SIMP(typ="R",fr="",ang="maximal element edges length",statut='o'),
  nb_iter=SIMP(typ="I",fr="",ang="number of iterations for remeshing process",defaut=2,statut='o'),
  ridge_names=SIMP(typ=grma,fr="",ang="",min=1,max="**",statut="f"),
  topo_names=SIMP(typ=grma,fr="",ang="",min=1,max="**",statut="f"),
  geom_names=SIMP(typ=grma,fr="",ang="",min=1,max="**",statut="f"),
  REMAILLAGE_LOCAL=FACT(statut='f',
     elset_radius=SIMP(typ="R",fr="",ang="",statut='o'),
  ),
  filter_tol=SIMP(typ="R",fr="",ang="filtering tolerance for meshing operations",defaut=1.e-6,statut="f"),
)
