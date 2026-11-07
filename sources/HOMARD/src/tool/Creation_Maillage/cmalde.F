      subroutine cmalde ( nomail,
     >                    indnoe, indnp2, indnim, indare,
     >                    indtri, indqua,
     >                    indtet, indhex, indpen,
     >                    lgopts, taopts, lgetco, taetco,
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
c    Creation du Maillage - ALlocation pour le DEraffinement
c    -           -          --                 --
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nomail . e   .  ch8   . nom de l'objet contenant le maillage       .
c . indnoe . es  .   1    . indice du dernier noeud cree               .
c . indnp2 . es  .   1    . nombre de noeuds p2 en vigueur             .
c . indnim . es  .   1    . nombre de noeuds internes en vigueur       .
c . indare . es  .   1    . indice de la derniere arete creee          .
c . indtri . es  .   1    . indice du dernier triangle cree            .
c . indqua . es  .   1    . indice du dernier quadrangle cree          .
c . indtet . es  .   1    . indice du dernier tetraedre cree           .
c . indhex . es  .   1    . indice du dernier hexaedre cree            .
c . indpen . es  .   1    . indice du dernier pentaedre cree           .
c . lgopts . e   .   1    . longueur du tableau des options caracteres .
c . taopts . e   . lgopts . tableau des options caracteres             .
c . lgetco . e   .   1    . longueur du tableau de l'etat courant      .
c . taetco . e   . lgetco . tableau de l'etat courant                  .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .   1    . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . e/s .   1    . code de retour des modules                 .
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
      parameter ( nompro = 'CMALDE' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
#include "impr02.h"
c
#include "envca1.h"
#include "nombno.h"
#include "nombar.h"
#include "nombtr.h"
#include "nombqu.h"
#include "nombte.h"
#include "nombhe.h"
#include "nombpe.h"
#include "nombpy.h"
#include "nouvnb.h"
c
c 0.3. ==> arguments
c
      character*8 nomail
c
      integer indnoe, indnp2, indnim, indare, indtri, indqua
      integer indtet, indhex, indpen
c
      integer lgopts
      character*8 taopts(lgopts)
c
      integer lgetco
      integer taetco(lgetco)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer codava
      integer nretap, nrsset
      integer iaux, jaux
c
      character*6 saux
      character*8 ndecfa
c
      logical extrus
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
      codava = codret
c
c=======================================================================
      if ( codava.eq.0 ) then
c=======================================================================
c
c 1.3. ==> les messages
c
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
      texte(1,4) =
     > '(/,a6,'' REALLOCATION MEMOIRE APRES LE DERAFFINEMENT'')'
      texte(1,5) = '(50(''=''),/)'
      texte(1,6) = '(''Modification de taille des tableaux des '',a)'
c
      texte(2,4) =
     > '(/,a6,'' MEMORY REALLOCATION AFTER UNREFINEMENT'')'
      texte(2,5) = '(45(''=''),/)'
      texte(2,6) = '(''Size modification of arrays for '',a)'
c
#include "impr03.h"
c
c 1.4. ==> le numero de sous-etape
c
      nretap = taetco(1)
      nrsset = taetco(2) + 1
      taetco(2) = nrsset
c
      call utcvne ( nretap, nrsset, saux, iaux, codret )
c
c 1.5. ==> le titre
c
      write (ulsort,texte(langue,4)) saux
      write (ulsort,texte(langue,5))
c
c====
c 2. decompte du nombre d'entites restantes apres deraffinement
c====
#ifdef _DEBUG_HOMARD_
      write(ulsort,90002) '2. decompte ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      permno = indnoe
      permar = indare
      permtr = indtri
      permqu = indqua
      permte = indtet
      permhe = indhex
      permpe = indpen
c
      if ( degre.eq.2 ) then
        permp2 = indnp2
      endif
c
      if ( mod(mailet,2).eq.0 .or.  mod(mailet,3).eq.0 .or.
     >     mod(mailet,5).eq.0 ) then
        permim = indnim
      endif
c
      endif
c
c====
c 3. reallocation des tableaux avec les nouvelles dimensions
c====
#ifdef _DEBUG_HOMARD_
      write(ulsort,90002) '3. reallocation ; codret', codret
#endif
      if ( codret.eq.0 ) then
c
      ndecfa = taopts(12)
      iaux = 1
      if ( typcca.eq.26 .or .typcca.eq.46 ) then
        extrus = .false.
      elseif ( maextr.ne.0 ) then
        extrus = .true.
      else
        extrus = .false.
      endif
      jaux = 0
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'CMAL01', nompro
#endif
      call cmal01 (   iaux, extrus,
     >              nomail, ndecfa,
     >              nbnoto, permno,
     >              nbarto, permar,
     >              nbtrto, permtr,
     >              nbquto, permqu,
     >              nbteto, permte, jaux, jaux,
     >              nbheto, permhe, jaux, jaux,
     >              nbpeto, permpe, jaux, jaux,
     >              nbpyto, permpy, jaux, jaux,
     >              ulsort, langue, codret )
c
      endif
c
c====
c 4. mise a jour
c====
#ifdef _DEBUG_HOMARD_
      write(ulsort,90002) '4. mise a jour ; codret', codret
#endif
      if ( codret.eq.0 ) then
c
c     remise a jour des longueurs totales stockees
c
      nbnoto = permno
      nbarto = permar
      nbtrto = permtr
      nbquto = permqu
      nbteto = permte
      nbtecf = nbteto
      nbteca = 0
      nbheto = permhe
      nbhecf = nbheto
      nbheca = 0
      nbpeto = permpe
      nbpecf = nbpeto
      nbpeca = 0
      nbpyto = permpy
      nbpycf = nbpyto
      nbpyca = 0
c
c     remise a jour des nombres d'entites permanentes
c     (lorsque la conformite est supprimee, elles sont identiques
c     aux nombres d'entites totales)
c
      nbarpe = permar
      nbtrpe = permtr
      nbqupe = permqu
      nbtepe = permte
      nbhepe = permhe
      nbpepe = permpe
c
c     remise a jour des nombres d'entites 'nouvelles'
c
      nouvno = nbnoto
      nouvar = nbarto
      nouvtr = nbtrto
      nouvqu = nbquto
      nouvte = nbteto
      nouvtf = nouvte
      nouvhe = nbheto
      nouvhf = nouvhe
      nouvpe = nbpeto
      nouvpf = nouvpe
c
      endif
c
c====
c 5. la fin
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
c=======================================================================
      endif
c=======================================================================
c
      end
