      subroutine infc35 ( numcas, nbcomp, nbentc,
     >                    profil, vafoti, vafotr,
     >                    facpyr, cofapy, arepyr,
     >                    perpyr, pphepe, npyrca,
     >                    coonoe, somare,
     >                    aretri, nivtri,
     >                    nivqua,
     >                    quahex, facpen,
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
c  INformation - inFormations Complementaires - phase 35
c  --              -          -                       --
c  Valeurs sur les pyramides
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
c . facpyr . e   .nbpycf*5. numeros des 5 faces des pyramides          .
c . cofapy . e   .nbpycf*5. codes des faces des pyramides              .
c . arepyr . e   .nbpyca*8. numeros des 8 aretes des pyramides         .
c . perpyr . e   . nbpyto . pere des pyramides                         .
c .        .     .        . si perpyr(i) > 0 : numero de la pyramide   .
c .        .     .        . si perpyr(i) < 0 : -numero dans pphepe     .
c . pphepe . e   .    *   . si i <= nbheco : numero de l'hexaedre      .
c .        .     .        . si non : numero du pentaedre               .
c . npyrca . e   .   *    . nro des pyramides dans le calcul           .
c . coonoe . e   . nbnoto . coordonnees des noeuds                     .
c .        .     . * sdim .                                            .
c . somare . e   .2*nbarto. numeros des extremites d'arete             .
c . aretri . e   .nbtrto*3. numeros des 3 aretes des triangles         .
c . nivtri . e   . nbtrto . niveau dans le raffinement/deraffinement   .
c . nivqua . e   . nbquto . niveau dans le raffinement/deraffinement   .
c . quahex . e   .nbhecf*6. numeros des 6 quadrangles des hexaedres    .
c . facpen . e   .nbpecf*5. numeros des 5 faces des pentaedres         .
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
      parameter ( nompro = 'INFC35' )
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
#include "nombpy.h"
#include "nombhe.h"
#include "nombpe.h"
c
c 0.3. ==> arguments
c
      integer numcas
      integer nbcomp, nbentc
      integer profil(nbentc)
      integer vafoti(nbentc)
      integer facpyr(nbpycf,5), cofapy(nbpycf,5), arepyr(nbpyca,8)
      integer perpyr(nbpyto), pphepe(*), npyrca(*)
      integer somare(2,nbarto)
      integer aretri(nbtrto,3), nivtri(nbtrto)
      integer nivqua(nbquto)
      integer quahex(nbhecf,6)
      integer facpen(nbpecf,5)
c
      double precision coonoe(nbnoto,sdim)
      double precision vafotr(nbentc)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux, kaux
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
      write (ulsort,texte(langue,4)) mess14(langue,3,5)
      write (ulsort,90002) 'numcas', numcas
      write (ulsort,90002) 'nbpyto', nbpyto
      write (ulsort,90002) 'nbpype', nbpype
      write (ulsort,90002) 'nbpycf', nbpycf
      write (ulsort,90002) 'nbentc', nbentc
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
c 3.1. ==> Les pyramides de depart ou issus d'un decoupage en 8
c          Les faces sont toutes du meme niveau
c          Remarque : elles sont toujours decrites par faces
c
        do 31 , iaux = 1 , nbpype
c
cgn      write (ulsort,90015) 'npyrca(',iaux,') =', npyrca(iaux)
cgn      write (ulsort,90015) 'nivtri(',iaux,') =', nivtri(iaux)
c
          jaux = npyrca(iaux)
          if ( jaux.ne.0 ) then
            vafotr(jaux) = dble(nivtri(facpyr(iaux,1)))
            profil(jaux) = 1
          endif
c
   31   continue
c
c 3.2. ==> Les pyramides issues d'un decoupage de conformite
c          Remarque : elles sont toujours actives
c
        do 32 , iaux = nbpype+1 , nbpyto
c
          call utnpyr ( iaux, niveau,
     >                  facpyr, perpyr, pphepe,
     >                  nivtri, nivqua,
     >                  quahex, facpen )
c
          jaux = npyrca(iaux)
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
        do 41 , iaux = 1 , nbpyto
c
          jaux = npyrca(iaux)
          if ( jaux.ne.0 ) then
            kaux = iaux
            call utqpyr ( kaux, qualit, qualij, volume,
     >                    coonoe, somare, aretri,
     >                    facpyr, cofapy, arepyr )
            vafotr(jaux) = qualit
            profil(jaux) = 1
c
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
        do 51 , iaux = 1 , nbpyto
c
          jaux = npyrca(iaux)
          if ( jaux.ne.0 ) then
            kaux = iaux
            call utdpyr ( kaux, diamet,
     >                    coonoe, somare, aretri,
     >                    facpyr, cofapy, arepyr )
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
        do 61 , iaux = 1 , nbpyto
c
          jaux = npyrca(iaux)
          if ( jaux.ne.0 ) then
            vafoti(jaux) = perpyr(iaux)
            profil(jaux) = 1
          endif
c
   61   continue
c
      endif
c
c====
c 7. la fin
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
