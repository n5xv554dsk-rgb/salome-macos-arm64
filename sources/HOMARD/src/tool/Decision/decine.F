      subroutine decine ( nupaci, nbsoci, nbsoav,
     >                    seuilh, seuinf, seusup,
     >                    nomail,
     >                    indnoe, indnp2, indnim, indare,
     >                    indtri, indqua,
     >                    indtet, indhex, indpen,
     >                    lgopts, taopts, lgetco, taetco,
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
c    DEcision - CIble - Noeud ou Elements
c    --         --      -        -
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nupaci . es  .   1    . numero du passage en cours pour la         .
c .        .     .        . recherche de cible                         .
c .        .     .        . vaut -1 si la cible est atteinte           .
c . nbsoci . e   .   1    . cible en nombre de sommets  (-1 si non)    .
c . nbmaci . e   .   1    . cible en nombre de mailles (-1 si non)     .
c . nbsoav . es  .   1    . nombre de sommetes aux etapes anterieures  .
c . seuilh . es  .   1    . borne superieure de l'erreur (absolue)     .
c . seuinf . es  .   1    . meilleur seuil inferieur en nombre noeuds  .
c . seusup . es  .   1    . meilleur seuil superieur en nombre noeuds  .
c . nomail . e   .  ch8   . nom de l'objet contenant le maillage       .
c . indnoe . es  .   1    . indice du dernier noeud cree               .
c . indnp2 . es  .   1    . nombre de noeuds p2 en vigueur             .
c . indnim . es  .   1    . nombre de noeuds internes en vigueur       .
c . indare . es  .   1    . indice de la derniere arete creee          .
c . indtri . es  .   1    . indice du dernier triangle cree            .
c . indqua . es  .   1    . indice du dernier quadrangle cree          .
c . indtet . es  .   1    . indice du dernier tetraedre cree           .
c . indhex . es  .   1    . indice du dernier hexaedre cree            .
c . indpen . es  .   1    . indice du dernier pentaedre cree           .
c . lgopts . e   .   1    . longueur du tableau des options caracteres .
c . taopts . e   . lgopts . tableau des options caracteres             .
c . lgetco . e   .   1    . longueur du tableau de l'etat courant      .
c . taetco . e   . lgetco . tableau de l'etat courant                  .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .   1    . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . e/s .   1    . code de retour des modules                 .
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
      parameter ( nompro = 'DECINE' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
#include "envca1.h"
c
#include "nombno.h"
#include "nouvnb.h"
c
c 0.3. ==> arguments
c
      integer nupaci, nbsoci
      integer nbsoav(6)
c
      character*8 nomail
c
      integer indnoe, indnp2, indnim, indare, indtri, indqua
      integer indtet, indhex, indpen
c
      double precision seuilh, seuinf, seusup
c
      integer lgopts
      character*8 taopts(lgopts)
c
      integer lgetco
      integer taetco(lgetco)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer codava
      integer nretap, nrsset
      integer iaux, jaux
c
      integer nbsoan, nbsono
      integer nbnoan, nbnono
      integer nbaran, nbarno
      integer nbtran, nbtrno
      integer nbquan, nbquno
      integer nbtean, nbteno
      integer nbhean, nbheno
      integer nbpean, nbpeno
      integer nbpyan, nbpyno
c
      double precision daux
c
      character*6 saux
      character*8 norenu
      character*8 nhnoeu, nhmapo, nharet, nhtria, nhquad
      character*8 nhtetr, nhhexa, nhpyra, nhpent
      character*8 nhelig
      character*8 nhvois, nhsupe, nhsups
      character*8 ndecar, ndecfa
c
      integer nbmess
      parameter ( nbmess = 11 )
      character*80 texte(nblang,nbmess)
c
c 0.5. ==> initialisations
c ______________________________________________________________________
c
c====
c 1. messages
c====
c
      codava = codret
c
c=======================================================================
      if ( codava.eq.0 ) then
c=======================================================================
c
c 1.3. ==> les messages
c
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'nupaci', nupaci
#endif
c
      texte(1,4) = '(/,a6,'' DECOMPTE DES NOUVELLES ENTITES'')'
      texte(1,5) = '(37(''=''),/)'
      texte(1,6) = '(''Pas assez de raffinement '',a)'
      texte(1,7) = '(''Trop de raffinement '',a)'
      texte(1,8) = '(''La cible est atteinte.'')'
      texte(1,9) = '(''Le nombre de noeuds ne bouge plus.'')'
      texte(1,10) = '(''Le nombre de noeuds alterne.'')'
      texte(1,11) = '(''Arret du processus.'')'
c
      texte(2,4) = '(/,a6,'' COUNTING OF NEW ENTITIES'')'
      texte(2,5) = '(31(''=''),/)'
      texte(2,6) = '(''Not enough refinement '',a)'
      texte(2,7) = '(''Too many refinement '',a)'
      texte(2,8) = '(''The target is reached.'')'
      texte(2,9) = '(''No more evolution of the number of nodes.'')'
      texte(2,10) = '(''The number of nodes alternates.'')'
      texte(2,11) = '(''The process is over.'')'
c
#include "impr03.h"
c
c 1.4. ==> le numero de sous-etape
c
      nretap = taetco(1)
      nrsset = taetco(2) + 1
      taetco(2) = nrsset
c
      call utcvne ( nretap, nrsset, saux, iaux, codret )
c
c 1.5. ==> le titre
c
      write (ulsort,texte(langue,4)) saux
      write (ulsort,texte(langue,5))
c
c====
c 2. recuperation des pointeurs
c====
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTNOMH', nompro
#endif
c
      call utnomh ( nomail,
     >                sdim,   mdim,
     >               degre, maconf, homolo, hierar,
     >              rafdef, nbmane, typcca, typsfr, maextr,
     >              mailet,
     >              norenu,
     >              nhnoeu, nhmapo, nharet,
     >              nhtria, nhquad,
     >              nhtetr, nhhexa, nhpyra, nhpent,
     >              nhelig,
     >              nhvois, nhsupe, nhsups,
     >              ulsort, langue, codret)
c
      endif
c
c====
c 3. programmes generiques
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3. programmes generiques ; codret', codret
#endif
c
c 3.1. ==> Base
c
      if ( codret.eq.0 ) then
c
      ndecar = taopts(11)
      ndecfa = taopts(12)
c
      endif
c
c 3.2. ==> Nombre de valeurs
c
      if ( codret.eq.0 ) then
c
      iaux = 0
#ifdef _DEBUG_HOMARD_
      jaux = 1
#else
      jaux = 0
#endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAL00', nompro
#endif
      call utal00 (   iaux,   jaux,
     >              nomail, ndecar, ndecfa,
     >              indnoe, indnp2, indnim, indare,
     >              indtri, indqua,
     >              indtet, indhex, indpen,
     >              nbsoan, nbsono,
     >              nbnoan, nbnono,
     >              nbaran, nbarno,
     >              nbtran, nbtrno,
     >              nbquan, nbquno,
     >              nbtean, nbteno,
     >              nbhean, nbheno,
     >              nbpean, nbpeno,
     >              nbpyan, nbpyno,
     >              ulsort, langue, codret )
c
      endif
c
c====
c 4. Evaluation
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3. programmes generiques ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90004) 'seuilh', seuilh
      write (ulsort,90004) 'seuinf avant', seuinf
      write (ulsort,90004) 'seusup avant', seusup
      write (ulsort,90002) 'nbsoav avant', nbsoav
      write (ulsort,90002) 'nbnop1', nbnop1
      write (ulsort,90002) 'nbsono', nbsono
      write (ulsort,90002) 'nbsoci', nbsoci
#endif
c
c 4.1. ==> Miracle ! La cible est atteinte : on arrete
c
      if ( nbsono.eq.nbsoci ) then
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,8))
#endif
c
        nupaci = -1
c
      endif
c
c 4.2. ==> La cible n'est pas atteinte au premier passage :
c          on applique un pourcentage de 20%
c
      if ( nupaci.eq.1 ) then
c
c 4.2.1. ==> Pas assez de raffinement
c
        if ( nbsono.lt.nbsoci ) then
#ifdef _DEBUG_HOMARD_
          write (ulsort,texte(langue,6)) ' '
#endif
          if ( seuilh.gt.0.d0 ) then
            daux = 0.8d0
          else
            daux = 1.2d0
          endif
          seuinf = seuilh
c
c 4.2.2. ==> Trop de raffinement
c
        else
#ifdef _DEBUG_HOMARD_
          write (ulsort,texte(langue,7)) ' '
#endif
          if ( seuilh.gt.0.d0 ) then
            daux = 1.2d0
          else
            daux = 0.8d0
          endif
          seusup = seuilh
        endif
c
c 4.2.3. ==> Nouveau seuil
c
        seuilh = seuilh*daux
c
      endif
c
c 4.3. ==> Arret eventuel aux passages suivants
c          Si on alterne, on arrete au meilleur choix
c
      if ( nupaci.gt.1 ) then
c
        if ( nbsono.eq.nbsoav(2) .and.
     >       nbsono.eq.nbsoav(4) .and.
     >       nbsono.eq.nbsoav(6) .and.
     >       nbsoav(1).eq.nbsoav(3) .and.
     >       nbsoav(3).eq.nbsoav(5) ) then
c
          iaux = abs(nbsono-nbsoci)
          jaux = abs(nbsoav(1)-nbsoci)
#ifdef _DEBUG_HOMARD_
          write (ulsort,90002) 'nbsono-nbsoci', iaux
          write (ulsort,90002) 'nbsoav(1)-nbsoci', jaux
#endif
          if ( iaux.le.jaux ) then
#ifdef _DEBUG_HOMARD_
            write (ulsort,texte(langue,10))
#endif
            nupaci = -1
          endif
c
        endif
c
      endif
c
c 4.4. ==> Poursuite aux passages suivants
c          On decale de la meme quantite quand on progresse dans
c          le meme sens, sinon dichotomie
c
      if ( nupaci.gt.1 ) then
c
c 4.4.1. ==> Si pas assez de raffinement
c
        if ( nbsono.lt.nbsoci ) then
#ifdef _DEBUG_HOMARD_
          write (ulsort,texte(langue,6)) ' '
#endif
c           Pas assez de raffinement au passage precedent
          if ( nbsoav(1).lt.nbsoci ) then
#ifdef _DEBUG_HOMARD_
            write (ulsort,texte(langue,6)) 'avant'
#endif
            daux = seuilh - seuinf
            seuinf = seuilh
            seuilh = min(seusup, seuilh+daux)
          else
            seuinf = seuilh
#ifdef _DEBUG_HOMARD_
            write (ulsort,texte(langue,7)) 'avant'
#endif
            seuilh = 0.5d0*(seusup+seuilh)
          endif
c
c 4.4.2. ==> Si trop de raffinement
c
        else
#ifdef _DEBUG_HOMARD_
          write (ulsort,texte(langue,7)) ' '
#endif
c           Pas assez de raffinement au passage precedent
          if ( nbsoav(1).lt.nbsoci ) then
#ifdef _DEBUG_HOMARD_
            write (ulsort,texte(langue,6)) 'avant'
#endif
            seusup = seuilh
            seuilh = 0.5d0*(seuilh+seuinf)
          else
#ifdef _DEBUG_HOMARD_
            write (ulsort,texte(langue,7)) 'avant'
#endif
            daux = seuilh - seusup
            seusup = seuilh
            seuilh = max(seuinf, seuilh+daux)
          endif
c
        endif
c
      endif
c
c 4.5. ==> Preparation de l'etape suivante
c
      if ( nupaci.ge.1 ) then
c
        do 45 , iaux = 6, 2, -1
          nbsoav(iaux) = nbsoav(iaux-1)
   45   continue
        nbsoav(1) = nbsono
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,90002) 'nbsoav apres', nbsoav
        write (ulsort,90004) 'seuilh apres', seuilh
        write (ulsort,90004) 'seuinf apres', seuinf
        write (ulsort,90004) 'seusup apres', seusup
#endif
c
        nupaci = nupaci + 1
c
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'nupaci', nupaci
#endif
c
#ifdef _DEBUG_HOMARD_
      if ( nupaci.lt.0 ) then
        write (ulsort,texte(langue,11))
      endif
#endif
c
      endif
c
c====
c 5. la fin
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
c=======================================================================
      endif
c=======================================================================
c
      end
