      subroutine pcsar0 ( nbfonc, typint, deraff,
     >                    prfcan, prfcap,
     >                    hetare, ancare, filare,
     >                    nbanar, anfiar,
     >                    nareca, narsca,
     >                    vafoen, vafott,
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
c    aPres adaptation - Conversion de Solution -
c     -                 -             -
c                       ARetes - solution P0
c                       --                 -
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nbfonc . e   .    1   . nombre de fonctions elements de volume     .
c . typint . e   .   1    . type d'interpolation                       .
c .        .     .        .  0, si automatique                         .
c .        .     .        .  elements : 0 si intensif, sans orientation.
c .        .     .        .             1 si extensif, sans orientation.
c .        .     .        .             2 si intensif, avec orientation.
c .        .     .        .             3 si extensif, avec orientation.
c .        .     .        .  noeuds : 1 si degre 1                     .
c .        .     .        .           2 si degre 2                     .
c .        .     .        .           3 si iso-P2                      .
c . deraff . e   .    1   . vrai, s'il y a eu du deraffinement en      .
c .        .     .        . passant de l'iteration n a n+1 ; faux sinon.
c . prfcan . e   .   *    . En numero du calcul a l'iteration n :      .
c .        .     .        . 0 : l'entite est absente du profil         .
c .        .     .        . i : l'entite est au rang i dans le profil  .
c . prfcap . es  .   *    . En numero du calcul a l'iteration n+1 :    .
c .        .     .        . 0 : l'entite est absente du profil         .
c .        .     .        . 1 : l'entite est presente dans le profil   .
c . hetare . e   . nbarto . historique de l'etat des aretes            .
c . ancare . e   . nbarto . anciens numeros des aretes conservees      .
c . filare . e   . nbarto . fille ainee de chaque arete                .
c . nareca . e   .   *    . nro des aretes dans le calcul en entree    .
c . narsca . e   . rsarto . numero des aretes du calcul                .
c . vafoen .   e . nbfonc*. variables en entree de l'adaptation        .
c .        .     .    *   .                                            .
c . vafott .   a . nbfonc*. tableau temporaire de la solution          .
c .        .     .    *   .                                            .
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
      parameter ( nompro = 'PCSAR0' )
c
#include "nblang.h"
#include "fracta.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "nombar.h"
#include "nombsr.h"
#include "nomber.h"
c
c 0.3. ==> arguments
c
      integer nbfonc
      integer typint
      integer prfcan(*), prfcap(*)
      integer hetare(nbarto), ancare(*)
      integer filare(nbarto)
      integer nbanar, anfiar(nbanar)
      integer nareca(rearto), narsca(rsarto)
c
      double precision vafoen(nbfonc,*)
      double precision vafott(nbfonc,*)
c
      logical deraff
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
c     arcn   = ARrete courante en numerotation Calcul a l'iteration N
c     arcnp1 = ARrete courante en numerotation Calcul a l'iteration N+1
c     arhn   = ARrete courante en numerotation Homard a l'iteration N
c     arhnp1 = ARrete courante en numerotation Homard a l'iteration N+1
c
      integer arcn, arcnp1, arhn, arhnp1
c
c     f1hp = Fille 1er de l'arete en numerotation Homard a l'it. N+1
c     f1cp = Fille 1er de l'arete en numerotation Calcul a l'it. N+1
c     f2cp = Fille 2eme de l'arete en numerotation Calcul a l'it. N+1
c
      integer f1hp
      integer f1cp, f2cp
c
c     f1hn = Fille 1er de l'arete en numerotation Homard a l'it. N
c     f1cn = Fille 1er de l'arete en numerotation Calcul a l'it. N
c     f2cn = Fille 2eme de l'arete en numerotation Calcul a l'it. N
c
      integer f1hn
      integer f1cn, f2cn
c
c     etan   = ETAt de l'arete a l'iteration N
c     etanp1 = ETAt de l'arete a l'iteration N+1
c
      integer etan, etanp1
c
      integer nrofon
      integer iaux
c
      double precision coefra(2), coefde(2)
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
#include "pcimp0.h"
#include "impr01.h"
#include "impr03.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
      texte(1,4) =
     > '(/,''Arete en cours : nro a l''''iteration '',a3,'' : '',i8)'
      texte(1,5) =
     > '(  ''                etat a l''''iteration '',a3,'' : '',i4)'
      texte(1,6) = '(  ''==> Aucune interpolation'')'
      texte(1,7) = '(''Ce type d''''interpolation est inconnu :'',i4)'
c
      texte(2,4) =
     > '(/,''Current edge : # at iteration '',a3,'': '',i8)'
      texte(2,5) =
     > '(  ''          status at iteration '',a3,'': '',i4)'
      texte(2,6) = '(  ''==> No interpolation'')'
      texte(2,7) = '(''This kind of interpolation is unknown:'',i4)'
c
      codret = 0
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'nbfonc', nbfonc
      write (ulsort,90002) 'nbarto', nbarto
      write (ulsort,90002) 'typint', typint
#endif
cgn      write(ulsort,*) 'nareca'
cgn      write(ulsort,91020) nareca
cgn      write(ulsort,*) 'prfcan'
cgn      write(ulsort,91020)(prfcan(iaux),iaux=1,74)
cgn 9999   format(1I5,g14.7,3i10)
c
c====
c 2. on boucle sur toutes les aretes du maillage HOMARD n+1 qui sont
c    des elements du calcul : pour cela, il suffit que le numero dans
c    le calcul en sortie soit non nul
c    on trie en fonction de l'etat de l'arete dans le maillage n
c====
c
      if ( nbfonc.ne.0 ) then
c
c 2.0. ==> coefficients multiplicateurs selon le type d'interpolation
c          intensif : valeur identique
c          extensif : on divise par deux
c          Si l'orientation est prise en compte, on se souvient que la
c          premiere fille est toujours dans le meme sens que la mere,
c          la seconde etant toujours en sens inverse.
c 2.0.0. ==> Intensif, sans orientation
c
      if ( typint.eq.0 ) then
        coefra(1) = 1.d0
        coefra(2) = 1.d0
        coefde(1) = unsde
        coefde(2) = unsde
c
c 2.0.1. ==> Extensif, sans orientation
c
      elseif ( typint.eq.1 ) then
        coefra(1) = unsde
        coefra(2) = unsde
        coefde(1) = 1.d0
        coefde(2) = 1.d0
c
c 2.0.2. ==> Intensif, avec orientation
c
      elseif ( typint.eq.2 ) then
        coefra(1) =  1.d0
        coefra(2) = -1.d0
        coefde(1) =  unsde
        coefde(2) = -unsde
c
c 2.0.3. ==> Extensif, avec orientation
c
      elseif ( typint.eq.3 ) then
        coefra(1) =  unsde
        coefra(2) = -unsde
        coefde(1) =  1.d0
        coefde(2) = -1.d0
      else
        codret = -1
      endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90004) 'coefra', coefra
      write (ulsort,90004) 'coefde', coefde
#endif
c
      do 20 , arhnp1 = 1 , nbarto
c
c 2.1. ==> caracteristiques de l'arete :
c 2.1.1. ==> son numero homard dans le maillage precedent
c
        if ( deraff ) then
          arhn = ancare(arhnp1)
        else
          arhn = arhnp1
        endif
c
c 2.1.2. ==> l'historique de son etat
c          On rappelle que l'etat vaut :
c          etan = 0 : l'arete etait active
c          etan = 2 : l'arete etait coupe en 2
c          etan = 5 : l'arete n'existait pas ; elle a ete produite par
c                     un decoupage.
c          etan = 9 : l'arete etait coupee en 2 et une de ses filles
c                     est inactive
c
        etanp1 = mod(hetare(arhnp1),10)
        etan   = (hetare(arhnp1)-etanp1) / 10
c
cgn        write (ulsort,1792) 'Arete', arhn, etan, arhnp1, etanp1
c
c=======================================================================
c 2.1.2.1. ===> etan = 0 : l'arete etait active
c=======================================================================
c
        if ( etan.eq.0 ) then
cgn          write (ulsort,*) 'l''arete etait active'
c
c         on repere son ancien numero dans le calcul
c         il faut que arcn soit non nul : l'arete etait du calcul
c
          arcn = nareca(arhn)
cgn          print 1790,arcn,prfcan(arcn)
cgn 1790 format(/,'Numero du calcul precedent arcn = ',i3,
cgn     >         ', de profil = ',i3)
c
          if ( arcn.gt.0 ) then
c
          if ( prfcan(arcn).gt.0 ) then
c
cgn          print 1789,(vafoen(nrofon,prfcan(arcn)),nrofon = 1 , nbfonc)
cgn 1789 format('  Valeurs anciennes  :  ',5g12.5)
c
c 2.1.2.1.1. ===> etanp1 = 0 : l'arete etait active et l'est encore ;
c                 elle est inchangee
c             c'est le cas le plus simple : on prend la valeur de la
c             fonction associee a l'ancien numero de l'arete.
c
c           O...............O  ===>   O...............O
c
          if ( etanp1.eq.0 ) then
c
            arcnp1 = narsca(arhnp1)
            prfcap(arcnp1) = 1
c
            do 221 , nrofon = 1 , nbfonc
              vafott(nrofon,arcnp1) = vafoen(nrofon,prfcan(arcn))
cgn              write(ulsort,7778) vafoen(nrofon,prfcan(arcn))
  221       continue
cgn        write(21,9999) arcnp1,vafott(15,arcnp1),0,arcn,prfcan(arcn)
cgn        write(ulsort,7777) arcn,-1,arcnp1
c
c 2.1.2.1.2. ===> etanp1 = 2 : l'arete etait active et est decoupee
c                              en deux.
c              les deux filles prennent la valeur de la fonction sur la
c              mere, eventuellement divisee par deux, eventuellement signee
c
c           O...............O  ===>  O.......O.......O
c
          elseif ( etanp1.eq.2 ) then
c
            f1hp = filare(arhnp1)
            f1cp = narsca(f1hp)
            f2cp = narsca(f1hp+1)
            prfcap(f1cp) = 1
            prfcap(f2cp) = 1
            do 2221 , nrofon = 1 , nbfonc
             vafott(nrofon,f1cp) = coefra(1)*vafoen(nrofon,prfcan(arcn))
             vafott(nrofon,f2cp) = coefra(2)*vafoen(nrofon,prfcan(arcn))
cgn              write(ulsort,7778) vafoen(nrofon,prfcan(arcn))
 2221       continue
cgn        write(22,9999) f1cp,vafott(15,f1cp),2,arcn,prfcan(arcn)
cgn        write(22,9999) f2cp,vafott(15,f1cp),2,arcn,prfcan(arcn)
cgn        write(22,7777) f1cp,f2cp
cgn        write(ulsort,7777) arcn,-1,
cgn     >                     f1cp,f2cp
c
c doc.0.erreur. ==> aucun autre etat sur l'arete courante n'est
c                   possible
c
          else
c
            codret = codret + 1
            write (ulsort,texte(langue,4)) 'n  ', arhn
            write (ulsort,texte(langue,5)) 'n  ', etan
            write (ulsort,texte(langue,4)) 'n+1', arhnp1
            write (ulsort,texte(langue,5)) 'n+1', etanp1
c
          endif
c
          endif
c
          endif
c
c=======================================================================
c 2.1.2.2. ===> etan = 2 : l'arete etait coupee en 2
c=======================================================================
c
        elseif ( etan.eq.2 ) then
c
cgn          write (ulsort,*) 'l''arete etait coupee en 2'
c         on repere les numeros dans le calcul pour ses deux filles a
c         l'iteration n
c
          f1hn = anfiar(arhn)
          f1cn = nareca(f1hn)
          f2cn = nareca(f1hn+1)
c
c         il faut que f1cn soit non nul : les filles etaient du calcul
c
          if (f1cn.gt.0 ) then
cgn        write(ulsort,90002) 'prfcan(f1/2cn)',prfcan(f1cn),prfcan(f2cn)
c
          if ( prfcan(f1cn).gt.0 .and. prfcan(f2cn).gt.0 ) then
c
c 2.1.2.2.1. ===> etanp1 = 0 : l'arete est reactivee.
c                 on lui attribue la valeur moyenne sur les deux
c                 anciennes filles.
c        remarque : cela arrive seulement avec du deraffinement.
c
c           O.......O.......O  ===>  O...............O
c
          if ( etanp1.eq.0 ) then
c
            arcnp1 = narsca(arhnp1)
cgn        write(ulsort,90002) 'arhnp1, arcnp1', arhnp1, arcnp1
            prfcap(arcnp1) = 1
            do 231 , nrofon = 1 , nbfonc
                vafott(nrofon,arcnp1) =
     >                    coefde(1)*vafoen(nrofon,prfcan(f1cn))
     >                  + coefde(2)*vafoen(nrofon,prfcan(f2cn))
cgn        write(ulsort,90004) '=> valeur', vafott(nrofon,arcnp1)
  231       continue
cgn        write(31,7777) arcnp1
cgn        write(ulsort,7777) f1cn,f2cn,-1,arcnp1
c
c 2.1.2.2.2. ===> etanp1 = etan : l'arete est decoupee en deux
c                 c'est le meme decoupage.
c             c'est ce qui se passe quand un decoupage de conformite
c             est supprime au debut des algorithmes d'adaptation,
c             puis reproduit a la creation du maillage car la situation
c             au voisinage est inchangee.
c             la fille prend la valeur de la fonction sur l'ancienne
c             fille qui etait au meme endroit. comme la procedure de
c             numerotation est la meme (voir cmcdar), la premiere fille
c             est toujours la meme, la seconde egalement. on prendra
c             alors la valeur sur la fille de rang identique a
c             l'iteration n.
c
c           O.......O.......O  ===>  O.......O.......O
c
          elseif ( etanp1.eq.etan ) then
c
            f1hp = filare(arhnp1)
            f1cp = narsca(f1hp)
            f2cp = narsca(f1hp+1)
            prfcap(f1cp) = 1
            prfcap(f2cp) = 1
            do 232 , nrofon = 1 , nbfonc
              vafott(nrofon,f1cp) = vafoen(nrofon,prfcan(f1cn))
              vafott(nrofon,f2cp) = vafoen(nrofon,prfcan(f2cn))
cgn              write(ulsort,7778) vafoen(nrofon,prfcan(f1cn)),
cgn     >                           vafoen(nrofon,prfcan(f2cn))
  232       continue
cgn        write(32,7777) f1cp,f2cp
cgn        write(ulsort,7777) f1cn,f2cn,-1,f1cp,f2cp
c
c 2.1.2.2.3. ===> etanp1 = 9 : l'arete est decoupee en deux et une de
c                              ses filles est decoupee ;
c                              rien n'est a faire
c                aucun autre etat sur l'arete courante n'est possible
c
          elseif ( etanp1.ne.9 ) then
c
            codret = codret + 1
            write (ulsort,texte(langue,4)) 'n  ', arhn
            write (ulsort,texte(langue,5)) 'n  ', etan
            write (ulsort,texte(langue,4)) 'n+1', arhnp1
            write (ulsort,texte(langue,5)) 'n+1', etanp1
c
          endif
c
          endif
c
          endif
c
#ifdef _DEBUG_HOMARD_
c
c=======================================================================
c doc.4. ==> l'arete n'existait pas
c=======================================================================
c
        else
c
cgn          print *,'l arete n''existait pas'
          write (ulsort,texte(langue,6))
c
#endif
c
c=======================================================================
c
        endif
c
   20 continue
c
      endif
c
      endif
c
cgn      write(ulsort,91020)(prfcap(iaux),iaux=1,nbtrto)
cgn      print *,'nbfonc = ',nbfonc
cgn      etan   = 1
cgn      etanp1 = nbarto
cgn      do 30001 , iaux=etan,etanp1
cgn        if ( mod(hetare(iaux),10).eq.0 ) then
cgn          print 11790,
cgn     >    ntrsca(iaux),prfcap(narsca(iaux)),vafott(1,narsca(iaux))
cgn        endif
cgn30001 continue
cgn11790 format(i4,' : ',i2,' / ',g15.7)
c
c====
c 3. la fin
c====
c
      if ( codret.ne.0 ) then
c
#include "envex2.h"
c
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      write (ulsort,texte(langue,2)) codret
      if ( codret.eq.-1 ) then
        write (ulsort,texte(langue,7)) typint
      endif
c
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      call dmflsh (iaux)
#endif
c
      end
