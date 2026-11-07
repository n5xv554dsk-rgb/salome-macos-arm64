      subroutine deisv6 ( laface, typfac, lamail, typenh,
     >                    hettri, pertri,
     >                    hetqua, perqua,
     >                    pertet,
     >                    hethex, filhex, perhex, fhpyte,
     >                    voltri, pypetr,
     >                    volqua, pypequ,
     >                    nbvote, voiste,
     >                    nbvohe, voishe,
     >                    nbvopy, voispy,
     >                    nbvope, voispe,
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
c    traitement des DEcisions - Initialisations - par Saut - Volumes - 6
c                   --          -                     -      -         -
c   Recherche des voisins d'une maille decrite par ses faces
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . laface . e   .   1    . la face en cours d'examen                  .
c . typfac . e   .   1    . type de la face                            .
c .        .     .        . 2 : triangles                              .
c .        .     .        . 4 : quadrangles                            .
c . lamail . e   .   1    . la maille en cours d'examen                .
c . typenh . e   .   1    . type de la maille                          .
c .        .     .        . 3 : tetraedres                             .
c .        .     .        . 5 : pyramides                              .
c .        .     .        . 6 : hexaedres                              .
c .        .     .        . 7 : pentaedres                             .
c . hettri . e   . nbtrto . historique de l'etat des triangles         .
c . pertri . e   . nbtrto . pere des triangles                         .
c . hetqua . e   . nbquto . historique de l'etat des quadrangles       .
c . perqua . e   . nbquto . pere des quadrangles                       .
c . pertet . e   . nbteto . pere des tetraedres                        .
c .        .     .        . si pertet(i) > 0 : numero du tetraedre     .
c .        .     .        . si pertet(i) < 0 : -numero dans pthepe     .
c . hethex . e   . nbheto . historique de l'etat des hexaedres         .
c . filhex . e   . nbheto . premier fils des hexaedres                 .
c . perhex . e   . nbheto . pere des hexaedres                         .
c . fhpyte . e   .2*nbheco. fhpyte(1,j) = numero de la 1ere pyramide   .
c .        .     .        . fille de l'hexaedre k tel que filhex(k) =-j.
c .        .     .        . fhpyte(2,j) = numero du 1er tetraedre      .
c .        .     .        . fils de l'hexaedre k tel que filhex(k) = -j.
c . voltri . es  .2*nbtrto. numeros des 2 volumes par triangle         .
c .        .     .        . voltri(i,k) definit le i-eme voisin de k   .
c .        .     .        .   0 : pas de voisin                        .
c .        .     .        . j>0 : tetraedre j                          .
c .        .     .        . j<0 : pyramide/pentaedre dans pypetr(1/2,j).
c . pypetr . e   .2*lgpype. pypetr(1,j) = numero de la pyramide voisine.
c .        .     .        . du triangle k tel que voltri(1/2,k) = -j   .
c .        .     .        . pypetr(2,j) = numero du pentaedre voisin   .
c .        .     .        . du triangle k tel que voltri(1/2,k) = -j   .
c . volqua . e   .2*nbquto. numeros des 2 volumes par quadrangle       .
c .        .     .        . volqua(i,k) definit le i-eme voisin de k   .
c .        .     .        .   0 : pas de voisin                        .
c .        .     .        . j>0 : hexaedre j                           .
c .        .     .        . j<0 : pyramide/pentaedre dans pypequ(1/2,j).
c . pypequ . e   .2*lgpype. pypequ(1,j) = numero de la pyramide voisine.
c .        .     .        . du quadrangle k tel que volqua(1/2,k) = -j .
c .        .     .        . pypequ(2,j) = numero du pentaedre voisin   .
c .        .     .        . du quadrangle k tel que volqua(1/2,k) = -j .
c . nbvote . es  .    1   . nombre de voisins de type tetraedre        .
c . voiste . es  . nbvote . les voisins de type tetraedre              .
c . nbvohe . es  .    1   . nombre de voisins de type hexaedre         .
c . voishe . es  . nbvohe . les voisins de type hexaedre               .
c . nbvopy . es  .    1   . nombre de voisins de type pyramide         .
c . voispy . es  . nbvopy . les voisins de type pyramide               .
c . nbvope . es  .    1   . nombre de voisins de type pentaedre        .
c . voispe . es  . nbvope . les voisins de type pentaedre              .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . 2 : probleme dans le traitement            .
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
      parameter ( nompro = 'DEISV6' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "impr02.h"
#include "nombtr.h"
#include "nombqu.h"
#include "nombte.h"
#include "nombhe.h"
#include "hexcf0.h"
c
c 0.3. ==> arguments
c
      integer laface, typfac
      integer lamail, typenh
      integer hettri(nbtrto), pertri(nbtrto)
      integer hetqua(nbquto), perqua(nbquto)
      integer pertet(nbteto)
      integer hethex(nbheto), filhex(nbheto), perhex(nbheto)
      integer fhpyte(2,nbheco)
      integer voltri(2,nbtrto), pypetr(2,*)
      integer volqua(2,nbquto), pypequ(2,*)
c
      integer nbvote, voiste(*)
      integer nbvohe, voishe(*)
      integer nbvopy, voispy(*)
      integer nbvope, voispe(*)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux, kaux, laux
      integer etat, bindec, lamere, lepere, levois
      integer nbfipy, filspy
      integer nbfite, filste
      integer nbfihe, filshe
c
      integer nbmess
      parameter (nbmess = 10 )
      character*80 texte(nblang,nbmess)
c ______________________________________________________________________
c
c====
c 1. initialisation
c====
c
c 1.1. ==> Les messages
c
#include "impr01.h"
#include "impr03.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
      texte(1,4) = '(''. Voisins de la maille'',i10,'' ('',a,'')'')'
c
      texte(2,4) =
     > '(''. Neighbourgs of the mesh #'',i10,'' ('',a,'')'')'
c
      codret = 0
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) lamail, mess14(langue,1,typenh)
#endif
c
c====
c 2. On parcourt tous les voisins de la face
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '2. parcours voisins face ; codret = ', codret
#endif
c
c 2.1. ==> L'etat de la face
c
      if ( typfac.eq.2 ) then
        etat = mod(hettri(laface),10)
      else
        etat = mod(hetqua(laface),100)
      endif
cgn      write (ulsort,90002) '.. etat', etat
c
c 2.2. ==> traitement pour une face non coupee
c
      if ( etat.eq.0 ) then
c
        do 221 , iaux = 1 , 2
cgn      write (ulsort,90002) '.... voisin de rang', iaux
c
c 2.2.1. ==> Cas de la face triangulaire
c
          if ( typfac.eq.2 ) then
c
            jaux = voltri(iaux,laface)
c
c 2.2.1.1. ==> Il existe un voisin tetraedre
            if ( jaux.gt.0 ) then
              nbvote = nbvote + 1
              voiste(nbvote) = jaux
c 2.2.1.2. ==> Il existe un voisin pyramide ou pentaedre
            elseif ( jaux.lt.0 ) then
              jaux = -jaux
              if ( pypetr(1,jaux).ne.0 ) then
                nbvopy = nbvopy + 1
                voispy(nbvopy) = pypetr(1,jaux)
              endif
              if ( pypetr(2,jaux).ne.0 ) then
                nbvope = nbvope + 1
                voispe(nbvope) = pypetr(2,jaux)
              endif
c 2.2.1.3. ==> Il n'existe pas de voisin
            else
              lamere = pertri(laface)
              if ( lamere.gt.0 ) then
                if ( voltri(2,lamere).ne.0 ) then
                  do 2211 , kaux = 1 , 2
                    levois = voltri(kaux,lamere)
                    if ( levois.ne.pertet(lamail) ) then
c
                  write(ulsort,*) 'A PROGRAMMER quand on aura'
                  write(ulsort,*) 'la conformite des pentaedres'
                  codret = 2211
c
                    endif
 2211             continue
                endif
              elseif ( lamere.lt.0 ) then
                if ( volqua(2,-lamere).ne.0 ) then
                  do 2212 , kaux = 1 , 2
                    levois = volqua(kaux,-lamere)
                    if ( levois.ne.pertet(lamail) ) then
c
                  write(ulsort,*) 'A PROGRAMMER quand on aura'
                  write(ulsort,*) 'la conformite des pentaedres'
                  codret = 2212
c
                    endif
 2212             continue
                endif
              endif
            endif
c
c 2.2.2. ==> Cas de la face quadrangulaire
c
          else
c
            jaux = volqua(iaux,laface)
cgn      write (ulsort,90002) '.... jaux', jaux
c 2.2.2.1. ==> Il existe un voisin hexaedre
            if ( jaux.gt.0 ) then
              nbvohe = nbvohe + 1
              voishe(nbvohe) = jaux
c 2.2.2.2. ==> Il existe un voisin pyramide ou pentaedre
            elseif ( jaux.lt.0 ) then
              jaux = -jaux
              if ( pypequ(1,jaux).ne.0 ) then
                nbvopy = nbvopy + 1
                voispy(nbvopy) = pypequ(1,jaux)
              endif
              if ( pypequ(2,jaux).ne.0 ) then
                nbvope = nbvope + 1
                voispe(nbvope) = pypequ(2,jaux)
              endif
c 2.2.2.3. ==> Il n'existe pas de voisin
c              Soit c'est un bord et il n'y a rien a faire.
c              Soit c'est que la maille du niveau precedent a ete
c              coupee par conformite et les fils sont decrites par
c              aretes : le voisinage n'est pas reconstitue. Dans ce
c              cas, on stocke tous les fils.
c              Remarque : la face mere ne peut avoir 2 voisins que
c              dans le cas d'hexaedres voisins. A completer quand
c              on aura programme le raffinement conforme complet
c              des pentaedres
            else
              lamere = perqua(laface)
cgn      write (ulsort,90002) 'lamere', lamere
              if ( lamere.gt.0 ) then
                if ( volqua(2,lamere).ne.0 ) then
                  do 2221 , kaux = 1 , 2
                    if ( volqua(kaux,lamere).ne.perhex(lamail) ) then
c
                      lepere = volqua(kaux,lamere)
                      etat = mod(hethex(lepere),1000)
                      bindec = chbiet(etat)
                      nbfihe = chnhe(bindec)
                      nbfipy = chnpy(bindec)
                      nbfite = chnte(bindec)
                      filshe = filhex(lepere)
                      if ( nbfihe.gt.0 ) then
                        do 22211 , laux = 0 , nbfihe-1
                          nbvohe = nbvohe + 1
                          voishe(nbvohe) = filshe + iaux
22211                   continue
                      endif
                      if ( nbfipy.gt.0 ) then
                        filspy = fhpyte(1,-filshe)
                        do 22212 , laux = 0 , nbfipy-1
                          nbvopy = nbvopy + 1
                          voispy(nbvopy) = filspy + iaux
22212                   continue
                      endif
                      if ( nbfite.gt.0 ) then
                        filste = fhpyte(2,-filshe)
                        do 22213 , laux = 0 , nbfite-1
                          nbvote = nbvote + 1
                          voiste(nbvote) = filste + iaux
22213                   continue
                      endif
c
                    endif
 2221             continue
                endif
              endif
            endif
c
          endif
c
  221   continue
c
      endif
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
