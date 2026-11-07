      subroutine cminma ( indnoe, indare, indtri, indqua,
     >                    indtet, indhex, indpyr, indpen,
     >                    lgopti, taopti,
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
c    Creation du Maillage - INitialisation du MAillage
c    -           -          --                --
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . indnoe .  s  .   1    . indice du dernier noeud cree               .
c . indare .  s  .   1    . indice de la derniere arete creee          .
c . indtri .  s  .   1    . indice du dernier triangle cree            .
c . indqua .  s  .   1    . indice du dernier quadrangle cree          .
c . indtet .  s  .   1    . indice du dernier tetraedre cree           .
c . indhex .  s  .   1    . indice du dernier hexaedre cree            .
c . indpyr .  s  .   1    . indice de la derniere pyramide creee       .
c . indpen .  s  .   1    . indice du dernier pentaedre cree           .
c . lgopti . e   .   1    . longueur du tableau des options entieres   .
c . taopti . e   . lgopti . tableau des options                        .
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
      parameter ( nompro = 'CMINMA' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
#include "envada.h"
#include "nombar.h"
#include "nombtr.h"
#include "nombqu.h"
#include "nombno.h"
#include "nombte.h"
#include "nombhe.h"
#include "nombpy.h"
#include "nombpe.h"
c
#include "nouvnb.h"
c
c 0.3. ==> arguments
c
      integer indnoe, indare, indtri, indqua
      integer indtet, indhex, indpyr, indpen
c
      integer lgopti
      integer taopti(lgopti)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux
c
      integer nbmess
      parameter ( nbmess = 10 )
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
c====
c 2. initialisation des pointeurs
c    Quand le maillage ne change pas, il faut initialiser les pointeurs.
c    Cela arrive dans deux cas :
c    A l'iteration 0 : si pas de raffinement, quel que soit le type de
c                      deraffinement car il sera ete inhibe
c    Aux iterations suivantes : si ni raffinement, ni deraffinement
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '2. initial. pointeurs ; codret', codret
#endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'nbiter', nbiter
      write (ulsort,90002) 'taopti(31)', taopti(31)
      write (ulsort,90002) 'taopti(32)', taopti(32)
#endif
c
      if ( codret.eq.0 ) then
c
      if ( ( nbiter.eq.0 .and. taopti(31).eq.0 ) .or.
     >     ( nbiter.gt.0 .and.
     >       taopti(31).eq.0 .and. taopti(32).eq.0 ) ) then
c
        permno = nbnoto
        permp2 = nbnop2
        permim = nbnoim
        permar = nbarpe
        permtr = nbtrpe
        permqu = nbqupe
        permte = nbtepe
        permhe = nbhepe
        permpy = nbpype
        permpe = nbpepe
c
        nouvno = nbnoto
        nouvp2 = nbnop2
        nouvim = nbnoim
        nouvar = nbarto
        nouvtr = nbtrto
        nouvqu = nbquto
        nouvte = nbteto
        nouvtf = nouvte
        nouvta = 0
        nouvhe = nbheto
        nouvhf = nouvhe
        nouvha = 0
        nouvpy = nbpyto
        nouvyf = nouvpy
        nouvya = 0
        nouvpe = nbpeto
        nouvpf = nouvpe
        nouvpa = 0
c
        indnoe = nbnoto
        indare = nbarto
        indtri = nbtrto
        indqua = nbquto
        indtet = nbteto
        indhex = nbheto
        indpyr = nbpyto
        indpen = nbpeto
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002)
     >'permar, permtr, permno, permp2, permim, permqu',
     > permar, permtr, permno, permp2, permim, permqu
      write (ulsort,90002)
     >'nouvar, nouvtr, nouvno, nouvp2, nouvim, nouvqu',
     > nouvar, nouvtr, nouvno, nouvp2, nouvim, nouvqu
      write (ulsort,90002)
     >'provar, provtr, provp1, provp2, provim, provqu',
     > provar, provtr, provp1, provp2, provim, provqu
      write (ulsort,90002)
     >'permte, permhe, permpy, permpe',
     > permte, permhe, permpy, permpe
      write (ulsort,90002)
     >'nouvte, nouvhe, nouvpy, nouvpe',
     > nouvte, nouvhe, nouvpy, nouvpe
      write (ulsort,90002)
     >'provta, provha, provya, provpa',
     > provta, provha, provya, provpa
      write (ulsort,90002)
     >'provtf, provhf, provyf, provpf',
     > provtf, provhf, provyf, provpf
#endif
c
      endif
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
