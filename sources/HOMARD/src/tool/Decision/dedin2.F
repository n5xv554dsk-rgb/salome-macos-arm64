      subroutine dedin2 ( decare, decfac,
     >                    posifa, facare,
     >                    arehom,
     >                    hettri, aretri, filtri, nivtri,
     >                    hetqua, arequa, filqua, nivqua,
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
c traitement des DEcisions - Deraffinement : Initialisation - option 2
c                --          -               -                       -
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . decare . e/s . nbarto . decisions des aretes                       .
c . decfac . e/s . -nbquto. decision sur les faces (quad. + tri.)      .
c .        .     . :nbtrto.                                            .
c . posifa . e   . nbarto . pointeur sur tableau facare                .
c . facare . e   . nbfaar . liste des faces contenant une arete        .
c . arehom . e   . nbarto . ensemble des aretes homologues             .
c . hettri . e   . nbtrto . historique de l'etat des triangles         .
c . aretri . e   . nbtrto . numeros des 3 aretes des triangles         .
c . filtri . e   . nbtrto . premier fils des triangles                 .
c . nivtri . e   . nbtrto . niveau des triangles                       .
c . hetqua . e   . nbquto . historique de l'etat des quadrangles       .
c . arequa . e   . nbquto . numeros des 4 aretes des quadrangles       .
c . filqua . e   . nbquto . fils des quadrangles                       .
c . nivqua . e   . nbquto . niveau des quadrangles                     .
c . ulsort . e   .   1    . unite logique de la sortie generale        .
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret .  s  .    1   . code de retour des modules                 .
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
      parameter ( nompro = 'DEDIN2' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "envada.h"
#include "nombar.h"
#include "nombtr.h"
#include "nombqu.h"
#include "impr02.h"
c
c 0.3. ==> arguments
c
      integer decare(0:nbarto)
      integer decfac(-nbquto:nbtrto)
      integer posifa(0:nbarto), facare(nbfaar)
      integer arehom(nbarto)
      integer hettri(nbtrto), aretri(nbtrto,3)
      integer filtri(nbtrto), nivtri(nbtrto)
      integer hetqua(nbquto), arequa(nbquto,4)
      integer filqua(nbquto), nivqua(nbquto)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer laface, larete, niveau, numfac, etatfa, nuarvo, nufavo
      integer iaux, ideb, ifin, jdeb, jfin, arevoi, facvoi, iarelo
      integer nivdeb, nivfin
      integer nbare1, liare1(4), nbare2, liare2(4)
      integer kaux, option
c
      logical afaire
c
      integer nbmess
      parameter ( nbmess = 30 )
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
      codret = 0
c
c====
c 2. on regarde tous les niveaux dans l'ordre croissant
c====
c
      nivdeb = max(nivinf-1,0)
      nivfin = nivsup - 1
      do 100 , niveau = nivdeb , nivfin
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) niveau
#endif
c
c       boucle sur toutes les faces marquee "a reactiver"
c       dans le niveau courant
c
        do 2 , laface = -nbquto , nbtrto
c
          if ( decfac(laface).eq.-1 ) then
c
c       on regarde toutes les faces meres d'actives du niveau courant
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
            if ( etatfa.ge.4 .and. etatfa.le.8 ) then
c
c 2.1. ==> liste des aretes de la face "a reactiver"
c
              if ( laface.gt.0 ) then
                nbare1 = 3
                do 211 , iarelo = 1 , nbare1
                  liare1(iarelo) = aretri(laface,iarelo)
  211           continue
              else
                nbare1 = 4
                iaux = -laface
                do 212 , iarelo = 1 , nbare1
                  liare1(iarelo) = arequa(iaux,iarelo)
  212           continue
              endif
c
c 2.2. ==> Pour un triangle, si le premier triangle fils (central) est
c          marque "a couper" (on ne teste ici que le premier fils
c          car les trois autres sont testes ensuite), le triangle pere
c          est a garder, de meme que ses aretes
c
              if ( laface.gt.0 ) then
c
                numfac = filtri(laface)
c
                if ( decfac(numfac).gt.0 ) then
c
                  decfac(laface) = max(0,decfac(laface))
                  do 221 , iarelo = 1 , nbare1
                    larete = liare1(iarelo)
                    decare(larete) = max(0,decare(larete))
                    if ( arehom(larete).ne.0 ) then
                      decare(abs(arehom(larete))) =
     >                                max(0,decare(abs(arehom(larete))))
                    endif
  221             continue
c
                endif
c
                ideb = filtri(laface) + 1
                ifin = ideb + 2
c
              else
c
                ideb = - filqua(-laface) - 3
                ifin = ideb + 3
c
              endif
c
c 2.3. ==> si l'une des faces filles sur le bord de la face est marquee
c          "a couper", on empeche le deraffinement de la mere et
c          des faces voisines de la face-mere
c
              do 231 , numfac = ideb , ifin
c
                if ( decfac(numfac).gt.0 ) then
c
                  decfac(laface) = 0
c
                  do 232 , iarelo = 1 , nbare1
c
                    larete = liare1(iarelo)
                    decare(larete) = max(0,decare(larete))
                    if ( arehom(larete).ne.0 ) then
                      decare(abs(arehom(larete))) =
     >                              max(0,decare(abs(arehom(larete))))
                    endif
c
                    jdeb = posifa(larete-1) + 1
                    jfin = posifa(larete)
c
                    do 233 , nufavo = jdeb , jfin
c
                      facvoi = facare(nufavo)
                      decfac(facvoi) = 0
c
                      if ( facvoi.gt.0 ) then
                        nbare2 = 3
                        do 234 , nuarvo = 1 , nbare2
                          liare2(nuarvo) = aretri(facvoi,nuarvo)
  234                   continue
                      else
                        iaux = -facvoi
                        nbare2 = 4
                        do 235 , nuarvo = 1 , nbare2
                          liare2(nuarvo) = arequa(iaux,nuarvo)
  235                   continue
                      endif
c
                      do 236 , nuarvo = 1 , nbare2
                        arevoi = liare2(nuarvo)
                        decare(arevoi) = max(0,decare(arevoi))
                        if ( arehom(arevoi).ne.0 ) then
                          decare(abs(arehom(arevoi))) =
     >                              max(0,decare(abs(arehom(arevoi))))
                        endif
  236                 continue
c
  233               continue
c
  232             continue
c
                endif
c
  231         continue
c
            endif
c
          endif
c
    2   continue
c
  100 continue
c
c====
c 3. on bascule "a garder" toutes les aretes des faces meres
c    non actives "a garder". cette etape est indispensable au
c    fonctionnement correct de la regle des deux voisins.
c    Il faut le transmettre aux eventuelles aretes homologues
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'Etape 3', codret
#endif
c
      do 30 , laface = -nbquto , nbtrto
c
        if ( decfac(laface).eq.0 ) then
c
          afaire = .false.
          if ( laface.gt.0 ) then
            etatfa = mod( hettri(laface) , 10 )
            if ( etatfa.ge.4 .and. etatfa.le.9 ) then
              afaire = .true.
            endif
          elseif ( laface.lt.0 ) then
            iaux = -laface
            etatfa = mod( hetqua(iaux) , 100 )
            if ( etatfa.eq.4 .or. etatfa.eq.99 ) then
              afaire = .true.
            endif
          endif
c
          if ( afaire ) then
#ifdef _DEBUG_HOMARD_
            if ( laface.gt.0 ) then
              option = 2
              iaux=nivtri(laface)
            else
              option = 4
              iaux=nivqua(-laface)
            endif
            write (ulsort,texte(langue,29)) mess14(langue,1,option),
     >      abs(laface), iaux,etatfa, decfac(laface)
#endif
            if ( laface.gt.0 ) then
              nbare1 = 3
              do 31 , iarelo = 1 , nbare1
                liare1(iarelo) = aretri(laface,iarelo)
   31         continue
            else
              nbare1 = 4
              iaux = -laface
              do 32 , iarelo = 1 , nbare1
                liare1(iarelo) = arequa(iaux,iarelo)
   32         continue
            endif
            do 33 , iarelo = 1 , nbare1
              kaux = liare1(iarelo)
              if ( decare(kaux).eq.-1 ) then
                decare(kaux) = 0
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,30)) 'decare', kaux, decare(kaux),' '
#endif
              endif
              if ( arehom(kaux).ne.0 ) then
                if ( decare(abs(arehom(kaux))).eq.-1 ) then
                  decare(abs(arehom(kaux))) = 0
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,30)) 'decare',
     >  abs(arehom(kaux)), decare(abs(arehom(kaux))), '(homologue)'
#endif
                endif
              endif
   33       continue
          endif
c
        endif
c
   30  continue
c
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
