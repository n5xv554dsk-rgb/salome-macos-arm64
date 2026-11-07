      subroutine utincg
c ______________________________________________________________________
c
c                             H O M A R D
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
c
c Copyright EDF 1996
c Copyright EDF 1998
c Copyright EDF 2002
c Copyright EDF 2020
c ______________________________________________________________________
c
c    UTilitaire - INitialisation des Constantes Generales
c    --           --                 -          -
c ______________________________________________________________________
c
c====
c 0. declarations et dimensionnement
c====
c
c 0.1. ==> generalites
c
      implicit none
      save
c
c 0.2. ==> communs
c
#include "i1i2i3.h"
#include "j1234j.h"
#include "defiqu.h"
#include "demitr.h"
#include "comp07.h"
#include "op0012.h"
#include "op0123.h"
#include "op1234.h"
#include "oriett.h"
#include "orieqh.h"
#include "oriefp.h"
#include "oriefy.h"
#include "op1aa6.h"
#include "ope1a3.h"
#include "ope1a4.h"
#include "ope4a6.h"
#include "ope001.h"
#include "ope002.h"
#include "infini.h"
#include "impr02.h"
#include "enti01.h"
#include "indefi.h"
#include "indefr.h"
#include "indefs.h"
#include "precis.h"
#include "chisig.h"
#include "hexcf0.h"
#include "hexcf1.h"
#include "dicfen.h"
#include "nbfamm.h"
c
#include "fahmed.h"
c
c 0.3. ==> arguments
c
c 0.4. ==> variables locales
c
      integer iaux, jaux
      integer kaux1, kaux2, kaux3, kaux4
      integer tabaux(6)
      integer typenh
c
#include "impr03.h"
c
c====
c 1. les constantes
c====
c
c 1.1. ==> les extremes
c
      call dmzero ( vinfpo, zeroma )
c
      vinfne = - vinfpo
c
c 1.2. ==> precision machine et plus grand entier
c
      call dmprma ( epsima, dmxent, nbchii )
c
c 1.3. ==> les valeurs indefinies
c
      call dmindf ( iindef, rindef, sindef )
c
c====
c 2. initialisation des fonctions en dur
c====
c
c 2.1. ==> fonction de numerotation des demi-triangles fils
c      remarque :  la diagonale du tableau n'est pas utilisee
c                  on met une valeur indefinie pour planter au cas ou !
c
      nutrde(1,1) = iindef
      nutrde(1,2) = 0
      nutrde(1,3) = 1
      nutrde(2,1) = 0
      nutrde(2,2) = iindef
      nutrde(2,3) = 1
      nutrde(3,1) = 0
      nutrde(3,2) = 1
      nutrde(3,3) = iindef
c
c 2.2. ==> Codes permettant d'ordonner les fils d'un quadrangle
c          quand il est face d'un hexaedre ou d'un pentaedre
c
      defiq1(1) = 0
      defiq1(2) = 3
      defiq1(3) = 2
      defiq1(4) = 1
      defiq1(5) = 1
      defiq1(6) = 2
      defiq1(7) = 3
      defiq1(8) = 0
c
      defiq2(1) = 1
      defiq2(2) = 0
      defiq2(3) = 3
      defiq2(4) = 2
      defiq2(5) = 0
      defiq2(6) = 1
      defiq2(7) = 2
      defiq2(8) = 3
c
      defiq3(1) = 2
      defiq3(2) = 1
      defiq3(3) = 0
      defiq3(4) = 3
      defiq3(5) = 3
      defiq3(6) = 0
      defiq3(7) = 1
      defiq3(8) = 2
c
      defiq4(1) = 3
      defiq4(2) = 2
      defiq4(3) = 1
      defiq4(4) = 0
      defiq4(5) = 2
      defiq4(6) = 3
      defiq4(7) = 0
      defiq4(8) = 1
c
c 2.3. ==> numero local de la face opposee pour un hexaedre respectant
c          la convention d'un de : i + coen07(i) = 7
c
      coen07(1) = 6
      coen07(2) = 5
      coen07(3) = 4
      coen07(4) = 3
      coen07(5) = 2
      coen07(6) = 1
c
c 2.4. ==> correspondance entre le code d'un triangle dans un
c          tetraedre ou un pentaedre et les numeros locaux des aretes
c          de cette face
c          Pour une face de code c :
c           i1(c) : numero local de l'arete I1
c           i2(c) : numero local de l'arete I2
c           i3(c) : numero local de l'arete I3
c
      i1(1) = 1
      i1(2) = 3
      i1(3) = 2
      i1(4) = 1
      i1(5) = 3
      i1(6) = 2
c
      i2(1) = 2
      i2(2) = 1
      i2(3) = 3
      i2(4) = 3
      i2(5) = 2
      i2(6) = 1
c
      i3(1) = 3
      i3(2) = 2
      i3(3) = 1
      i3(4) = 2
      i3(5) = 1
      i3(6) = 3
c
c 2.5. ==> correspondance entre le code d'un quadrangle dans un
c          un hexaedre ou un pentaedre et les numeros locaux des aretes
c          de cette face
c          Pour une face de code c :
c           j1(c) : numero local de l'arete I1
c           j2(c) : numero local de l'arete I2
c           j3(c) : numero local de l'arete I3
c           j4(c) : numero local de l'arete I4
c
      j1(1) = 1
      j1(2) = 4
      j1(3) = 3
      j1(4) = 2
      j1(5) = 1
      j1(6) = 2
      j1(7) = 3
      j1(8) = 4
c
      j2(1) = 2
      j2(2) = 1
      j2(3) = 4
      j2(4) = 3
      j2(5) = 4
      j2(6) = 1
      j2(7) = 2
      j2(8) = 3
c
      j3(1) = 3
      j3(2) = 2
      j3(3) = 1
      j3(4) = 4
      j3(5) = 3
      j3(6) = 4
      j3(7) = 1
      j3(8) = 2
c
      j4(1) = 4
      j4(2) = 3
      j4(3) = 2
      j4(4) = 1
      j4(5) = 2
      j4(6) = 3
      j4(7) = 4
      j4(8) = 1
c
c 2.6. ==> correspondance entre le code des faces dans un volume
c          et l'orientation relative de cette face
c          Pour la face i de code c :
c            orcoxx(i,c) :  1, la face est sortante
c                          -1, la face est entrante
c 2.6.1. ==> tetraedre/triangle
c
      orcott(1,1) =  1
      orcott(1,2) =  1
      orcott(1,3) =  1
      orcott(1,4) = -1
      orcott(1,5) = -1
      orcott(1,6) = -1
c
      orcott(2,1) = -1
      orcott(2,2) = -1
      orcott(2,3) = -1
      orcott(2,4) =  1
      orcott(2,5) =  1
      orcott(2,6) =  1
c
      orcott(3,1) = -1
      orcott(3,2) = -1
      orcott(3,3) = -1
      orcott(3,4) =  1
      orcott(3,5) =  1
      orcott(3,6) =  1
c
      orcott(4,1) =  1
      orcott(4,2) =  1
      orcott(4,3) =  1
      orcott(4,4) = -1
      orcott(4,5) = -1
      orcott(4,6) = -1
c
c 2.6.3. ==> hexaedre/quadrangle
c
      orcoqh(1,1) = -1
      orcoqh(1,2) = -1
      orcoqh(1,3) = -1
      orcoqh(1,4) = -1
      orcoqh(1,5) =  1
      orcoqh(1,6) =  1
      orcoqh(1,7) =  1
      orcoqh(1,8) =  1
c
      orcoqh(2,1) = -1
      orcoqh(2,2) = -1
      orcoqh(2,3) = -1
      orcoqh(2,4) = -1
      orcoqh(2,5) =  1
      orcoqh(2,6) =  1
      orcoqh(2,7) =  1
      orcoqh(2,8) =  1
c
      orcoqh(3,1) = -1
      orcoqh(3,2) = -1
      orcoqh(3,3) = -1
      orcoqh(3,4) = -1
      orcoqh(3,5) =  1
      orcoqh(3,6) =  1
      orcoqh(3,7) =  1
      orcoqh(3,8) =  1
c
      orcoqh(4,1) = -1
      orcoqh(4,2) = -1
      orcoqh(4,3) = -1
      orcoqh(4,4) = -1
      orcoqh(4,5) =  1
      orcoqh(4,6) =  1
      orcoqh(4,7) =  1
      orcoqh(4,8) =  1
c
      orcoqh(5,1) = -1
      orcoqh(5,2) = -1
      orcoqh(5,3) = -1
      orcoqh(5,4) = -1
      orcoqh(5,5) =  1
      orcoqh(5,6) =  1
      orcoqh(5,7) =  1
      orcoqh(5,8) =  1
c
      orcoqh(6,1) = -1
      orcoqh(6,2) = -1
      orcoqh(6,3) = -1
      orcoqh(6,4) = -1
      orcoqh(6,5) =  1
      orcoqh(6,6) =  1
      orcoqh(6,7) =  1
      orcoqh(6,8) =  1
c
c 2.6.3. ==> pentaedre/triangle et pentaedre/quadrangle
c
      orcofp(1,1) = -1
      orcofp(1,2) = -1
      orcofp(1,3) = -1
      orcofp(1,4) =  1
      orcofp(1,5) =  1
      orcofp(1,6) =  1
c
      orcofp(2,1) = -1
      orcofp(2,2) = -1
      orcofp(2,3) = -1
      orcofp(2,4) =  1
      orcofp(2,5) =  1
      orcofp(2,6) =  1
c
      orcofp(3,1) = -1
      orcofp(3,2) = -1
      orcofp(3,3) = -1
      orcofp(3,4) = -1
      orcofp(3,5) =  1
      orcofp(3,6) =  1
      orcofp(3,7) =  1
      orcofp(3,8) =  1
c
      orcofp(4,1) = -1
      orcofp(4,2) = -1
      orcofp(4,3) = -1
      orcofp(4,4) = -1
      orcofp(4,5) =  1
      orcofp(4,6) =  1
      orcofp(4,7) =  1
      orcofp(4,8) =  1
c
      orcofp(5,1) = -1
      orcofp(5,2) = -1
      orcofp(5,3) = -1
      orcofp(5,4) = -1
      orcofp(5,5) =  1
      orcofp(5,6) =  1
      orcofp(5,7) =  1
      orcofp(5,8) =  1
c
c 2.6.4. ==> pyramide/triangle et pyramide/quadrangle
c
      orcofy(1,1) = -1
      orcofy(1,2) = -1
      orcofy(1,3) = -1
      orcofy(1,4) =  1
      orcofy(1,5) =  1
      orcofy(1,6) =  1
c
      orcofy(2,1) = -1
      orcofy(2,2) = -1
      orcofy(2,3) = -1
      orcofy(2,4) =  1
      orcofy(2,5) =  1
      orcofy(2,6) =  1
c
      orcofy(3,1) = -1
      orcofy(3,2) = -1
      orcofy(3,3) = -1
      orcofy(3,4) =  1
      orcofy(3,5) =  1
      orcofy(3,6) =  1
c
      orcofy(4,1) = -1
      orcofy(4,2) = -1
      orcofy(4,3) = -1
      orcofy(4,4) =  1
      orcofy(4,5) =  1
      orcofy(4,6) =  1
c
      orcofy(5,1) = -1
      orcofy(5,2) = -1
      orcofy(5,3) = -1
      orcofy(5,4) = -1
      orcofy(5,5) =  1
      orcofy(5,6) =  1
      orcofy(5,7) =  1
      orcofy(5,8) =  1
c
c====
c 3. manipulations numeriques
c====
c 3.1. ==> choix du 2nd chiffre entre 1 et 2
c
      fp0012(1) = 2
      fp0012(2) = 1
c
c 3.2. ==> choix du 3eme chiffre entre 1, 2 et 3
c
      fp0123(1,1) = iindef
      fp0123(1,2) = 3
      fp0123(1,3) = 2
      fp0123(2,1) = 3
      fp0123(2,2) = iindef
      fp0123(2,3) = 1
      fp0123(3,1) = 2
      fp0123(3,2) = 1
      fp0123(3,3) = iindef
c
c 3.3. ==> choix du 4eme chiffre entre 1, 2, 3 et 4
c
      do 33 , iaux = 1 , 4
        do 331 , jaux = 1 , 4
          do 3311 , kaux1 = 1 , 4
            tabaux(kaux1) = 0
 3311     continue
          tabaux(iaux) = 1
          tabaux(jaux) = 1
          do 3312 , kaux1 = 1 , 4
            if ( iaux.eq.jaux .or. jaux.eq.kaux1 .or.
     >           kaux1.eq.iaux ) then
              fp1234(iaux,jaux,kaux1) = iindef
            else
              do 3313 , kaux2 = 1 , 4
                if ( tabaux(kaux2).eq.0 .and. kaux2.ne.kaux1 ) then
                  fp1234(iaux,jaux,kaux1) = kaux2
                endif
 3313         continue
            endif
 3312     continue
  331   continue
   33 continue
c
c 3.4. ==> choix du 6eme chiffre entre 1, 2, 3, 4, 5 et 6
c
      do 34 , iaux = 1 , 6
        do 341 , jaux = 1 , 6
          do 3411 , kaux1 = 1 , 6
            do 3412 , kaux2 = 1 , 6
              do 3413 , kaux3 = 1 , 6
                tabaux(kaux3) = 0
 3413         continue
              tabaux(iaux) = 1
              tabaux(jaux) = 1
              tabaux(kaux1) = 1
              tabaux(kaux2) = 1
              do 3414 , kaux3 = 1 , 6
                if ( iaux.eq.jaux .or. iaux.eq.kaux1 .or.
     >               iaux.eq.kaux2 .or. jaux.eq.kaux1 .or.
     >               jaux.eq.kaux2 .or. kaux1.eq.kaux2 ) then
                  fp1aa6(iaux,jaux,kaux1,kaux2,kaux3) = iindef
                else
                  do 3415 , kaux4 = 1 , 6
                    if ( tabaux(kaux4).eq.0 .and. kaux4.ne.kaux3 ) then
                      fp1aa6(iaux,jaux,kaux1,kaux2,kaux3) = kaux4
                    endif
 3415             continue
                endif
 3414         continue
 3412       continue
 3411     continue
  341   continue
   34 continue
c
c 3.5. ==> dans la permutation circulaire (1,2,3) :
c          per1a3(-1,i) renvoie l'entier qui est avant i
c          per1a3( 0,i) renvoie l'entier i
c          per1a3( 1,i) renvoie l'entier qui est apres i
c          per1a3( 2,i) renvoie l'entier qui est 2 places apres i
c
      per1a3(-1,1) = 3
      per1a3(-1,2) = 1
      per1a3(-1,3) = 2
c
      per1a3( 0,1) = 1
      per1a3( 0,2) = 2
      per1a3( 0,3) = 3
c
      per1a3( 1,1) = 2
      per1a3( 1,2) = 3
      per1a3( 1,3) = 1
c
      per1a3( 2,1) = 3
      per1a3( 2,2) = 1
      per1a3( 2,3) = 2
c
c 3.6. ==> dans la permutation circulaire (1,2,3,4) :
c          . Pour i de 1 a 4 :
c            per1a4(-5,i) = 1 devient 2, puis sens inverse
c            per1a4(-4,i) = 1 devient 3, puis sens inverse
c            per1a4(-3,i) = 1 devient 4, puis sens inverse
c            per1a4(-2,i) = 1 idem, puis sens inverse
c            per1a4(-1,i) renvoie l'entier qui est avant i
c            per1a4( 0,i) renvoie l'entier i
c            per1a4( 1,i) renvoie l'entier qui est apres i
c            per1a4( 2,i) renvoie l'entier qui est 2 places apres i
c            per1a4( 3,i) renvoie l'entier qui est 3 places apres i
c          . Pour i =5 :
c            per1a4(j,5) = le reciproque de per1a4(j,*)
c
      per1a4(-5,1) = 2
      per1a4(-5,2) = 1
      per1a4(-5,3) = 4
      per1a4(-5,4) = 3
      per1a4(-5,5) = -5
c
      per1a4(-4,1) = 3
      per1a4(-4,2) = 2
      per1a4(-4,3) = 1
      per1a4(-4,4) = 4
      per1a4(-4,5) = -4
c
      per1a4(-3,1) = 4
      per1a4(-3,2) = 3
      per1a4(-3,3) = 2
      per1a4(-3,4) = 1
      per1a4(-3,5) = -3
c
      per1a4(-2,1) = 1
      per1a4(-2,2) = 4
      per1a4(-2,3) = 3
      per1a4(-2,4) = 2
      per1a4(-2,5) = -2
c
      per1a4(-1,1) = 4
      per1a4(-1,2) = 1
      per1a4(-1,3) = 2
      per1a4(-1,4) = 3
      per1a4(-1,5) = 3
c
      per1a4( 0,1) = 1
      per1a4( 0,2) = 2
      per1a4( 0,3) = 3
      per1a4( 0,4) = 4
      per1a4( 0,5) = 0
c
      per1a4( 1,1) = 2
      per1a4( 1,2) = 3
      per1a4( 1,3) = 4
      per1a4( 1,4) = 1
      per1a4( 1,5) = -1
c
      per1a4( 2,1) = 3
      per1a4( 2,2) = 4
      per1a4( 2,3) = 1
      per1a4( 2,4) = 2
      per1a4( 2,5) = 2
c
      per1a4( 3,1) = 4
      per1a4( 3,2) = 1
      per1a4( 3,3) = 2
      per1a4( 3,4) = 3
      per1a4( 3,5) = 1
c
c 3.7. ==> dans la permutation circulaire (4,5,6) :
c          per4a6(-1,i) = entier avant i
c          per4a6( 0,i) = i
c          per4a6( 1,i) = entier apres i
c          per4a6( 2,i) = entier 2 places apres i = per4a6(-1,i)
c
      per4a6(-1,4) = 6
      per4a6(-1,5) = 4
      per4a6(-1,6) = 5
c
      per4a6( 0,4) = 4
      per4a6( 0,5) = 5
      per4a6( 0,6) = 6
c
      per4a6( 1,4) = 5
      per4a6( 1,5) = 6
      per4a6( 1,6) = 4
c
      per4a6( 2,4) = 6
      per4a6( 2,5) = 4
      per4a6( 2,6) = 5
c
c 3.8. ==> per001 : etablissement des codes pour les raffinements
c                   conformes des pentaedres
c     remarque : per001(i,1) = i
c
      per001(1,1) = 1
      per001(1,2) = 2
      per001(1,3) = 3
      per001(1,4) = 4
      per001(1,5) = 5
      per001(1,6) = 6
c
      per001(2,1) = 2
      per001(2,2) = 3
      per001(2,3) = 1
      per001(2,4) = 6
      per001(2,5) = 4
      per001(2,6) = 5
c
      per001(3,1) = 3
      per001(3,2) = 1
      per001(3,3) = 2
      per001(3,4) = 5
      per001(3,5) = 6
      per001(3,6) = 4
c
      per001(4,1) = 4
      per001(4,2) = 5
      per001(4,3) = 6
      per001(4,4) = 1
      per001(4,5) = 2
      per001(4,6) = 3
c
      per001(5,1) = 5
      per001(5,2) = 6
      per001(5,3) = 4
      per001(5,4) = 3
      per001(5,5) = 1
      per001(5,6) = 2
c
      per001(6,1) = 6
      per001(6,2) = 4
      per001(6,3) = 5
      per001(6,4) = 2
      per001(6,5) = 3
      per001(6,6) = 1
c
c 3.9. ==> per002 : permutation circulaire des 8 permiers entiers,
c                   traites par paquet de 4
c     remarque : per002(i,1) = i
c
      per002(1,1) = 1
      per002(1,2) = 2
      per002(1,3) = 3
      per002(1,4) = 4
      per002(1,5) = 5
      per002(1,6) = 6
      per002(1,7) = 7
      per002(1,8) = 8
c
      per002(2,1) = 2
      per002(2,2) = 3
      per002(2,3) = 4
      per002(2,4) = 1
      per002(2,5) = 6
      per002(2,6) = 7
      per002(2,7) = 8
      per002(2,8) = 5
c
      per002(3,1) = 3
      per002(3,2) = 4
      per002(3,3) = 1
      per002(3,4) = 2
      per002(3,5) = 7
      per002(3,6) = 8
      per002(3,7) = 5
      per002(3,8) = 6
c
      per002(4,1) = 4
      per002(4,2) = 1
      per002(4,3) = 2
      per002(4,4) = 3
      per002(4,5) = 8
      per002(4,6) = 5
      per002(4,7) = 6
      per002(4,8) = 7
c
c====
c 4. description pour une connectivite a la med
c====
c
c 4.1. ==> prealable
c
      do 41 , iaux = 0 , 7
        do 411 , jaux = 1 , 6
          nofmed(iaux,jaux,1) = iindef
          nofmed(iaux,jaux,2) = iindef
          nofmed(iaux,jaux,3) = iindef
  411   continue
   41 continue
c
c 4.2. ==> tetraedre
c
      typenh = 3
      nofmed(typenh,1,1) = 1
      nofmed(typenh,2,1) = 2
      nofmed(typenh,3,1) = 3
      nofmed(typenh,4,1) = 4
c
      do 42 , jaux = 1 , 4
        iaux = nofmed(typenh,jaux,1)
        nofmed(typenh,iaux,2) = jaux
   42 continue
cgn      print *,(nofmed(typenh,jaux,2),jaux = 1 , 4)
c
c 4.3. ==> hexaedre
c
      typenh = 6
      nofmed(typenh,1,1) = 1
      nofmed(typenh,2,1) = 6
      nofmed(typenh,3,1) = 2
      nofmed(typenh,4,1) = 4
      nofmed(typenh,5,1) = 5
      nofmed(typenh,6,1) = 3
c
      do 43 , jaux = 1 , 6
        iaux = nofmed(typenh,jaux,1)
        nofmed(typenh,iaux,2) = jaux
   43 continue
cgn      print *,(nofmed(typenh,jaux,2),jaux = 1 , 6)
c
c 4.4. ==> pentaedre
c
      typenh = 7
      nofmed(typenh,1,1) = 1
      nofmed(typenh,2,1) = 2
      nofmed(typenh,3,1) = 3
      nofmed(typenh,4,1) = 4
      nofmed(typenh,5,1) = 5
c
      do 44 , jaux = 1 , 5
        iaux = nofmed(typenh,jaux,1)
        nofmed(typenh,iaux,2) = jaux
   44 continue
cgn      print *,(nofmed(typenh,jaux,2),jaux = 1 , 5)

c 4.5. ==> pyramide
c
      typenh = 5
      nofmed(typenh,1,1) = 5
      nofmed(typenh,2,1) = 1
      nofmed(typenh,3,1) = 2
      nofmed(typenh,4,1) = 3
      nofmed(typenh,5,1) = 4
c
      do 45 , jaux = 1 , 5
        iaux = nofmed(typenh,jaux,1)
        nofmed(typenh,iaux,2) = jaux
   45 continue
cgn      print *,(nofmed(typenh,jaux,2),jaux = 1 , 5)
c
c====
c 5. messages
c    remarque : le code doit etre le meme que pour suffix
c====
c
c                       12345678901234
      mess14(1,1,-1) = 'noeud         '
      mess14(1,1,0)  = 'maille-point  '
      mess14(1,1,1)  = 'segment       '
      mess14(1,1,2)  = 'triangle      '
      mess14(1,1,3)  = 'tetraedre     '
      mess14(1,1,4)  = 'quadrangle    '
      mess14(1,1,5)  = 'pyramide      '
      mess14(1,1,6)  = 'hexaedre      '
      mess14(1,1,7)  = 'pentaedre     '
      mess14(1,1,8)  = 'face          '
      mess14(1,1,9)  = 'volume        '
      mess14(1,1,10) = '  entite      '
      mess14(1,1,11) = 'provisoire    '
      mess14(1,1,12) = 'sans objet    '
      mess14(1,1,13) = 'maille        '
c
      mess14(1,2,-1) = 'Noeud         '
      mess14(1,2,0)  = 'Maille-Point  '
      mess14(1,2,1)  = 'Segment       '
      mess14(1,2,2)  = 'Triangle      '
      mess14(1,2,3)  = 'Tetraedre     '
      mess14(1,2,4)  = 'Quadrangle    '
      mess14(1,2,5)  = 'Pyramide      '
      mess14(1,2,6)  = 'Hexaedre      '
      mess14(1,2,7)  = 'Pentaedre     '
      mess14(1,2,8)  = 'Face          '
      mess14(1,2,9)  = 'Volume        '
      mess14(1,2,10) = '  Entite      '
      mess14(1,2,11) = 'Provisoire    '
      mess14(1,2,12) = 'Sans objet    '
      mess14(1,2,13) = 'Maille        '
c
      mess14(1,3,-1) = 'noeuds        '
      mess14(1,3,0)  = 'mailles-points'
      mess14(1,3,1)  = 'segments      '
      mess14(1,3,2)  = 'triangles     '
      mess14(1,3,3)  = 'tetraedres    '
      mess14(1,3,4)  = 'quadrangles   '
      mess14(1,3,5)  = 'pyramides     '
      mess14(1,3,6)  = 'hexaedres     '
      mess14(1,3,7)  = 'pentaedres    '
      mess14(1,3,8)  = 'faces         '
      mess14(1,3,9)  = 'volumes       '
      mess14(1,3,10) = 'entites       '
      mess14(1,3,11) = 'Provisoire    '
      mess14(1,3,12) = 'Sans objet    '
      mess14(1,3,13) = 'mailles       '
c
      mess14(1,4,-1) = 'Noeuds        '
      mess14(1,4,0)  = 'Mailles-Points'
      mess14(1,4,1)  = 'Segments      '
      mess14(1,4,2)  = 'Triangles     '
      mess14(1,4,3)  = 'Tetraedres    '
      mess14(1,4,4)  = 'Quadrangles   '
      mess14(1,4,5)  = 'Pyramides     '
      mess14(1,4,6)  = 'Hexaedres     '
      mess14(1,4,7)  = 'Pentaedres    '
      mess14(1,4,8)  = 'Faces         '
      mess14(1,4,9)  = 'Volumes       '
      mess14(1,4,10) = '  Entites     '
      mess14(1,4,11) = 'Provisoires   '
      mess14(1,4,12) = 'Sans objet    '
      mess14(1,4,13) = 'Mailles       '
c
      mess14(1,5,-1) = 'NOEUDS        '
      mess14(1,5,0)  = 'MAILLES-POINTS'
      mess14(1,5,1)  = 'SEGMENTS      '
      mess14(1,5,2)  = 'TRIANGLES     '
      mess14(1,5,3)  = 'TETRAEDRES    '
      mess14(1,5,4)  = 'QUADRANGLES   '
      mess14(1,5,5)  = 'PYRAMIDES     '
      mess14(1,5,6)  = 'HEXAEDRES     '
      mess14(1,5,7)  = 'PENTAEDRES    '
      mess14(1,5,8)  = 'FACES         '
      mess14(1,5,9)  = 'VOLUMES       '
      mess14(1,5,10) = '  ENTITES     '
      mess14(1,5,11) = 'PROVISOIRES   '
      mess14(1,5,12) = 'SANS OBJET    '
      mess14(1,5,13) = 'MAILLES       '
c
      mess14(2,1,-1) = 'node          '
      mess14(2,1,0)  = 'point-mesh    '
      mess14(2,1,1)  = 'edge          '
      mess14(2,1,2)  = 'triangle      '
      mess14(2,1,3)  = 'tetrahedron   '
      mess14(2,1,4)  = 'quadrangle    '
      mess14(2,1,5)  = 'pyramid       '
      mess14(2,1,6)  = 'hexahedron    '
      mess14(2,1,7)  = 'prism         '
      mess14(2,1,8)  = 'face          '
      mess14(2,1,9)  = 'volume        '
      mess14(2,1,10) = '  entity      '
      mess14(2,1,11) = 'temporary     '
      mess14(2,1,12) = 'useless       '
      mess14(2,1,13) = 'mesh          '
c
      mess14(2,2,-1) = 'Node          '
      mess14(2,2,0)  = 'Point-Mesh    '
      mess14(2,2,1)  = 'Edge          '
      mess14(2,2,2)  = 'Triangle      '
      mess14(2,2,3)  = 'Tetrahedron   '
      mess14(2,2,4)  = 'Quadrangle    '
      mess14(2,2,5)  = 'Pyramid       '
      mess14(2,2,6)  = 'Hexahedron    '
      mess14(2,2,7)  = 'Prism         '
      mess14(2,2,8)  = 'Face          '
      mess14(2,2,9)  = 'Volume        '
      mess14(2,2,10) = '  Entity      '
      mess14(2,2,11) = 'Temporary     '
      mess14(2,2,12) = 'Useless       '
      mess14(2,2,13) = 'Mesh          '
c
      mess14(2,3,-1) = 'nodes         '
      mess14(2,3,0)  = 'point-meshes  '
      mess14(2,3,1)  = 'edges         '
      mess14(2,3,2)  = 'triangles     '
      mess14(2,3,3)  = 'tetraedra     '
      mess14(2,3,4)  = 'quadrangles   '
      mess14(2,3,5)  = 'pyramids      '
      mess14(2,3,6)  = 'hexahedrons   '
      mess14(2,3,7)  = 'prisms        '
      mess14(2,3,8)  = 'faces         '
      mess14(2,3,9)  = 'volumes       '
      mess14(2,3,10) = 'entities      '
      mess14(2,3,11) = 'Temporary     '
      mess14(2,3,12) = 'Useless       '
      mess14(2,3,13) = 'meshes        '
c
      mess14(2,4,-1) = 'Nodes         '
      mess14(2,4,0)  = 'Point-Meshes  '
      mess14(2,4,1)  = 'Edges         '
      mess14(2,4,2)  = 'Triangles     '
      mess14(2,4,3)  = 'Tetraedra     '
      mess14(2,4,4)  = 'Quadrangles   '
      mess14(2,4,5)  = 'Pyramids      '
      mess14(2,4,6)  = 'Hexahedrons   '
      mess14(2,4,7)  = 'Prisms        '
      mess14(2,4,8)  = 'Faces         '
      mess14(2,4,9)  = 'Volumes       '
      mess14(2,4,10) = '  Entities    '
      mess14(2,4,11) = 'Temporary     '
      mess14(2,4,12) = 'Useless       '
      mess14(2,4,13) = 'Meshes        '
c
      mess14(2,5,-1) = 'NODES         '
      mess14(2,5,0)  = 'POINT-MESHES  '
      mess14(2,5,1)  = 'EDGES         '
      mess14(2,5,2)  = 'TRIANGLES     '
      mess14(2,5,3)  = 'TETRAEDRA     '
      mess14(2,5,4)  = 'QUADRANGLES   '
      mess14(2,5,5)  = 'PYRAMIDS      '
      mess14(2,5,6)  = 'HEXAHEDRONS   '
      mess14(2,5,7)  = 'PRISMS        '
      mess14(2,5,8)  = 'FACES         '
      mess14(2,5,9)  = 'VOLUMES       '
      mess14(2,5,10) = '  ENTITIES    '
      mess14(2,5,11) = 'TEMPORARY     '
      mess14(2,5,12) = 'USELESS       '
      mess14(2,5,13) = 'MESHES        '
c                       12345678901234
c
c====
c 6. type gm
c    remarque : le code doit etre le meme que pour mess14
c====
c
c                     12345678
      suffix(1,-1) = 'Noeud   '
      suffix(1,0)  = 'Point   '
      suffix(1,1)  = 'Arete   '
      suffix(1,2)  = 'Trian   '
      suffix(1,3)  = 'Tetra   '
      suffix(1,4)  = 'Quadr   '
      suffix(1,5)  = 'Pyram   '
      suffix(1,6)  = 'Hexae   '
      suffix(1,7)  = 'Penta   '
      suffix(1,8)  = '        '
      suffix(1,9)  = '        '
      suffix(1,10) = '        '
c
      suffix(2,-1) = 'noeu    '
      suffix(2,0)  = 'poin    '
      suffix(2,1)  = 'aret    '
      suffix(2,2)  = 'tria    '
      suffix(2,3)  = 'tetr    '
      suffix(2,4)  = 'quad    '
      suffix(2,5)  = 'pyra    '
      suffix(2,6)  = 'hexa    '
      suffix(2,7)  = 'pent    '
      suffix(2,8)  = '        '
      suffix(2,9)  = '        '
      suffix(2,10) = '        '
c                     12345678
      suffix(3,-1) = 'No      '
      suffix(3,0)  = 'MP      '
      suffix(3,1)  = 'Ar      '
      suffix(3,2)  = 'Tr      '
      suffix(3,3)  = 'Te      '
      suffix(3,4)  = 'Qu      '
      suffix(3,5)  = 'Py      '
      suffix(3,6)  = 'He      '
      suffix(3,7)  = 'Pe      '
      suffix(3,8)  = '        '
      suffix(3,9)  = '        '
      suffix(3,10) = '        '
c                     12345678
      suffix(4,-1) = 'no      '
      suffix(4,0)  = 'mp      '
      suffix(4,1)  = 'ar      '
      suffix(4,2)  = 'tr      '
      suffix(4,3)  = 'te      '
      suffix(4,4)  = 'qu      '
      suffix(4,5)  = 'py      '
      suffix(4,6)  = 'he      '
      suffix(4,7)  = 'pe      '
      suffix(4,8)  = '        '
      suffix(4,9)  = '        '
      suffix(4,10) = '        '
c
c====
c 7. fonctions pour la conformite des hexaedres
c====
c
#include "hexcf2.h"
c
c====
c 8. Caracteristiques des familles :
c====
c 8.1. ==> initialisation des nombres maximaux de familles
c
      nbfarm = 20000
      nbftrm = 20000
      nbfqum = 20000
c
#ifdef _DEBUG_HOMARD_
      write (*,90002) 'nbfarm', nbfarm
      write (*,90002) 'nbftrm', nbftrm
      write (*,90002) 'nbfqum', nbfqum
#endif
c
c 8.2. ==> Caracteristiques par type de mailless
c
c  noeuds          1 : famille MED
c                 Si extrusion :
c                  2 : famille du noeud translate dans l'extrusion
c                  3 : famille de l'arete creee dans l'extrusion
c                  4 : position du noeud
c                 Si equivalence :
c                + l : appartenance a l'equivalence l
c
c  mailles-points  1 : famille MED
c                  2 : type de maille-point
c                  3 : famille du sommet support
c                + l : appartenance a l'equivalence l
c
c  aretes          1 : famille MED
c                  2 : type de segment
c                  3 : orientation
c                  4 : famille d'orientation inverse
c                  5 : numero de ligne de frontiere
c                       > 0 si arete concernee par le suivi de frontiere
c                      <= 0 si non concernee
c                  6 : famille de suivi de frontiere active/inactive
c                  7 : numero de surface de frontiere
c                 Si extrusion :
c                  8 : famille de l'arete translatee dans l'extrusion
c                  9 : famille du quadrangle cree dans l'extrusion
c                 10 : position de l'arete
c                 Si equivalence :
c                + l : appartenance a l'equivalence l
c
c  triangles       1 : famille MED
c                  2 : type de triangle
c                  3 : numero de surface de frontiere
c                  4 : famille des aretes internes apres raf
c                 Si extrusion :
c                  5 : famille du triangle translate dans l'extrusion
c                  6 : famille du pentaedre cree dans l'extrusion
c                  7 : orientation du triangle face du pentaedre
c                  8 : position du triangle
c                 Si equivalence :
c                + l : appartenance a l'equivalence l
c
c  quadrangles     1 : famille MED
c                  2 : type de quadrangle
c                  3 : numero de surface de frontiere
c                  4 : famille des aretes internes apres raf
c                  5 : famille des triangles de conformite
c                  6 : famille de suivi de frontiere active/inactive
c                 Si extrusion :
c                  7 : famille du quadrangle translate dans l'extrusion
c                  8 : famille de l'hexaedre cree dans l'extrusion
c                  9 : orientation du quadrangle face de l'hexaedre
c                 10 : position du quadrangle
c                 Si equivalence :
c                + l : appartenance a l'equivalence l
c
c  tetraedres      1 : famille MED
c                  2 : type de tetraedres
c
c  hexaedres       1 : famille MED
c                  2 : type de hexaedres
c                  3 : famille des tetraedres de conformite
c                  4 : famille des pyramides de conformite
c
c  pyramides       1 : famille MED
c                  2 : type de pyramides
c
c  pentaedres      1 : famille MED
c                  2 : type de pentaedres
c                  3 : famille des tetraedres de conformite
c                  4 : famille des pyramides de conformite
c====
c
      ncffno = 1
      ncffmp = 3
      ncffar = 7
      ncfftr = 4
      ncffqu = 6
      ncffte = 2
      ncffhe = 4
      ncffpy = 2
      ncffpe = 4
c
#ifdef _DEBUG_HOMARD_
      write (*,90002) 'ncffno', ncffno
      write (*,90002) 'ncffmp', ncffmp
      write (*,90002) 'ncffar', ncffar
      write (*,90002) 'ncfftr', ncfftr
      write (*,90002) 'ncffqu', ncffqu
      write (*,90002) 'ncffte', ncffte
      write (*,90002) 'ncffhe', ncffhe
      write (*,90002) 'ncffpy', ncffpy
      write (*,90002) 'ncffpe', ncffpe
#endif
c
      ncxfno = 3
      ncxfar = 3
      ncxftr = 4
      ncxfqu = 4
c
#ifdef _DEBUG_HOMARD_
      write (*,90002) 'ncxfno', ncxfno
      write (*,90002) 'ncxfar', ncxfar
      write (*,90002) 'ncxftr', ncxftr
      write (*,90002) 'ncxfqu', ncxfqu
#endif
c
      nctfno = ncffno
      nctfmp = ncffmp
      nctfar = ncffar
      nctftr = ncfftr
      nctfqu = ncffqu
      nctfte = ncffte
      nctfhe = ncffhe
      nctfpy = ncffpy
      nctfpe = ncffpe
c
      end
