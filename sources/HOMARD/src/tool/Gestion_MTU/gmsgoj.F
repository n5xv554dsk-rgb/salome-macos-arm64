      subroutine gmsgoj ( nomemc, codret )
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
c     supprimer le graphe d'un objet en memoire centrale
c     et le detruire
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nomemc . e   .char(*) . nom etendu en memoire centrale             .
c . codret .  s  . ent    . code retour de l'operation                 .
c .        .     .        .  0 : OK                                    .
c .        .     .        . -1 : Probleme dans la suppression du graphe.
c .        .     .        . -2 : Probleme dans la liberation de l'objet.
c .____________________________________________________________________.
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
      parameter ( nompro = 'GMSGOJ' )
c
c
#include "genbla.h"
c
#include "gmcain.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
#include "gmcoer.h"
#include "gmimpr.h"
#include "gmlang.h"
c
c 0.3. ==> arguments
c
      integer codret
c
      character*(*) nomemc 
c
c 0.4. ==> variables locales
c
      integer iaux
      integer icar, imin, imax
c
      character*8 nomter, nomaux
c
      integer nbmess
      parameter ( nbmess = 20 )
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
      texte(1,10) = '(''Suppression du graphe de l''''objet '',a8)'
      texte(1,4) = '(''en memoire centrale.'')'
      texte(1,11) = '(''Probleme a la suppression du graphe.'')'
      texte(1,12) = '(''Probleme a la liberation de l''''objet.'')'
c
      texte(2,10) = '(''Suppression of the graph of the object '',a8)'
      texte(2,4) = '(''in central memory.'')'
      texte(2,11) = '(''Problem in freeing the graph.'')'
      texte(2,12) = '(''Problem in freeing the object.'')'
c
c====
c 2. on supprime le graphe seul
c====
c
      call gasgmc (nomemc,codret)
c
c====
c 3. si l'objet est structure et que la suppression du graphe
c    s'est bien passe
c    ou : si l'objet est simple
c    detachement de l'objet de tous ses supports
c    si c'est un objet temporaire et que c'est une tete, on le raye
c    de la liste
c====
c
      if ( codret.eq.0 .or. codret.eq.-5 ) then
c
        call gmnomc (nomemc, nomter, codret)
c
        if ( codret.eq.0 ) then
c
          call gblboj ( nomter )
          codret = coergm
c
        endif
c
        if ( codret.eq.0 ) then
c
          nomaux = '        '
          call gbdtoj ( nomaux, nomter )
          codret = coergm
c
        endif
c
        if ( codret.ne.0 ) then
          codret = -2
        endif
c
      else
c
         codret = - 1
c
      endif
c
      if ( codret.eq.0 .and. len(nomemc).ge.8 ) then
c
c avant de supprimer le nom de la liste des noms d'objets temporaires,
c on verifie que le nom (terminal) a bien la structure d'un nom
c temporaire : un certain nombre (>0) de caracteres caint1 (% a priori),
c suivis d'un entier (le tout, code sur 8 caracteres).
c
          if ( nomter(1:1).eq.caint1 .and. 
     >         nomter.eq.nomemc(1:8)       ) then
            imin = 2
            imax = 11
            do 80 icar = 2, 8
              iaux = index('0123456789'//caint1, nomter(icar:icar))
              if (iaux.lt.imin.or.iaux.gt.imax) then
                goto 91
              else
                if (iaux.ne.11) then
                  imin = 1
                  imax = 10
                endif
              endif
   80       continue
            if (imax.ne.11) then
              call gbntde ( nomter , iaux )
            endif
          endif
c
      endif
c
c====
c 9. gestion des erreurs
c====
c
   91 continue
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '9. Gestions des erreurs ; codret = ', codret
#endif
c
      if ( codret.ne.0 ) then
c
        write (ulsort,90000)
        write (ulsort,texte(langue,1)) 'Sortie', nompro
        write (ulsort,texte(langue,10))
        write (ulsort,*) nomemc
        write (ulsort,texte(langue,4))
        if ( abs(codret).le.2 .and. coergm.eq.0 ) then
          iaux = 10+abs(codret)
          write (ulsort,texte(langue,iaux))
        endif
        write (ulsort,90000)
c
#include "envex2.h"
c
      endif
c
90000 format (70('='))
c
      end
