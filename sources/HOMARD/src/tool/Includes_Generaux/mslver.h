      texte(1,6) =
     > '(/,1x,''Une ERREUR dans les mots-cles des options !'')'
      texte(1,7) = '(/,1x,''ERREURS dans les mots-cles des options !'')'
c
      texte(1,11) = '(7x,''--> OPTION INVALIDE :'',i10)'
      texte(1,12) = '(7x,''--> pas de conversion'',/)'
      texte(1,13) = '(7x,''--> conversion'',/)'
      texte(1,14) = '(7x,''--> inactif'')'
      texte(1,15) = '(7x,''--> actif'')'
c
      texte(1,20) = '(5x,''Maillage initial'')'
      texte(1,21) = '(5x,''Maillage apres une iteration'')'
      texte(1,22) = '(5x,''Maillage apres'',i4,'' iterations'')'
      texte(1,23) = '(/,5x,''Point de depart :'',/,5x,17(''-''))'
      texte(1,24) = '(7x,''Maillage a analyser :'')'
      texte(1,25) = '(7x,''Maillage a modifier :'')'
c
      texte(1,26) =
     > '(/,5x,''Code de calcul associe : '',a18,/,5x,24(''-''))'
c
      texte(1,27) = '(/,5x,''Suivi de frontiere :'',/,5x,20(''-''))'
      texte(1,28) = '(  5x,''Impossible en 3D'')'
      texte(1,29) = '(  5x,''Non disponible avec ce code de calcul'')'
c
      texte(1,30) =
     > '(/,5x,''Pilotage du raffinement :'',/,5x,25(''-''))'
      texte(1,31) =
     > '(/,7x,''--> Les mailles incompatibles sont ignorees'')'
c     remarque : l'indice vaut 33 + code du type de raffinement
      texte(1,32) = '(7x,''--> raffinement uniforme'',/)'
      texte(1,33) = '(7x,''--> pas de raffinement'')'
      texte(1,34) = '(7x,''--> raffinement libre'',/)'
      texte(1,35) =
     > '(7x,''    avec conservation des types de mailles'',/)'
c
      texte(1,39) =
     > '(7x,''--> decalage d''''au moins 2 mailles pour 2 zones a ni'',
     > ''veau different'',/)'
      texte(1,40) = '(7x,''--> bande interdite'',/)'
c
      texte(1,41) =
     > '(/,5x,''Pilotage du deraffinement :'',/,5x,27(''-''))'
c     remarque : l'indice vaut 43 + code du type de raffinement
      texte(1,42) = '(7x,''--> deraffinement uniforme'',/)'
      texte(1,43) = '(7x,''--> pas de deraffinement'')'
      texte(1,44) = '(7x,''--> deraffinement libre'',/)'
c
      texte(1,51) = '(7x,''--> niveau maximum autorise :'',i4)'
      texte(1,52) = '(7x,''--> niveau minimum autorise :'',i4)'
      texte(1,53) =
     > '(/,7x,''Deraffinement interdit si le raffinement est uniforme.''
     >)'
      texte(1,54) =
     > '(/,7x,''Raffinement interdit si le deraffinement est uniforme.''
     >)'
c
      texte(1,61) = '(/,5x,''Les conversions :'',/,5x,17(''-''))'
c
      texte(1,70) =
     > '(/,5x,''Options pour Code_Saturne :'',/,5x,27(''-''))'
      texte(1,71) =
     > '(/,7x,''--> Il faut definir le delta z voulu.'')'
      texte(1,72) =
     > '(/,7x,''--> Le delta z voulu doit etre strictement positif.'')'
c
      texte(1,80) =
     > '(/,7x,''--> Mauvaise definition des seuils d''''erreur.'')'
      texte(1,81) =
     > '(7x,''--> borne superieure absolue de l''''erreur : '',g15.6,/)'
      texte(1,82) =
     >'(7x,''--> borne superieure relative de l''''erreur : '',g11.3,/)'
      texte(1,83) =
     > '(7x,''--> pourcentage de mailles a raffiner : '',g11.3,/)'
      texte(1,84) =
     > '(7x,''--> borne inferieure absolue de l''''erreur : '',g15.6,/)'
      texte(1,85) =
     >'(7x,''--> borne inferieure relative de l''''erreur : '',g11.3,/)'
      texte(1,86) =
     > '(7x,''--> pourcentage de mailles a deraffiner : '',g11.3,/)'
      texte(1,87) =
     > '(/,7x,''Le pourcentage doit etre entre 0 et 100.'')'
      texte(1,88) =
     > '(7x,''--> seuil en moyenne '',a,'' '',g11.3,''*sigma'',/)'
      texte(1,93) = '(/,7x,''Les seuils sont incompatibles.'')'
      texte(1,94) = '(7x,''--> selon des zones geometriques'')'
c
      texte(1,101) =
     >'(''Choix de l''''instant de l''''indicateur d''''errreur'')'
      texte(1,102) =
     >'(''Impossible de demander un ''''dernier'''' et autre chose'',/)'
      texte(1,103) =
     >'(''Impossible de demander un instant et un pas de temps'',/)'
c
      texte(1,110) =
     > '(/,5x,''Mode de conformite :'',/,5x,20(''-''))'
      texte(1,111) =
     > '(7x,''--> non conforme avec 1 seule arete decoupee'')'
      texte(1,112) =
     > '(7x,''--> Adaptation conforme avec des boites'')'
      texte(1,113) =
     > '(7x,''--> Adaptation conforme'')'
      texte(1,114) =
     > '(7x,''--> Adaptation non conforme'')'
      texte(1,115) =
     > '(7x,''--> non conforme avec 1 seul noeud pendant par arete'',/)'
      texte(1,116) =
     > '(7x,''--> non conforme fidele a l''''indicateur'',/)'
c
      texte(1,119) =
     > '(/,5x,''Maillage extrude selon '',a1,/,5x,24(''-''))'
c
      texte(1,120) =
     > '(7x,''--> Cible en nombre de sommets possible exclusivement'')'
      texte(1,121) = '(11x,''avec du raffinement libre'')'
      texte(1,122) = '(11x,''sans deraffinement'')'
      texte(1,123) =
     > '(7x,''--> cible en nombre de sommets : '',i11,/)'
      texte(1,124) =
     > '(7x,''--> nombre maximum de passages :'',i5,/)'
c
      texte(2,6) = '(/,1x,''One ERROR in keywords of options !'')'
      texte(2,7) = '(/,1x,''ERRORS in keywords of options !'')'
c
      texte(2,11) = '(7x,''--> UNCORRECT OPTION :'',i10)'
      texte(2,12) = '(7x,''--> no conversion'',/)'
      texte(2,13) = '(7x,''--> conversion'',/)'
      texte(2,14) = '(7x,''--> non active'')'
      texte(2,15) = '(7x,''--> active'')'
c
      texte(2,20) = '(5x,''Initial mesh'')'
      texte(2,21) = '(5x,''Mesh after one iteration'')'
      texte(2,22) = '(5x,''Mesh after'',i4,'' iterations'')'
      texte(2,23) = '(/,5x,''Start point:'',/,5x,13(''-''))'
      texte(2,24) = '(7x,''Mesh to be checked:'')'
      texte(2,25) = '(7x,''Mesh to be modified:'')'
c
      texte(2,26) = '(/,5x,''Related code: '',a18,/,5x,14(''-''))'
c
      texte(2,27) = '(/,5x,''Boundary following:'',/,5x,20(''-''))'
      texte(2,28) = '(  5x,''Impossible for 3D'')'
      texte(2,29) = '(  5x,''Non available with this connected code'')'
c
      texte(2,30) = '(/,5x,''Control of refinement:'',/,5x,23(''-''))'
      texte(2,31) = '(/,7x,''--> Incompatible meshes are ignored'')'
c     remarque : l'indice vaut 33 + code du type de raffinement
      texte(2,32) = '(7x,''--> uniform refinement'',/)'
      texte(2,33) = '(7x,''--> no refinement'')'
      texte(2,34) = '(7x,''--> free refinement'',/)'
c
      texte(2,39) = '(7x,''--> shift of at least 2 meshes'',/)'
      texte(2,40) = '(7x,''--> stripes are forbidden'',/)'
c
      texte(2,41) =
     > '(/,5x,''Control of unrefinement:'',/,5x,25(''-''))'
c     remarque : l'indice vaut 43 + code du type de raffinement
      texte(2,42) = '(7x,''--> uniform unrefinement'',/)'
      texte(2,43) = '(7x,''--> no unrefinement'')'
      texte(2,44) = '(7x,''--> free unrefinement'',/)'
c
      texte(2,51) = '(7x,''--> maximum authorized level:'',i4)'
      texte(2,52) = '(7x,''--> minimum authorized level:'',i4)'
      texte(2,53) =
     >'(/,7x,''Unrefinement is forbidden when refinement is uniform.'')'
      texte(2,54) =
     >'(/,7x,''Refinement is forbidden when unrefinement is uniform.'')'
c
      texte(2,61) = '(/,5x,''Conversions:'',/,5x,13(''-''))'
c
      texte(2,70) =
     > '(/,5x,''Options for Code_Saturne:'',/,5x,26(''-''))'
      texte(2,71) =
     > '(/,7x,''--> Wanted delta z should be defined.'')'
      texte(2,72) =
     > '(/,7x,''--> Wanted delta z should be positive.'')'
c
      texte(2,80) =
     > '(/,7x,''--> Error threshold ill-defined.'')'
      texte(2,81) =
     >'(7x,''--> high absolute threshold for error: '',g15.6,/)'
      texte(2,82) =
     >'(7x,''--> high relative threshold for error: '',g11.3,/)'
      texte(2,83) =
     >'(7x,''--> percentage of meshes to refine: '',g11.3,/)'
      texte(2,84) =
     >'(7x,''--> low absolute threshold for error : '',g15.6,/)'
      texte(2,85) =
     >'(7x,''--> low relative threshold for error : '',g11.3,/)'
      texte(2,86) =
     >'(7x,''--> percentage of meshes to coarsen: '',g11.3,/)'
      texte(2,87) = '(/,7x,''Percentage should be between 0 and 100.'')'
      texte(2,88) =
     > '(7x,''--> threshold by mean '',a,'' '',g11.3,''*sigma'',/)'
      texte(2,93) = '(/,7x,''The thresholds do not fit together.'')'
      texte(2,94) = '(7x,''--> by geometrical zones'')'
c
      texte(2,101) = '(''Choice for error indicator'')'
      texte(2,102) =
     >'(''''Last'''' and something else cannot be both required'',/)'
      texte(2,103) =
     >'(''A time step and an instant cannot be both required'',/)'
c
      texte(2,110) =
     > '(/,5x,''Type of conformal situations:'',/,5x,30(''-''))'
      texte(2,111) =
     > '(7x,''--> hanging node refinement with a single cut edge'',/)'
      texte(2,112) =
     > '(7x,''--> Conformal adaptation with boxes'')'
      texte(2,113) =
     > '(7x,''--> Conformal adaptation'')'
      texte(2,114) =
     > '(7x,''--> Non conformal adaptation'')'
      texte(2,115) =
     > '(7x,''--> hanging node refinement, a single node per edge'',/)'
      texte(2,116) =
     > '(7x,''--> hanging node refinement from indicator'',/)'
c
      texte(2,119) =
     > '(/,5x,''Extruded mesh along '',a1,/,5x,21(''-''))'
c
      texte(2,120) =
     > '(7x,''--> Target for the number of vertices is possible only'')'
      texte(2,121) = '(11x,''with free refinement'')'
      texte(2,122) = '(11x,''without unrefinement'')'
      texte(2,123) =
     > '(7x,''--> target for the number of vertices: '',i11,/)'
      texte(2,124) =
     > '(7x,''--> maximal number of iterations:'',i5,/)'
