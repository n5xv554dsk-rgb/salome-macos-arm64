      subroutine infc33 ( numcas, nbcomp, nbentc,
     >                    profil, vafoti, vafotr,
     >                    tritet, cotrte, aretet,
     >                    pertet, pthepe, ntetca,
     >                    coonoe, somare,
     >                    aretri, nivtri,
     >                    nivqua,
     >                    quahex, facpen,
     >                    npterc, tetrec,
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
c  INformation - inFormations Complementaires - phase 33
c  --              -          -                       --
c  Valeurs sur les tetraedres
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . numcas . e   .   1    . numero du cas en cours de traitement       .
c .        .     .        . 1 : niveau                                 .
c .        .     .        . 2 : qualite                                .
c .        .     .        . 3 : diametre                               .
c .        .     .        . 4 : parente                                .
c .        .     .        . 5 : voisins des recollements               .
c . nbcomp . e   .   1    . nombre de composantes                      .
c . nbentc . e   .   1    . nombre total d'entites du calcul           .
c . profil .  s  . nbentc . pour chaque entite du calcul :             .
c .        .     .        . 0 : l'entite est absente du profil         .
c .        .     .        . 1 : l'entite est presente dans le profil   .
c . vafoti .  s  . nbentc . tableau temporaire de la fonction          .
c . vafotr .  s  . nbentc . tableau temporaire de la fonction          .
c . tritet . e   .nbtecf*4. numeros des 4 triangles des tetraedres     .
c . cotrte . e   .nbtecf*4. code des 4 triangles des tetraedres        .
c . aretet . e   .nbteca*6. numeros des 6 aretes des tetraedres        .
c . pertet . e   . nbteto . pere des tetraedres                        .
c .        .     .        . si pertet(i) > 0 : numero du tetraedre     .
c .        .     .        . si pertet(i) < 0 : -numero dans pthepe     .
c . pthepe . e   .    *   . si i <= nbheco : numero de l'hexaedre      .
c .        .     .        . si non : numero du pentaedre               .
c . ntetca . e   .   *    . nro des tetraedres dans le calcul          .
c . coonoe . e   . nbnoto . coordonnees des noeuds                     .
c .        .     . * sdim .                                            .
c . somare . e   .2*nbarto. numeros des extremites d'arete             .
c . aretri . e   .nbtrto*3. numeros des 3 aretes des triangles         .
c . nivtri . e   . nbtrto . niveau dans le raffinement/deraffinement   .
c . nivqua . e   . nbquto . niveau dans le raffinement/deraffinement   .
c . quahex . e   .nbhecf*6. numeros des 6 quadrangles des hexaedres    .
c . facpen . e   .nbpecf*5. numeros des 5 faces des pentaedres         .
c . npterc . e   .   1    . nombre de paires de tetraedres recolles    .
c . tetrec . e   .3*npterc. paires des tetra. voisins faces a recoller .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . 5 : mauvais type de code de calcul associe .
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
      parameter ( nompro = 'INFC33' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
#include "envca1.h"
#include "impr02.h"
#include "nombno.h"
#include "nombar.h"
#include "nombtr.h"
#include "nombqu.h"
#include "nombte.h"
#include "nombhe.h"
#include "nombpe.h"
c
c 0.3. ==> arguments
c
      integer numcas
      integer nbcomp, nbentc
      integer profil(nbentc)
      integer vafoti(nbentc)
      integer tritet(nbtecf,4), cotrte(nbtecf,4), aretet(nbteca,6)
      integer pertet(nbteto), pthepe(*), ntetca(*)
      integer somare(2,nbarto)
      integer aretri(nbtrto,3), nivtri(nbtrto)
      integer nivqua(nbquto)
      integer quahex(nbhecf,6)
      integer facpen(nbpecf,5)
      integer npterc, tetrec(3,npterc)
c
      double precision coonoe(nbnoto,sdim)
      double precision vafotr(nbentc)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux, kaux, laux
      integer indice
c
      double precision niveau, qualit, qualij, volume, diamet
c
      integer nbmess
      parameter ( nbmess = 10 )
      character*80 texte(nblang,nbmess)
c
c 0.5. ==> initialisations
c ______________________________________________________________________
c
c====
c 1. messages
c====
c
#include "impr01.h"
#include "impr03.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
      texte(1,4) = '(''.. Valeurs sur les '',a)'
c
      texte(2,4) = '(''.. Values over the '',a)'
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) mess14(langue,3,3)
      write (ulsort,90002) 'numcas', numcas
      write (ulsort,90002) 'nbteto', nbteto
      write (ulsort,90002) 'nbtepe', nbtepe
      write (ulsort,90002) 'nbtecf', nbtecf
      write (ulsort,90002) 'nbcomp', nbcomp
      write (ulsort,90002) 'nbentc', nbentc
      write (ulsort,90002) 'npterc', npterc
#endif
c
      codret = 0
c
c====
c 2. Rien par defaut
c====
c
      do 21 , iaux = 1 , nbentc
        profil(iaux) = 0
   21 continue
c
c====
c 3. Niveau
c====
c
      if ( numcas.eq.1 ) then
c
c 3.1. ==> Les tetraedres de depart ou issus d'un decoupage en 8
c          Les faces sont toutes du meme niveau
c          Remarque : ils sont toujours decrits par faces
c
        do 31 , iaux = 1 , nbtepe
c
cgn      write (ulsort,90015) 'ntetca(',iaux,') =', ntetca(iaux)
c
          jaux = ntetca(iaux)
          if ( jaux.ne.0 ) then
cgn      write (ulsort,90015) 'nivtri(',iaux,') =', nivtri(tritet(iaux,1))
            vafotr(jaux) = dble(nivtri(tritet(iaux,1)))
            profil(jaux) = 1
          endif
c
   31   continue
c
c 3.2. ==> Les tetraedres issus d'un decoupage de conformite
c          Remarque : ils sont toujours actifs
c
        do 32 , iaux = nbtepe+1 , nbteto
c
          call utntet ( iaux, niveau,
     >                  tritet, pertet, pthepe,
     >                  nivtri, nivqua,
     >                  quahex, facpen )
c
          jaux = ntetca(iaux)
          vafotr(jaux) = niveau
          profil(jaux) = 1
c
   32   continue
c
c====
c 4. Qualite
c====
c
      elseif ( numcas.eq.2 ) then
c
        do 41 , iaux = 1 , nbteto
c
          jaux = ntetca(iaux)
          if ( jaux.ne.0 ) then
            kaux = iaux
            call utqtet ( kaux, qualit, qualij, volume,
     >                     coonoe, somare, aretri,
     >                     tritet, cotrte, aretet )
            vafotr(jaux) = qualit
            profil(jaux) = 1
          endif
c
   41   continue
c
c====
c 5. Diametre
c====
c
      elseif ( numcas.eq.3 ) then
c
        do 51 , iaux = 1 , nbteto
c
          jaux = ntetca(iaux)
          if ( jaux.ne.0 ) then
            kaux = iaux
            call utdtet ( kaux, diamet,
     >                    coonoe, somare, aretri,
     >                    tritet, cotrte, aretet )
            vafotr(jaux) = diamet
            profil(jaux) = 1
c
          endif
c
   51   continue
c
c====
c 6. Parente
c====
c
      elseif ( numcas.eq.4 ) then
c
        do 61 , iaux = 1 , nbteto
c
          jaux = ntetca(iaux)
          if ( jaux.ne.0 ) then
            vafoti(jaux) = pertet(iaux)
            profil(jaux) = 1
          endif
c
   61   continue
c
c====
c 7. Voisins par recollement
c====
c
      elseif ( numcas.eq.5 ) then
c
c 7.1. ==> On met des valeurs nulles par defaut
c
        do 71 , iaux = 1 , nbteto
c
          jaux = ntetca(iaux)
          if ( jaux.ne.0 ) then
            indice = nbcomp*(jaux-1) + 1
            do 711 , kaux = 1 , nbcomp
              vafoti(indice) = 0
              indice = indice + 1
  711       continue
            profil(jaux) = 1
          endif
c
   71   continue
c
c 7.2. ==> Percours des paires enregistrees
c
        do 72 , iaux = 1 , npterc
c
          jaux = tetrec(1,iaux)
          kaux = tetrec(2,iaux)
cgn          write (ulsort,90002) 'iaux, jaux, kaux, face',
cgn     >                          iaux, jaux, kaux, tetrec(3,iaux)
c
          if ( jaux.ne.0 ) then
            indice = nbcomp*(jaux-1) + 1
            if ( vafoti(indice).eq.0 ) then
              vafoti(indice) = kaux
              vafoti(indice+1) = tetrec(3,iaux)
              profil(jaux) = 1
            endif
          endif
c
          if ( kaux.ne.0 ) then
            indice = nbcomp*(kaux-1) + 1
            do 723 , laux = 1, 3
              if ( vafoti(indice).eq.0 ) then
                vafoti(indice) = jaux
                vafoti(indice+1) = tetrec(3,iaux)
                profil(kaux) = 1
                goto 724
              endif
              indice = indice + 2
  723       continue
  724       continue
          endif
c
   72   continue
c
cgn        do 73 , iaux = 1,nbentc
cgn          write(ulsort,90112)'profil',iaux,profil(iaux)
cgn       write (ulsort,90002) 'indices', nbcomp*(iaux-1)+1,nbcomp*iaux
cgn          write(ulsort,90112)'vafoti',iaux,
cgn     >(vafoti(jaux),jaux=nbcomp*(iaux-1)+1,nbcomp*iaux)
cgn   73 continue
c
      endif
c
c====
c 8. la fin
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
