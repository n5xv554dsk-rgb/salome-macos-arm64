      subroutine cmchad ( nulofa, lehexa,
     >                    indpyr, indptp,
     >                    triint,   tab1,
     >                    hetpyr, facpyr, cofapy,
     >                    filpyr, perpyr, fampyr,
     >                    quahex, coquhe,
     >                    famhex, cfahex,
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
c    Creation du Maillage - Conformite - decoupage des Hexaedres
c    -           -          -                          -
c                         - par 2 Aretes - phase D
c                                 -              -
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nulofa . e   .   2    . numero local des faces quadrangles         .
c . lehexa . e   .   1    . hexaedre a decouper                        .
c . indpyr . es  .   1    . indice de la derniere pyramide creee       .
c . indptp . e   .   1    . indice du dernier pere enregistre          .
c . triint . e   .  22    . triangles internes a l'hexaedre            .
c .        .     .        .  1-4 = bordant la pyramide 1               .
c .        .     .        .  5-8 = bordant la pyramide 2               .
c .        .     .        .  9-10 = s'appuyant sur les 2 autres aretes .
c .        .     .        .         non decoupees                      .
c .        .     .        .  11-14 = appuyes sur une arete interne a   .
c .        .     .        .   une face coupee, du cote de la pyramide 1.
c .        .     .        .  15-18 = appuyes sur une arete interne a   .
c .        .     .        .   une face coupee, du cote de la pyramide 2.
c .        .     .        .  19-22 = appuyes sur les filles des aretes .
c .        .     .        .   coupees                                  .
c . tab1   . e   .    2   . code de la permutation circulaire des 4    .
c .        .     .        . faces definissant la pyramide              .
c . hetpyr . e   . nouvpy . historique de l'etat des pyramides         .
c . facpyr . es  .nouvyf*5. numeros des 5 faces des pyramides          .
c . cofapy . es  .nouvyf*5. codes des faces des pyramides              .
c . filpyr . es  . nouvpy . premier fils des pyramides                 .
c . perpyr . es  . nouvpy . pere des pyramides                         .
c .        .     .        . si perpyr(i) > 0 : numero de la pyramide   .
c .        .     .        . si perpyr(i) < 0 : -numero dans pphepe     .
c . fampyr . es  . nouvpy . famille des pyramides                      .
c . quahex . e   .nouvhf*6. numeros des 6 quadrangles des hexaedres    .
c . coquhe . e   .nouvhf*6. codes des 6 quadrangles des hexaedres      .
c . famhex . e   . nouvhe . famille des hexaedres                      .
c . cfahex .     . nctfhe. codes des familles des hexaedres            .
c .        .     . nbfhex .   1 : famille MED                          .
c .        .     .        .   2 : type d'hexaedres                     .
c .        .     .        .   3 : famille des tetraedres de conformite .
c .        .     .        .   4 : famille des pyramides de conformite  .
c . ulsort . e   .   1    . unite logique de la sortie generale        .
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . 1 : aucune arete ne correspond             .
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
      parameter ( nompro = 'CMCHAD' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "dicfen.h"
#include "nbfami.h"
#include "nouvnb.h"
#include "cofpfh.h"
#include "ope1a4.h"
c
c 0.3. ==> arguments
c
      integer lehexa, nulofa(2)
      integer indpyr, indptp
      integer triint(22), tab1(2)
      integer hetpyr(nouvpy), facpyr(nouvyf,5), cofapy(nouvyf,5)
      integer filpyr(nouvpy), perpyr(nouvpy), fampyr(nouvpy)
      integer quahex(nouvhf,6), coquhe(nouvhf,6)
      integer famhex(nouvhe), cfahex(nctfhe,nbfhex)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux
      integer laface
      integer codfac
c
      integer nbmess
      parameter ( nbmess = 10 )
      character*80 texte(nblang,nbmess)
c
c 0.5. ==> initialisations
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
      codret = 0
c
c====
c 2. Creation des deux pyramides
c====
c
c 2.1. ==> Le pere des pyramides et leur famille
c
      iaux = -indptp
      jaux = cfahex(cofpfh,famhex(lehexa))
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'CMCPYR', nompro
      write (ulsort,2100) indpyr+1, indpyr+2
 2100 format( '.. pyramides de',i10,' a',i10)
#endif
c
      laface = quahex(lehexa,nulofa(1))
      codfac = coquhe(lehexa,nulofa(1))
      indpyr = indpyr + 1
      call cmcpyr ( facpyr, cofapy, fampyr, hetpyr, filpyr, perpyr,
     >              triint(per1a4(tab1(1),1)), 3,
     >              triint(per1a4(tab1(1),2)), 3,
     >              triint(per1a4(tab1(1),3)), 3,
     >              triint(per1a4(tab1(1),4)), 2,
     >                 laface, codfac,
     >              iaux,  jaux,   indpyr )
c
      laface = quahex(lehexa,nulofa(2))
      codfac = coquhe(lehexa,nulofa(2))
      indpyr = indpyr + 1
      call cmcpyr ( facpyr, cofapy, fampyr, hetpyr, filpyr, perpyr,
     >              triint(4+per1a4(tab1(2),1)), 3,
     >              triint(4+per1a4(tab1(2),2)), 3,
     >              triint(4+per1a4(tab1(2),3)), 3,
     >              triint(4+per1a4(tab1(2),4)), 2,
     >                 laface, codfac,
     >              iaux,  jaux,   indpyr )
c
#ifdef _DEBUG_HOMARD_
      do 4333 , iaux = indpyr-1, indpyr
      write(ulsort,1789) iaux, (facpyr(iaux,jaux),jaux=1,5)
 4333 continue
 1789 format('pyramide ',i6,' : ',5i6)
#endif
c
c====
c 3. la fin
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
