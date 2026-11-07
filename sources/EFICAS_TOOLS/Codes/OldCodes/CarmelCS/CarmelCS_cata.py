from Accas import *


JdC = JDC_CATA (code = 'CarmelCS',
                execmodul = None,
                regles=(AU_MOINS_UN('PARAM_CS',),)
               )
                
# ======================================================================
# ======================================================================


PARAM_CS=PROC(nom='PARAM_CS',op=None,
            Formulation=SIMP(statut='o',typ='TXM',defaut="tomega",into=('tomega','aphi'),),
            Per=SIMP(statut='o',typ='I',min=1),
            Ind=SIMP(statut='o',typ='I',min=0),
            FinalTime=SIMP(statut='o',typ='I',min=1),
            SyrthesProcNumber=SIMP(statut='o',typ='I',defaut=1,min=1),
            HomogenousPhysFile=SIMP(statut='o',typ='TXM',defaut="MeshC_homogene.phys",),
            HeterogenousPhysFile=SIMP(statut='o',typ='TXM',defaut="MeshC_heterogene.phys",),
            Carmel3D_StudyDirectory=SIMP(typ='Repertoire', statut='o'),
            Syrthes_StudyDirectory=SIMP(typ='Repertoire', statut='o'),
            XMLYacsFile=SIMP(typ=('Fichier','Files (*.xml)'),fr= 'Schema yacs du couplage a executer',ang= 'Yacs coupling schema for running', statut='o'),
#TODO examiner comment generer un schema yacs de maniere automatique
)
