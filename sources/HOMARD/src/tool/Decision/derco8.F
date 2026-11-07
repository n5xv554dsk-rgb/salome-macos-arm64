      subroutine derco8 ( niveau,
     >                    decare, decfac,
     >                    hetare,
     >                    hettri, aretri, pertri, nivtri,
     >                    voltri,
     >                    hetqua, arequa, perqua, nivqua,
     >                    volqua,
     >                    hettet, tritet,
     >                    hethex, quahex,
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
c traitement des DEcisions - Raffinement : COntamination - option 8
c                --          -             --                     -
c Complement sur la regle des ecarts de niveau pour du non-conforme
c a 1 noeud pendant par arete
c Cas ou les non-conformites sur les faces sont uniquement dans un
c rapport de 1 a 4
c Point de depart : un volume dont au moins une des faces est coupee,
c et au moins une ne l'est pas. On a donc une non conformite entre cet
c hexaedre et son voisin.
c Situation : une des faces filles de la face coupee est a couper, peu
c importe le reste.
c Il faut s'assurer que le volume sera coupe pour eviter que le rapport
c soit > 1/4.
c Methode : on repere le voisin de la mere de la fille a couper qui
c est actif (il y en a au plus 1). On impose a ce voisin que toutes
c ses faces soient decoupees.
c Attention : il faut sauter les faces du bord exterieur car le probleme
c             de non conformite ne se pose pas
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . niveau . e   .    1   . niveau en cours d'examen                   .
c . decare . es  . nbarto . decisions des aretes                       .
c . decfac . es  . -nbquto. decision sur les faces (quad. + tri.)      .
c .        .     . :nbtrto.                                            .
c . merare . e   . nbarto . mere des aretes                            .
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
      parameter ( nompro = 'DERCO8' )
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
#include "nombhe.h"
c
c 0.3. ==> arguments
c
      integer niveau
      integer decare(0:nbarto)
      integer decfac(-nbquto:nbtrto)
      integer hetare(nbarto)
      integer hettri(nbtrto), aretri(nbtrto,3)
      integer pertri(nbtrto), nivtri(nbtrto)
      integer voltri(2,nbtrto)
      integer hetqua(nbquto), arequa(nbquto,4)
      integer perqua(nbquto), nivqua(nbquto)
      integer volqua(2,nbquto)
      integer hettet(nbteto), tritet(nbtecf,4)
      integer hethex(nbheto), quahex(nbhecf,6)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer laface, lehexa, letetr
      integer facdeb, facfin
      integer iaux, jaux
      integer afaire
      integer jarelo, jarete, iface
      integer merefa
#ifdef _DEBUG_HOMARD_
      integer glop
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
#ifdef _DEBUG_HOMARD_
#include "impr03.h"
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
      if ( nbheto.gt.0 ) then
        facdeb = -nbquto
      else
        facdeb = 0
      endif
c
      if ( nbteto.gt.0 ) then
        facfin = 0
      else
        facfin = nbtrto
      endif
cgn      write (ulsort,*) facdeb, facfin
c
c====
c 2. Complements sur la regle des ecarts de niveau
c====
c
      do 2 , laface = facdeb , facfin
cgn        print *,'entree de ',nompro,', ',laface,' :',decfac(laface)
#ifdef _DEBUG_HOMARD_
          if ( laface.eq.-215996 .or.
     >         laface.eq.-215996  ) then
            glop=1
          else
            glop=0
          endif
          if ( glop.eq.1 ) then
          if ( nivqua(-laface).eq.niveau ) then
        write (ulsort,*) ' ===================='
        write (ulsort,*) ' quadrangle : ',-laface
        write (ulsort,*) ' decfac : ',decfac(laface)
        write (ulsort,*) ' etat   : ',hetqua(-laface)
        write (ulsort,*) ' niveau : ',nivqua(-laface)
        if ( nbheto.gt.0 ) then
        write (ulsort,*) ' volqua(*,laface) : ',
     >         volqua(1,-laface),volqua(2,-laface)
        if ( volqua(1,-laface).gt.0 ) then
        write (ulsort,*) ' etat du voisin 1 : ',
     >                   hethex(volqua(1,-laface))
        endif
        if ( volqua(2,-laface).gt.0 ) then
        write (ulsort,*) ' etat du voisin 2 : ',
     >                   hethex(volqua(2,-laface))
        endif
        write(ulsort,*) ' perqua : ',perqua(-laface)
          endif
          endif
          endif
#endif
c
c 2.1. ==> on s'interesse aux faces :
c          . du niveau courant
c          . a decouper
c          . qui ne sont pas au bord du domaine
c
        if ( decfac(laface).eq.4 ) then
c
        afaire = 0
c
        if ( laface.gt.0 ) then
c
          if ( nivtri(laface).eq.niveau ) then
            afaire = 1
          endif
c
        elseif ( laface.lt.0 ) then
c
          iaux = -laface
          if ( nivqua(iaux).eq.niveau ) then
            afaire = 1
          endif
c
        endif
c
c 2.2. ==> on regarde le voisin non decoupe de la face mere
c          attention : on ne traite que les volumes traditionnels
c                      tetra ou hexa, d'ou le codret=12
c
#ifdef _DEBUG_HOMARD_
          if ( glop.eq.1 ) then
        write (ulsort,*) ' afaire : ',afaire
          endif
#endif
        if ( afaire.gt.0 ) then
c
          if ( laface.gt.0 ) then
c
            merefa = pertri(laface)
            if ( merefa.gt.0 ) then
            if ( voltri(1,merefa).lt.0 .or. voltri(2,merefa).lt.0 ) then
               codret = 12
               goto 33
            endif
c
            if ( voltri(1,merefa).gt.0 .and.
     >           voltri(2,merefa).gt.0 ) then
c
              do 2211 , iaux = 1 , 2
                letetr = voltri(iaux,merefa)
                if ( mod(hettet(letetr),100).eq.0 ) then
                  do 2212 , jaux = 1 , 4
                    iface = tritet(letetr,jaux)
                    if ( mod(hettri(iface),10).eq.0 .and.
     >                   decfac(iface).ne.4  ) then
                      decfac(iface) = 4
                      do 2213 , jarelo = 1 , 3
                        jarete = aretri(iface,jarelo)
                        if ( mod(hetare(jarete),10).eq.0 .and.
     >                       decare(jarete).ne.2 ) then
                          decare(jarete) = 2
                        endif
 2213                 continue
                    endif
 2212             continue
                endif
 2211         continue
c
              endif
c
            endif
c
          else
c
            merefa = perqua(-laface)
            if ( merefa.gt.0 ) then
#ifdef _DEBUG_HOMARD_
          if ( glop.eq.1 ) then
        write (ulsort,*) ' perqua : ',merefa
          endif
#endif
            if ( volqua(1,merefa).gt.0 .and.
     >           volqua(2,merefa).gt.0 ) then
c
              do 2214 , iaux = 1 , 2
                lehexa = volqua(iaux,merefa)
#ifdef _DEBUG_HOMARD_
          if ( glop.eq.1 ) then
        write (ulsort,*) '..... lehexa : ',lehexa
        write (ulsort,*) '..... etat   : ',hethex(lehexa)
          endif
#endif
                if ( mod(hethex(lehexa),1000).eq.0 ) then
                  do 2215 , jaux = 1 , 6
                    iface = quahex(lehexa,jaux)
                    if ( mod(hetqua(iface),100).eq.0 .and.
     >                   decfac(-iface).ne.4 ) then
                      decfac(-iface) = 4
                      do 2216 , jarelo = 1 , 4
                        jarete = arequa(iface,jarelo)
                        if ( mod(hetare(jarete),10).eq.0 .and.
     >                       decare(jarete).ne.2 ) then
                          decare(jarete) = 2
                        endif
 2216                 continue
                    endif
 2215             continue
                endif
 2214         continue
c
            endif
c
            endif
c
          endif
c
        endif
c
        endif
c
    2 continue
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,*) 'sortie de ',nompro
        do 1106 , iaux = 1 , nbquto
          write (ulsort,90001) 'decision quadrangle', iaux,decfac(-iaux)
cgn          write (ulsort,90001) 'quadrangle', iaux,
cgn     >    arequa(iaux,1), arequa(iaux,2),
cgn     >    arequa(iaux,3), arequa(iaux,4)
 1106   continue
      if ( nbquto.gt.0 ) then
        iaux = min(nbquto,5)
        write (ulsort,90001) 'quadrangle', iaux,
     >  decare(arequa(iaux,1)), decare(arequa(iaux,2)),
     >  decare(arequa(iaux,3)), decare(arequa(iaux,4))
        iaux = min(nbquto,8)
        write (ulsort,90001) 'quadrangle', iaux,
     >  decare(arequa(iaux,1)), decare(arequa(iaux,2)),
     >  decare(arequa(iaux,3)), decare(arequa(iaux,4))
      endif
#endif
c
c====
c 3. la fin
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
