      subroutine utboqu ( nbquto, nbheto, numead,
     >                    nivqua, filqua, perqua,
     >                    hethex, hetpyr,
     >                    volqua, pypequ,
     >                    borqua,
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
c    UTilitaire - BOrd - quadrangles
c    --           --     --
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nbquto . e   .   1    . nombre de quadrangles total                .
c . nbheto . e   .   1    . nombre d'hexaedres total                   .
c . numead . e   .   1    . numero de la mere adoptive                 .
c . nivqua . e   . nbquto . niveau des quadrangles                     .
c . filqua . e   . nbquto . fils des quadrangles                       .
c . perqua . e   . nbquto . pere des quadrangles                       .
c . hethex . e   . nbheto . historique de l'etat des hexaedres         .
c . hetpyr . e   . nbpyto . historique de l'etat des pyramides         .
c . volqua . e   .nbquto*2. numeros des 2 volumes par quadrangle       .
c .        .     .        . volqua(i,k) definit le i-eme voisin de k   .
c .        .     .        .   0 : pas de voisin                        .
c .        .     .        . j>0 : hexaedre j                           .
c .        .     .        . j<0 : pyramide/pentaedre dans pypequ(1/2,j).
c . pypequ . e   .2*lgpype. pypequ(1,j) = numero de la pyramide voisine.
c .        .     .        . du quadrangle k tel que volqua(k,1/2) = -j .
c .        .     .        . pypequ(2,j) = numero du pentaedre voisin   .
c .        .     .        . du quadrangle k tel que volqua(k,1/2) = -j .
c . borqua .  s  . nbquto . reperage des quadrangles de bord           .
c .        .     .        . -1 : quadrangle non classe                 .
c .        .     .        .  0 : quadrangle bidimensionnel             .
c .        .     .        .  1 : quadrangle au bord d'un seul hexaedre .
c .        .     .        .  2 : quadrangle entre 2 hexaedres          .
c .        .     .        .  3 : quadrangle de non conformite          .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . sinon : probleme                           .
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
      parameter ( nompro = 'UTBOQU' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
#include "impr02.h"
c
c 0.3. ==> arguments
c
      integer nbquto, nbheto, numead
      integer nivqua(nbquto)
      integer filqua(nbquto), perqua(nbquto)
      integer hethex(*), hetpyr(*)
      integer volqua(2,nbquto), pypequ(2,*)
      integer borqua(nbquto)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux
      integer nbqu2d, nbqubo, nbquv2, nbquv3, nbquv4, nbqunc
c
      integer nbmess
      parameter ( nbmess = 10 )
      character*80 texte(nblang,nbmess)
c ______________________________________________________________________
c
c====
c 1. messages
c====
c
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
      texte(1,4) =
     > '(''Nombre de '',a,'' de regions bidimensionnelles :'',i10)'
      texte(1,5) =
     > '(''Nombre de '',a,'' de bord                      :'',i10)'
      texte(1,6) =
     > '(''Nombre de '',a,'' internes aux volumes         :'',i10)'
      texte(1,7) =
     > '(''Nombre de '',a,'' de non conformite            :'',i10)'
      texte(1,8) =
     > '(''Nombre de '',a,'' non classes                  :'',i10)'
c
      texte(2,4) =
     > '(''Number of '',a,'' in 2D regions     :'',i10)'
      texte(2,5) =
     > '(''Number of boundary '',a,''          :'',i10)'
      texte(2,6) =
     > '(''Number of '',a,'' inside of volume  :'',i10)'
      texte(2,7) =
     > '(''Number of non conformal '',a,''     :'',i10)'
      texte(2,8) =
     > '(''Number of '',a,'' without any place :'',i10)'
c
      codret = 0
c
c====
c 2. appel du programme generique
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTBOFA', nompro
#endif
      iaux = 4
      call utbofa ( iaux, numead,
     >              nbquto, nbheto,
     >              nivqua, filqua, perqua,
     >              hethex, hetpyr,
     >              volqua, pypequ,
     >              borqua, nbqu2d, nbqubo,
     >              nbquv2, nbquv3, nbquv4, nbqunc,
     >              ulsort, langue, codret )
c
#ifdef _DEBUG_HOMARD_
      if ( codret.eq.0 ) then
      iaux = 4
      write(ulsort,texte(langue,4)) mess14(langue,3,iaux), nbqu2d
      write(ulsort,texte(langue,5)) mess14(langue,3,iaux), nbqubo
      write(ulsort,texte(langue,6)) mess14(langue,3,iaux), nbquv2
      write(ulsort,texte(langue,7)) mess14(langue,3,iaux), nbqunc
      write(ulsort,texte(langue,8)) mess14(langue,3,iaux),
     >                        nbquto - nbqu2d - nbqubo - nbquv2 - nbqunc
      endif
#endif
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
c
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      call dmflsh (iaux)
#endif
c
      end
