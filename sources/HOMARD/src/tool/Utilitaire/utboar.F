      subroutine utboar ( choix,
     >                    nbarto, nbtrto, nbquto, nbteto, nbfaar,
     >                    hetare, filare,
     >                    posifa, facare,
     >                    aretri, hettri, voltri,
     >                    arequa, hetqua,
     >                    nbar2d, nbar3d, borare,
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
c    UTilitaire - BOrd - ARetes
c    --           --     --
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . choix  . e   .   1    . choix du travail a faire                   .
c .        .     .        . 1 : les aretes du bord du domaine          .
c .        .     .        . 2 : les aretes a la limite entre deux zones.
c .        .     .        .     de raffinement de niveau different     .
c .        .     .        . 3 : idem mais en ignorant le bord exterieur.
c . nbarto . e   .   1    . nombre d'aretes total                      .
c . nbtrto . e   .   1    . nombre de triangles total                  .
c . nbquto . e   .   1    . nombre de quadrangles total                .
c . nbteto . e   .   1    . nombre de tetraedres total                 .
c . hetare . e   . nbarto . historique de l'etat des aretes            .
c . filare . e   . nbarto . fille ainee de chaque arete                .
c . posifa . e   .0:nbarto. pointeur sur tableau facare                .
c . facare . e   . nbfaar . liste des faces contenant une arete        .
c . aretri . e   .nbtrto*3. numeros des 3 aretes des triangles         .
c . hettri . e   . nbtrto . historique de l'etat des triangles         .
c . voltri . e   .2*nbtrto. numeros des 2 volumes par triangle         .
c .        .     .        . voltri(i,k) definit le i-eme voisin de k   .
c .        .     .        .   0 : pas de voisin                        .
c .        .     .        . j>0 : tetraedre j                          .
c .        .     .        . j<0 : pyramide/pentaedre dans pypetr(1/2,j).
c . arequa . e   .nbquto*4. numeros des 4 aretes des quadrangles       .
c . hetqua . e   . nbquto . historique de l'etat des quadrangles       .
c . nbar2d .  s  .   1    . nombre d'aretes de bord 2D                 .
c . nbar3d .  s  .   1    . nombre d'aretes de bord 3D                 .
c . borare .  s  . nbarto . reperage des aretes de bord                .
c .        .     .        . avec le choix 1 (aretes du bord du domaine).
c .        .     .        . 0 : l'arete est interne au domaine         .
c .        .     .        . 1 : l'arete borde une region 2D            .
c .        .     .        . 2 : l'arete borde une region 3D            .
c .        .     .        . avec le choix 3 (aretes du bord du domaine).
c .        .     .        . 0 : l'arete est interne au domaine         .
c .        .     .        . 1 : l'arete borde une region 2D            .
c .        .     .        . 2 : l'arete borde une region 3D            .
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
      parameter ( nompro = 'UTBOAR' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "impr02.h"
c
c 0.3. ==> arguments
c
      integer choix
      integer nbarto, nbtrto, nbquto, nbteto, nbfaar
      integer hetare(nbarto), filare(nbarto)
      integer posifa(0:nbarto), facare(nbfaar)
      integer aretri(nbtrto,3), hettri(nbtrto)
      integer voltri(2,nbtrto)
      integer arequa(nbquto,4), hetqua(nbquto)
      integer nbar2d, nbar3d, borare(nbarto)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux
      integer ideb, ifin
      integer larete, laface
      integer nbfact
#ifdef _DEBUG_HOMARD_
      integer glop
#endif
c
      logical aubord
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
      texte(1,4) = '(''Nombre d''''aretes de bord '',i1,''D :'',i10)'
      texte(1,5) = '(''Traitement des '',a)'
      texte(1,6) = '(a,''.. Examen du '',a,''numero '',i10)'
c
      texte(2,4) = '(''Number of '',i1,''D boundary edges :'',i10)'
      texte(2,5) = '(''Treatment of '',a)'
      texte(2,6) = '(a,''.. Examination of '',a,'',# '',i10)'
c
#include "impr03.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'choix', choix
#endif
c
      codret = 0
c
c====
c 2. initialisations : tout est interne
c====
c
      do 20 , larete = 1, nbarto
        borare(larete) = 0
   20 continue
c
c====
c 3. recherche des aretes de bords du domaine
c====
c
      if ( choix.eq.1 ) then
c
c 3.1. ==> les 3 aretes d'un triangle qui borde un tetraedre et un seul
c          sont de bord. c'est le bord du domaine volumique.
c
        if ( nbteto.ne.0 ) then
c
          do 31 , laface = 1, nbtrto
            if ( voltri(1,laface).lt.0 .or. voltri(2,laface).lt.0) then
               codret = 12
               goto 66
            endif
            if ( voltri(1,laface).ne.0 .and.
     >           voltri(2,laface).eq.0 ) then
              borare(aretri(laface,1)) = 2
              borare(aretri(laface,2)) = 2
              borare(aretri(laface,3)) = 2
            endif
   31     continue
c
        endif
c
c 3.2. ==> chaque arete qui ne borde qu'une face est de bord. c'est
c          le bord du domaine surfacique.
c
        do 32 , larete = 1, nbarto
c
          if ( posifa(larete-1)+1 .eq. posifa(larete) ) then
            borare(larete) = 1
          endif
c
   32   continue
c
      endif
c
c====
c 4. recherche des aretes de bords des zones de differents niveaux
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '4. recherche ; codret', codret
#endif
c
      if ( choix.eq.2 .or. choix.eq.3 ) then
c
        do 41 , larete = 1 , nbarto
c
          aubord = .false.
c
#ifdef _DEBUG_HOMARD_
        if ( larete.eq.-12) then
          glop = 1
        else
          glop = 0
        endif
#endif
c
c       On s'interesse aux aretes coupees en 2
c
            jaux = mod(hetare(larete),10)
            if ( ( jaux.eq.2 ) .or. ( jaux.eq.9 ) ) then
c
c 4.1. ==> Si l'arete a ete reperee au bord par sa mere, on le progage
c          directement aux filles
c
            if ( borare(larete).gt.0 ) then
c
              aubord = .true.
c
            else
c
c 4.2. ==> Sinon, on fait l'analyse.
c
#ifdef _DEBUG_HOMARD_
        if ( glop.ne.0 ) then
        write (ulsort,texte(langue,6)) ' ', mess14(langue,1,1), larete
        endif
#endif
c
c 4.2.1. ==> decompte du nombre de faces actives voisines de cette arete
c
              ideb = posifa(larete-1) + 1
              ifin = posifa(larete)
              nbfact = 0
              do 421 , iaux = ideb, ifin
c
                laface = facare(iaux)
                if ( laface.gt.0 ) then
                  if ( mod(hettri(laface),10).eq.0 ) then
                    nbfact = nbfact + 1
                  endif
                else
                  if ( mod(hetqua(-laface),100).eq.0 ) then
                    nbfact = nbfact + 1
                  endif
                endif
#ifdef _DEBUG_HOMARD_
          if ( glop.ne.0 ) then
              if ( laface.gt.0 ) then
                jaux = 2
              else
                jaux = 4
              endif
          write (ulsort,texte(langue,6)) ' ..',
     >          mess14(langue,1,jaux), abs(laface)
          endif
#endif
c
  421         continue
c
c 4.2.2. ==> Si au moins une face est active et qu'au moins une autre
c            est coupee, c'est que l'arete est a une limite de niveau
c
#ifdef _DEBUG_HOMARD_
        if ( glop.ne.0 ) then
        write (ulsort,90002) '. nbfact', nbfact
        write (ulsort,90002) '. nbfdec', ifin-ideb+1-nbfact
        endif
#endif
c
              if ( nbfact.ge.(choix-2) ) then
c
                iaux = ifin - ideb + 1 - nbfact
                if ( iaux.ge.1 ) then
                  aubord = .true.
                endif
c
              endif
c
            endif
c
          endif
c
c 4.3. ==> enregistrement des deux filles
c
          if ( aubord ) then
c
            do 43 , jaux = 0, 1
#ifdef _DEBUG_HOMARD_
        if ( glop.ne.0 ) then
        write (ulsort,90002) '.. reperage de l''arete',
     >                       filare(larete)+jaux
        endif
#endif
              borare(filare(larete)+jaux) = 1
   43       continue
c
          endif
c
   41   continue
c
      endif
c
c====
c 5. decompte des aretes de bords
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '5. decompte ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      nbar2d = 0
      nbar3d = 0
      do 50 , larete = 1, nbarto
        if ( borare(larete).eq.1 ) then
          nbar2d = nbar2d + 1
        elseif ( borare(larete).eq.2 ) then
          nbar3d = nbar3d + 1
        endif
   50 continue
c
      endif
c
c====
c 6. la fin
c====
c
   66 continue
c
#ifdef _DEBUG_HOMARD_
      write(ulsort,texte(langue,4)) 2, nbar2d
      write(ulsort,texte(langue,4)) 3, nbar3d
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
