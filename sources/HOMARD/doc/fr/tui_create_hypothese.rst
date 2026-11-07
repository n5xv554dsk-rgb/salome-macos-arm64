.. _tui_create_hypothese:

L'hypothèse
###########

.. index:: single: itération
.. index:: single: hypothèse
.. index:: single: zone

Les variables sont décrites dans :doc:`gui_create_hypothese`.

Méthodes de la classe homard
****************************

+---------------------------------------------------------------+
+---------------------------------------------------------------+
| .. module:: CreateHypothesis                                  |
|                                                               |
| **CreateHypothesis(hypo_name)**                               |
|     Retourne une instance de la classe ``hypothese``          |
|                                                               |
|     - ``hypo_name`` : le nom de l'hypothèse                   |
+---------------------------------------------------------------+
| .. module:: GetHypothesis                                     |
|                                                               |
| **GetHypothesis(hypo_name)**                                  |
|     Retourne l'instance de la classe ``hypothese`` connue par |
|     son nom                                                   |
|                                                               |
|     - ``hypo_name`` : le nom de l'hypothèse                   |
+---------------------------------------------------------------+
| .. module:: GetAllHypothesesName                              |
|                                                               |
| **GetAllHypothesesName()**                                    |
|     Retourne la liste des noms de toutes les hypothèses créées|
+---------------------------------------------------------------+
| .. module:: GetZone                                           |
|                                                               |
| **GetZone(zone_name)**                                        |
|     Retourne l'instance de la classe ``zone`` connue par      |
|     son nom                                                   |
|                                                               |
|     - ``zone_name`` : le nom de la zone                       |
+---------------------------------------------------------------+

Méthodes de la classe hypothese
*******************************

Généralités
===========

+---------------------------------------------------------------+
+---------------------------------------------------------------+
| .. module:: GetName                                           |
|                                                               |
| **GetName()**                                                 |
|     Retourne le nom de l'hypothèse                            |
+---------------------------------------------------------------+
| .. module:: GetAdapType                                       |
|                                                               |
| **GetAdapType()**                                             |
|     Retourne le type d'adaptation                             |
|                                                               |
|         * -1 : uniforme                                       |
|         * 0 : selon des zones                                 |
|         * 1 : selon un champ                                  |
+---------------------------------------------------------------+
| .. module:: GetRefinType                                      |
|                                                               |
| **GetRefinType()**                                            |
|     Retourne le type de raffinement                           |
|                                                               |
|         * 0 : inactif                                         |
|         * 1 : actif                                           |
+---------------------------------------------------------------+
| .. module:: GetUnRefType                                      |
|                                                               |
| **GetUnRefType()**                                            |
|     Retourne le type de déraffinement                         |
|                                                               |
|         * 0 : inactif                                         |
|         * 1 : actif                                           |
+---------------------------------------------------------------+
| .. module:: Delete                                            |
|                                                               |
| **Delete()**                                                  |
|     Detruit l'hypothèse                                       |
|                                                               |
|     Retourne un entier :                                      |
|         * 0 : destruction réussie                             |
|         * autre valeur : problème                             |
+---------------------------------------------------------------+

Adaptation uniforme
===================

+---------------------------------------------------------------+
+---------------------------------------------------------------+
| .. module:: SetUnifRefinUnRef                                 |
|                                                               |
| **SetUnifRefinUnRef(RefinUnRef)**                             |
|     Définit un mode d'adaptation uniforme à tout le maillage  |
|                                                               |
|     - ``RefinUnRef`` : entier précisant le type d'adaptation  |
|                                                               |
|         * 1 : raffinement                                     |
|         * -1 : déraffinement                                  |
+---------------------------------------------------------------+

Adaptation selon un champ
=========================

Le champ de pilotage de l'adaptation et les seuils
--------------------------------------------------

+---------------------------------------------------------------+
+---------------------------------------------------------------+
| .. module:: SetField                                          |
|                                                               |
| **SetField(FieldName)**                                       |
|     Attribue un nom de champ de pilotage à l'hypothèse        |
|                                                               |
|     - ``FieldName`` : le nom du champ  de pilotage            |
+---------------------------------------------------------------+
| .. module:: GetFieldName                                      |
|                                                               |
| **GetFieldName()**                                            |
|     Retourne le nom du champ de pilotage                      |
+---------------------------------------------------------------+
| .. module:: SetUseField                                       |
|                                                               |
| **SetUseField(use_field)**                                    |
|     Attribue un mode d'usage du champ de pilotage             |
|                                                               |
|     - ``use_field`` : entier précisant l'usage du champ       |
|                                                               |
|        * 0 : valeur par élément (défaut)                      |
|        * 1 : saut entre un élément et ses voisins             |
+---------------------------------------------------------------+
| .. module:: SetRefinThr                                       |
|                                                               |
| **SetRefinThr(type_thres, threshold)**                        |
|     Définit les seuils en raffinement                         |
|                                                               |
|     - ``type_thres`` : entier précisant le type de seuil en   |
|       raffinement                                             |
|                                                               |
|        * 1 : valeur absolue                                   |
|        * 2 : valeur relative en %                             |
|        * 3 : fraction des mailles en %                        |
|        * 4 : moyenne + n fois l'écart-type                    |
|                                                               |
|     - ``threshold`` : valeur numérique entrant dans la        |
|       définition du seuil                                     |
+---------------------------------------------------------------+
| .. module:: GetRefinThrType                                   |
|                                                               |
| **GetRefinThrType()**                                         |
|     Retourne le type de seuil de raffinement                  |
+---------------------------------------------------------------+
| .. module:: SetUnRefThr                                       |
|                                                               |
| **SetUnRefThr(type_thres, threshold)**                        |
|     Définit les seuils en déraffinement                       |
|                                                               |
|     - ``type_thres`` : entier précisant le type de seuil en   |
|       déraffinement                                           |
|                                                               |
|        * 1 : valeur absolue                                   |
|        * 2 : valeur relative en %                             |
|        * 3 : fraction des mailles en %                        |
|        * 4 : moyenne - n fois l'écart-type                    |
|                                                               |
|     - ``threshold`` : valeur du seuil                         |
+---------------------------------------------------------------+
| .. module:: GetUnRefThrType                                   |
|                                                               |
| **GetUnRefThrType()**                                         |
|     Retourne le type de seuil de déraffinement                |
+---------------------------------------------------------------+


Les composantes du champ de pilotage
------------------------------------

+---------------------------------------------------------------+
+---------------------------------------------------------------+
| .. module:: AddComp                                           |
|                                                               |
| **AddComp(comp_name)**                                        |
|     Ajoute une composante du champ de pilotage à considérer   |
|                                                               |
|     - ``comp_name`` : nom d'une composante à prendre en       |
|       compte                                                  |
|                                                               |
|     Remarque : si cette méthode n'est pas appelée, par défaut |
|     toutes les composantes seront retenues.                   |
+---------------------------------------------------------------+
| .. module:: SetUseComp                                        |
|                                                               |
| **SetUseComp(use_comp)**                                      |
|     Définit l'usage des composantes                           |
|                                                               |
|     - ``use_comp`` : entier précisant l'usage des composantes |
|                                                               |
|        * 0 : norme L2 (défaut)                                |
|        * 1 : norme infinie                                    |
|        * 2 : valeur relative, si une seule composante         |
+---------------------------------------------------------------+
| .. module:: GetComps                                          |
|                                                               |
| **GetComps()**                                                |
|     Retourne la liste des composantes utilisées               |
+---------------------------------------------------------------+
| .. module:: SupprComp                                         |
|                                                               |
| **SupprComp(comp_name)**                                      |
|     Supprime une composante du champ à considérer             |
|                                                               |
|     - ``comp_name`` : nom de la composante à supprimer        |
+---------------------------------------------------------------+
| .. module:: SupprComps                                        |
|                                                               |
| **SupprComps()**                                              |
|     Supprime toutes les composantes du champ à considérer     |
+---------------------------------------------------------------+


Adaptation selon des zones
==========================

+---------------------------------------------------------------+
+---------------------------------------------------------------+
| .. module:: AddZone                                           |
|                                                               |
| **AddZone(zone_name, type_use)**                              |
|                                                               |
|     - ``zone_name`` : le nom de la zone à ajouter             |
|     - ``type_use``  : entier précisant l'usage de la zone     |
|                                                               |
|         * 1 : raffinement                                     |
|         * -1 : déraffinement                                  |
+---------------------------------------------------------------+
| .. module:: GetZones                                          |
|                                                               |
| **GetZones()**                                                |
|     Retourne la liste des zones utilisées avec leur usage.    |
|                                                               |
|     Attention : l'usage est stocké sous forme de chaîne de    |
|     caractères et non pas d'entier dans la liste.             |
|                                                               |
|     Exemple : ['Zone_A', '1', 'Zone_B', '1', 'Zone_C', '1']   |
+---------------------------------------------------------------+
| .. module:: SupprZone                                         |
|                                                               |
| **SupprZone(zone_name)**                                      |
|     Supprime une zone de l'hypothèse                          |
|                                                               |
|     - ``zone_name`` : nom de la zone à supprimer              |
+---------------------------------------------------------------+
| .. module:: SupprZones                                        |
|                                                               |
| **SupprZones()**                                              |
|     Supprime toutes les zones de l'hypothèse                  |
+---------------------------------------------------------------+


Le filtrage par les groupes
===========================

+---------------------------------------------------------------+
+---------------------------------------------------------------+
| .. module:: AddGroup                                          |
|                                                               |
| **AddGroup(group_name)**                                      |
|     Ajoute un groupe au filtrage                              |
|                                                               |
|     - ``group_name`` : nom du groupe à prendre en compte      |
+---------------------------------------------------------------+
| .. module:: GetGroups                                         |
|                                                               |
| **GetGroups()**                                               |
|     Retourne la liste des groupes utilisés pour le filtrage   |
+---------------------------------------------------------------+


Les champs à interpoler
=======================

+---------------------------------------------------------------+
+---------------------------------------------------------------+
| .. module:: SetTypeFieldInterp                                |
|                                                               |
| **SetTypeFieldInterp(typefieldinterp)**                       |
|                                                               |
|     - ``typefieldinterp`` : entier précisant si des champs    |
|       sont a interpoler                                       |
|                                                               |
|         * 0 : aucun champ n'est à interpoler (défaut)         |
|         * 1 : tous les champs sont interpolés                 |
|         * 2 : certains champs sont interpolés ; implicitement |
|           affecté après usage de AddFieldInterp ou            |
|           AddFieldInterpType                                  |
+---------------------------------------------------------------+
| .. module:: GetTypeFieldInterp                                |
|                                                               |
| **GetTypeFieldInterp()**                                      |
|     Retourne l'entier précisant si des champs sont à          |
|     interpoler                                                |
+---------------------------------------------------------------+
| .. module:: AddFieldInterp                                    |
|                                                               |
| **AddFieldInterp(FieldName)**                                 |
|                                                               |
|     - ``FieldName`` : le nom du champ à interpoler            |
|                                                               |
|     Le mode d'interpolation sera choisi automatiquement par   |
|     HOMARD ; cela correspond au mode 0 de AddFieldInterpType  |
+---------------------------------------------------------------+
| .. module:: AddFieldInterpType                                |
|                                                               |
| **AddFieldInterpType(FieldName, type_interp)**                |
|                                                               |
|     - ``FieldName`` : le nom du champ à interpoler            |
|     - ``type_interp`` : entier précisant le type              |
|       d'interpolation du champ                                |
|                                                               |
|     Pour un champ aux noeuds :                                |
|                                                               |
|         * 0 : le champ sera interpolé en degré 1 ou 2 selon   |
|           son support.                                        |
|         * 1 : interpolation en degré 1                        |
|         * 2 : interpolation en degré 2                        |
|         * 3 : interpolation iso-P2                            |
|                                                               |
|     Pour un champ aux éléments :                              |
|                                                               |
|         * 0 : le champ sera interpolé en le considérant comme |
|           une variable intensive.                             |
|         * 1 : le champ sera interpolé en le considérant comme |
|           une variable extensive.                             |
+---------------------------------------------------------------+
| .. module:: GetFieldInterps                                   |
|                                                               |
| **GetFieldInterps()**                                         |
|     Retourne la liste des champs à interoler avec leur usage. |
|                                                               |
|     Attention : l'usage est stocké sous forme de chaîne de    |
|     caractères et non pas d'entier dans la liste.             |
|                                                               |
|     Exemple : ['DEPL', '0', 'Masse', '1', 'Densite', '0']     |
+---------------------------------------------------------------+
| .. module:: SupprFieldInterp                                  |
|                                                               |
| **SupprFieldInterp(FieldName)**                               |
|     Supprime un champ à interpoler de l'hypothèse             |
|                                                               |
|     - ``FieldName`` : nom du champ à supprimer                |
+---------------------------------------------------------------+
| .. module:: SupprFieldInterps                                 |
|                                                               |
| **SupprFieldInterps()**                                       |
|     Supprime tous les champs à interpoler de l'hypothèse      |
+---------------------------------------------------------------+

.. note::
  Le fichier et les instants où sont pris les champs sont définis dans l'itération ; voir :doc:`tui_create_iteration`.

Les options avancées
====================

+---------------------------------------------------------------+
+---------------------------------------------------------------+
| .. module:: SetNivMax                                         |
|                                                               |
| **SetNivMax(nivmax)**                                         |
|     Définit le niveau maximal de raffinement                  |
|                                                               |
|     - ``nivmax`` : niveau de raffinement à ne pas dépasser    |
+---------------------------------------------------------------+
| .. module:: GetNivMax                                         |
|                                                               |
| **GetNivMax()**                                               |
|     Retourne le niveau maximal de raffinement                 |
+---------------------------------------------------------------+
| .. module:: SetDiamMin                                        |
|                                                               |
| **SetDiamMin(diammin)**                                       |
|     Définit le diamètre minimal des futures mailles           |
|                                                               |
|     - ``diammin`` : diamètre minimal voulu pour une maille    |
+---------------------------------------------------------------+
| .. module:: GetDiamMin                                        |
|                                                               |
| **GetDiamMin()**                                              |
|     Retourne le diamètre minimal voulu                        |
+---------------------------------------------------------------+
| .. module:: SetAdapInit                                       |
|                                                               |
| **SetAdapInit(option)**                                       |
|     Définit le traitement à appliquer aux mailles où          |
|     le champ de pilotage de l'adaptation n'est pas défini     |
|                                                               |
|     - ``option`` : entier précisant le choix retenu           |
|                                                               |
|         *  0 : aucun effet (défaut)                           |
|         *  1 : les mailles sans indicateurs sont raffinées    |
|         * -1 : les mailles sans indicateurs sont déraffinées  |
+---------------------------------------------------------------+
| .. module:: GetAdapInit                                       |
|                                                               |
| **GetAdapInit()**                                             |
|     Retourne le type de traitement à appliquer aux mailles où |
|     le champ de pilotage de l'adaptation n'est pas défini     |
+---------------------------------------------------------------+
| .. module:: SetExtraOutput                                    |
|                                                               |
| **SetExtraOutput(option)**                                    |
|     Précise quelles sorties supplémentaires sur les mailles on|
|     veut récupérer dans le fichier MED de sortie. C'est un    |
|     entier multiple ou non de 2, 3, 5, 7, 11.                 |
|                                                               |
|     - ``option`` : entier précisant le choix retenu           |
|                                                               |
|         *  1 : aucun effet (défaut)                           |
|         *  2x : le niveau de raffinement de chaque maille     |
|         *  3x : la qualité de chaque maille                   |
|         *  5x : le diamètre de chaque maille                  |
|         *  7x : les fratries des mailles                      |
|         * 11x : les voisins des mailles recollées             |
+---------------------------------------------------------------+
| .. module:: GetExtraOutput                                    |
|                                                               |
| **GetExtraOutput()**                                          |
|     Retourne le choix retenu pour la récupération des sorties |
|     supplémentaires                                           |
+---------------------------------------------------------------+


Exemple
*******
La création de l'objet hypo_1 se fait ainsi : ::

    hypo_1 = homard.CreateHypothesis("HypoField")
    hypo_1.SetField("INDICATEUR")
    hypo_1.AddComp("INDX")
    hypo_1.AddComp("INDZ")
    hypo_1.SetRefinThr(1, 80.)
    hypo_1.AddFieldInterp("DEPL")
    hypo_1.AddFieldInterpType("MASSE", 1)


Saisie graphique correspondante
*******************************
Consulter :doc:`gui_create_hypothese`

.. warning::
  En mode graphique, si on édite une hypothèse et que l'on modifie une de ses caractéristiques, par exemple le seuil de raffinement, toutes les itérations qui ont été calculées précédemment avec cette hypothèse sont invalidées. En mode python, cela n'est plus vrai : les itérations restent telles quelles.
