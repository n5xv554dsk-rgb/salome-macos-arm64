      subroutine vccfcf ( typdep, nctfde, nbfdem, nbfdep,
     >                    typfin, nctffi, nbffim, nbffin, ncfffi,
     >                    cofafd,
     >                    cfadep, cfafin,
     >                    eddep1, edfin1,
     >                    eddep2, edfin2,
     >                    eddep3, edfin3,
     >                    tabaux,
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
c    aVant adaptation - Creation des Familles
c                       -            -
c                     - gestion de la ConFormite
c                                     -  -
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . typdep . e   .   1    . type de l'entite de depart                 .
c . nctfde . e   .   1    . nombre de codes pour les familles de depart.
c . nbfdem . e   .   1    . nombre de familles de depart au maximum    .
c . nbfdep . e   .   1    . nombre de familles de depart               .
c . typfin . e   .   1    . type de l'entite finale                    .
c . nctffi . e   .   1    . nombre de codes pour les familles finales  .
c . nbffim . e   .   1    . nombre de familles finales au maximum      .
c . nbffin . e   .   1    . nombre de familles finales                 .
c . ncfffi . e   .   1    . nombre fige de carac. de familles finales  .
c . cofafd . e   .   1    . code depart contenant la famille d'arrivee .
c . cfadep . e   . nctfde*. codes des familles des depart              .
c .        .     . nbfdep .   1 : famille MED                          .
c .        .     .        .   2 : type                                 .
c .        .     .        . si quadrangle :                            .
c .        .     .        .   3 : numero de surface de frontiere       .
c .        .     .        .   4 : famille des aretes internes apres raf.
c .        .     .        .   5 : famille des triangles de conformite  .
c .        .     .        .   6 : famille de sf active/inactive        .
c .        .     .        . + l : appartenance a l'equivalence l       .
c .        .     .        . si hexaedre ou pentaedre :                 .
c .        .     .        .   3 : famille des tetraedres de conformite .
c .        .     .        .   4 : famille des pyramides de conformite  .
c . cfafin . e   . nctffi*. codes des familles finales                 .
c .        .     . nbffim .   1 : famille MED                          .
c .        .     .        .   2 : type                                 .
c .        .     .        . si triangle :                              .
c .        .     .        .   3 : numero de surface de frontiere       .
c .        .     .        .   4 : famille des aretes internes apres raf.
c .        .     .        . + l : appartenance a l'equivalence l       .
c .        .     .        . si tetraedre ou pyramide :                 .
c . eddep1 . e   .   1    . type med numero 1 au depart                .
c . edfin1 . e   .   1    . type med numero 1 au final                 .
c . eddep2 . e   .   1    . type med numero 2 au depart                .
c . edfin2 . e   .   1    . type med numero 2 au final                 .
c . eddep3 . e   .   1    . type med numero 3 au depart                .
c . edfin3 . e   .   1    . type med numero 3 au final                 .
c . tabaux .  a  . nctffi . tableau auxiliaire                         .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . 1 : probleme                               .
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
      parameter ( nompro = 'VCCFCF' )
c
#include "nblang.h"
c
#include "coftex.h"
#include "cofatq.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "impr02.h"
c
c 0.3. ==> arguments
c
      integer typdep, nctfde, nbfdem, nbfdep
      integer typfin, nctffi, nbffim, nbffin, ncfffi
      integer cofafd
      integer cfadep(nctfde,nbfdem)
      integer cfafin(nctffi,nbffim)
      integer eddep1, edfin1
      integer eddep2, edfin2
      integer eddep3, edfin3
      integer tabaux(nctffi)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux
      integer nufdep, nucode
c
      integer nbmess
      parameter ( nbmess = 10 )
      character*80 texte(nblang,nbmess)
c
c 0.5. ==> initialisations
c ______________________________________________________________________
c
c====
c 1. initialisations
c====
c
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
      texte(1,4) = '(a14,'' : nombre de familles :'',i8)'
      texte(1,5) = '(''. Creation de la famille '',i8,/)'
      texte(1,6) = '(''Ce nombre est superieur au maximum :'',i8)'
      texte(1,7) = '(''Modifier les programmes UTINCG et/ou VCCFAM'')'
c
      texte(2,4) = '(a14,'' : number of families :'',i8)'
      texte(2,5) = '(''. Creation of family '',i8,/)'
      texte(2,6) = '(''This number is greater than maximum:'',i8)'
      texte(2,7) = '(''Modify the programs UTINCG and/or VCCFAM'')'
c
      codret = 0
c
#include "impr03.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) mess14(langue,4,typdep), nbfdep
      write (ulsort,texte(langue,4)) mess14(langue,4,typfin), nbffin
#endif
c
c====
c 2. La famille libre de depart est liee a la famille libre d'arrivee
c====
c
      cfadep(cofafd,1) = 1
c
c====
c 3. Creation des familles finales a partir de celles de depart
c====
c
cgn      write (ulsort,90002)'cofamd, cotyel',cofamd,cotyel
cgn      write (ulsort,90002)'nctfde',nctfde
cgn      write (ulsort,90002)'ncfffi, nctffi',ncfffi,nctffi
cgn      write (ulsort,90002)'nbffin initial',nbffin
cgn      write (ulsort,1788)
cgn      do 3333 , iaux = 1,nbffin
cgn      write (ulsort,90012)'famille ',iaux,
cgn     >(cfafin(nucode,iaux),nucode=1,nctffi)
cgn 3333 continue
cgn 1788  format('                MED type surf ar.su')
c
cgn      write (ulsort,90002)'... eddep1, edfin1', eddep1, edfin1
cgn      write (ulsort,90002)'... eddep2, edfin2', eddep2, edfin2
cgn      write (ulsort,90002)'... eddep3, edfin3', eddep3, edfin3
      do 30 , nufdep = 2 , nbfdep
c
cgn        write (ulsort,*) ' '
cgn        write (ulsort,1788)
cgn        write (ulsort,90012)'famille ',nufdep,
cgn     >(cfadep(nucode,nufdep),nucode=1,nctfde)
c
c 3.1. ==> Etablissement des futurs codes dans tabaux
c 3.1.1. ==> La famille MED doit etre la meme
c
        tabaux(cofamd) = cfadep(cofamd,nufdep)
c
c 3.1.2. ==> definition du type d'element
c
cgn        write (ulsort,90002)'typel depart', cfadep(cotyel,nufdep)
        if ( cfadep(cotyel,nufdep).eq.eddep1 ) then
          tabaux(cotyel) = edfin1
        elseif ( cfadep(cotyel,nufdep).eq.eddep2 ) then
          tabaux(cotyel) = edfin2
        elseif ( cfadep(cotyel,nufdep).eq.eddep3 ) then
          tabaux(cotyel) = edfin3
        else
          tabaux(cotyel) = 0
        endif
cgn        write (ulsort,90002)'typel arrivee', tabaux(cotyel)
c
c 3.1.3. ==> Surfaces frontieres
c
cgn       write (ulsort,90002)'... cosfsu depart', cfadep(cosfsu,nufdep)
cgn       write (ulsort,90002)'... cofafa depart', cfadep(cofafa,nufdep)
        if ( typdep.eq.4 ) then
          tabaux(cosfsu) = cfadep(cosfsu,nufdep)
          tabaux(cofafa) = cfadep(cofafa,nufdep)
        endif
c
c 3.1.4. ==> Les groupes et equivalences doivent etre les memes
c            le decalage est de 2 (cf. UTINCG/UTECF0)
c
        do 314, nucode = ncfffi+1, nctffi
          tabaux(nucode) = cfadep(nucode+2,nufdep)
  314   continue
c
cgn          write (ulsort,1788)
cgn          write (ulsort,90012)'tabaux a',315,
cgn     >                       (tabaux(nucode),nucode=1,nctffi)
c
c 3.2. ==> Existe-t-il une famille finale avec ces caracteristiques ?
c          Dans les nbffin familles deja definies, recherche d'une
c          dont les codes sont les memes.
c            Si on l'a, on note son numero (jaux) et on continue (33).
c            Si aucune ne correspond, on en cree une nouvelle.
c
        do 32 , iaux = 1 , nbffin
cgn          write (ulsort,90002)'. Famille', iaux
          do 321 , nucode = 1, nctffi
cgn          write (ulsort,90012)'.. code',nucode,
cgn     > cfafin(nucode,iaux),tabaux(nucode)
            if ( cfafin(nucode,iaux).ne.tabaux(nucode) ) then
              goto 32
            endif
  321     continue
          jaux = iaux
cgn          write (ulsort,90002)'ok Famille ', iaux
          goto 33
   32   continue
c
        nbffin = nbffin + 1
cgn        write (ulsort,*)'Creation de la famille ', nbffin
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,5)) nbffin
#endif
        do 322, nucode = 1, nctffi
          cfafin(nucode,nbffin) = tabaux(nucode)
  322   continue
        jaux = nbffin
cgn        write (ulsort,1788)
cgn        do 3221 , iaux = 1,nbffin
cgn        write (ulsort,90012)'famille ',iaux,
cgn     >  (cfafin(nucode,iaux),nucode=1,nctffi)
cgn 3221 continue
c
c 3.3. ==> memorisation du type de famille finale
c
   33   continue
c
cgn        write (ulsort,*)'Stockage de ', jaux,
cgn     >   ' dans la famille de depart',nufdep
        cfadep(cofafd,nufdep) = jaux
c
   30 continue
c
c====
c 4. Controle
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) mess14(langue,4,typfin), nbffin
#endif
c
      if ( nbffin.gt.nbffim ) then
        write (ulsort,texte(langue,4)) mess14(langue,4,typfin), nbffin
        write (ulsort,texte(langue,6)) nbffim
        write (ulsort,texte(langue,7))
        codret = 1
      endif
c
c====
c 5. La fin
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
