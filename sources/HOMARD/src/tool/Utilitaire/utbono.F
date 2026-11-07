      subroutine utbono ( choix,
     >                    nbnoto,
     >                    nbarto, nbtrto, nbquto, nbteto, nbfaar,
     >                    somare,
     >                    filare, hetare,
     >                    posifa, facare,
     >                    hettri, aretri, voltri,
     >                    hetqua, arequa,
     >                    nbnobo, bornoe,
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
c    UTilitaire - BOrd - NOeuds
c    --           --     --
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . choix  . e   .   1    . choix du travail a faire                   .
c .        .     .        . 1 : les noeuds du bord du domaine          .
c .        .     .        . 2 : les noeuds a la limite entre deux zones.
c .        .     .        .     de raffinement de niveau different     .
c .        .     .        . 3 : idem mais en ignorant le bord exterieur.
c . nbnoto . e   .   1    . nombre de noeuds total                     .
c . nbarto . e   .   1    . nombre d'aretes total                      .
c . nbtrto . e   .   1    . nombre de triangles total                  .
c . nbquto . e   .   1    . nombre de quadrangles total                .
c . nbteto . e   .   1    . nombre de tetraedres total                 .
c . somare . e   .nbarto*2. numeros des extremites d'arete             .
c . filare . e   . nbarto . fille ainee de chaque arete                .
c . hetare . e   . nbarto . historique de l'etat des aretes            .
c . posifa . e   .0:nbarto. pointeur sur tableau facare                .
c . facare . e   . nbfaar . liste des faces contenant une arete        .
c . hettri . e   . nbtrto . historique de l'etat des triangles         .
c . aretri . e   .nbtrto*3. numeros des 3 aretes des triangles         .
c . voltri . e   .2*nbtrto. numeros des 2 volumes par triangle         .
c .        .     .        . voltri(i,k) definit le i-eme voisin de k   .
c .        .     .        .   0 : pas de voisin                        .
c .        .     .        . j>0 : tetraedre j                          .
c .        .     .        . j<0 : pyramide/pentaedre dans pypetr(1/2,j).
c . hetqua . e   . nbquto . historique de l'etat des quadrangles       .
c . arequa . e   .nbquto*4. numeros des 4 aretes des quadrangles       .
c . nbnobo .  s  .   1    . nombre de noeuds de bord                   .
c . bornoe .  s  . nbnoto . reperage des noeuds de bord                .
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
      parameter ( nompro = 'UTBONO' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "gmenti.h"
c
c 0.3. ==> arguments
c
      integer choix
      integer nbnoto, nbarto, nbtrto, nbquto, nbteto, nbfaar
      integer somare(2,nbarto)
      integer hetare(nbarto), filare(nbarto)
      integer posifa(0:nbarto), facare(nbfaar)
      integer hettri(nbtrto), aretri(nbtrto,3)
      integer voltri(2,nbtrto)
      integer hetqua(nbquto), arequa(nbquto,4)
      integer nbnobo, bornoe(nbnoto)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, lenoeu, nbar2d, nbar3d
      integer adtrav
c
      character*8 ntrava
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
      texte(1,4) = '(''Nombre de noeuds de bord :'',i10)'
c
      texte(2,4) = '(''Number of boundary nodes :'',i10)'
c
      codret = 0
c
c====
c 2. recherche des aretes de bords du domaine
c====
c
      call gmalot ( ntrava, 'entier', nbarto, adtrav, codret )
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTBOAR', nompro
#endif
      call utboar ( choix,
     >              nbarto, nbtrto, nbquto, nbteto, nbfaar,
     >              hetare, filare,
     >              posifa, facare,
     >              aretri, hettri, voltri,
     >              arequa, hetqua,
     >              nbar2d, nbar3d, imem(adtrav),
     >              ulsort, langue, codret )
c
      endif
c
c====
c 3. determination des noeuds de bords
c====
c
      if ( codret.eq.0 ) then
c
      do 31 , lenoeu = 1, nbnoto
        bornoe(lenoeu) = 0
   31 continue
c
      do 32 , iaux = 1, nbarto
        if ( imem(adtrav+iaux-1).ne.0 ) then
          bornoe(somare(1,iaux)) = 1
          bornoe(somare(2,iaux)) = 1
        endif
   32 continue
c
      nbnobo = 0
      do 33 , lenoeu = 1, nbnoto
        nbnobo = nbnobo + bornoe(lenoeu)
cgn      write(ulsort,*) lenoeu,' : ',bornoe(lenoeu)
   33 continue
c
      endif
c
c====
c 4. la fin
c====
c
      if ( codret.eq.0 ) then
c
      call gmlboj ( ntrava, codret )
c
      endif
c
#ifdef _DEBUG_HOMARD_
      write(ulsort,texte(langue,4)) nbnobo
#endif
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
