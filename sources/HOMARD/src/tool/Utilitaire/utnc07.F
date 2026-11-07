      subroutine utnc07 ( nbanci,
     >                    noerec, arreca, arrecb,
     >                    somare, arenoe,
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
c    UTilitaire - Non Conformite - phase 07
c    --           -   -                  --
c    A partir des correspondances entre aretes, on memorise le sommet
c    commun aux deux filles.
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nbanci . e   .    1   . nombre d'aretes de non conformite initiale .
c .        .     .        . egal au nombre d'aretes recouvrant 2 autres.
c . noerec .  s  . nbanci . liste initiale des noeuds de recollement   .
c . arreca . e   .2*nbanci. liste des aretes recouvrant une autre      .
c . arrecb . e   .2*nbanci. liste des aretes recouvertes par une autre .
c . somare . e   .2*nbarto. numeros des extremites d'arete             .
c . arenoe . es  . nbnoto . 0 pour un sommet, le numero de l'arete pour.
c .        .     .        . un noeud milieu                            .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . 3 : probleme                               .
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
      parameter ( nompro = 'UTNC07' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "nombno.h"
#include "nombar.h"
c
c 0.3. ==> arguments
c
      integer nbanci
      integer noerec(nbanci)
      integer arreca(2*nbanci), arrecb(2*nbanci)
      integer arenoe(nbnoto)
      integer somare(2,nbarto)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux
      integer ifin, jfin
      integer laret1, laretg
      integer lesomm
c
      integer nbmess
      parameter ( nbmess = 10 )
      character*80 texte(nblang,nbmess)
c
c 0.5. ==> initialisations
c ______________________________________________________________________
c
c====
c 1. preliminaires
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
      texte(1,4) = '(''Examen de l''''arete'',i10)'
      texte(1,5) = '(''.. couverte par l''''arete'',i10)'
      texte(1,6) = '(''Sommet commun aux aretes'')'
      texte(1,7) = '(''Nombre de noeuds trouves  :'',i10)'
      texte(1,8) = '(''Nombre de noeuds attendus :'',i10)'
c
      texte(2,4) = '(''Examination of edge #'',i10)'
      texte(2,5) = '(''.. covered by edge #'',i10)'
      texte(2,6) = '(''Glue for edges'')'
      texte(2,7) = '(''Number of found edges    :'',i10)'
      texte(2,8) = '(''Number of expected edges :'',i10)'
c
      codret = 0
c
c====
c 2. On regarde toutes les non conformites
c====
c
      jfin = 0
      ifin = 2*nbanci
      do 21 , iaux = 1 , ifin
c
        if ( codret.eq.0 ) then
c
        laret1 = arrecb(iaux)
        laretg = arreca(iaux)
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) laret1
      write (ulsort,texte(langue,5)) laretg
#endif
c
        lesomm = somare(2,laret1)
c
        do 211 , jaux = 1 , jfin
c
           if ( noerec(jaux).eq.lesomm ) then
             goto 21
           endif
c
  211   continue
c
        jfin = jfin + 1
        noerec(jfin) = lesomm
        arenoe(lesomm) = laretg
c
        endif
c
   21 continue
c
c====
c 3. controle
c====
c
      if ( jfin.gt.nbanci ) then
c
        write (ulsort,texte(langue,6))
        write (ulsort,texte(langue,7)) jfin
        write (ulsort,texte(langue,8)) nbanci
        codret = 1
c
      endif
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
