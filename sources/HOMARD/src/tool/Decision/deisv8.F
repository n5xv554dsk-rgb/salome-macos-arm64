      subroutine deisv8 ( lehexa,
     >                    filqua,
     >                    hethex, quahex,
     >                    filhex, fhpyte,
     >                    volqua,
     >                    nbfite, nbvote, voiste,
     >                    nbfihe, nbvohe, voishe,
     >                    nbfipy, nbvopy, voispy,
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
c    traitement des DEcisions - Initialisations - par Saut - Volumes - 8
c                   --          -                     -      -         -
c   Pour un hexaedre coupe par conformite et dont les fils sont decrits
c   par aretes :
c   - etablissement de la liste des fils par type de maille
c   - ajout des fils des voisins de l'hexaedre
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . lehexa . e   .   1    . l'hexaedre en cours d'examen               .
c . filqua . e   . nbquto . fils des quadrangles                       .
c . hethex . e   . nbheto . historique de l'etat des hexaedres         .
c . quahex . e   .nbhecf*6. numeros des 6 quadrangles des hexaedres    .
c . filhex . e   . nbheto . premier fils des hexaedres                 .
c . fhpyte . e   .2*nbheco. fhpyte(1,j) = numero de la 1ere pyramide   .
c .        .     .        . fille de l'hexaedre k tel que filhex(k) =-j.
c .        .     .        . fhpyte(2,j) = numero du 1er tetraedre      .
c .        .     .        . fils de l'hexaedre k tel que filhex(k) = -j.
c . volqua . e   .2*nbquto. numeros des 2 volumes par quadrangle       .
c .        .     .        . volqua(i,k) definit le i-eme voisin de k   .
c .        .     .        .   0 : pas de voisin                        .
c .        .     .        . j>0 : hexaedre j                           .
c .        .     .        . j<0 : pyramide/pentaedre dans pypequ(1/2,j).
c . nbfite .  s  .  1     . nombre de fils de type tetraedre           .
c . nbvote .  s  .    1   . nombre de voisins de type tetraedre        .
c . voiste .  s  . nbvote . les voisins de type tetraedre              .
c . nbfihe .  s  .  1     . nombre de fils de type hexaedre            .
c . nbvohe .  s  .    1   . nombre de voisins de type hexaedre         .
c . voishe .  s  . nbvohe . les voisins de type hexaedre               .
c . nbfipy .  s  .  1     . nombre de fils de type pyramide            .
c . nbvopy .  s  .    1   . nombre de voisins de type pyramide         .
c . voispy .  s  . nbvopy . les voisins de type pyramide               .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret .  s  .    1   . code de retour des modules                 .
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
      parameter ( nompro = 'DEISV8' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "impr02.h"
#include "nombqu.h"
#include "nombhe.h"
c
c 0.3. ==> arguments
c
      integer lehexa
      integer filqua(nbquto)
      integer hethex(nbheto), filhex(nbheto)
      integer quahex(nbhecf,6)
      integer fhpyte(2,nbheco)
      integer volqua(2,nbquto)
c
      integer nbfite, nbvote, voiste(*)
      integer nbfihe, nbvohe, voishe(*)
      integer nbfipy, nbvopy, voispy(*)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux, kaux, laux
      integer etat
      integer laface, levois
      integer lafafi, levofi
      integer filste
      integer filshe
      integer filspy
      integer nbfitf, filstf
      integer nbfihf, filshf
      integer nbfipf, filspf
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
      texte(1,4) = '(''. Voisins de l''''hexaedre'',i10,'')'
      texte(1,5) = '(''... Face '',i10,'')'
c
      texte(2,4) = '(''. Neighbourgs of the mesh #'',i10,'')'
      texte(2,5) = '(''... Face '',i10,'')'
c
      codret = 0
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) lehexa
#endif
c
c====
c 2. Recuperation des fils
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '2. parcours voisins face ; codret = ', codret
#endif
c
      call utfihe ( lehexa,
     >              hethex, filhex, fhpyte,
     >              nbfite, filste,
     >              nbfihe, filshe,
     >              nbfipy, filspy )
c
      nbvote = nbfite
      do 21 , iaux = 1 ,  nbfite
        voiste(iaux) = filste + iaux - 1
   21 continue
c
      nbvohe = nbfihe
      do 22 , iaux = 1 ,  nbfihe
        voishe(iaux) = filshe + iaux - 1
   22 continue
c
      nbvopy = nbfipy
      do 23 , iaux = 1 ,  nbfipy
        voispy(iaux) = filspy + iaux - 1
   23 continue
c
c====
c 3. On passe en revue les voisins par face de l'hexaedre
c====
c
      do 30 , iaux = 1 , 6
c
        laface = quahex(lehexa,iaux)
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,5)) laface
#endif
c
        do 31 , jaux = 1 , 2
c
          levois = volqua(jaux,laface)
c
c 3.1. ==> Le jaux-eme est un hexaedre
c
          if ( levois.gt.0 ) then
c
            if ( levois.ne.lehexa ) then
c
            etat = mod(hethex(levois),1000)
c 3.1.1. ==> Le voisin est actif : on le stocke
            if ( etat.eq.0 ) then
              nbvohe = nbvohe + 1
              voishe(nbvohe) = levois
c 3.1.2. ==> Le voisin est coupe en 8 avec eventuellement des
c            petits-fils :
c            On parcourt les 4 filles de laface : elles n'ont qu'un
c            voisin qui est un hexaedre fils de levois.
c            . Si ce fils est actif, on le stocke
c            . Sinon, c'est qu'il est coupe par conformite et
c              on stocke ses enfants.
            elseif ( etat.eq.8 .or. etat.eq.9 ) then
              lafafi = filqua(laface)
              do 312 , kaux = 1 , 4
                levofi = volqua(1,lafafi+kaux-1)
                if ( mod(hethex(levofi),1000).eq.0 ) then
                  nbvohe = nbvohe + 1
                  voishe(nbvohe) = levofi
                else
                  call utfihe ( levofi,
     >                          hethex, filhex, fhpyte,
     >                          nbfitf, filstf,
     >                          nbfihf, filshf,
     >                          nbfipf, filspf )
                  do 3121 , laux = 1 ,  nbfitf
                    nbvote = nbvote + 1
                    voiste(nbvote) = filstf + laux - 1
 3121             continue
                  do 3122 , laux = 1 ,  nbfihf
                    nbvohe = nbvohe + 1
                    voishe(nbvohe) = filshf + laux - 1
 3122             continue
                  do 3123 , laux = 1 ,  nbfipf
                    nbvopy = nbvopy + 1
                    voispy(nbvopy) = filspf + laux - 1
 3123             continue
                endif
  312         continue
c
c 3.1.3. ==> Le voisin est coupepar conformite :
c              on stocke ses enfants.
            else
              call utfihe ( levois,
     >                      hethex, filhex, fhpyte,
     >                      nbfitf, filstf,
     >                      nbfihf, filshf,
     >                      nbfipf, filspf )
              do 3131 , laux = 1 ,  nbfitf
                nbvote = nbvote + 1
                voiste(nbvote) = filstf + laux - 1
 3131         continue
              do 3132 , laux = 1 ,  nbfihf
                nbvohe = nbvohe + 1
                voishe(nbvohe) = filshf + laux - 1
 3132         continue
              do 3133 , laux = 1 ,  nbfipf
                nbvopy = nbvopy + 1
                voispy(nbvopy) = filspf + laux - 1
 3133         continue
c
            endif
c
            endif
c
c 3.2. ==> Le jaux-eme est un pentaedre ou une pyramide : pas encore
c
          elseif ( levois.lt.0 ) then
            codret = 3829
          endif
c
   31   continue
c
   30 continue
c
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'hexaedre', lehexa
      write (ulsort,90002) 'fils/voisins tetr', nbfite, nbvote
      if ( nbvote.gt.0 ) then
      write (ulsort,91010) (voiste(iaux),iaux=1,nbvote)
      endif
      write (ulsort,90002) 'fils/voisins hexa', nbfihe, nbvohe
      if ( nbvohe.gt.0 ) then
      write (ulsort,91010) (voishe(iaux),iaux=1,nbvohe)
      endif
      write (ulsort,90002) 'fils/voisins pyra', nbfipy, nbvopy
      if ( nbvopy.gt.0 ) then
      write (ulsort,91010) (voispy(iaux),iaux=1,nbvopy)
      endif
#endif
c====
c 4. la fin
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
