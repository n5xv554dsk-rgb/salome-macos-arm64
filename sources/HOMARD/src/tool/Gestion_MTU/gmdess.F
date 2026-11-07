      subroutine gmdess (nomtab,nbplac, detlg0)
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
c .  derniere modif decembre 93 gn appel au programme generique gmdesg
c .  creation juin 93 jyb
c ......................................................................
c .
c .  - fonction :
c .    desallocation d'un emplacement memoire dans le tableau des
c .    character*8
c . 'attention' le contenu du tableau est inchange
c .
c .  - realisation:
c .    appel au programme generique gmdesg
c .
c .  - arguments:
c .       donnees:     nomtab  -->  nom du tableau
c .                    detlg0  --> vrai si le tableau est supprime
c .                                s'il devient vide
c .                       nbplac   -->  nombre de mots memoire liberes
c ......................................................................
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
      parameter ( nompro = 'GMDESS' )
c
#include "genbla.h"
#include "gmmaxt.h"
c
c 0.2. ==> communs
c
#include "gmadus.h"
#include "gmtrst.h"
#include "gmalst.h"
c
#include "gmimpr.h"
#include "envex1.h"
#include "gmlang.h"
#include "gmcoer.h"
c
c 0.3. ==> arguments
c
      character*8 nomtab
c
      integer nbplac
c
      logical detlg0
c
c 0.4. ==> variables locales
c
      integer iaux
c 
      character*1 typtab
c
c 0.5. ==> initialisations
c ______________________________________________________________________
c
      integer nbmess
      parameter ( nbmess = 10 )
      character*80 texte(nblang,nbmess)
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
c====
c 2. appel au programme generique
c====
c
      typtab = 's'
      call gmdesg ( nomtab, nbplac, typtab, detlg0,
     >      ntrous, nballs, ptrous, ltrous,
     >      ptalls, lgalls,adus, nomals )
c
c====
c 3. Fin
c====
c
      if ( coergm.ne.0 ) then
c
#include "envex2.h"
c
      endif
c
      end
