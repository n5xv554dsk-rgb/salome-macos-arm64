      subroutine gmitob
c ______________________________________________________________________
c
c                         H O M A R D     V11.n   
c
c Outil de Maillage Adaptatif par Raffinement et Deraffinement d'EDF R&D
c
c Version originale enregistree le 18 juin 1996 sous le numero 96036
c aupres des huissiers de justice Simart et Lavoir a Clamart
c Version 11.2 enregistree le 13 fevrier 2015 sous le numero 2015/014
c aupres des huissiers de justice
c Lavoir, Silinski & Cherqui-Abrahmi a Clamart
c
c    HOMARD est une marque deposee d'Electricite de France
c Copyright EDF 1996, 2020
c ______________________________________________________________________
c
c       Gestionnaire de la Memoire :
c       -                  -
c       Initialisation des Tables d'OBjets
c       -                  -        --
c
      save
c
#include "gmmatc.h"
c
#include "gmtoas.h"
#include "gmtori.h"
#include "gmtors.h"
#include "gmtove.h"
c
      integer iaux
c
c numeros de version des tables d'objets
c
      nuveto =           11
      nusvto =            9
      daheto =     30585600
      nuanto =         2016
c
c objets structures
c
      nbrtyp =           43
c
c--------------------------------------------------
c
      nomtyp(         1) = 'HOM_Mail'
      nbratt(         1) =           11
      nbcham(         1) =           10
      adrdst(         1) =            1
c
        nomcha(         1) = 'Noeud   '
        typcha(         1) =            3
        nomcha(         2) = 'Ma_Point'
        typcha(         2) =            7
        nomcha(         3) = 'Arete   '
        typcha(         3) =            4
        nomcha(         4) = 'Face    '
        typcha(         4) =            5
        nomcha(         5) = 'Volume  '
        typcha(         5) =            6
        nomcha(         6) = 'ElemIgno'
        typcha(         6) =            8
        nomcha(         7) = 'Voisins '
        typcha(         7) =           11
        nomcha(         8) = 'RenuMail'
        typcha(         8) =            2
        nomcha(         9) = 'InfoSupE'
        typcha(         9) =           41
        nomcha(        10) = 'InfoSupS'
        typcha(        10) =           43
c
c--------------------------------------------------
c
      nomtyp(         2) = 'RenuMail'
      nbratt(         2) =           19
      nbcham(         2) =           20
      adrdst(         2) =           11
c
        nomcha(        11) = 'NoHOMARD'
        typcha(        11) =           -1
        nomcha(        12) = 'NoCalcul'
        typcha(        12) =           -1
        nomcha(        13) = 'MPHOMARD'
        typcha(        13) =           -1
        nomcha(        14) = 'MPCalcul'
        typcha(        14) =           -1
        nomcha(        15) = 'ArHOMARD'
        typcha(        15) =           -1
        nomcha(        16) = 'ArCalcul'
        typcha(        16) =           -1
        nomcha(        17) = 'TrHOMARD'
        typcha(        17) =           -1
        nomcha(        18) = 'TrCalcul'
        typcha(        18) =           -1
        nomcha(        19) = 'TeHOMARD'
        typcha(        19) =           -1
        nomcha(        20) = 'TeCalcul'
        typcha(        20) =           -1
        nomcha(        21) = 'QuHOMARD'
        typcha(        21) =           -1
        nomcha(        22) = 'QuCalcul'
        typcha(        22) =           -1
        nomcha(        23) = 'PyHOMARD'
        typcha(        23) =           -1
        nomcha(        24) = 'PyCalcul'
        typcha(        24) =           -1
        nomcha(        25) = 'HeHOMARD'
        typcha(        25) =           -1
        nomcha(        26) = 'HeCalcul'
        typcha(        26) =           -1
        nomcha(        27) = 'PeHOMARD'
        typcha(        27) =           -1
        nomcha(        28) = 'PeCalcul'
        typcha(        28) =           -1
        nomcha(        29) = 'Nombres '
        typcha(        29) =           -1
        nomcha(        30) = 'InfoSupE'
        typcha(        30) =           41
c
c--------------------------------------------------
c
      nomtyp(         3) = 'HOM_Noeu'
      nbratt(         3) =            4
      nbcham(         3) =           10
      adrdst(         3) =           31
c
        nomcha(        31) = 'Coor    '
        typcha(        31) =           -2
        nomcha(        32) = 'HistEtat'
        typcha(        32) =           -1
        nomcha(        33) = 'AretSupp'
        typcha(        33) =           -1
        nomcha(        34) = 'Homologu'
        typcha(        34) =           -1
        nomcha(        35) = 'Deraffin'
        typcha(        35) =           -1
        nomcha(        36) = 'CoorCons'
        typcha(        36) =           -2
        nomcha(        37) = 'InfoGene'
        typcha(        37) =           -3
        nomcha(        38) = 'Recollem'
        typcha(        38) =           -1
        nomcha(        39) = 'Famille '
        typcha(        39) =            9
        nomcha(        40) = 'Frontier'
        typcha(        40) =           39
c
c--------------------------------------------------
c
      nomtyp(         4) = 'HOM_Aret'
      nbratt(         4) =            0
      nbcham(         4) =            2
      adrdst(         4) =           41
c
        nomcha(        41) = 'HOM_Se02'
        typcha(        41) =            7
        nomcha(        42) = 'HOM_Se03'
        typcha(        42) =            7
c
c--------------------------------------------------
c
      nomtyp(         5) = 'HOM_Face'
      nbratt(         5) =            0
      nbcham(         5) =            6
      adrdst(         5) =           43
c
        nomcha(        43) = 'HOM_Tr03'
        typcha(        43) =            7
        nomcha(        44) = 'HOM_Tr06'
        typcha(        44) =            7
        nomcha(        45) = 'HOM_Tr07'
        typcha(        45) =            7
        nomcha(        46) = 'HOM_Qu04'
        typcha(        46) =            7
        nomcha(        47) = 'HOM_Qu08'
        typcha(        47) =            7
        nomcha(        48) = 'HOM_Qu09'
        typcha(        48) =            7
c
c--------------------------------------------------
c
      nomtyp(         6) = 'HOM_Volu'
      nbratt(         6) =            0
      nbcham(         6) =            9
      adrdst(         6) =           49
c
        nomcha(        49) = 'HOM_Te04'
        typcha(        49) =            7
        nomcha(        50) = 'HOM_Te10'
        typcha(        50) =            7
        nomcha(        51) = 'HOM_Py05'
        typcha(        51) =            7
        nomcha(        52) = 'HOM_Py13'
        typcha(        52) =            7
        nomcha(        53) = 'HOM_He08'
        typcha(        53) =            7
        nomcha(        54) = 'HOM_He20'
        typcha(        54) =            7
        nomcha(        55) = 'HOM_He27'
        typcha(        55) =            7
        nomcha(        56) = 'HOM_Pe06'
        typcha(        56) =            7
        nomcha(        57) = 'HOM_Pe15'
        typcha(        57) =            7
c
c--------------------------------------------------
c
      nomtyp(         7) = 'HOM_Enti'
      nbratt(         7) =            2
      nbcham(         7) =           14
      adrdst(         7) =           58
c
        nomcha(        58) = 'ConnDesc'
        typcha(        58) =           -1
        nomcha(        59) = 'ConnAret'
        typcha(        59) =           -1
        nomcha(        60) = 'HistEtat'
        typcha(        60) =           -1
        nomcha(        61) = 'Niveau  '
        typcha(        61) =           -1
        nomcha(        62) = 'Mere    '
        typcha(        62) =           -1
        nomcha(        63) = 'Fille   '
        typcha(        63) =           -1
        nomcha(        64) = 'Homologu'
        typcha(        64) =           -1
        nomcha(        65) = 'InfoSupp'
        typcha(        65) =           -1
        nomcha(        66) = 'InfoSup2'
        typcha(        66) =           -1
        nomcha(        67) = 'NoeuInMa'
        typcha(        67) =           -1
        nomcha(        68) = 'Deraffin'
        typcha(        68) =           -1
        nomcha(        69) = 'InfoGene'
        typcha(        69) =           -3
        nomcha(        70) = 'Recollem'
        typcha(        70) =           10
        nomcha(        71) = 'Famille '
        typcha(        71) =            9
c
c--------------------------------------------------
c
      nomtyp(         8) = 'HOM_Elig'
      nbratt(         8) =            1
      nbcham(         8) =            2
      adrdst(         8) =           72
c
        nomcha(        72) = 'ConnNoeu'
        typcha(        72) =           -1
        nomcha(        73) = 'FamilMED'
        typcha(        73) =           -1
c
c--------------------------------------------------
c
      nomtyp(         9) = 'HOM_Fami'
      nbratt(         9) =            2
      nbcham(         9) =            2
      adrdst(         9) =           74
c
        nomcha(        74) = 'EntiFamm'
        typcha(        74) =           -1
        nomcha(        75) = 'Codes   '
        typcha(        75) =           -1
c
c--------------------------------------------------
c
      nomtyp(        10) = 'HOM_Reco'
      nbratt(        10) =            3
      nbcham(        10) =            2
      adrdst(        10) =           76
c
        nomcha(        76) = 'ListeA  '
        typcha(        76) =           -1
        nomcha(        77) = 'ListeB  '
        typcha(        77) =           -1
c
c--------------------------------------------------
c
      nomtyp(        11) = 'Voisins '
      nbratt(        11) =            2
      nbcham(        11) =           10
      adrdst(        11) =           78
c
        nomcha(        78) = '0D/1D   '
        typcha(        78) =           32
        nomcha(        79) = '1D/2D   '
        typcha(        79) =           32
        nomcha(        80) = 'Vol/Tri '
        typcha(        80) =           -1
        nomcha(        81) = 'Vol/Qua '
        typcha(        81) =           -1
        nomcha(        82) = 'PyPe/Tri'
        typcha(        82) =           -1
        nomcha(        83) = 'PyPe/Qua'
        typcha(        83) =           -1
        nomcha(        84) = 'Tet/Are '
        typcha(        84) =           32
        nomcha(        85) = 'Hex/Are '
        typcha(        85) =           32
        nomcha(        86) = 'Pen/Are '
        typcha(        86) =           32
        nomcha(        87) = 'Pyr/Are '
        typcha(        87) =           32
c
c--------------------------------------------------
c
      nomtyp(        12) = 'Sauve_HM'
      nbratt(        12) =            7
      nbcham(        12) =           18
      adrdst(        12) =           88
c
        nomcha(        88) = 'Fille_Ar'
        typcha(        88) =           -1
        nomcha(        89) = 'HEtat_Ar'
        typcha(        89) =           -1
        nomcha(        90) = 'Fille_Tr'
        typcha(        90) =           -1
        nomcha(        91) = 'HEtat_Tr'
        typcha(        91) =           -1
        nomcha(        92) = 'Famil_Tr'
        typcha(        92) =           -1
        nomcha(        93) = 'Fille_Qu'
        typcha(        93) =           -1
        nomcha(        94) = 'HEtat_Qu'
        typcha(        94) =           -1
        nomcha(        95) = 'Fille_Te'
        typcha(        95) =           -1
        nomcha(        96) = 'HEtat_Te'
        typcha(        96) =           -1
        nomcha(        97) = 'Fille_Py'
        typcha(        97) =           -1
        nomcha(        98) = 'HEtat_Py'
        typcha(        98) =           -1
        nomcha(        99) = 'Fille_He'
        typcha(        99) =           -1
        nomcha(       100) = 'HEtat_He'
        typcha(       100) =           -1
        nomcha(       101) = 'Insu2_He'
        typcha(       101) =           -1
        nomcha(       102) = 'Fille_Pe'
        typcha(       102) =           -1
        nomcha(       103) = 'HEtat_Pe'
        typcha(       103) =           -1
        nomcha(       104) = 'Insu2_Pe'
        typcha(       104) =           -1
        nomcha(       105) = 'RenuMail'
        typcha(       105) =            2
c
c--------------------------------------------------
c
      nomtyp(        13) = 'HOM_Indi'
      nbratt(        13) =            0
      nbcham(        13) =            9
      adrdst(        13) =          106
c
        nomcha(       106) = 'Noeud   '
        typcha(       106) =           14
        nomcha(       107) = 'Point   '
        typcha(       107) =           14
        nomcha(       108) = 'Arete   '
        typcha(       108) =           14
        nomcha(       109) = 'Trian   '
        typcha(       109) =           14
        nomcha(       110) = 'Quadr   '
        typcha(       110) =           14
        nomcha(       111) = 'Tetra   '
        typcha(       111) =           14
        nomcha(       112) = 'Hexae   '
        typcha(       112) =           14
        nomcha(       113) = 'Pyram   '
        typcha(       113) =           14
        nomcha(       114) = 'Penta   '
        typcha(       114) =           14
c
c--------------------------------------------------
c
      nomtyp(        14) = 'Indicate'
      nbratt(        14) =            3
      nbcham(        14) =            3
      adrdst(        14) =          115
c
        nomcha(       115) = 'Support '
        typcha(       115) =           -1
        nomcha(       116) = 'ValeursE'
        typcha(       116) =           -1
        nomcha(       117) = 'ValeursR'
        typcha(       117) =           -2
c
c--------------------------------------------------
c
      nomtyp(        15) = 'Cal_Mail'
      nbratt(        15) =            8
      nbcham(        15) =            9
      adrdst(        15) =          118
c
        nomcha(       118) = 'InfoGene'
        typcha(       118) =           34
        nomcha(       119) = 'Noeud   '
        typcha(       119) =           16
        nomcha(       120) = 'ConnNoeu'
        typcha(       120) =           17
        nomcha(       121) = 'ConnDesc'
        typcha(       121) =           18
        nomcha(       122) = 'Famille '
        typcha(       122) =           19
        nomcha(       123) = 'Equivalt'
        typcha(       123) =           20
        nomcha(       124) = 'Frontier'
        typcha(       124) =           -1
        nomcha(       125) = 'CodeExte'
        typcha(       125) =           21
        nomcha(       126) = 'Nombres '
        typcha(       126) =           -1
c
c--------------------------------------------------
c
      nomtyp(        16) = 'MC_Noe  '
      nbratt(        16) =            3
      nbcham(        16) =            4
      adrdst(        16) =          127
c
        nomcha(       127) = 'NumeExte'
        typcha(       127) =           -1
        nomcha(       128) = 'Coor    '
        typcha(       128) =           -2
        nomcha(       129) = 'FamilMED'
        typcha(       129) =           -1
        nomcha(       130) = 'CoorCons'
        typcha(       130) =           -2
c
c--------------------------------------------------
c
      nomtyp(        17) = 'MC_CNo  '
      nbratt(        17) =            3
      nbcham(        17) =            4
      adrdst(        17) =          131
c
        nomcha(       131) = 'NumeExte'
        typcha(       131) =           -1
        nomcha(       132) = 'FamilMED'
        typcha(       132) =           -1
        nomcha(       133) = 'Type    '
        typcha(       133) =           -1
        nomcha(       134) = 'Noeuds  '
        typcha(       134) =           -1
c
c--------------------------------------------------
c
      nomtyp(        18) = 'MC_CDe  '
      nbratt(        18) =            2
      nbcham(        18) =            4
      adrdst(        18) =          135
c
        nomcha(       135) = 'NumeExte'
        typcha(       135) =           -1
        nomcha(       136) = 'FamilMED'
        typcha(       136) =           -1
        nomcha(       137) = 'Type    '
        typcha(       137) =           -1
        nomcha(       138) = 'Entites '
        typcha(       138) =           -1
c
c--------------------------------------------------
c
      nomtyp(        19) = 'MC_Fam  '
      nbratt(        19) =            3
      nbcham(        19) =            3
      adrdst(        19) =          139
c
        nomcha(       139) = 'Numero  '
        typcha(       139) =           -1
        nomcha(       140) = 'Nom     '
        typcha(       140) =           -3
        nomcha(       141) = 'Groupe  '
        typcha(       141) =           34
c
c--------------------------------------------------
c
      nomtyp(        20) = 'MC_Equ  '
      nbratt(        20) =            8
      nbcham(        20) =            9
      adrdst(        20) =          142
c
        nomcha(       142) = 'Pointeur'
        typcha(       142) =           -1
        nomcha(       143) = 'InfoGene'
        typcha(       143) =           -3
        nomcha(       144) = 'Noeud   '
        typcha(       144) =           -1
        nomcha(       145) = 'Point   '
        typcha(       145) =           -1
        nomcha(       146) = 'Arete   '
        typcha(       146) =           -1
        nomcha(       147) = 'Trian   '
        typcha(       147) =           -1
        nomcha(       148) = 'Quadr   '
        typcha(       148) =           -1
        nomcha(       149) = 'Tetra   '
        typcha(       149) =           -1
        nomcha(       150) = 'Hexae   '
        typcha(       150) =           -1
c
c--------------------------------------------------
c
      nomtyp(        21) = 'MC_CEx  '
      nbratt(        21) =           10
      nbcham(        21) =           10
      adrdst(        21) =          151
c
        nomcha(       151) = 'Noeud   '
        typcha(       151) =           -1
        nomcha(       152) = 'Point   '
        typcha(       152) =           -1
        nomcha(       153) = 'Arete   '
        typcha(       153) =           -1
        nomcha(       154) = 'Trian   '
        typcha(       154) =           -1
        nomcha(       155) = 'Quadr   '
        typcha(       155) =           -1
        nomcha(       156) = 'Tetra   '
        typcha(       156) =           -1
        nomcha(       157) = 'Pyram   '
        typcha(       157) =           -1
        nomcha(       158) = 'Hexae   '
        typcha(       158) =           -1
        nomcha(       159) = 'Penta   '
        typcha(       159) =           -1
        nomcha(       160) = 'ElemBord'
        typcha(       160) =           -1
c
c--------------------------------------------------
c
      nomtyp(        22) = 'Solution'
      nbratt(        22) =            4
      nbcham(        22) =            4
      adrdst(        22) =          161
c
        nomcha(       161) = 'InfoCham'
        typcha(       161) =           -3
        nomcha(       162) = 'InfoPaFo'
        typcha(       162) =           -3
        nomcha(       163) = 'InfoProf'
        typcha(       163) =           -3
        nomcha(       164) = 'InfoLoPG'
        typcha(       164) =           -3
c
c--------------------------------------------------
c
      nomtyp(        23) = 'InfoCham'
      nbratt(        23) =            3
      nbcham(        23) =            4
      adrdst(        23) =          165
c
        nomcha(       165) = 'Nom_Comp'
        typcha(       165) =           -3
        nomcha(       166) = 'Cham_Ent'
        typcha(       166) =           -1
        nomcha(       167) = 'Cham_Ree'
        typcha(       167) =           -2
        nomcha(       168) = 'Cham_Car'
        typcha(       168) =           -3
c
c--------------------------------------------------
c
      nomtyp(        24) = 'PackFonc'
      nbratt(        24) =            5
      nbcham(        24) =            2
      adrdst(        24) =          169
c
        nomcha(       169) = 'Fonction'
        typcha(       169) =           -3
        nomcha(       170) = 'TypeSuAs'
        typcha(       170) =           -1
c
c--------------------------------------------------
c
      nomtyp(        25) = 'Profil  '
      nbratt(        25) =            2
      nbcham(        25) =            2
      adrdst(        25) =          171
c
        nomcha(       171) = 'NomProfi'
        typcha(       171) =           -3
        nomcha(       172) = 'ListEnti'
        typcha(       172) =           -1
c
c--------------------------------------------------
c
      nomtyp(        26) = 'LocaPG  '
      nbratt(        26) =            4
      nbcham(        26) =            4
      adrdst(        26) =          173
c
        nomcha(       173) = 'NomLocPG'
        typcha(       173) =           -3
        nomcha(       174) = 'CoorNoeu'
        typcha(       174) =           -2
        nomcha(       175) = 'CoorPtGa'
        typcha(       175) =           -2
        nomcha(       176) = 'PoidPtGa'
        typcha(       176) =           -2
c
c--------------------------------------------------
c
      nomtyp(        27) = 'Fonction'
      nbratt(        27) =            8
      nbcham(        27) =            5
      adrdst(        27) =          177
c
        nomcha(       177) = 'ValeursE'
        typcha(       177) =           -1
        nomcha(       178) = 'ValeursR'
        typcha(       178) =           -2
        nomcha(       179) = 'InfoCham'
        typcha(       179) =           -3
        nomcha(       180) = 'InfoPrPG'
        typcha(       180) =           -3
        nomcha(       181) = 'TypeSuAs'
        typcha(       181) =           -1
c
c--------------------------------------------------
c
      nomtyp(        28) = 'DonnHOMA'
      nbratt(        28) =            5
      nbcham(        28) =            4
      adrdst(        28) =          182
c
        nomcha(       182) = 'OptEnt  '
        typcha(       182) =           -1
        nomcha(       183) = 'OptRee  '
        typcha(       183) =           -2
        nomcha(       184) = 'OptCar  '
        typcha(       184) =           -3
        nomcha(       185) = 'EtatCour'
        typcha(       185) =           -1
c
c--------------------------------------------------
c
      nomtyp(        29) = 'FichExec'
      nbratt(        29) =            2
      nbcham(        29) =            6
      adrdst(        29) =          186
c
        nomcha(       186) = 'NomRefer'
        typcha(       186) =           -3
        nomcha(       187) = 'LongNomF'
        typcha(       187) =           -1
        nomcha(       188) = 'PosiNomF'
        typcha(       188) =           -1
        nomcha(       189) = 'NomUFich'
        typcha(       189) =           -3
        nomcha(       190) = 'NomObjSt'
        typcha(       190) =           -3
        nomcha(       191) = 'InfoSupp'
        typcha(       191) =           -3
c
c--------------------------------------------------
c
      nomtyp(        30) = 'ChampMAJ'
      nbratt(        30) =            1
      nbcham(        30) =            3
      adrdst(        30) =          192
c
        nomcha(       192) = 'CarCaChp'
        typcha(       192) =           -3
        nomcha(       193) = 'CarEnChp'
        typcha(       193) =           -1
        nomcha(       194) = 'CarReChp'
        typcha(       194) =           -2
c
c--------------------------------------------------
c
      nomtyp(        31) = 'Cal_Fron'
      nbratt(        31) =            5
      nbcham(        31) =            7
      adrdst(        31) =          195
c
        nomcha(       195) = 'CoorNoeu'
        typcha(       195) =           -2
        nomcha(       196) = 'NumeLign'
        typcha(       196) =           -1
        nomcha(       197) = 'TypeLign'
        typcha(       197) =           -1
        nomcha(       198) = 'PtrSomLi'
        typcha(       198) =           -1
        nomcha(       199) = 'SommSegm'
        typcha(       199) =           -1
        nomcha(       200) = 'AbsCurvi'
        typcha(       200) =           -2
        nomcha(       201) = 'Groupes '
        typcha(       201) =           34
c
c--------------------------------------------------
c
      nomtyp(        32) = 'PtTabEnt'
      nbratt(        32) =            2
      nbcham(        32) =            2
      adrdst(        32) =          202
c
        nomcha(       202) = 'Pointeur'
        typcha(       202) =           -1
        nomcha(       203) = 'Table   '
        typcha(       203) =           -1
c
c--------------------------------------------------
c
      nomtyp(        33) = 'PtTabRee'
      nbratt(        33) =            2
      nbcham(        33) =            2
      adrdst(        33) =          204
c
        nomcha(       204) = 'Pointeur'
        typcha(       204) =           -1
        nomcha(       205) = 'Table   '
        typcha(       205) =           -2
c
c--------------------------------------------------
c
      nomtyp(        34) = 'PtTabC08'
      nbratt(        34) =            2
      nbcham(        34) =            3
      adrdst(        34) =          206
c
        nomcha(       206) = 'Pointeur'
        typcha(       206) =           -1
        nomcha(       207) = 'Taille  '
        typcha(       207) =           -1
        nomcha(       208) = 'Table   '
        typcha(       208) =           -3
c
c--------------------------------------------------
c
      nomtyp(        35) = 'Pt2TbEnt'
      nbratt(        35) =            2
      nbcham(        35) =            3
      adrdst(        35) =          209
c
        nomcha(       209) = 'Pointeur'
        typcha(       209) =           -1
        nomcha(       210) = 'ListeA  '
        typcha(       210) =           -1
        nomcha(       211) = 'ListeB  '
        typcha(       211) =           -1
c
c--------------------------------------------------
c
      nomtyp(        36) = 'PtPtTEnt'
      nbratt(        36) =            3
      nbcham(        36) =            3
      adrdst(        36) =          212
c
        nomcha(       212) = 'Pointer1'
        typcha(       212) =           -1
        nomcha(       213) = 'Pointer2'
        typcha(       213) =           -1
        nomcha(       214) = 'Table   '
        typcha(       214) =           -1
c
c--------------------------------------------------
c
      nomtyp(        37) = '2ListEnt'
      nbratt(        37) =            1
      nbcham(        37) =            2
      adrdst(        37) =          215
c
        nomcha(       215) = 'ListeA  '
        typcha(       215) =           -1
        nomcha(       216) = 'ListeB  '
        typcha(       216) =           -1
c
c--------------------------------------------------
c
      nomtyp(        38) = '3ListEnt'
      nbratt(        38) =            1
      nbcham(        38) =            3
      adrdst(        38) =          217
c
        nomcha(       217) = 'ListeA  '
        typcha(       217) =           -1
        nomcha(       218) = 'ListeB  '
        typcha(       218) =           -1
        nomcha(       219) = 'ListeC  '
        typcha(       219) =           -1
c
c--------------------------------------------------
c
      nomtyp(        39) = '2ListeER'
      nbratt(        39) =            1
      nbcham(        39) =            2
      adrdst(        39) =          220
c
        nomcha(       220) = 'ListeA  '
        typcha(       220) =           -1
        nomcha(       221) = 'ListeB  '
        typcha(       221) =           -1
c
c--------------------------------------------------
c
      nomtyp(        40) = 'EntCarRe'
      nbratt(        40) =            1
      nbcham(        40) =            4
      adrdst(        40) =          222
c
        nomcha(       222) = 'ValeursE'
        typcha(       222) =           -1
        nomcha(       223) = 'ValeursS'
        typcha(       223) =           -3
        nomcha(       224) = 'ValeursR'
        typcha(       224) =           -2
        nomcha(       225) = 'Suivant '
        typcha(       225) =           40
c
c--------------------------------------------------
c
      nomtyp(        41) = '10TabEnt'
      nbratt(        41) =           10
      nbcham(        41) =           10
      adrdst(        41) =          226
c
        nomcha(       226) = 'Tab1    '
        typcha(       226) =           -1
        nomcha(       227) = 'Tab2    '
        typcha(       227) =           -1
        nomcha(       228) = 'Tab3    '
        typcha(       228) =           -1
        nomcha(       229) = 'Tab4    '
        typcha(       229) =           -1
        nomcha(       230) = 'Tab5    '
        typcha(       230) =           -1
        nomcha(       231) = 'Tab6    '
        typcha(       231) =           -1
        nomcha(       232) = 'Tab7    '
        typcha(       232) =           -1
        nomcha(       233) = 'Tab8    '
        typcha(       233) =           -1
        nomcha(       234) = 'Tab9    '
        typcha(       234) =           -1
        nomcha(       235) = 'Tab10   '
        typcha(       235) =           -1
c
c--------------------------------------------------
c
      nomtyp(        42) = '10TabRee'
      nbratt(        42) =           10
      nbcham(        42) =           10
      adrdst(        42) =          236
c
        nomcha(       236) = 'Tab1    '
        typcha(       236) =           -2
        nomcha(       237) = 'Tab2    '
        typcha(       237) =           -2
        nomcha(       238) = 'Tab3    '
        typcha(       238) =           -2
        nomcha(       239) = 'Tab4    '
        typcha(       239) =           -2
        nomcha(       240) = 'Tab5    '
        typcha(       240) =           -2
        nomcha(       241) = 'Tab6    '
        typcha(       241) =           -2
        nomcha(       242) = 'Tab7    '
        typcha(       242) =           -2
        nomcha(       243) = 'Tab8    '
        typcha(       243) =           -2
        nomcha(       244) = 'Tab9    '
        typcha(       244) =           -2
        nomcha(       245) = 'Tab10   '
        typcha(       245) =           -2
c
c--------------------------------------------------
c
      nomtyp(        43) = '10TabC08'
      nbratt(        43) =           10
      nbcham(        43) =           10
      adrdst(        43) =          246
c
        nomcha(       246) = 'Tab1    '
        typcha(       246) =           -3
        nomcha(       247) = 'Tab2    '
        typcha(       247) =           -3
        nomcha(       248) = 'Tab3    '
        typcha(       248) =           -3
        nomcha(       249) = 'Tab4    '
        typcha(       249) =           -3
        nomcha(       250) = 'Tab5    '
        typcha(       250) =           -3
        nomcha(       251) = 'Tab6    '
        typcha(       251) =           -3
        nomcha(       252) = 'Tab7    '
        typcha(       252) =           -3
        nomcha(       253) = 'Tab8    '
        typcha(       253) =           -3
        nomcha(       254) = 'Tab9    '
        typcha(       254) =           -3
        nomcha(       255) = 'Tab10   '
        typcha(       255) =           -3
c
      do 24 , iaux = 1 , nbrtyp
        nomtbp(iaux) = nomtyp(iaux)
   24 continue
c
      end
