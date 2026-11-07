      subroutine dehmaj ( option,
     >                    hetnoe, hetare,
     >                    hettri, hetqua,
     >                    hettet, hethex,
     >                    hetpen, hetpyr,
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
c traitement des DEcisions - Historique - Mis A Jour vraie
c                --          -            -   - -
c ______________________________________________________________________
c
c but : mise a jour effective des historiques
c    de maniere generale, l'historique des etats est un nombre a 2k
c    chiffres. les k premiers decrivent l'etat de l'entite avant le
c    processus de raffinement/deraffinement. les k derniers decrivent
c    l'etat apres. a ce stade, nous sommes au depart du processus. il
c    faut basculer l'etat "apres" pour le maillage n vers ce qui va etre
c    l'etat "avant" pour le maillage n+1. les k premiers chiffres sont
c    donc remplaces par les k derniers. les k derniers chiffres
c    decrivent alors l'etat courant, une fois les entites de mise en
c    conformite supprimees.
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . option . e   .    1   . 0 : tri selon la conformite                .
c .        .     .        . 1 : transfert direct                       .
c . hetnoe . es  . nbnoto . historique de l'etat des noeuds            .
c . hetare . es  . nbarto . historique de l'etat des aretes            .
c . hettri . es  . nbtrto . historique de l'etat des triangles         .
c . hetqua . es  . nbquto . historique de l'etat des quadrangles       .
c . hettet . es  . nbteto . historique de l'etat des tetraedres        .
c . hethex . es  . nbheto . historique de l'etat des hexaedres         .
c . hetpen . es  . nbpeto . historique de l'etat des pentaedres        .
c . hetpyr . es  . nbpyto . historique de l'etat des pyramides         .
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
      parameter ( nompro = 'DEHMAJ' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "nombar.h"
#include "nombtr.h"
#include "nombqu.h"
#include "nombno.h"
#include "nombte.h"
#include "nombhe.h"
#include "nombpy.h"
#include "nombpe.h"
#include "impr02.h"
c
c 0.3. ==> arguments
c
      integer option
      integer hetnoe(nbnoto)
      integer hetare(nbarto)
      integer hettri(nbtrto)
      integer hetqua(nbquto)
      integer hettet(nbteto)
      integer hethex(nbheto)
      integer hetpen(nbpeto)
      integer hetpyr(nbpyto)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux
      integer etat
c
      integer nbmess
      parameter (nbmess = 10 )
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
      texte(1,4) =
     > '(5x,''Nombre d''''entites dont on modifie l''''historique'')'
c
      texte(2,4) =
     > '(5x,''Number of entities whose history is modified'')'
c
10000 format(7x,a,' : ',i10)
10001 format(1x)
c
      codret = 0
c
      write (ulsort,texte(langue,4))
#ifdef _DEBUG_HOMARD_
      write (ulsort,10000) 'Option', option
#endif
c
c====
c 1. historique des noeuds
c
c   |------------------|----------------------------------------------|
c   |      etat        |         description                          |
c   |------------------|----------------------------------------------|
c   |       0          | noeud isole                                  |
c   |       1          | degre 1 = p1                                 |
c   |       2          | degre 2 = p2                                 |
c   |       3          | noeud de maille-point uniquement             |
c   |       5          | inexistant                                   |
c   |       9          | detruit                                      |
c   |------------------|----------------------------------------------|
c
c====
c
      write (ulsort,10000) mess14(langue,4,-1), nbnoto
c
      do 10 , iaux = 1 , nbnoto
c
        etat = mod(hetnoe(iaux),10)
c
        hetnoe(iaux) = etat * 11
c
   10 continue
c
c====
c 2. historique des aretes
c
c   |------------------|----------------------------------------------|
c   |      etat        |         description                          |
c   |------------------|----------------------------------------------|
c   |       0          | active                                       |
c   |       2          | coupee en 2 et ses 2 filles sont actives     |
c   |       5          | inexistante                                  |
c   |       9          | coupee en 2 et un de ses filles est inactive |
c   |------------------|----------------------------------------------|
c
c====
c
      write (ulsort,10000) mess14(langue,4,1), nbarto
c
      do 20 , iaux = 1 , nbarto
c
        etat = mod(hetare(iaux),10)
c
        hetare(iaux) = etat * 11
c
   20 continue
c
c====
c 3. historique des triangles
c
c   |------------------|----------------------------------------------|
c   |      etat        |         description                          |
c   |------------------|----------------------------------------------|
c   |       0          | actif                                        |
c   |       1          | coupe en 2 par sa premiere arete             |
c   |       2          | coupe en 2 par sa deuxieme arete             |
c   |       3          | coupe en 2 par sa troisieme arete            |
c   |       4          | coupe en 4 et ses 4 fils sont actifs         |
c   |       5          | inexistant                                   |
c   |       6          | coupe en 4 et bascule de la premiere arete   |
c   |                  | ses 4 fils sont actifs                       |
c   |       7          | idem avec la deuxieme arete                  |
c   |       8          | idem avec la troisieme arete                 |
c   |       9          | coupe en 4 et un de ses fils est inactif     |
c   |------------------|----------------------------------------------|
c
c====
c
      if ( nbtrto.ne.0 ) then
c
        write (ulsort,10000) mess14(langue,4,2), nbtrto
c
        jaux = 10 + option
c
        do 30 , iaux = 1 , nbtrto
c
          etat = mod(hettri(iaux),10)
c
          if ( etat.lt.4 ) then
            hettri(iaux) = etat * jaux
          else
            hettri(iaux) = etat * 11
          endif
c
   30   continue
c
      endif
c
c====
c 4. historique des quadrangles
c
c   |------------------|----------------------------------------------|
c   |      etat        |         description                          |
c   |------------------|----------------------------------------------|
c   |       0          | actif                                        |
c   |       4          | coupe en 4 et ses 4 fils sont actifs         |
c   |      21          | coupe en 2 quadrangles par les aretes 1 et 3 |
c   |      22          | coupe en 2 quadrangles par les aretes 2 et 4 |
c   |      31          | coupe en 3 triangles par son arete numero 1  |
c   |      32          | coupe en 3 triangles par son arete numero 2  |
c   |      33          | coupe en 3 triangles par son arete numero 2  |
c   |      34          | coupe en 3 triangles par son arete numero 4  |
c   |      41          | coupe en 3 quadrangles par les aretes 1 et 2 |
c   |      42          | coupe en 3 quadrangles par les aretes 2 et 3 |
c   |      43          | coupe en 3 quadrangles par les aretes 3 et 4 |
c   |      44          | coupe en 3 quadrangles par les aretes 4 et 1 |
c   |      55          | inexistant                                   |
c   |      99          | coupe en 4 et un de ses fils est inactif     |
c   |------------------|----------------------------------------------|
c
c====
c
      if ( nbquto.ne.0 ) then
c
        write (ulsort,10000) mess14(langue,4,4), nbquto
c
        jaux = 100 + option
c
        do 40 , iaux = 1 , nbquto
c
          etat = mod(hetqua(iaux),100)
c
          if ( etat.ge.21 .and. etat.le.44 ) then
            hetqua(iaux) = etat * jaux
          else
            hetqua(iaux) = etat * 101
          endif
c
   40   continue
c
      endif
c
c====
c 5. historique des tetraedres
c
c   |------------------|----------------------------------------------|
c   |      etat        |         description                          |
c   |------------------|----------------------------------------------|
c   |       0          | actif                                        |
c   | 2i i=1,2,3,4,5,6 | coupe en 2 par sa i-eme arete                |
c   | 4i i=1,2,3,4     | coupe en 4 par sa i-eme face                 |
c   | 4i i=5,6,7       | coupe en 4 par la diagonale 1-6,2-5,3-4      |
c   |      55          | inexistant                                   |
c   | 8i i=5,6,7       | coupe en 8 par la diagonale 1-6,2-5,3-4      |
c   | 99               | coupe en 8 et un de ses fils est inactif     |
c   |------------------|----------------------------------------------|
c
c====
c
      if ( nbteto.ne.0 ) then
c
        write (ulsort,10000) mess14(langue,4,3), nbteto
c
        jaux = 100 + option
c
        do 50 , iaux = 1 , nbteto
c
          etat = mod(hettet(iaux),100)
c
          if ( etat.lt.55 ) then
            hettet(iaux) = etat * jaux
          else
            hettet(iaux) = etat * 101
          endif
c
   50   continue
c
      endif
c
c====
c 6. historique des hexaedres
c
c   |------------------|----------------------------------------------|
c   |      etat        |         description                          |
c   |------------------|----------------------------------------------|
c   |       0          | actif                                        |
c   |       5          | inexistant                                   |
c   |       8          | coupe en 8                                   |
c   |       9          | coupe en 8 et un de ses fils est inactif     |
c   |      11          | coupe par conformite                         |
c   |------------------|----------------------------------------------|
c
c====
c
      if ( nbheto.ne.0 ) then
c
        write (ulsort,10000) mess14(langue,4,6), nbheto
c
        jaux = 1000 + option
c
        do 60 , iaux = 1 , nbheto
c
          etat = mod(hethex(iaux),1000)
c
          if ( etat.ge.11 ) then
            hethex(iaux) = etat * jaux
          else
            hethex(iaux) = etat * 1001
          endif
c
   60   continue
c
      endif
c
c====
c 7. historique des pyramides
c
c   |------------------|----------------------------------------------|
c   |      etat        |         description                          |
c   |------------------|----------------------------------------------|
c   |       0          | active                                       |
c   |------------------|----------------------------------------------|
c
c====
c
      if ( nbpyto.ne.0 ) then
c
        write (ulsort,10000) mess14(langue,4,5), nbpyto
c
        jaux = 100 + option
c
        do 70 , iaux = 1 , nbpyto
c
          etat = mod(hetpyr(iaux),100)
c
          if ( etat.eq.0 ) then
            hetpyr(iaux) = etat * jaux
          else
            codret = 70
          endif
c
   70   continue
c
      endif
c
c====
c 8. historique des pentaedres
c
c   |------------------|----------------------------------------------|
c   |      etat        |         description                          |
c   |------------------|----------------------------------------------|
c   |       0          | actif                                        |
c   |  i i=1, ...,  6  | coupee par l'arete i                         |
c   |  i i=17, 18, 19  | coupee par l'arete i-10                      |
c   |  i i=21, ..., 26 | coupee par 2 aretes tria & quad              |
c   |  i i=31, ..., 36 | coupee par 2 aretes tria & tria              |
c   |  i i=43, 44, 45  | coupee par une face quad                     |
c   |  i i=51, 52      | coupee par une face tria                     |
c   |      55          | inexistant                                   |
c   | 80               | coupe en 8                                   |
c   | 99               | coupe en 8 et un de ses fils est inactif     |
c   |------------------|----------------------------------------------|
c
c====
c
      if ( nbpeto.ne.0 ) then
c
        write (ulsort,10000) mess14(langue,4,7), nbpeto
c
        jaux = 100 + option
c
        do 80 , iaux = 1 , nbpeto
c
          etat = mod(hetpen(iaux),100)
c
          if ( etat.lt.55 ) then
            hetpen(iaux) = etat * jaux
          else
            hetpen(iaux) = etat * 101
          endif
c
   80   continue
c
      endif
c
c====
c 9. la fin
c====
c
      write (ulsort,10001)
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
