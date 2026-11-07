      subroutine utnc13 ( option,
     >                    nbnoct, trreca, trrecb,
     >                    nbnocq, qureca, qurecb,
     >                    arequa, filqua, perqua,
     >                    filare,
     >                    nouqua, tabaux,
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
c    UTilitaire - Non Conformite - phase 13
c    --           -   -                  --
c    On change les numeros des faces concernees par les non-conformites
c    . les faces recouvrantes sont mises au debut.
c    . les faces recouvertes sont mises a la fin, en les regroupant
c      par fratries
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . option . e   .    1   . option de l'operation de renumerotation    .
c .        .     .        . 1 : on enleve des nbnocq premieres places  .
c .        .     .        .     les faces recouvertes                  .
c .        .     .        . 2 : on met aux nbnocq premieres places les .
c .        .     .        .     faces recouvrantes                     .
c .        .     .        . 3 : on regroupe par fratries les faces     .
c .        .     .        .     recouvertes                            .
c . nbnoct . e   .    1   . nombre de non conformites de quadrangles   .
c . trreca .  s  .4*nbnoct. liste des triangles recouvrant un autre    .
c . trrecb .  s  .4*nbnoct. liste des triangles recouverts par un autre.
c . nbnocq . e   .    1   . nombre de non conformites de quadrangles   .
c . qureca . e   .4*nbnocq. liste des quad. recouvrant un autre        .
c . qurecb . e   .4*nbnocq. liste des quad. recouverts par un autre    .
c . arequa . e   .nbquto*4. numeros des 4 aretes des quadrangles       .
c . filqua . e   . nbquto . premier fils des quadrangles               .
c . perqua . e   . nbquto . pere des quadrangles                       .
c . filare . e   . nbarto . premiere fille des aretes                  .
c . nouqua .  s  . nbquto . nouveau numero des quadrangles             .
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
      parameter ( nompro = 'UTNC13' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "ope1a4.h"
#include "impr02.h"
#include "nombar.h"
#include "nombqu.h"
c
c 0.3. ==> arguments
c
      integer option
      integer nbnoct, trreca(4*nbnoct), trrecb(4*nbnoct)
      integer nbnocq, qureca(4*nbnocq), qurecb(4*nbnocq)
      integer arequa(nbquto,4)
      integer filqua(nbquto), perqua(nbquto)
      integer filare(nbarto)
      integer nouqua(0:nbquto)
      integer tabaux(5,*)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux, kaux, laux, maux
      integer ifin
      integer jauxm1
      integer lequa1, lequag, lequad
      integer lefils(4), quangl(4)
      integer arei, areim1
      integer f1ai, f2ai, f1aim1, f2aim1
      integer aretf(4)
      integer debut
      integer lgtab
c
      integer nbmess
      parameter ( nbmess = 20 )
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
      texte(1,4) =
     > '(''Nombre de paquets de 4 '',a,'' non-conformes :'',i10))'
      texte(1,5) = '(''Decalage des quadrangles recouverts'')'
      texte(1,6) = '(''Renumerotation des quadrangles recouvrants'')'
      texte(1,7) = '(''Regroupement des quadrangles recouverts'')'
      texte(1,8) = '(''Examen du '',a,'' numero'',i10)'
      texte(1,9) = '(''.. couvert par le '',a,'' numero'',i10)'
      texte(1,10) = '(''.. couvrant les '',a,'' numero'',4i10)'
      texte(1,11) = '(''dont les '',a,'' sont :'',4i10)'
c
      texte(2,4) =
     > '(''Number of packs of 4 non-conformal '',a,'' :'',i10))'
      texte(2,5) = '(''Shift of covered edges'')'
      texte(2,6) = '(''Renumbering of covering edges'')'
      texte(2,7) = '(''Gathering of covered edges'')'
      texte(2,8) = '(''Examination of '',a,'' #'',i10)'
      texte(2,9) = '(''.. covered by '',a,'' #'',i10)'
      texte(2,10) = '(''.. covering '',a,'' #'',4i10)'
      texte(2,11) = '(''with '',a,'' # :'',4i10)'
c
      codret = 0
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) mess14(langue,3,2), nbnoct
      write (ulsort,texte(langue,4)) mess14(langue,3,4), nbnocq
      write (ulsort,texte(langue,4+option))
#endif
c
c 1.2. ==> Aucune renumerotation au depart
c
      do 12 , iaux = 0 , nbquto
        nouqua(iaux) = iaux
   12 continue
c
c====
c 2. option numero 1 : plus aucune face recouverte ne doit se trouver
c    parmi les nbnocq premieres
c    On examine chacune des faces recouvertes. Si son numero
c    est inferieur a nbnocq, on la permute avec une face de numero
c    superieur a nbnocq et qui n'est pas une recouverte
c====
c
      if ( option.eq.1 ) then
c
        if ( codret.eq.0 ) then
c
        debut = nbnocq + 1
        ifin = 4*nbnocq
        do 21 , iaux = 1 , ifin
c
          if ( codret.eq.0 ) then
c
          lequad = qurecb(iaux)
c
          if ( lequad.le.nbnocq ) then
c
#ifdef _DEBUG_HOMARD_
            write (ulsort,texte(langue,8)) mess14(langue,1,4), lequad
#endif
            do 211 , jaux = debut, nbquto
              if ( perqua(jaux).eq.0 ) then
                kaux = jaux
                goto 212
              endif
  211       continue
c
            codret = option
c
  212       continue
c
            nouqua(kaux) = lequad
            nouqua(lequad) = kaux
            debut = kaux + 1
cgn          write (ulsort,texte(langue,8)) mess14(langue,1,4), lequad
cgn          write (ulsort,*) lequad,' devient', kaux
c
          endif
c
          endif
c
   21   continue
c
        endif
c
c====
c 3. option numero 2 : les faces recouvrantes sont mises aux nbnocq
c    premieres places
c    On examine chacune des faces recouvrantes dans la liste qureca. Si
c    son numero est superieur a nbnocq, on la permute avec une face
c    de numero inferieur a nbnocq et qui n'est pas une recouvrante. Il
c    faut noter que chaque face apparait plusieurs fois. Il ne faut la
c    permuter que la 1ere fois : cela se repere avec son nouveau numero
c====
c
      elseif ( option.eq.2 ) then
c
        if ( codret.eq.0 ) then
c
        debut = 1
        ifin = 4*nbnocq
        do 31 , iaux = 1 , ifin
c
          if ( codret.eq.0 ) then
c
          lequad = qureca(iaux)
c
          if ( lequad.gt.nbnocq .and. nouqua(lequad).eq.lequad ) then
c
#ifdef _DEBUG_HOMARD_
            write (ulsort,texte(langue,8)) mess14(langue,1,4), lequad
#endif
            do 311 , jaux = debut, nbnocq
              if ( filqua(jaux).eq.0 ) then
                kaux = jaux
                goto 312
              endif
  311       continue
c
            codret = option
c
  312       continue
c
            nouqua(kaux) = lequad
            nouqua(lequad) = kaux
            debut = kaux + 1
cgn          write (ulsort,*) lequad,' devient', kaux
c
          endif
c
          endif
c
   31   continue
c
        endif
c
c====
c 4. option numero 3 : les faces recouvertes sont regroupees par
c    fratries
c====
c
      elseif ( option.eq.3 ) then
c
c 4.1. ==> Regroupement des fils adoptifs et de leur pere
c 4.1.1. ==> Aucun regroupement au depart
c
        do 41 , iaux = 1 , nbnocq
c
          tabaux(1,iaux) = 0
          tabaux(2,iaux) = 0
          tabaux(3,iaux) = 0
          tabaux(4,iaux) = 0
          tabaux(5,iaux) = 0
c
   41   continue
c
c 4.1.2. ==> On regroupe les fils adoptifs et leur pere
c
        lgtab = 0
        ifin = 4*nbnocq
        do 42 , iaux = 1 , ifin
c
          lequa1 = qurecb(iaux)
          lequag = qureca(iaux)
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,8)) mess14(langue,1,4), lequa1
      write (ulsort,texte(langue,9)) mess14(langue,1,4), lequag
#endif
c
c       on cherche si on a deja place le quadrangle jumeau de lequa1
c       . si oui, on place le quadrangle courant en position 3, 4 ou 5
c       . si non, on place le quadrangle pere en position 1 et le fils
c         en position 2
c
          do 422 ,  jaux = 1, lgtab
c
            if ( tabaux(1,jaux).eq.lequag ) then
              if ( tabaux(3,jaux).eq.0 ) then
                tabaux(3,jaux) = lequa1
              elseif ( tabaux(4,jaux).eq.0 ) then
                tabaux(4,jaux) = lequa1
              else
                tabaux(5,jaux) = lequa1
              endif
              goto 42
            endif
c
  422     continue
c
          lgtab = lgtab + 1
          tabaux(1,lgtab) = lequag
          tabaux(2,lgtab) = lequa1
c
   42   continue
cgn      print *,'lgtab = ', lgtab
c
c 4.3. ==> Les quadrangles recouverts : on les place par 2 ou 4
c     On cherche en partant de la fin de la numerotation 2 ou 4 places
c     contigues qui ne soient pas deja des quadrangles recouverts.
c          Remarque : ce ne peut pas etre des recouvrants car on les
c                     a mis au debut au cours du passage option=1
c
        debut = nbnocq + 1
        do 43 , iaux = 1 , lgtab
c
          if ( codret.eq.0 ) then
c
          lequag = tabaux(1,iaux)
          lefils(1) = tabaux(2,iaux)
          lefils(2) = tabaux(3,iaux)
          lefils(3) = tabaux(4,iaux)
          lefils(4) = tabaux(5,iaux)
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,8)) mess14(langue,1,4), lefils(1)
      write (ulsort,texte(langue,8)) mess14(langue,1,4), lefils(2)
      write (ulsort,texte(langue,8)) mess14(langue,1,4), lefils(3)
      write (ulsort,texte(langue,8)) mess14(langue,1,4), lefils(4)
      write (ulsort,texte(langue,9)) mess14(langue,1,4), lequag
#endif
c
c          Pour 2 fils, on ne fait rien car pas prevu aujourd'hui
          if ( lefils(3).eq.0 ) then
c
      write (ulsort,texte(langue,8)) mess14(langue,1,4), lefils(1)
      write (ulsort,texte(langue,8)) mess14(langue,1,4), lefils(2)
      write (ulsort,texte(langue,8)) mess14(langue,1,4), lefils(3)
      write (ulsort,texte(langue,8)) mess14(langue,1,4), lefils(4)
      write (ulsort,texte(langue,9)) mess14(langue,1,4), lequag
            codret = -1
c
          else
c
            do 432 , jaux = debut, nbquto
              if ( perqua(jaux  ).eq.0 .and. perqua(jaux+1).eq.0 .and.
     >             perqua(jaux+2).eq.0 .and. perqua(jaux+3).eq.0 ) then
                kaux = jaux
                goto 433
              endif
  432       continue
            codret = option
c
          endif
c
  433     continue
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) 'kaux = ', kaux
#endif
c
c 4.4. ==> Dans le cas de 4 fils, on doit reperer dans quel angle du
c          pere se situe chacun d'eux pour respecter la convention
c          de cmrdqu
c
          if ( codret.eq.0 ) then
c
          do 44 , jaux = 1 , 4
c
            if ( codret.eq.0 ) then
c
c 4.4.1. ==> Les 2 aretes j et j-1 du pere ainsi que leurs filles
c
            arei = arequa(lequag,jaux)
            f1ai = filare(arei)
            f2ai = f1ai + 1
c
            jauxm1 = per1a4(-1,jaux)
            areim1 = arequa(lequag,jauxm1)
            f1aim1 = filare(areim1)
            f2aim1 = f1aim1 + 1
c
c 4.4.2. ==> Lequel des 4 quadrangles fils est dans cet angle ?
c
            do 442 , laux = 1 , 4
c
c 4.4.2.1. ==> Les aretes du laux-eme fils
c
              do 4421 , maux = 1 , 4
                aretf(maux) = arequa(lefils(laux),maux)
 4421         continue
c
#ifdef _DEBUG_HOMARD_
            write (ulsort,texte(langue,8))
     >                   mess14(langue,1,4)//'fils', lefils(laux)
            write (ulsort,texte(langue,11)) mess14(langue,3,1), 
     >                                     aretf
#endif
c
c 4.4.2.2. ==> Quelle arete du laux-eme fils est fille de l'arete i ?
c              Si on n'en a pas trouve, on passe au fils suivant
c
              do 4422 , maux = 1 , 4
c
                if ( aretf(maux).eq.f1ai .or.
     >               aretf(maux).eq.f2ai ) then
                  goto 44221
                endif
c
 4422         continue
c
              goto 442
c
44221         continue
c
c 4.4.2.3. ==> Quelle arete du fils est fille de l'arete i-1 ?
c              Si on n'en a pas trouve, on passe au fils suivant
c
              do 4423 , maux = 1 , 4
c
                if ( aretf(maux).eq.f1aim1 .or.
     >               aretf(maux).eq.f2aim1 ) then
                  goto 44231
                endif
c
 4423         continue
c
              goto 442
c
44231         continue
c
c 4.4.2.4. ==> Si on arrive ici, c'est que le laux-eme fils est
c              dans l'angle jaux
c              On passe a l'angle suivant.
c
              quangl(jaux) = lefils(laux)
              goto 44
c
  442       continue
c
c 4.4.3. ==> Si on arrive ici, c'est qu'aucun fils n'est
c            dans l'angle jaux
c
            codret = 443
c
            endif
c
   44     continue
cgn            write (ulsort,*) 'quangle : ',quangl
c
          endif
c
c 4.5. ==> On renumerote en placant dans les angles corrects
c
          if ( codret.eq.0 ) then
c
          do 45 , jaux = 1 , 4
c
cgn            if ( kaux.eq.1501)then
cgn              write(ulsort,*) 'kaux=1501 ',quangl(jaux)
cgn            elseif ( quangl(jaux).eq.1501)then
cgn              write(ulsort,*) 'quangl(jaux)=1501 ',kaux
cgn            endif
            nouqua(kaux) = quangl(jaux)
            nouqua(quangl(jaux)) = kaux
c
            kaux = kaux + 1
c
   45     continue
c
          debut = kaux
c
          endif
c
          endif
c
   43   continue
c
c====
c 5. option autre : impossible
c====
c
      else
c
        codret = -1
c
      endif
c
c====
c 6. la fin
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
