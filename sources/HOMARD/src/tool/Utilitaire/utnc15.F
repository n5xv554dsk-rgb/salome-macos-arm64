      subroutine utnc15 ( nbnocq, qureca, qurecb,
     >                    somare, arequa,
     >                    nounoe, tabaux,
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
c    UTilitaire - Non Conformite - phase 15
c    --           -   -                  --
c    On cherche le numero du noeud central des faces recouvrantes
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nbnocq . e   .    1   . nombre de non conformites de quadrangles   .
c . qureca . e   .4*nbnocq. liste des quad. recouvrant un autre        .
c . qurecb . e   .4*nbnocq. liste des quad. recouverts par un autre    .
c . somare . e   .2*nbarto. numeros des extremites d'arete             .
c . arequa . e   .nbquto*4. numeros des 4 aretes des quadrangles       .
c . nounoe .  s  . nbnoto . nouveau numero des noeuds                  .
c . tabaux . a   .5*nbnocq. tableau auxiliaire                         .
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
      parameter ( nompro = 'UTNC15' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "impr02.h"
#include "nombno.h"
#include "nombar.h"
#include "nombqu.h"
c
c 0.3. ==> arguments
c
      integer nbnocq
      integer qureca(4*nbnocq), qurecb(4*nbnocq)
      integer somare(2,nbarto)
      integer arequa(nbquto,4)
      integer nounoe(0:nbnoto)
      integer tabaux(*)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux, kaux
      integer ifin
      integer numqua, lequad(4), lepere
      integer arequ1(4), arequ2(4), arequ3(4)
      integer arco12, arco23, noecom, nbnoce
      integer a1, a2, a3, a4
      integer sa1a2, sa2a3, sa3a4, sa4a1
c
      integer nbmess
      parameter ( nbmess = 10 )
      character*80 texte(nblang,nbmess)
c
c 0.5. ==> initialisations
c ______________________________________________________________________
c
c====
c 1. preliminaires
c====
c
c 1.1. ==> messages
c
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
      texte(1,4) = '(''Examen du '',a,'' numero'',i10)'
      texte(1,5) = '(''.. couvert par le '',a,'' numero'',i10)'
      texte(1,6) = '(''.. couvrant le '',a,'' numero'',4i10)'
      texte(1,7) = '(''dont les '',a,'' sont :'',4i10)'
      texte(1,8) = '(''Aucun '',a,'' en commun.'')'
      texte(1,9) = '(''Ce noeud n''''appartient pas au '',a)'
      texte(1,10) = '(a,'' commun :'',i10)'
c
      texte(2,4) = '(''Examination of '',a,'' #'',i10)'
      texte(2,5) = '(''.. covered by '',a,'' #'',i10)'
      texte(2,6) = '(''.. covering '',a,'' #'',4i10)'
      texte(2,7) = '(''with '',a,'' # :'',4i10)'
      texte(2,8) = '(''No common '',a,''.'')'
      texte(2,9) = '(''That node does not belong to '',a)'
      texte(2,10) = '(''Common '',a,'' :'',i10)'
c
#include "impr03.h"
c
      codret = 0
c
c====
c 2. On explore les paquets de 4 quadrangles recouverts
c====
c
      nbnoce = 0
      numqua = 1
      lequad(numqua) = qurecb(1)
      lepere = qureca(1)
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) mess14(langue,1,4), lepere
      write (ulsort,texte(langue,6)) mess14(langue,1,4), qurecb(1)
#endif
c
      ifin = 4*nbnocq
      do 21 , iaux = 2 , ifin
c
c 2.1. ==> On cherche jusqu'a avoir trouve 4 quadrangles consecutifs
c          recouverts par le meme autre
c
        if ( codret.eq.0 ) then
c
        if ( qureca(iaux).eq.lepere ) then
          numqua = numqua + 1
          lequad(numqua) = qurecb(iaux)
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,6)) mess14(langue,1,4), qurecb(iaux)
#endif
        else
          numqua = 1
          lequad(numqua) = qurecb(iaux)
          lepere = qureca(iaux)
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) mess14(langue,1,4), lepere
      write (ulsort,texte(langue,6)) mess14(langue,1,4), qurecb(iaux)
#endif
        endif
c
        endif
c
c 2.2. ==> On cherche le noeud commun aux 4 quadrangles
c
        if ( numqua.eq.4 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) mess14(langue,4,4),
     >                     (lequad(kaux),kaux=1,numqua)
#endif
c
c 2.2.0. ==> On passe par des tableaux locaux pour les numeros
c            d'arete pour eviter les problemes d'optimisation
c            avec le compilateur intel ...
c
          do 220 , kaux = 1 , 4
            arequ1(kaux) = arequa(lequad(1),kaux)
            arequ2(kaux) = arequa(lequad(2),kaux)
            arequ3(kaux) = arequa(lequad(3),kaux)
  220     continue

c
c 2.2.1. ==> L'arete commune aux 1er et 2nd quadrangle
c
          if ( codret.eq.0 ) then
c
          arco12 = 0
          do 221 , kaux = 1 , 4
            if ( ( arequ1(kaux).eq.arequ2(1) ) .or.
     >           ( arequ1(kaux).eq.arequ2(2) ) .or.
     >           ( arequ1(kaux).eq.arequ2(3) ) .or.
     >           ( arequ1(kaux).eq.arequ2(4) ) ) then
              arco12 = arequ1(kaux)
            endif
  221     continue
c
#ifdef _DEBUG_HOMARD_
c
#else
          if ( arco12.eq.0 ) then
#endif
            write (ulsort,texte(langue,4)) mess14(langue,1,4), lequad(1)
            write (ulsort,texte(langue,7)) mess14(langue,3,1),
     >                   (arequa(lequad(1),kaux),kaux=1,4)
            write (ulsort,texte(langue,4)) mess14(langue,1,4), lequad(2)
            write (ulsort,texte(langue,7)) mess14(langue,3,1),
     >                   (arequa(lequad(2),kaux),kaux=1,4)
            write (ulsort,texte(langue,10)) mess14(langue,2,1), arco12
#ifdef _DEBUG_HOMARD_
c
#else
          endif
#endif
          if ( arco12.eq.0 ) then
            write (ulsort,texte(langue,8)) mess14(langue,1,1)
            codret = 1
          endif
c
          endif
c
c 2.2.2. ==> L'arete commune aux 2nd et 3eme quadrangle
c
          if ( codret.eq.0 ) then
c
          arco23 = 0
          do 222 , kaux = 1 , 4
            if ( ( arequ3(kaux).eq.arequ2(1) ) .or.
     >           ( arequ3(kaux).eq.arequ2(2) ) .or.
     >           ( arequ3(kaux).eq.arequ2(3) ) .or.
     >           ( arequ3(kaux).eq.arequ2(4) ) ) then
              arco23 = arequ3(kaux)
            endif
  222     continue
c
#ifdef _DEBUG_HOMARD_
c
#else
          if ( arco23.eq.0 ) then
#endif
            write (ulsort,texte(langue,4)) mess14(langue,1,4), lequad(2)
            write (ulsort,texte(langue,7)) mess14(langue,3,1),
     >                   (arequa(lequad(2),kaux),kaux=1,4)
            write (ulsort,texte(langue,4)) mess14(langue,1,4), lequad(3)
            write (ulsort,texte(langue,7)) mess14(langue,3,1),
     >                   (arequa(lequad(3),kaux),kaux=1,4)
            write (ulsort,texte(langue,10)) mess14(langue,2,1), arco23
#ifdef _DEBUG_HOMARD_
c
#else
          endif
#endif
          if ( arco23.eq.0 ) then
            write (ulsort,texte(langue,8)) mess14(langue,1,1)
            codret = 1
          endif
c
          endif
c
c 2.2.3. ==> Le noeud commun est le noeud commun a ces 2 aretes
c
          if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
          write (ulsort,texte(langue,10)) mess14(langue,2,1), arco12
          write (ulsort,texte(langue,10)) mess14(langue,2,1), arco23
#endif
          if ( somare(1,arco12).eq.somare(1,arco23) .or.
     >         somare(1,arco12).eq.somare(2,arco23) ) then
            noecom = somare(1,arco12)
          elseif ( somare(2,arco12).eq.somare(1,arco23) .or.
     >             somare(2,arco12).eq.somare(2,arco23) ) then
            noecom = somare(2,arco12)
          else
            write (ulsort,texte(langue,8)) mess14(langue,1,-1)
            codret = 223
          endif
#ifdef _DEBUG_HOMARD_
          write (ulsort,texte(langue,10)) mess14(langue,2,-1), noecom
#endif
          nbnoce = nbnoce + 1
          tabaux(nbnoce) = noecom
c
          endif
c
c 2.2.3. ==> On verifie que ce noeud commun appartient bien au dernier
c            quadrangle de la fratrie
c
          if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) mess14(langue,1,4), lequad(4)
#endif
          a1 = arequa(lequad(4),1)
          a2 = arequa(lequad(4),2)
          a3 = arequa(lequad(4),3)
          a4 = arequa(lequad(4),4)
c
          call utsoqu ( somare, a1, a2, a3, a4,
     >                  sa1a2, sa2a3, sa3a4, sa4a1 )
c
          if ( ( noecom.ne.sa1a2 ) .and.
     >         ( noecom.ne.sa2a3 ) .and.
     >         ( noecom.ne.sa3a4 ) .and.
     >         ( noecom.ne.sa4a1 ) ) then
          write (ulsort,texte(langue,4)) mess14(langue,1,4),
     >                 lequad(4)
          write (ulsort,texte(langue,7)) mess14(langue,3,-1),
     >                 sa1a2, sa2a3, sa3a4, sa4a1
          write (ulsort,texte(langue,10)) mess14(langue,2,-1), noecom
          write (ulsort,texte(langue,9)) mess14(langue,1,4)
            codret = 1
          endif
c
          endif
c
        endif
c
   21 continue
c
c====
c 3. Etablissement de la table de renumerotation des noeuds
c    Les noeuds communs doivent etre mis au bout de la numerotation.
c    On descend les autres numeros d'autant.
c    Attention a ne pas permuter brutalement car les actuels grands
c    numeros le sont du fait de la renumerotation precedente. Ils
c    doivent donc rester grands, juste avant ceux que l'on traite ici.
c    Exemple :
c    On veut repousser les noeuds 4, 2 et 8 sur les 20 possibles.
c    1  2  3  4  5  6  7  8  9 10 11 12 13 14 15 16 17 18 19 20
c    Etapes de 'do 32' :
c    ... pour tabaux(1) = 4
c    1  2  3  4  4  5  6  7  8  9 10 11 12 13 14 15 16 17 18 19
c    ... pour tabaux(2) = 2
c    1  2  2  3  3  4  5  6  7  8  9 10 11 12 13 14 15 16 17 18
c    ... pour tabaux(3) = 8
c    1  2  2  3  3  4  5  6  6  7  8  9 10 11 12 13 14 15 16 17
c    Etapes de 'do 33' :
c    ... pour tabaux(1) = 4
c    1  2  2 20  3  4  5  6  6  7  8  9 10 11 12 13 14 15 16 17
c    ... pour tabaux(2) = 2
c    1 19  2 20  3  4  5  6  6  7  8  9 10 11 12 13 14 15 16 17
c    ... pour tabaux(3) = 8
c    1 19  2 20  3  4  5 18  6  7  8  9 10 11 12 13 14 15 16 17
c====
c
      if ( codret.eq.0 ) then
c
c 3.1. ==> Aucune renumerotation au depart
c
      do 31 , iaux = 0 , nbnoto
        nounoe(iaux) = iaux
   31 continue
c
c 3.2. ==> Pour chaque noeud de numero superieur a un noeud a bouger,
c          on diminue de 1 son rang
c
cgn      write(ulsort,*) 'nbnoce = ',nbnoce
cgn      print *,(tabaux(iaux),iaux=1,nbnoce)
      do 32 , iaux = 1 , nbnoce
        jaux = tabaux(iaux)+1
        do 321 , kaux = jaux, nbnoto
          nounoe(kaux) = nounoe(kaux) - 1
  321   continue
   32 continue
cgn      print *,(nounoe(iaux),iaux=1,nbnoto)
c
c 3.3. ==> Les noeuds a bouger sont a mettre au bout
c
      do 33 , iaux = 1 , nbnoce
        jaux = tabaux(iaux)
        nounoe(jaux) = nbnoto + 1 - iaux
   33 continue
cgn      print *,(nounoe(iaux),iaux=1,nbnoto)
c
cgn      do 34 , iaux = 1 , nbnoto
cgn      do 34 , jaux = iaux+1 , nbnoto
cgn        if ( nounoe(jaux).eq.nounoe(iaux)) then
cgn          print *,iaux
cgn        endif
cgn   34 continue
cgn      jaux=nbnoto
cgn      do 341 , iaux = 1 , nbnoce
cgn        jaux = min(jaux,nounoe(tabaux(iaux)))
cgn  341 continue
cgn      print *,'nbnoto - nbnoce + 1 = ',nbnoto - nbnoce + 1
cgn      print *,'le mini = ',jaux
c
      endif
c
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
      write (ulsort,texte(langue,4)) mess14(langue,1,4), lepere
      do 40 , iaux = 1 , 4
        write (ulsort,texte(langue,6)) mess14(langue,1,4), lequad(iaux)
   40 continue
c
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      call dmflsh (iaux)
#endif
c
      end
