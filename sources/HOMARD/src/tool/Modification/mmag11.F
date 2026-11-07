      subroutine mmag11 ( somare,
     >                    aretri,
     >                    tritet, cotrte,
     >                    nbpejs, tbaux1, tbaux2,
     >                    tbau30, tbau40,
     >                    nbduno, nbduar, nbdutr,
     >                    indnoe, indare,
     >                    ulsort, langue, codret )
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
c    Modification de Maillage - AGregat - phase 1.1
c    -               -          --              - -
c    Connaissant le nombre et les caracteristiques des pentaedres
c    a creer pour les joints simples :
c    . Liste des duplications de noeuds avec pour chacune d'elles :
c      - numero du noeud a dupliquer
c      - numero de l'arete entre les noeuds doubles
c      - numero des 2 noeuds doubles a creer
c      - numero du joint simple exigeant la duplication
c    . Liste des duplications d'aretes avec pour chacune d'elles :
c      - numero de l'arete entre les noeuds doubles
c      - numero des 2 aretes doubles a creer
c      - numero du joint simple exigeant la duplication
c    . Decompte du nombre de duplications de noeuds, d'aretes et
c      de triangles
c    . Numero du dernier noeud cree
c    . Numero de la derniere arete creee
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . somare . e   .2*nbarto. numeros des extremites d'arete             .
c . aretri . e   .nbtrto*3. numeros des 3 aretes des triangles         .
c . tritet . e   .nbtecf*4. numeros des 4 triangles des tetraedres     .
c . cotrte . e   .nbtecf*4. codes des 4 triangles des tetraedres       .
c . nbpejs . e   .   1    . nombre de pentaedres de joints simples     .
c . tbaux1 . e   .4*nbpejs. Pour le i-eme pentaedre de joint simple :  .
c .        .     .        . (1,i) : numero du triangle a dupliquer     .
c .        .     .        . (2,i) : numero du joint simple cree        .
c .        .     .        . (3,i) : tetraedre du cote min(fammed)      .
c .        .     .        . (4,i) : tetraedre du cote max(fammed)      .
c . tbaux2 . e   .   4**  . Pour le i-eme joint :                      .
c .        .     .        . Numeros des familles MED des volumes       .
c .        .     .        . jouxtant le pentaedre/hexaedre, classes du .
c .        .     .        . plus petit (1,i) au plus grand             .
c .        .     .        . 0, si pas de volume voisin                 .
c . tbau30 .   s .   8**  . Pour la i-eme duplication de noeud :       .
c .        .     .        . (1,i) : noeud a dupliquer                  .
c .        .     .        . (2,i) : arete construite sur le noeud      .
c .        .     .        . (3,i) : noeud cree cote min(fammed)        .
c .        .     .        . (4,i) : noeud cree cote max(fammed)        .
c .        .     .        . (5,i) : numero du joint simple cree        .
c .        .     .        . (6,i) : arete entrant dans le cote 1       .
c .        .     .        . (7,i) : arete entrant dans le cote 2       .
c .        .     .        . (8,i) : ordre de multiplicite              .
c . tbau40 .   s .   6**  . Pour la i-eme duplication d'arete :        .
c .        .     .        . (1,i) : arete a dupliquer                  .
c .        .     .        . (2,i) : arete creee cote min(fammed)       .
c .        .     .        . (3,i) : arete creee cote max(fammed)       .
c .        .     .        . (4,i) : numero du joint simple cree        .
c .        .     .        . (5,i) : ordre de multiplicite              .
c .        .     .        . (6,i) : arete d'orientation de joint       .
c . nbduno .  s  .   1    . nombre de duplications de noeuds           .
c . nbduar .  s  .   1    . nombre de duplications d'aretes            .
c . nbdutr .  s  .   1    . nombre de duplications de triangles        .
c . indnoe . es  .   1    . dernier noeud a creer                      .
c . indare . es  .   1    . derniere arete a creer                     .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
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
      character*6 nompro
      parameter ( nompro = 'MMAG11' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
#include "impr02.h"
c
#include "nombar.h"
#include "nombtr.h"
#include "nombte.h"
c
c 0.3. ==> arguments
c
      integer somare(2,nbarto)
      integer aretri(nbtrto,3)
      integer tritet(nbtecf,4), cotrte(nbtecf,4)
      integer nbpejs
      integer tbaux1(4,nbpejs), tbaux2(4,*)
      integer tbau30(8,*), tbau40(6,*)
c
      integer nbduno, nbduar, nbdutr
      integer indnoe, indare
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux, kaux, laux
      integer letria
      integer letetr, listar(6)
      integer laret0(2), laret1(2)
      integer lenoe0(2)
      integer nujois, nujoi0
      integer fammed(2)
      integer som1, arejnt
c
      integer are(3), som(3)
c
      integer nbmess
      parameter ( nbmess = 40 )
      character*80 texte(nblang,nbmess)
c
c 0.5. ==> initialisations
c ______________________________________________________________________
c
c====
c 1. prealables
c====
c 1.1. ==> messages
c
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
#include "mmag01.h"
#include "impr03.h"
c
      texte(1,31) = '(''   ==> '',a,''en lien :'',2i8)'
c
      texte(2,31) = '(''   ==> connected '',a,'':'',2i8)'
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,7)) mess14(langue,3,7), nbpejs
#endif
c
c 1.2. ==> Constantes
c
      codret = 0
c
      nbduno = 0
      nbduar = 0
      nbdutr = nbpejs
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,8)) mess14(langue,3,2), nbdutr
#endif
c
c====
c 2. Parcours des pentaedres a creer pour noter les aretes a dupliquer
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,5)) mess14(langue,3,7)//' - ar dupl'
#endif
c
      if ( codret.eq.0 ) then
c
      do 2 , iaux = 1 , nbpejs
c
        letria = tbaux1(1,iaux)
        nujois = tbaux1(2,iaux)
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) '. ', mess14(langue,1,2), letria
#endif
c
        do 21 , jaux = 1 , 3
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) '.. ',mess14(langue,1,1),
     >                               aretri(letria,jaux)
#endif
c
c 2.1.1. ==> Si l'arete a deja ete dupliquee pour ce joint, on
c            passe a la suite
c
          do 211  , kaux = 1 , nbduar
c
            if ( tbau40(1,kaux).eq.aretri(letria,jaux) .and.
     >           tbau40(4,kaux).eq.nujois ) then
              goto 21
            endif
c
  211     continue
c
c 2.1.2. ==> L'arete est a dupliquer.
c            On repere si elle l'a deja ete pour un des cotes.
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,9)) mess14(langue,1,1),
     >                               aretri(letria,jaux)
#endif
c
          fammed(1) = tbaux2(1,nujois)
          fammed(2) = tbaux2(2,nujois)
cgn          write(ulsort,*) fammed
          do 212  , laux = 1 , 2
            do 2121  , kaux = 1 , nbduar
cgn            write(ulsort,*) kaux, tbau40(1,kaux),tbau40(4,kaux)
              if ( tbau40(1,kaux).eq.aretri(letria,jaux) ) then
                nujoi0 = tbau40(4,kaux)
                if ( tbaux2(1,nujoi0).eq.fammed(laux) ) then
                  laret0(laux) = tbau40(2,kaux)
                  goto 212
                elseif ( tbaux2(2,nujoi0).eq.fammed(laux) ) then
                  laret0(laux) = tbau40(3,kaux)
                  goto 212
                endif
              endif
 2121       continue
            indare = indare + 1
            laret0(laux) = indare
  212     continue
c
c 2.1.3. ==> Le triangle est a dupliquer pour le joint en cours.
c            L'arete dupliquee est tbau40(1,kaux). On cherche l'autre
c            arete du triangle dont une extremite est le point de depart
c            de cette arete dupliquee. Cela servira a orienter les
c            joints multiples.
c
          som1 = somare(1,aretri(letria,jaux))
          do 213 , kaux = 1 ,3
            if ( kaux.ne.jaux ) then
              if ( som1.eq.somare(1,aretri(letria,kaux)) .or.
     >             som1.eq.somare(2,aretri(letria,kaux)) ) then
                arejnt = aretri(letria,kaux)
              endif
            endif
  213     continue
c
c 2.1.4. ==> Enregistrement
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,31)) mess14(langue,3,1), laret0
#endif
          nbduar = nbduar + 1
          tbau40(1,nbduar) = aretri(letria,jaux)
          tbau40(2,nbduar) = laret0(1)
          tbau40(3,nbduar) = laret0(2)
          tbau40(4,nbduar) = nujois
          tbau40(6,nbduar) = arejnt
c
   21   continue
c
    2 continue
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,8)) mess14(langue,3,1), nbduar
      write (ulsort,texte(langue,7)) mess14(langue,3,4), nbduar
#endif
c
      endif
c
c====
c 3. Parcours des pentaedres a creer pour noter les aretes a creer
c    Remarque : on le fait en deux fois pour gerer les numerotations
c               des aretes de manieres independantes : d'abord celles
c               issues de duplication, ensuite celles issues de
c               duplications de noeuds
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,5)) mess14(langue,3,7)//' - ar crea'
#endif
c
      if ( codret.eq.0 ) then
c
      do 3 , iaux = 1 , nbpejs
c
        letria = tbaux1(1,iaux)
        nujois = tbaux1(2,iaux)
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) '. ', mess14(langue,1,2), letria
#endif
c
c 3.1. ==> Aretes et les sommets
c
        are(1) = aretri(letria,1)
        are(2) = aretri(letria,2)
        are(3) = aretri(letria,3)
c
        call utsotr ( somare, are(1), are(2), are(3),
     >                som(1), som(2), som(3) )
c
c 3.2. ==> Les noeuds
c
        do 32  , jaux = 1 , 3
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) '..',mess14(langue,1,-1),som(jaux)
#endif
c
c 3.2.1. ==> Si le noeud a deja ete duplique pour ce joint, on
c            passe a la suite
c
          do 321  , kaux = 1 , nbduno
c
            if ( tbau30(1,kaux).eq.som(jaux) .and.
     >           tbau30(5,kaux).eq.nujois ) then
cgn              write(ulsort,*) '.... noeud deja duplique'
              goto 32
            endif
c
  321   continue
c
c 3.2.2. ==> Le noeud est a dupliquer.
c            On repere si il l'a deja ete pour un des cotes.
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,9)) mess14(langue,1,-1), som(jaux)
#endif
          fammed(1) = tbaux2(1,nujois)
          fammed(2) = tbaux2(2,nujois)
cgn          write(ulsort,*) 'fammed des 2 cotes', fammed
          do 322 , laux = 1 , 2
            do 3221 , kaux = 1 , nbduno
cgn              write(ulsort,*) 'Duplication nro', kaux
cgn      write(ulsort,*)'no dup', tbau30(1,kaux), ', j simp',tbau30(5,kaux)
              if ( tbau30(1,kaux).eq.som(jaux) ) then
                nujoi0 = tbau30(5,kaux)
cgn              write(ulsort,*) 'Joint nro', nujoi0
cgn      write(ulsort,*) 'avec fammed',tbaux2(1,nujoi0),tbaux2(2,nujoi0)
                if ( tbaux2(1,nujoi0).eq.fammed(laux) ) then
                  lenoe0(laux) = tbau30(3,kaux)
                  goto 322
                elseif ( tbaux2(2,nujoi0).eq.fammed(laux) ) then
                  lenoe0(laux) = tbau30(4,kaux)
                  goto 322
                endif
              endif
 3221       continue
            indnoe = indnoe + 1
            lenoe0(laux) = indnoe
  322     continue
c
c 3.2.3. ==> Reperage de l'arete partant du noeud vers le volume
c
          do 323 , kaux = 1 , 2
c
            letetr = tbaux1(2+kaux,iaux)
            call utarte ( letetr,
     >                    nbtrto, nbtecf,
     >                    aretri, tritet, cotrte,
     >                    listar )
cgn            write(ulsort,90002) mess14(langue,4,1)//'du noeud', listar
c
            do 3231 , laux = 1 , 6
c
              if ( listar(laux).ne.are(1) .and.
     >             listar(laux).ne.are(2) .and.
     >             listar(laux).ne.are(3) ) then
cgn             write(ulsort,90002) mess14(langue,2,1), listar(laux)
               if ( somare(1,listar(laux)).eq.som(jaux) ) then
                 laret1(kaux) = listar(laux)
               elseif ( somare(2,listar(laux)).eq.som(jaux) ) then
                 laret1(kaux) = -listar(laux)
               endif
             endif
c
 3231      continue
c
  323   continue
c
c 3.2.4. ==> Enregistrement
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,31)) mess14(langue,3,-1), lenoe0
      write (ulsort,texte(langue,31)) mess14(langue,1,1), indare+1
#endif
          indare = indare + 1
          nbduno = nbduno + 1
          tbau30(1,nbduno) = som(jaux)
          tbau30(2,nbduno) = indare
          tbau30(3,nbduno) = lenoe0(1)
          tbau30(4,nbduno) = lenoe0(2)
          tbau30(5,nbduno) = nujois
          tbau30(6,nbduno) = laret1(1)
          tbau30(7,nbduno) = laret1(2)
c
   32   continue
c
    3 continue
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,8)) mess14(langue,3,-1), nbduno
      write (ulsort,texte(langue,7)) mess14(langue,3,1), nbduno
#endif
c
      endif
c
c====
c 4. la fin
c====
c
      if ( codret.ne.0 ) then
c
#include "envex2.h"
c
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      write (ulsort,texte(langue,2)) codret
c
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      call dmflsh (iaux)
#endif
c
      end
