      subroutine utaipe ( lepent, option,
     >                    hetpen, facpen, filpen, fppyte,
     >                    aretri,
     >                    tritet, cotrte,
     >                    nbaint, nuaret,
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
c     UTilitaire : Aretes Internes d'un PEntaedre
c     --           -      -             --
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . lepent . e   .    1   . pentaedre a traiter                        .
c . option . e   .    1   . produit de :                               .
c .        .     .        . 1 : toutes                                 .
c .        .     .        . 2 : du noeud central aux sommets           .
c .        .     .        . 3 : du noeud central aux milieux           .
c .        .     .        . 5 : autres                                 .
c . hetpen . e   . nbpeto . historique de l'etat des pentaedres        .
c . facpen . e   .nbpecf*5. numeros des faces des pentaedres           .
c . filpen . e   . nbpeto . premier fils des pentaedres                .
c . fppyte . e   .  2**   . fppyte(1,j) = numero de la 1ere pyramide   .
c .        .     .        . fille du pentaedre k tel que filpen(k) =-j .
c .        .     .        . fppyte(2,j) = numero du 1er tetraedre      .
c .        .     .        . fils du pentaedre k tel que filpen(k) = -j .
c . aretri . e   .nbtrto*3. numeros des 3 aretes des triangles         .
c . tritet . e   .nbtecf*4. numeros des 4 triangles des tetraedres     .
c . cotrte . e   .nbtecf*4. code des 4 triangles des tetraedres        .
c . nbaint .  s  .   1    . nombre d'aretes internes                   .
c . nuaret .  s  . nbaint . numero des aretes internes                 .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
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
      parameter ( nompro = 'UTAIPE' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
#include "nombtr.h"
#include "nombte.h"
#include "nombpe.h"
#include "impr02.h"
c
c 0.3. ==> arguments
c
      integer lepent, option
      integer aretri(nbtrto,3)
      integer hetpen(nbpeto), facpen(nbpecf,5)
      integer filpen(nbpeto), fppyte(2,nbpeco)
      integer tritet(nbtecf,4), cotrte(nbtecf,4)
      integer nbaint
      integer nuaret(*)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux
      integer etapen, letria
      integer listar(6), lista3(6)
      integer f1hp, numtet
c
      integer nbmess
      parameter ( nbmess = 10 )
      character*80 texte(nblang,nbmess)
c ______________________________________________________________________
c
c====
c 1. initialisations
c====
c
c 1.1. ==> messages
c
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
      texte(1,4) = '(''Recherche des aretes internes au '',a,i10)'
      texte(1,5) = '(''Etat :'',i10)'
      texte(1,6) = '(''Option :'',i2)'
      texte(1,7) = '(''Impossible.'')'
c
      texte(2,4) = '(''Search of he internal edges of the '',a,i10)'
      texte(2,5) = '(''Status:'',i10)'
      texte(2,6) = '(''Option:'',i2)'
      texte(2,7) = '(''Impossible.'')'
c
#include "impr03.h"
c
      codret = 0
c
      etapen = mod(hetpen(lepent),100)
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) mess14(langue,1,7), lepent
      write (ulsort,texte(langue,5)) etapen
      write (ulsort,texte(langue,6)) option
#endif
c
c====
c 2. Reperage des fils
c====
c
      f1hp = filpen(lepent)
cgn      write(1,90002) 'f1hp',f1hp
      if ( f1hp.lt.0 ) then
        numtet = fppyte(2,-f1hp)
cgn        write(1,90002) 'tetraedre numtet', numtet
      endif
c
      nbaint = 0
c
c====
c 3. Decoupage selon 1 arete
c    Arete interne entre le milieu de l'arete coupee et le sommet oppose
c====
c
      if ( etapen.ge.1 .and. etapen.le.6 ) then
c
        call utarte ( numtet,
     >                nbtrto, nbtecf,
     >                aretri, tritet, cotrte,
     >                listar )
c
        nuaret(nbaint+1) = listar(1)
        nbaint = nbaint + 1
c
c====
c 4. Decoupage selon 2 aretes des faces triangulaire et quadrangulaires
c    Arete interne entre les milieux des 2 aretes coupees
c====
c
      elseif ( etapen.ge.21 .and. etapen.le.26 ) then
c
        iaux = numtet + 1
        call utarte ( iaux,
     >                nbtrto, nbtecf,
     >                aretri, tritet, cotrte,
     >                listar )
c
        nuaret(nbaint+1) = listar(3)
        nbaint = nbaint + 1
c
c====
c 5. Decoupage selon 2 aretes des faces triangulaires
c====
c
      elseif ( etapen.ge.31 .and. etapen.le.36 ) then
c
c 5.1. ==> Aretes du 1er et du 3eme fils
c
        call utarte ( numtet,
     >                nbtrto, nbtecf,
     >                aretri, tritet, cotrte,
     >                listar )
c
        iaux = numtet + 2
        call utarte ( iaux,
     >                nbtrto, nbtecf,
     >                aretri, tritet, cotrte,
     >                lista3 )
c
c 5.2. ==> Aretes internes entre noeud central et sommets
c
        if ( mod(option,2).eq.0 .or. option.eq.1 ) then
c
c 5.2.1. ==> Sommets de la face quadrangulaire coupee
c            . Les deux premiers sommets sont ceux qui appartiennent
c              a la face triangulaire F1
c            . Les 4 sommets tournent dans le sens positif, vus
c              de l'exterieur
c
          nuaret(nbaint+1) = listar(3)
          nuaret(nbaint+2) = listar(2)
          nuaret(nbaint+3) = lista3(3)
          nuaret(nbaint+4) = lista3(2)
c
c 5.2.2. ==> Autres sommets
c            . Le premier sommet appartient a la face triangulaire F1
c
          iaux = numtet + 6
          call utarte ( iaux,
     >                  nbtrto, nbtecf,
     >                  aretri, tritet, cotrte,
     >                  listar )
c
          nuaret(nbaint+5) = listar(3)
          nuaret(nbaint+6) = listar(2)
c
          nbaint = nbaint + 6
c
        endif
c
c 5.3. ==> Aretes internes entre noeud central et noeuds milieux
c          . Le premier noeud appartient a la face triangulaire F1
c
        if ( mod(option,3).eq.0 .or. option.eq.1 ) then
c
c 5.3.1. ==> Cote de la face F1
c
          nbaint = nbaint + 1
          nuaret(nbaint) = listar(1)
c
c 5.3.2. ==> Cote de la face F2
c
          nbaint = nbaint + 1
          nuaret(nbaint) = lista3(1)
c
        endif
c
c====
c 6. Decoupage selon 1 face quadrangulaire
c    Aretes internes entre le milieu de la face et les sommets opposes
c====
c
      elseif ( etapen.ge.43 .and. etapen.le.45 ) then
c
        call utarte ( numtet,
     >                nbtrto, nbtecf,
     >                aretri, tritet, cotrte,
     >                listar )
c
c 6.1. ==> Cote de la face F1
c
        nbaint = nbaint + 1
        nuaret(nbaint) = listar(3)
c
c 6.2. ==> Cote de la face F2
c
        nbaint = nbaint + 1
        nuaret(nbaint) = listar(2)
c
c====
c 7. Decoupage selon 1 face triangulaire
c====
c
      elseif ( etapen.ge.51 .and. etapen.le.52 ) then
c
c 7.1. ==> Aretes internes entre noeud central et sommets
c          . Les 3 sommets tournent dans le sens positif, vus
c            de l'exterieur
c
        if ( mod(option,2).eq.0 .or. option.eq.1 ) then
c
          iaux = numtet + 10
          call utarte ( iaux,
     >                  nbtrto, nbtecf,
     >                  aretri, tritet, cotrte,
     >                  listar )
c
c         . Decoupage de la face triangulaire F1 : le 1er sommet est S4
          if ( etapen.eq.51 ) then
            nuaret(nbaint+1) = listar(3)
            nuaret(nbaint+2) = listar(2)
            nuaret(nbaint+3) = listar(1)
c
c         . Decoupage de la face triangulaire F2 : le 1er sommet est S1
          elseif ( etapen.eq.52 ) then
            nuaret(nbaint+1) = listar(1)
            nuaret(nbaint+2) = listar(2)
            nuaret(nbaint+3) = listar(3)
          endif
          nbaint = nbaint + 3
c
        endif
c
c 7.2. ==> Aretes internes entre noeud central et noeuds milieux
c          . Les 3 noeuds tournent dans le sens positif, vus
c            de l'exterieur
c
        if ( mod(option,3).eq.0 .or. option.eq.1 ) then
c
          iaux = numtet + 9
          call utarte ( iaux,
     >                  nbtrto, nbtecf,
     >                  aretri, tritet, cotrte,
     >                  listar )
c
c         . Decoupage de la face triangulaire F1 : le 1er noeud est N1
          if ( etapen.eq.51 ) then
            nuaret(nbaint+1) = listar(1)
            nuaret(nbaint+2) = listar(2)
            nuaret(nbaint+3) = listar(3)
c
c         . Decoupage de la face triangulaire F2 : le 1er noeud est N4
          elseif ( etapen.eq.52 ) then
            nuaret(nbaint+1) = listar(3)
            nuaret(nbaint+2) = listar(1)
            nuaret(nbaint+3) = listar(2)
          endif
          nbaint = nbaint + 3
c
        endif
c
c====
c 8. Decoupage standard en 8
c    Aretes internes entre les centres des faces dans l'ordre :
c    NF2NF4, NF4NF5, NF5NF3
c====
c
      elseif ( etapen.eq.80 ) then
c
        letria = facpen(f1hp+7,1)
cgn        write(1,90002) 'letria',letria
c
        do 81 , iaux = 1 , 3
          nuaret(iaux) = aretri(letria,iaux)
   81   continue
        nbaint = nbaint + 3
c
c====
c 9. Etat inconnu
c====
c
      else
        codret = 2
      endif
c
cgn      write(1,90002) 'Aretes', (nuaret(iaux),iaux=1,nbaint)
c
c====
c 10. la fin
c====
c
      if ( codret.ne.0 ) then
c
#include "envex2.h"
c
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      write (ulsort,texte(langue,2)) codret
      write (ulsort,texte(langue,4)) mess14(langue,1,7), lepent
      write (ulsort,texte(langue,5)) etapen
      write (ulsort,texte(langue,7))
c
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      call dmflsh (iaux)
#endif
c
      end
