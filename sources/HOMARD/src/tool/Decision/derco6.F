      subroutine derco6 ( niveau,
     >                    decare, decfac,
     >                    merare, arehom,
     >                    posifa, facare,
     >                    hettri, aretri, pertri, nivtri,
     >                    voltri,
     >                    hetqua, arequa, perqua, nivqua,
     >                    tritet,
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
c traitement des DEcisions - Raffinement : COntamination - option 6
c                --          -             --                     -
c Complement sur la regle des ecarts de niveau pour du non-conforme
c a 1 noeud pendant par arete
c en presence d'aretes et/ou de faces homologues
c Remarque : cela ne peut concerner que des niveaux au moins egal a 2
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . niveau . e   .    1   . niveau en cours d'examen                   .
c . decare . es  . nbarto . decisions des aretes                       .
c . decfac . es  . -nbquto. decision sur les faces (quad. + tri.)      .
c .        .     . :nbtrto.                                            .
c . merare . e   . nbarto . mere des aretes                            .
c . arehom . e   . nbarto . ensemble des aretes homologues             .
c . posifa . e   . nbarto . pointeur sur tableau facare                .
c . facare . e   . nbfaar . liste des faces contenant une arete        .
c . hettri . e   . nbtrto . historique de l'etat des triangles         .
c . aretri . e   . nbtrto . numeros des 3 aretes des triangles         .
c . pertri . e   . nbtrto . pere des triangles                         .
c . nivtri . e   . nbtrto . niveau des triangles                       .
c . voltri . e   .2*nbtrto. numeros des 2 volumes par triangle         .
c .        .     .        . voltri(i,k) definit le i-eme voisin de k   .
c .        .     .        .   0 : pas de voisin                        .
c .        .     .        . j>0 : tetraedre j                          .
c .        .     .        . j<0 : pyramide/pentaedre dans pypetr(1/2,j).
c . hetqua . e   . nbquto . historique de l'etat des quadrangles       .
c . arequa . e   . nbquto . numeros des 4 aretes des quadrangles       .
c . perqua . e   . nbquto . pere des quadrangles                       .
c . nivqua . e   . nbquto . niveau des quadrangles                     .
c . tritet . e   .nbtecf*4. numeros des 4 triangles des tetraedres     .
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
      parameter ( nompro = 'DERCO6' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
#include "nombar.h"
#include "nombtr.h"
#include "nombqu.h"
#include "nombte.h"
c
c 0.3. ==> arguments
c
      integer niveau
      integer decare(0:nbarto)
      integer decfac(-nbquto:nbtrto)
      integer merare(nbarto), arehom(nbarto)
      integer posifa(0:nbarto), facare(nbfaar)
      integer hettri(nbtrto), aretri(nbtrto,3)
      integer pertri(nbtrto), nivtri(nbtrto)
      integer voltri(2,nbtrto)
      integer hetqua(nbquto), arequa(nbquto,4)
      integer perqua(nbquto), nivqua(nbquto)
      integer tritet(nbtecf,4)
      integer listfa(*)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer laface, tetrae, nbtetr
      integer ipos, ipos1
      integer ideb, ifin, ifacli, nbfali
      integer iaux, jaux, kaux, jfin
      integer iarelo, jarelo, ifalo, iarete, jarete, iface, itetra
      integer etatfa, merear, merefa, grdmfa
      integer nbare1, nbare2, liare1(4), liare2(4), liare3(2)
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
#include "derco1.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,12)) niveau
#endif
c
      codret = 0
c
c  nombre maximum de tetraedres par triangle
c
      if ( nbteto.eq.0 ) then
        nbtetr = 0
      else
        nbtetr = 2
      endif
c
c     initialisation vide de la liste de faces a examiner
c
      nbfali = 0
c
c====
c 2. Complements sur la regle des ecarts de niveau
c====
c
      do 2 , laface = -nbquto , nbtrto
cgn        print *,'entree de ',nompro,', ',laface,' :',decfac(laface)
c
c 2.1. ==> on s'interesse aux faces :
c          . du niveau courant
c          . actives
c          . qui ont une mere qui ne reapparait pas
c          . qui ont une grand-mere
c
        grdmfa = 0
c
        if ( laface.gt.0 ) then
c
          if ( nivtri(laface).eq.niveau ) then
            etatfa = mod( hettri(laface) , 10 )
            if ( etatfa.eq.0 ) then
              merefa = pertri(laface)
              if ( merefa.gt.0 ) then
                if ( decfac(merefa).eq.0 ) then
                  grdmfa = pertri(merefa)
                endif
              endif
            endif
          endif
c
        elseif ( laface.lt.0 ) then
c
          iaux = -laface
          if ( nivqua(iaux).eq.niveau ) then
            etatfa = mod( hetqua(iaux) , 100 )
            if ( etatfa.eq.0 ) then
              merefa = perqua(iaux)
              if ( merefa.gt.0 ) then
                if ( decfac(-merefa).eq.0 ) then
                  grdmfa = perqua(merefa)
                endif
              endif
            endif
          endif
c
        endif
c
c 2.2. ==> on regarde les aretes de la face mere
c
        if ( grdmfa.gt.0 ) then
c
c 2.2.1. ==> liste de ces aretes
c
          if ( laface.gt.0 ) then
c
            nbare2 = 3
            do 2211 , iarelo = 1 , nbare2
              liare2(iarelo) = aretri(merefa,iarelo)
 2211       continue
c
          else
c
            nbare2 = 4
            do 2212 , iarelo = 1 , nbare2
              liare2(iarelo) = arequa(merefa,iarelo)
 2212       continue
c
          endif
c
          nbare1 = 0
          do 2213 , iaux = 1 , nbare2
            if ( decare(liare2(iaux)).eq.0 ) then
              nbare1 = nbare1 + 1
              liare1(nbare1) = liare2(iaux)
            endif
 2213     continue
c
c on parcourt les aretes retenues
c
          do 220 , iarelo = 1 , nbare1
c
            iarete = liare1(iarelo)
c
            merear = merare(iarete)
c
            if ( merear.ne.0 ) then
c
c 2.2.2. ==> l'arete iarete est sur le bord de la face grdmfa
c            ------------------------------------------------
c                on explore les faces qui s'enroulent autour de
c                l'arete merear et celles qui s'enroulent autour
c                de son eventuelle homologue
c
c               ==> pour toutes les faces qui s'appuient sur merear,
c                   mere de cette arete iarete, ou son homologue :
c                 . si elles sont a reactiver, on les garde
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
                ideb = posifa(liare3(jaux)-1)+1
                ifin = posifa(liare3(jaux))
c
                do 2221 , ipos = ideb , ifin
c
                  iface = facare(ipos)
c
                  if ( decfac(iface).eq.-1 ) then
c
                    decfac(iface) = 0
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,30))'decfac', iface,decfac(iface),' '
#endif
                    if ( iface.gt.0 ) then
                      nbare2 = 3
                      do 22211 , jarelo = 1 , nbare2
                        liare2(jarelo) = aretri(iface,jarelo)
22211                 continue
                    else
                      nbare2 = 4
                      iaux = -iface
                      do 22212 , jarelo = 1 , nbare2
                        liare2(jarelo) = arequa(iaux,jarelo)
22212                 continue
                    endif
                    do 22213 , jarelo = 1 , nbare2
                      jarete = liare2(jarelo)
                      decare(jarete) = 0
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,30))' decare',jarete,decare(jarete),' '
#endif
c
c                   on regarde si l'arete a une homologue               
c
                      if ( arehom(jarete) .ne. 0 ) then       
c
                        kaux = abs( arehom(jarete) )
                        decare(kaux) = 0
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,30))' decare',kaux,decare(kaux),' '
#endif
c
c                    on regarde toutes les faces qui s'appuient sur
c                    cette arete, on memorise celles qui sont           
c                    actives a "garder"
c
                        ideb = posifa(kaux-1)+1
                        ifin = posifa(kaux)         
c
                        do 22214, ipos1 = ideb, ifin
                          iface = facare(ipos1)          
                          if ( decfac(iface) .eq. 0 ) then      
                            if ( iface.gt.0 ) then
                              etatfa = mod( hettri(iface) , 10 )
                            else
                              etatfa = mod( hetqua(-iface) , 100 )
                            endif
                            if ( etatfa .eq. 0 ) then            
                              do 22215, ifacli = 1, nbfali          
                                if ( listfa(ifacli).eq.iface ) then
                                  goto 22216
                                endif
22215                         continue
                              nbfali = nbfali + 1
                              listfa(nbfali) = iface      
22216                         continue
                            endif
                          endif
22214                   continue
                      endif
22213               continue
c
                  endif
c
 2221           continue
c
 2220         continue
c
            else
c
c 2.2.3. ==> l'arete iarete est interieure a la face grdmfa
c            ----------------------------------------------
c               ==> pour toutes les faces des tetraedres qui
c                   s'appuient sur le triangle pere grdmfa :
c                 . si elles sont a reactiver, on les garde 
c
              if ( laface.gt.0 ) then
c
                do 2231 , itetra = 1 , nbtetr
c            attention : on ne traite que les volumes traditionnels
c                        tetra ou hexa, d'ou le codret=12
c
            if ( voltri(itetra,grdmfa).lt.0 ) then
               codret = 12
               goto 33
            endif
                  tetrae = voltri(itetra,grdmfa)
                  if ( tetrae.ne.0 ) then
c
                    do 2232 , ifalo = 1 , 4
c
                      iface = tritet(tetrae,ifalo)
c
                      if ( decfac(iface) .eq. -1 ) then
c
                        decfac(iface) = 0
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,30))'decfac', iface,decfac(iface),' '
#endif
c
                        do 2233 , jarelo = 1 , 3
                          jarete = aretri(iface,jarelo)
                          decare(jarete) = 0
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,30))' decare',jarete,decare(jarete),' '
#endif
c
c                         on regarde si l'arete a une homologue
c                                                  ---------
                          if ( arehom(jarete).ne.0 ) then
c
                            kaux = abs( arehom(jarete) )
                            decare(kaux) = 0
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,30))' decare',kaux,decare(kaux),' '
#endif
c
c                       on regarde toutes les faces qui s'appuient sur
c                       cette arete, on memorise celles qui sont
c                       actives a "garder"
c
                            ideb = posifa(kaux-1)+1
                            ifin = posifa(kaux)
c
                            do 2234 , ipos = ideb , ifin
                              iface = facare(ipos)
                              if ( decfac(iface) .eq. 0 ) then
                                etatfa = mod(hettri(iface),10)
                                if ( etatfa .eq. 0 ) then
                                  do 2235 , ifacli = 1 , nbfali
                                    if ( listfa(ifacli).eq.iface ) then
                                     goto 2236
                                    endif
 2235                             continue
                                  nbfali = nbfali + 1
                                  listfa(nbfali) = iface
 2236                             continue
                                endif
                              endif
 2234                       continue
c
                          endif
c
 2233                   continue
c
                      endif
c
 2232               continue
c
                  endif
c
 2231           continue
c
              endif
c
            endif
c
  220     continue
c
        endif
c
    2 continue
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
cgn        print *,'sortie de ',nompro,', ',laface,' :',decfac(laface)
c
c====
c 4. la fin
c====
c
   33 continue
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
