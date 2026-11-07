      subroutine cmchf0 ( lehexa, etahex, etatfa,
     >                    indare, indtri, indtet, indpyr,
     >                    indptp,
     >                    hetare, somare,
     >                    filare, merare, famare,
     >                    hettri, aretri,
     >                    filtri, pertri, famtri,
     >                    nivtri,
     >                    arequa, filqua,
     >                    hettet, tritet, cotrte,
     >                    filtet, pertet, famtet,
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
c                         - par 1 Face - pilotage
c                                 -
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . lehexa . e   .   1    . hexaedre a decouper                        .
c . etahex .  s  .    1   . etat final de l'hexaedre                   .
c . etatfa . e   .   6    . etat des faces de l'hexaedre               .
c . indare . es  .   1    . indice de la derniere arete creee          .
c . indtri . es  .   1    . indice du dernier triangle cree            .
c . indtet . es  .   1    . indice du dernier tetraedre cree           .
c . indpyr . es  .   1    . indice de la derniere pyramide creee       .
c . indptp . e   .   1    . indice du dernier pere enregistre          .
c . hetare . es  . nouvar . historique de l'etat des aretes            .
c . somare . es  .2*nouvar. numeros des extremites d'arete             .
c . filare . es  . nouvar . premiere fille des aretes                  .
c . merare . es  . nouvar . mere des aretes                            .
c . famare .     . nouvar . famille des aretes                         .
c . hettri . es  . nouvtr . historique de l'etat des triangles         .
c . aretri . es  .nouvtr*3. numeros des 3 aretes des triangles         .
c . filtri . es  . nouvtr . premier fils des triangles                 .
c . pertri . es  . nouvtr . pere des triangles                         .
c . famtri . es  . nouvtr . famille des triangles                      .
c . nivtri . es  . nouvtr . niveau des triangles                       .
c . arequa . e   .nouvqu*4. numeros des 4 aretes des quadrangles       .
c . filqua . e   . nouvqu . premier fils des quadrangles               .
c . hettet . es  . nouvte . historique de l'etat des tetraedres        .
c . tritet . es  .nouvtf*4. numeros des 4 triangles des tetraedres     .
c . cotrte . e   .nouvtf*4. code des 4 triangles des tetraedres        .
c . filtet . es  . nouvte . premier fils des tetraedres                .
c . pertet . es  . nouvte . pere des tetraedres                        .
c .        .     .        . si pertet(i) > 0 : numero du tetraedre     .
c .        .     .        . si pertet(i) < 0 : -numero dans pthepe     .
c . famtet . es  . nouvte . famille des tetraedres                     .
c . hetpyr . e   . nouvpy . historique de l'etat des pyramides         .
c . facpyr . e   .nouvyf*5. numeros des 5 faces des pyramides          .
c . cofapy . e   .nouvyf*5. codes des faces des pyramides              .
c . filpyr . e   . nouvpy . premier fils des pyramides                 .
c . perpyr . e   . nouvpy . pere des pyramides                         .
c .        .     .        . si perpyr(i) > 0 : numero de la pyramide   .
c .        .     .        . si perpyr(i) < 0 : -numero dans pphepe     .
c . fampyr . e   . nouvpy . famille des pyramides                      .
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
c .        .     .        . 1 : aucune face ne correspond              .
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
      parameter ( nompro = 'CMCHF0' )
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
#include "impr02.h"
c
c 0.3. ==> arguments
c
      integer lehexa, etahex, etatfa(6)
      integer indare, indtri, indtet, indpyr
      integer indptp
      integer hetare(nouvar), somare(2,nouvar)
      integer filare(nouvar), merare(nouvar), famare(nouvar)
      integer hettri(nouvtr), aretri(nouvtr,3)
      integer filtri(nouvtr), pertri(nouvtr), famtri(nouvtr)
      integer nivtri(nouvtr)
      integer arequa(nouvqu,4), filqua(nouvqu)
      integer hettet(nouvte), tritet(nouvtf,4), cotrte(nouvtf,4)
      integer filtet(nouvte), pertet(nouvte), famtet(nouvte)
      integer hetpyr(nouvpy), facpyr(nouvyf,5), cofapy(nouvyf,5)
      integer filpyr(nouvpy), perpyr(nouvpy), fampyr(nouvpy)
      integer quahex(nouvhf,6), coquhe(nouvhf,6)
      integer famhex(nouvhe), cfahex(nctfhe,nbfhex)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux
      integer listar(12), listso(8)
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
      write (ulsort,1000) 'indtri', indtri
      write (ulsort,1000) 'indtet', indtet
      write (ulsort,1000) 'indpyr', indpyr
 1000 format (a6,' =',i10)
#endif
c
      texte(1,4) = '(''Aucune face ne correspond.'')'
      texte(1,5) = '(''Liste des '',a,'' :'',6i10)'
      texte(1,6) = '(''avec les etats           :'',6i10)'
c
      texte(2,4) = '(''No face is good'')'
      texte(2,5) = '(''List of '',a,'' :'',6i10)'
      texte(2,6) = '(''with status              :'',6i10)'
c
      codret = 0
c
c====
c 2. Recherche des faces, des aretes et des sommets
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTARHE', nompro
#endif
      call utarhe ( lehexa,
     >              nouvqu, nouvhe,
     >              arequa, quahex, coquhe,
     >              listar )
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTSOHE', nompro
#endif
      call utsohe ( somare, listar, listso )
#ifdef _DEBUG_HOMARD_
      write(ulsort,*) 'listar = ', listar
      write(ulsort,*) 'listso = ', listso
#endif
c
c====
c 3. decoupage
c====
#ifdef _DEBUG_HOMARD_
       iaux = 212
      write(ulsort,*) 'arequa(iaux,1) = ', arequa(iaux,1),
     >                   ' de ',somare(1,arequa(iaux,1)),
     >                   ' a ',somare(2,arequa(iaux,1))
      write(ulsort,*) 'arequa(iaux,2) = ', arequa(iaux,2),
     >                   ' de ',somare(1,arequa(iaux,2)),
     >                   ' a ',somare(2,arequa(iaux,2))
      write(ulsort,*) 'arequa(iaux,3) = ', arequa(iaux,3),
     >                   ' de ',somare(1,arequa(iaux,3)),
     >                   ' a ',somare(2,arequa(iaux,3))
      write(ulsort,*) 'arequa(iaux,4) = ', arequa(iaux,4),
     >                   ' de ',somare(1,arequa(iaux,4)),
     >                   ' a ',somare(2,arequa(iaux,4))
#endif
c
c 3.1. ==> C'est la face 1 qui est coupee
c
      if ( etatfa(1).eq.4 ) then
        etahex = 285
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'CMCH41', nompro
#endif
        call cmch41 ( lehexa, listar, listso,
     >                indare, indtri, indtet, indpyr,
     >                indptp,
     >                hetare, somare,
     >                filare, merare, famare,
     >                hettri, aretri,
     >                filtri, pertri, famtri,
     >                nivtri,
     >                arequa, filqua,
     >                hettet, tritet, cotrte,
     >                filtet, pertet, famtet,
     >                hetpyr, facpyr, cofapy,
     >                filpyr, perpyr, fampyr,
     >                quahex, coquhe,
     >                famhex, cfahex,
     >                ulsort, langue, codret )
c
c 3.2. ==> C'est la face 2 qui est coupee
c
      elseif ( etatfa(2).eq.4 ) then
        etahex = 286
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'CMCH42', nompro
#endif
        call cmch42 ( lehexa, listar, listso,
     >                indare, indtri, indtet, indpyr,
     >                indptp,
     >                hetare, somare,
     >                filare, merare, famare,
     >                hettri, aretri,
     >                filtri, pertri, famtri,
     >                nivtri,
     >                arequa, filqua,
     >                hettet, tritet, cotrte,
     >                filtet, pertet, famtet,
     >                hetpyr, facpyr, cofapy,
     >                filpyr, perpyr, fampyr,
     >                quahex, coquhe,
     >                famhex, cfahex,
     >                ulsort, langue, codret )
c
c 3.3. ==> C'est la face 3 qui est coupee
c
      elseif ( etatfa(3).eq.4 ) then
        etahex = 287
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'CMCH43', nompro
      write (ulsort,*) 'indtri = ', indtri
#endif
        call cmch43 ( lehexa, listar, listso,
     >                indare, indtri, indtet, indpyr,
     >                indptp,
     >                hetare, somare,
     >                filare, merare, famare,
     >                hettri, aretri,
     >                filtri, pertri, famtri,
     >                nivtri,
     >                arequa, filqua,
     >                hettet, tritet, cotrte,
     >                filtet, pertet, famtet,
     >                hetpyr, facpyr, cofapy,
     >                filpyr, perpyr, fampyr,
     >                quahex, coquhe,
     >                famhex, cfahex,
     >                ulsort, langue, codret )
c
c 3.4. ==> C'est la face 4 qui est coupee
c
      elseif ( etatfa(4).eq.4 ) then
        etahex = 288
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'CMCH44', nompro
#endif
        call cmch44 ( lehexa, listar, listso,
     >                indare, indtri, indtet, indpyr,
     >                indptp,
     >                hetare, somare,
     >                filare, merare, famare,
     >                hettri, aretri,
     >                filtri, pertri, famtri,
     >                nivtri,
     >                arequa, filqua,
     >                hettet, tritet, cotrte,
     >                filtet, pertet, famtet,
     >                hetpyr, facpyr, cofapy,
     >                filpyr, perpyr, fampyr,
     >                quahex, coquhe,
     >                famhex, cfahex,
     >                ulsort, langue, codret )
c
c 3.5. ==> C'est la face 5 qui est coupee
c
      elseif ( etatfa(5).eq.4 ) then
        etahex = 289
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'CMCH45', nompro
#endif
        call cmch45 ( lehexa, listar, listso,
     >                indare, indtri, indtet, indpyr,
     >                indptp,
     >                hetare, somare,
     >                filare, merare, famare,
     >                hettri, aretri,
     >                filtri, pertri, famtri,
     >                nivtri,
     >                arequa, filqua,
     >                hettet, tritet, cotrte,
     >                filtet, pertet, famtet,
     >                hetpyr, facpyr, cofapy,
     >                filpyr, perpyr, fampyr,
     >                quahex, coquhe,
     >                famhex, cfahex,
     >                ulsort, langue, codret )
c
c 3.6. ==> C'est la face 6 qui est coupee
c
      elseif ( etatfa(6).eq.4 ) then
        etahex = 290
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'CMCH46', nompro
#endif
        call cmch46 ( lehexa, listar, listso,
     >                indare, indtri, indtet, indpyr,
     >                indptp,
     >                hetare, somare,
     >                filare, merare, famare,
     >                hettri, aretri,
     >                filtri, pertri, famtri,
     >                nivtri,
     >                arequa, filqua,
     >                hettet, tritet, cotrte,
     >                filtet, pertet, famtet,
     >                hetpyr, facpyr, cofapy,
     >                filpyr, perpyr, fampyr,
     >                quahex, coquhe,
     >                famhex, cfahex,
     >                ulsort, langue, codret )
c
c 3.7. ==> Laquelle ?
c
      else
        codret = 1
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
      write (ulsort,texte(langue,4))
      write (ulsort,texte(langue,5)) mess14(langue,3,4),
     >                      ( quahex(lehexa,iaux), iaux=1,6 )
      write (ulsort,texte(langue,6)) (etatfa(iaux),iaux=1,6 )
c
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      call dmflsh (iaux)
#endif
c
      end
