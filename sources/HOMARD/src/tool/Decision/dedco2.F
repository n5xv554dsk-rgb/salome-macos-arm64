      subroutine dedco2 ( tyconf,
     >                    decare, decfac,
     >                    posifa, facare,
     >                    hetare, merare, arehom,
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
c traitement des DEcisions - Deraffinement : COntamination - option 2
c                --          -               --                     -
c  prise en compte des homologues
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . tyconf . e   .   1    .  0 : conforme (defaut)                     .
c .        .     .        .  1 : non-conforme avec au minimum 2 aretes .
c .        .     .        .      non decoupees en 2 par face           .
c .        .     .        .  2 : non-conforme avec 1 seul noeud        .
c .        .     .        .      pendant par arete                     .
c .        .     .        .  3 : non-conforme fidele a l'indicateur    .
c .        .     .        . -1 : conforme, avec des boites pour les    .
c .        .     .        .      quadrangles, hexaedres et pentaedres  .
c .        .     .        . -2 : non-conforme avec au maximum 1 arete  .
c .        .     .        .      decoupee en 2 (boite pour les         .
c .        .     .        .      quadrangles, hexaedres et pentaedres) .
c . decare . e/s . nbarto . decisions des aretes                       .
c . decfac . e/s . -nbquto. decision sur les faces (quad. + tri.)      .
c .        .     . :nbtrto.                                            .
c . posifa . e   . nbarto . pointeur sur tableau facare                .
c . facare . e   . nbfaar . liste des faces contenant une arete        .
c . hetare . e   . nbarto . historique de l'etat des aretes            .
c . merare . e   . nbarto . mere des aretes                            .
c . arehom . e   . nbarto . ensemble des aretes homologues             .
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
      parameter ( nompro = 'DEDCO2' )
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
#ifdef _DEBUG_HOMARD_
#include "impr02.h"
#endif
c
c 0.3. ==> arguments
c
      integer tyconf
      integer decare(0:nbarto)
      integer decfac(-nbquto:nbtrto)
      integer posifa(0:nbarto), facare(nbfaar)
      integer hetare(nbarto), merare(nbarto), arehom(nbarto)
      integer hettri(nbtrto), aretri(nbtrto,3), nivtri(nbtrto)
      integer hetqua(nbquto), arequa(nbquto,4), nivqua(nbquto)
      integer listfa(*)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer nivdeb, nivfin, niveau
      integer nbfali, laface, etatfa
      integer facact, iarelo, iarete, etatar
      integer nbaret, nbar00, anodec(4)
      integer iaux, ideb, ifin
      integer jaux, jfin
      integer ipos, iface, ifacli, merear, jarelo
      integer jarete
      integer kaux
      integer nbare1, liare1(4), nbare2, liare2(4), liare3(2)
#ifdef _DEBUG_HOMARD_
      integer option
#endif
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
#ifdef _DEBUG_HOMARD_
        write (ulsort,90002) 'tyconf', tyconf
#endif
c
#ifdef _DEBUG_HOMARD_
cgn      write (ulsort,*) 'en entree de ',nompro
cgn      write (ulsort,*) 'quadrangle 5, de niveau ',nivqua(5)
cgn      write (ulsort,*) 'decfac(q5) =',decfac(-5)
cgn      write (ulsort,*) arequa(5,1),arequa(5,2),
cgn     >arequa(5,3),arequa(5,4)
cgn      write (ulsort,*) decare(arequa(5,1)),decare(arequa(5,2)),
cgn     >decare(arequa(5,3)),decare(arequa(5,4))
cgn      write (ulsort,*) hetare(arequa(5,1)),hetare(arequa(5,2)),
cgn     >hetare(arequa(5,3)),hetare(arequa(5,4))
cgn      write (ulsort,*) ' '
#endif
c
c====
c 2. algorithme : on regarde tous les niveaux dans l'ordre decroissant
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'Etape 3', codret
#endif
c     initialisation vide de la liste de faces a examiner
c
      nbfali = 0
c
c     initialisation du nombre d'aretes decoupees possibles
c     pour un quadrangle dans le cas de l'adaptation conforme
      if ( tyconf.ge.0 ) then
        nbar00 = -2
      else
        nbar00 = 2
      endif
c
      nivdeb = nivsup - 1
      nivfin = max(nivinf-1,0)
      do 100 , niveau = nivdeb , nivfin , -1
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,12)) niveau
cgn      write (ulsort,texte(langue,12)) niveau
cgn      write (ulsort,*) 'quadrangle 5, de niveau ',nivqua(5)
cgn      write (ulsort,*) 'decfac(q5) =',decfac(-5)
cgn      write (ulsort,*) arequa(5,1),arequa(5,2),
cgn     >arequa(5,3),arequa(5,4)
cgn      write (ulsort,*) decare(arequa(5,1)),decare(arequa(5,2)),
cgn     >decare(arequa(5,3)),decare(arequa(5,4))
cgn      write (ulsort,*) hetare(arequa(5,1)),hetare(arequa(5,2)),
cgn     >hetare(arequa(5,3)),hetare(arequa(5,4))
cgn      write (ulsort,*) ' '
cgn      write (ulsort,*) ' '
#endif
c
c 2.1. ==> traitement des faces pour la regle des deux voisins
c          ===================================================
c
        do 21 , laface = -nbquto , nbtrto
c
c         on regarde les faces meres d'actives du niveau courant
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
#ifdef _DEBUG_HOMARD_
          if ( etatfa.gt.0 ) then
          if ( laface.gt.0 ) then
            option = 2
            iaux=nivtri(laface)
          else
            option = 4
            iaux=nivqua(-laface)
          endif
          write (ulsort,texte(langue,29)) mess14(langue,1,option),
     >    abs(laface), iaux,etatfa, decfac(laface)
          endif
#endif
c
          if ( etatfa.ge.4 .and. etatfa.le.8 ) then
c
            facact = laface
c
c           --------
  200       continue
c           -------- debut du traitement de la face courante
c                    ***************************************
c
c             on ne regarde que les faces "a reactiver"
c
            if ( decfac(facact).eq.-1 ) then
c
#ifdef _DEBUG_HOMARD_
              if ( facact.gt.0 ) then
                option = 2
                iaux=nivtri(facact)
              else
                option = 4
                iaux=nivqua(-facact)
              endif
              write (ulsort,texte(langue,29))
     >'. '//mess14(langue,1,option),abs(facact),
     > iaux,-99999, decfac(facact)
#endif
c
c 2.1.1. ==> on compte les aretes inactives a garder
c
              if ( facact.gt.0 ) then
                nbare1 = 3
                do 2111 , iarelo = 1 , nbare1
                  liare1(iarelo) = aretri(facact,iarelo)
 2111           continue
              else
                nbare1 = 4
                iaux = -facact
                do 2112 , iarelo = 1 , nbare1
                  liare1(iarelo) = arequa(iaux,iarelo)
 2112           continue
              endif
c
c             nbaret = nombre d'aretes coupees en deux et a garder
c             nbare2 = nombre d'aretes a reactiver
c
              nbaret = 0
              nbare2 = 0
              do 2113 , iarelo = 1 , nbare1
                iarete = liare1(iarelo)
cgn      write (ulsort,*) '... arete ',iarelo,' : ',iarete
                if ( decare(iarete).eq.0 ) then
                  etatar = mod( hetare(iarete) , 10 )
                  if ( etatar.eq.2 ) then
                    nbaret = nbaret + 1
                  endif
                else
                  nbare2 = nbare2 + 1
                  anodec(nbare2) = iarete
                  liare2(nbare2) = iarelo
                endif
 2113         continue
#ifdef _DEBUG_HOMARD_
              write (ulsort,texte(langue,22)) nbaret, nbare2
#endif
c
              if ( nbaret.eq.nbare1 ) then
c
c 2.1.2. ==> toutes les aretes sont coupees en deux et a garder
c            --------------------------------------------------
c               on declare la face "a garder"
c
                decfac(facact) = 0
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,30))'decfac', facact,decfac(facact),' '
#endif
c
              elseif ( nbaret.eq.(nbare1-1) ) then
c
c 2.1.3. ==> toutes les aretes sauf une sont coupees en deux et a garder
c            -----------------------------------------------------------
c               on declare la face et la derniere arete "a garder"
c
                decfac(facact) = 0
                decare(anodec(1)) = 0
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,30))'decfac', facact,decfac(facact),' '
      write (ulsort,texte(langue,30))'decare',
     >anodec(1),decare(anodec(1)),' (arete encore a reactiver)'
#endif
c
c               on regarde toutes les faces qui s'appuient sur cette
c               arete, on memorise celles qui sont non actives
c               "a reactiver"
c
                ideb = posifa(anodec(1)-1)+1
                ifin = posifa(anodec(1))
                do 2131 , ipos = ideb , ifin
                  iface = facare(ipos)
                  if ( decfac(iface).eq.-1 ) then
                    if ( iface.gt.0 ) then
                      etatfa = mod( hettri(iface) , 10 )
                    else
                      etatfa = mod( hetqua(-iface) , 100 )
                    endif
                    if ( etatfa.ge.4 .and. etatfa.le.8 ) then
                      do 2132 , ifacli = 1 , nbfali
                        if ( listfa(ifacli).eq.iface ) then
                          goto 2133
                        endif
 2132                 continue
                      nbfali = nbfali + 1
                      listfa(nbfali) = iface
 2133                 continue
                    endif
                  endif
 2131           continue
c
c               on regarde si l'arete a une homologue
c                                           ---------
c
                if ( arehom(anodec(1)).ne.0 ) then
c
                  kaux = abs( arehom(anodec(1)) )
c
c                 l'arete homologue est declaree "a garder"
c
                  decare(kaux) = 0
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,30))'decare',
     >kaux,decare(kaux),' (homologue)'
#endif
c
c                 on regarde toutes les faces qui s'appuient sur cette
c                 arete, on memorise celles qui sont non actives "a
c                 reactiver"
c
                  ideb = posifa(kaux-1) + 1
                  ifin = posifa(kaux)
c
                  do 2134, ipos = ideb , ifin
                    iface = facare(ipos)
                    if ( decfac(iface).eq.-1 ) then
                      if ( iface.gt.0 ) then
                        etatfa = mod( hettri(iface) , 10 )
                      else
                        etatfa = mod( hetqua(-iface) , 100 )
                      endif
                      if ( etatfa.ge.4 .and. etatfa.le.8 ) then
                        do 2135 , ifacli = 1 , nbfali
                          if ( listfa(ifacli).eq.iface ) then
                            goto 2136
                          endif
 2135                   continue
                        nbfali = nbfali + 1
                        listfa(nbfali) = iface
 2136                   continue
                      endif
                    endif
 2134             continue
c
                endif
c
              elseif ( facact.lt.0 ) then
c
                if ( nbaret.eq.nbar00 ) then
c
c 2.1.4. ==> pour un quadrangle, deux aretes sont
c            ------------------------------------
c            des actives a garder si on veut des boites
c            ------------------------------------------
c               on declare la face et les 2 dernieres aretes "a garder"
c
                  decfac(facact) = 0
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,30))'decfac', facact,decfac(facact),' '
#endif
c
                  do 214 , iaux = 1 , 2
c
                    decare(anodec(iaux)) = 0
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,30))'decare',
     >anodec(iaux),decare(anodec(iaux)),' (arete encore a reactiver)'
#endif
c
c               on regarde toutes les faces qui s'appuient sur cette
c               arete, on memorise celles qui sont non actives
c               "a reactiver"
c
                    ideb = posifa(anodec(iaux)-1)+1
                    ifin = posifa(anodec(iaux))
                    do 2141 , ipos = ideb , ifin
                      iface = facare(ipos)
                      if ( decfac(iface).eq.-1 ) then
                        if ( iface.gt.0 ) then
                          etatfa = mod( hettri(iface) , 10 )
                        else
                          etatfa = mod( hetqua(-iface) , 100 )
                        endif
                        if ( etatfa.ge.4 .and. etatfa.le.8 ) then
                          do 2142 , ifacli = 1 , nbfali
                            if ( listfa(ifacli).eq.iface ) then
                              goto 2143
                            endif
 2142                     continue
                          nbfali = nbfali + 1
                          listfa(nbfali) = iface
 2143                     continue
                        endif
                      endif
 2141               continue
c
c                 on regarde si l'arete a une homologue
c                                             ---------
c
                    if ( arehom(anodec(iaux)).ne.0 ) then
c
                      kaux = abs( arehom(anodec(iaux)) )
c
c                   l'arete homologue est declaree "a garder"
c
                      decare(kaux) = 0
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,30))'decare',
     >kaux,decare(kaux),' (homologue)'
#endif
c
c                   on regarde toutes les faces qui s'appuient sur cette
c                   arete, on memorise celles qui sont non actives "a
c                   reactiver"
c
                      ideb = posifa(kaux-1) + 1
                      ifin = posifa(kaux)
c
                      do 2144, ipos = ideb , ifin
                        iface = facare(ipos)
                        if ( decfac(iface).eq.-1 ) then
                          if ( iface.gt.0 ) then
                            etatfa = mod( hettri(iface) , 10 )
                          else
                            etatfa = mod( hetqua(-iface) , 100 )
                          endif
                          if ( etatfa.ge.4 .and. etatfa.le.8 ) then
                            do 2145 , ifacli = 1 , nbfali
                              if ( listfa(ifacli).eq.iface ) then
                                goto 2146
                              endif
 2145                       continue
                            nbfali = nbfali + 1
                            listfa(nbfali) = iface
 2146                       continue
                          endif
                        endif
 2144                 continue
c
                    endif
c
  214             continue
c
                endif
c
#ifdef _DEBUG_HOMARD_
c 2.1.n. ==> toutes les aretes sont a reactiver : OK
c
              elseif ( nbare2.eq.nbare1 ) then
c
                write (ulsort,texte(langue,15))
#endif
c
              endif
c
            endif
c
            if ( nbfali.gt.0 ) then
c
c             on passe a la face suivante de la liste
c             ---------------------------------------
c
#ifdef _DEBUG_HOMARD_
              write (ulsort,texte(langue,21)) nbfali
              write (ulsort,*) (listfa(iaux),iaux=1,nbfali)
#endif
c
              facact = listfa(nbfali)
              nbfali = nbfali - 1
              goto 200
c
            endif
c
          endif
c
   21   continue
c
c 2.2. ==>  regle des ecarts de niveau
c           ==========================
c
        do 22 , laface = -nbquto , nbtrto
c
c         on passe en revue les faces :
c          . du niveau courant
c          . actives
c
          etatfa = -1
c
          if ( laface.gt.0 ) then
c
            if ( nivtri(laface).eq.niveau ) then
              etatfa = mod( hettri(laface) , 10 )
            endif
c
          elseif ( laface.lt.0 ) then
c
            iaux = -laface
            if ( nivqua(iaux).eq.niveau ) then
              etatfa = mod( hetqua(iaux) , 100 )
            endif
c
          endif
c
          if ( etatfa.eq.0 ) then
c
c 2.2.1. ==> liste des aretes ayant une mere
c
            if ( laface.gt.0 ) then
              nbare2 = 3
              do 2211 , iarelo = 1 , nbare2
                liare2(iarelo) = aretri(laface,iarelo)
 2211         continue
            else
              nbare2 = 4
              iaux = -laface
              do 2212 , iarelo = 1 , nbare2
                liare2(iarelo) = arequa(iaux,iarelo)
 2212         continue
            endif
c
            nbare1 = 0
            do 2213 , iaux = 1 , nbare2
             if ( merare(liare2(iaux)).gt.0 ) then
                nbare1 = nbare1 + 1
                liare1(nbare1) = liare2(iaux)
              endif
 2213       continue
c
c 2.2.2. ==> on parcourt les aretes retenues
c
            do 222 , iarelo = 1 , nbare1
c
              iarete = liare1(iarelo)
              merear = merare(iarete)
c
c             on explore les faces qui s'enroulent autour de
c             l'arete merear et celles qui s'enroulent autour
c             de son eventuelle homologue
c
              liare3(1) = merear
              if ( arehom(merear).eq.0 ) then
                jfin = 1
              else
                liare3(2) = abs(arehom(merear))
                jfin = 2
              endif
c
              do 2220 , jaux = 1 , jfin
c
c                 on marque comme etant "a garder"
c                 celles qui sont "a reactiver"
c
                ideb = posifa(liare3(jaux)-1)+1
                ifin = posifa(liare3(jaux))
                do 2221 , ipos = ideb , ifin
c
                  iface  = facare(ipos)
                  if ( decfac(iface).eq.-1 ) then
c
                    if ( iface.gt.0 ) then
                      etatfa = mod( hettri(iface) , 10 )
                    else
                      etatfa = mod( hetqua(-iface) , 100 )
                    endif
                    if ( etatfa.eq.0 ) then
                      decfac(iface) = 0
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,30)) 'decfac',
     > iface, decfac(iface), ' (face voisine)'
#endif
                      if ( iface.gt.0 ) then
                        nbare2 = 3
                        do 2222 , jarelo = 1 , nbare2
                          liare2(jarelo) = aretri(iface,jarelo)
 2222                   continue
                      else
                        nbare2 = 4
                        iaux = -iface
                        do 2223 , jarelo = 1 , nbare2
                          liare2(jarelo) = arequa(iaux,jarelo)
 2223                   continue
                      endif
                      do 2224 , jarelo = 1 , nbare2
                        jarete = liare2(jarelo)
                        if ( decare(jarete).eq.-1 ) then
                          decare(jarete) = 0
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,30))'decare',
     >jarete,decare(jarete),' '
#endif
                          if ( arehom(jarete).lt.0 ) then
                            if ( decare(abs(arehom(jarete))).eq.-1 )then
                              decare(abs(arehom(jarete))) = 0
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,30))'decare',
     >abs(arehom(jarete)),decare(abs(arehom(jarete))),' (homologue)'
#endif
                            endif
                          endif
                        endif
 2224                 continue
                    endif
c
                  endif
c
 2221           continue
c
 2220         continue
c
  222       continue
c
          endif
c
   22   continue
c
  100 continue
c
#ifdef _DEBUG_HOMARD_
c====
c 3. verification
c====
c
      if ( codret.eq.0 ) then
c
      call dehova ( arehom, decare,
     >              nompro, 1,
     >              ulsort, langue, codret )
c
      endif
#endif
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
