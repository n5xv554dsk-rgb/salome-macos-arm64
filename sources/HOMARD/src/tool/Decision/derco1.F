      subroutine derco1 ( tyconf,
     >                    niveau,
     >                    decare, decfac,
     >                    hetare,
     >                    posifa, facare,
     >                    hettri, aretri, nivtri,
     >                    hetqua, arequa, nivqua,
     >                    listfa,
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
c traitement des DEcisions - Raffinement : COntamination - option 1
c                --          -             --                     -
c Application de la regle des deux voisins dans les cas :
c    tyconf = 0 ; conforme
c    tyconf = 1 ; non-conforme avec au minimum 2 aretes non coupees
c    tyconf = -1 ; conforme avec boites
c    tyconf = -2 ; non-conforme avec au maximum 1 arete coupee
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . tyconf . e   .   1    .  0 : conforme                              .
c .        .     .        .  1 : non-conforme avec au minimum 2 aretes .
c .        .     .        .      non decoupees en 2                    .
c .        .     .        .  2 : non-conforme avec 1 seul noeud        .
c .        .     .        .      pendant par arete                     .
c .        .     .        .  3 : non-conforme fidele a l'indicateur    .
c .        .     .        . -1 : conforme, avec des boites pour les    .
c .        .     .        .      quadrangles, hexaedres et pentaedres  .
c .        .     .        . -2 : non-conforme avec au maximum 1 arete  .
c .        .     .        .      decoupee en 2 (boite pour les         .
c .        .     .        .      quadrangles, hexaedres et pentaedres) .
c .        .     .        . -2 : non-conforme avec au maximum 1 arete  .
c .        .     .        .      decoupee en 2 (boite pour les         .
c .        .     .        .      quadrangles, hexaedres et pentaedres) .
c . niveau . e   .    1   . niveau en cours d'examen                   .
c . decare . es  . nbarto . decisions des aretes                       .
c . decfac . es  . -nbquto. decision sur les faces (quad. + tri.)      .
c .        .     . :nbtrto.                                            .
c . hetare . e   . nbarto . historique de l'etat des aretes            .
c . posifa . e   . nbarto . pointeur sur tableau facare                .
c . facare . e   . nbfaar . liste des faces contenant une arete        .
c . hettri . e   . nbtrto . historique de l'etat des triangles         .
c . aretri . e   . nbtrto . numeros des 3 aretes des triangles         .
c . nivtri . e   . nbtrto . niveau des triangles                       .
c . hetqua . e   . nbquto . historique de l'etat des quadrangles       .
c . arequa . e   . nbquto . numeros des 4 aretes des quadrangles       .
c . nivqua . e   . nbquto . niveau des quadrangles                     .
c . listfa . t   .   *    . liste de faces a considerer                .
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
      parameter ( nompro = 'DERCO1' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
#include "nombar.h"
#include "nombtr.h"
#include "nombqu.h"
c
c 0.3. ==> arguments
c
      integer tyconf
      integer niveau
      integer decare(0:nbarto)
      integer hetare(nbarto)
      integer decfac(-nbquto:nbtrto)
      integer posifa(0:nbarto), facare(nbfaar)
      integer hettri(nbtrto), aretri(nbtrto,3), nivtri(nbtrto)
      integer hetqua(nbquto), arequa(nbquto,4), nivqua(nbquto)
      integer listfa(*)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer facact, laface, nbfali
      integer ipos
      integer iaux, ideb, ifin, ifacli
      integer nbaret, nbar00, anodec(4)
      integer iarelo, iarete, iface
      integer etatar, etatfa
      integer nbare1, liare1(4)
c
      integer nbmess
      parameter ( nbmess = 30 )
      character*80 texte(nblang,nbmess)
c
c 0.5. ==> initialisations
c ______________________________________________________________________
c
c====
c 1. initialisations
c====
c
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
#include "impr03.h"
c
#include "derco1.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,12)) niveau
#endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'tyconf', tyconf
#endif
c
#ifdef _DEBUG_HOMARD_
      ideb = 0
      do 1105 , iaux = 1 , nbquto
        if ( decfac(-iaux).eq.4 ) ideb = ideb+1
cgn        write (ulsort,90001) 'decision quadrangle', iaux,decfac(-iaux)
cgn          write (ulsort,90001) 'quadrangle', iaux,
cgn     >    arequa(iaux,1), arequa(iaux,2),
cgn     >    arequa(iaux,3), arequa(iaux,4)
 1105 continue
       write (ulsort,90002) 'quadrangles a decision 4', ideb
       ideb = 0
      do 11051 , iaux = 1 , nbarto
        if ( decare(iaux).eq.2 ) ideb = ideb+1
11051 continue
       write (ulsort,90002) 'aretes a decision 2', ideb
#endif
#ifdef _DEBUG_HOMARD_
      if ( nbquto.gt.0 ) then
      iaux = min(nbquto,38)
      write (ulsort,90112) 'nivqua', iaux, nivqua(iaux)
      write (ulsort,90112) 'decfac', -iaux, decfac(-iaux)
      write (ulsort,90001) 'aretes du quadrangle         ', iaux,
     >arequa(iaux,1), arequa(iaux,2),
     >arequa(iaux,3), arequa(iaux,4)
      write (ulsort,90001) 'decare pour aretes quadrangle', iaux,
     >decare(arequa(iaux,1)), decare(arequa(iaux,2)),
     >decare(arequa(iaux,3)), decare(arequa(iaux,4))
      endif
#endif
#ifdef _DEBUG_HOMARD_
      if ( nbquto.gt.0 ) then
      iaux = min(nbquto,10)
      write (ulsort,90001) 'aretes du quadrangle         ', iaux,
     >arequa(iaux,1), arequa(iaux,2),
     >arequa(iaux,3), arequa(iaux,4)
      write (ulsort,90001) 'decare pour aretes quadrangle', iaux,
     >decare(arequa(iaux,1)), decare(arequa(iaux,2)),
     >decare(arequa(iaux,3)), decare(arequa(iaux,4))
      iaux = min(nbquto,19)
      write (ulsort,90001) 'aretes du quadrangle         ', iaux,
     >arequa(iaux,1), arequa(iaux,2),
     >arequa(iaux,3), arequa(iaux,4)
      write (ulsort,90001) 'decare pour aretes quadrangle', iaux,
     >decare(arequa(iaux,1)), decare(arequa(iaux,2)),
     >decare(arequa(iaux,3)), decare(arequa(iaux,4))
      endif
#endif
c
      codret = 0
c
c     initialisation vide de la liste de faces a examiner
c
      nbfali = 0
c
c     initialisation du nombre d'aretes decoupees possibles
c     pour un quadrangle dans le cas de l'adaptation conforme
c
      if ( tyconf.ge.0 ) then
        nbar00 = -2
      else
        nbar00 = 2
      endif
c
c====
c 2. Application de la regle des deux voisins
c====
c
      do 2 , laface = -nbquto , nbtrto
c
c       on regarde toutes les faces actives du niveau courant
c
        etatfa = -1
        if ( laface.gt.0 ) then
          if ( nivtri(laface).eq.niveau ) then
            etatfa = mod( hettri(laface) , 10 )
          endif
        elseif ( laface.lt.0 ) then
          iaux = -laface
          if ( nivqua(iaux).eq.niveau ) then
            etatfa = mod( hetqua(iaux) , 100 )
          endif
        endif
c
        if ( etatfa.eq.0 ) then
c
          facact = laface
cgn          write (ulsort,90001) 'face', facact
c
c         debut du traitement de la face courante
c         ***************************************
c
c         --------
   20     continue
c         --------
c         on ne regarde que les faces "a garder"
c
          if ( decfac(facact).eq.0 ) then
c
c 2.1. ==> on compte les aretes actives a garder et les aretes
c          inactives a reactiver
c
            if ( facact.gt.0 ) then
              nbare1 = 3
              do 211 , iarelo = 1 , nbare1
                liare1(iarelo) = aretri(facact,iarelo)
  211         continue
            else
              nbare1 = 4
              iaux = -facact
              do 212 , iarelo = 1 , nbare1
                liare1(iarelo) = arequa(iaux,iarelo)
  212         continue
            endif
c
            nbaret = 0
            do 213 , iarelo = 1 , nbare1
              iarete = liare1(iarelo)
              if ( decare(iarete).eq.0 ) then
                etatar = mod( hetare(iarete) , 10 )
                if ( etatar.eq.0 ) then
                  nbaret = nbaret + 1
                  anodec(nbaret) = iarete
                endif
              elseif ( decare(iarete).eq.-1 ) then
                nbaret = nbaret + 1
                anodec(nbaret) = iarete
              endif
  213       continue
c
c 2.2. ==> aucune arete n'est ni "active a garder" ni "a reactiver"
c          --------------------------------------------------------
c          ==> on declare la face "a couper"
c
            if ( nbaret.eq.0 ) then
c
              decfac(facact) = 4
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,30))'decfac', facact,decfac(facact),' '
#endif
c
c 2.3. ==> une seule arete est une "active a garder" ou "a reactiver"
c          ----------------------------------------------------------
c          ==> on declare la face "a couper"
c             . si l'arete est active, on la declare "a couper"
c             . si l'arete est inactive, on la declare "a garder"
c
            elseif ( nbaret.eq.1 ) then
c
              decfac(facact) = 4
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,30))'decfac', facact,decfac(facact),' '
#endif
              if ( mod(hetare(anodec(1)),10).eq.0 ) then
                decare(anodec(1)) = 2
              else
                decare(anodec(1)) = 0
              endif
c
c             on regarde toutes les faces qui s'appuient sur cette
c             arete, on memorise celles qui sont actives "a garder"
c
              ideb = posifa(anodec(1)-1)+1
              ifin = posifa(anodec(1))
c
              do 23 , ipos = ideb , ifin
                iface = facare(ipos)
                if ( decfac(iface).eq.0 ) then
                  if ( iface.gt.0 ) then
                    etatfa = mod( hettri(iface) , 10 )
                  else
                    etatfa = mod( hetqua(-iface) , 100 )
                  endif
                  if ( etatfa.eq.0 ) then
                    do 231 , ifacli = 1 , nbfali
                      if ( listfa(ifacli).eq.iface ) then
                        goto 232
                      endif
  231               continue
                    nbfali = nbfali + 1
                    listfa(nbfali) = iface
  232               continue
                  endif
                endif
   23         continue
c
c 2.4. ==> pour un quadrangle, deux aretes sont
c          ------------------------------------
c          des "actives a garder" ou "a reactiver" si on veut des boites
c          -------------------------------------------------------------
c
            elseif ( facact.lt.0 ) then
c
              if ( nbaret.eq.nbar00 ) then
c
c             on declare la face "a couper"
c
                decfac(facact) = 4
#ifdef _DEBUG_HOMARD_
            if ( facact.eq.0 ) then
      write (ulsort,texte(langue,30))'decfac', facact,decfac(facact),' '
            endif
#endif
c
                do 241 , iaux = 1 , 2
c
c             . si l'arete est active, on la declare "a couper"
c             . si l'arete est inactive, on la declare "a garder"
c
                  if ( mod(hetare(anodec(iaux)),10).eq.0 ) then
                    decare(anodec(iaux)) = 2
                  else
                    decare(anodec(iaux)) = 0
                  endif
c
c                 on regarde toutes les faces qui s'appuient sur cette
c                 arete, on memorise celles qui sont actives "a garder"
c
                  ideb = posifa(anodec(iaux)-1)+1
                  ifin = posifa(anodec(iaux))
c
                  do 242 , ipos = ideb , ifin
                    iface = facare(ipos)
                    if ( decfac(iface).eq.0 ) then
                      if ( iface.gt.0 ) then
                        etatfa = mod( hettri(iface) , 10 )
                      else
                        etatfa = mod( hetqua(-iface) , 100 )
                      endif
                      if ( etatfa.eq.0 ) then
                        do 243 , ifacli = 1 , nbfali
                          if ( listfa(ifacli).eq.iface ) then
                            goto 244
                          endif
  243                   continue
                        nbfali = nbfali + 1
                        listfa(nbfali) = iface
  244                   continue
                      endif
                    endif
  242             continue
c
  241           continue
c
              endif
c
            endif
c
          endif
c
c 2.5. ==> on passe a la face suivante de la liste
c          ---------------------------------------
c
          if ( nbfali .gt. 0 ) then
c
            facact = listfa(nbfali)
            nbfali = nbfali - 1
            goto 20
c
          endif
c
        endif
c
    2 continue
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) 'sortie de ',nompro
      do 11060 , iaux = 1 , nbarto
        if ( iaux.eq.-17735 .or. iaux.eq.-877 ) then
          write (ulsort,90001) '.. arete e/d', iaux,
     >    hetare(iaux), decare(iaux)
        endif
11060 continue
#endif
#ifdef _DEBUG_HOMARD_
       ideb = 0
      do 1106 , iaux = 1 , nbquto
        if ( decfac(-iaux).eq.4 ) ideb = ideb+1
cgn       write (ulsort,90001) 'decision quadrangle', iaux,decfac(-iaux)
cgn          write (ulsort,90001) 'quadrangle', iaux,
cgn     >    arequa(iaux,1), arequa(iaux,2),
cgn     >    arequa(iaux,3), arequa(iaux,4)
 1106 continue
       write (ulsort,90002) 'quadrangle a decision 4', ideb
       ideb = 0
      do 11061 , iaux = 1 , nbarto
        if ( decare(iaux).eq.2 ) ideb = ideb+1
11061 continue
       write (ulsort,90002) 'arete a decision 2', ideb
      if ( nbquto.lt.0 ) then
      iaux = min(nbquto,12)
      write (ulsort,90112) 'decfac', -iaux, decfac(-iaux)
      write (ulsort,90001) 'decare pour aretes quadrangle', iaux,
     >decare(arequa(iaux,1)), decare(arequa(iaux,2)),
     >decare(arequa(iaux,3)), decare(arequa(iaux,4))
cgn      iaux = min(nbquto,10)
cgn      write (ulsort,90001) 'decare pour aretes quadrangle', iaux,
cgn     >decare(arequa(iaux,1)), decare(arequa(iaux,2)),
cgn     >decare(arequa(iaux,3)), decare(arequa(iaux,4))
cgn      iaux = min(nbquto,19)
cgn      write (ulsort,90001) 'decare pour aretes quadrangle', iaux,
cgn     >decare(arequa(iaux,1)), decare(arequa(iaux,2)),
cgn     >decare(arequa(iaux,3)), decare(arequa(iaux,4))
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
