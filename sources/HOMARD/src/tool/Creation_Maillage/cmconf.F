      subroutine cmconf ( nomail,
     >                    indnoe, indare,
     >                    indtri, indqua,
     >                    indtet, indpyr, indhex,
     >                    lgopti, taopti, lgopts, taopts,
     >                    lgetco, taetco,
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
c    Creation du Maillage - mise en CONFormite
c    -           -                  ----
c ______________________________________________________________________
c
c but : mise en conformite du maillage :
c       - decoupage des triangles en 2
c       - decoupage des quadrangles en 3 triangles,
c         en 2 ou 3 quadrangles
c       - decoupage des tetraedres en 2 ou en 4
c       - decoupage des hexaedres en hexaedres, pyramides et tetraedres
c       - decoupage des pentaedres en pyramides et tetraedres
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nomail . e   .  ch8   . nom de l'objet contenant le maillage       .
c . indnoe . es  .   1    . indice du dernier noeud cree               .
c . indare . es  .   1    . indice de la derniere arete creee          .
c . indtri . es  .   1    . indice du dernier triangle cree            .
c . indqua . es  .   1    . indice du dernier quadrangle cree          .
c . indtet . es  .   1    . indice du dernier tetraedre cree           .
c . indpyr . es  .   1    . indice de la derniere pyramide creee       .
c . indhex . es  .   1    . indice du dernier hexaedre cree            .
c . lgopti . e   .   1    . longueur du tableau des options entieres   .
c . taopti . e   . lgopti . tableau des options                        .
c . lgopts . e   .   1    . longueur du tableau des options caracteres .
c . taopts . e   . lgopts . tableau des options caracteres             .
c . lgetco . e   .   1    . longueur du tableau de l'etat courant      .
c . taetco . e   . lgetco . tableau de l'etat courant                  .
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
      parameter ( nompro = 'CMCONF' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "gmenti.h"
#include "gmreel.h"
c
#include "nombno.h"
#include "nombtr.h"
#include "nombqu.h"
#include "nombte.h"
#include "nombhe.h"
#include "nombpe.h"
#include "nombpy.h"
#include "nouvnb.h"
#include "envca1.h"
#include "impr02.h"
c
c 0.3. ==> arguments
c
      character*8 nomail
c
      integer indnoe, indare, indtri, indqua
      integer indtet, indpyr, indhex
c
      integer lgopti
      integer taopti(lgopti)
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
      integer codre0
      integer pdecfa
      integer phetno, pcoono, pareno
      integer phetar, psomar, pfilar, pmerar
      integer phettr, paretr, pfiltr, ppertr, pnivtr
      integer phetqu, parequ, pfilqu, pperqu, pnivqu, adnmqu
      integer phette, ptrite, pcotrt, pfilte, pperte, adtes2, parete
      integer phetpe, pfacpe, pcofap, pfilpe, pperpe, adpes2, parepe
      integer phetpy, pfacpy, pcofay, pfilpy, pperpy, adpys2, parepy
      integer pquahe, pcoquh, phethe, pfilhe, pperhe, adhes2, parehe
      integer pfamno, pcfano
      integer pfamar
      integer pfamtr, pcfatr
      integer pfamte
      integer pfamqu, pcfaqu
      integer pfamhe, pcfahe
      integer pfampe, pcfape
      integer pfampy
c
      integer indtea, indpya, indhea
c
      character*6 saux
      character*8 norenu
      character*8 nhnoeu, nhmapo, nharet, nhtria, nhquad
      character*8 nhtetr, nhhexa, nhpyra, nhpent
      character*8 nhelig
      character*8 nhvois, nhsupe, nhsups
      character*8 ntrav1
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
     > '(/,a6,'' MISE EN CONFORMITE DU MAILLAGE'')'
      texte(1,5) = '(37(''=''),/)'
      texte(1,6) =
     >'(5x,''Nombre de '',a,'' crees :'',i10)'
      texte(1,7) =
     > '(5x,''Ce nombre est incorrect. On en attendait'',i10)'
c
      texte(2,4) =
     > '(/,a6,'' MESH CONFORMITY'')'
      texte(2,5) = '(22(''=''),/)'
      texte(2,6) = '(5x,''Number of new '',a,'':'',i10)'
      texte(2,7) =
     > '(5x,''Wrong number.'',i10,'' were expected.'')'
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
      write ( ulsort,texte(langue,4)) saux
      write ( ulsort,texte(langue,5))
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90006) 'nouvar =', nouvar, 'provar =', provar
      write (ulsort,90006) 'nouvtr =', nouvtr, 'provtr =', provtr
      write (ulsort,90006) 'nouvqu =', nouvqu, 'provqu =', provqu
      write (ulsort,90006) 'nouvte =', nouvte, 'provte =', provte,
     >                     'provtf =', provtf, 'provta =', provta
      write (ulsort,90006) 'nouvhe =', nouvhe, 'provhe =', provhe,
     >                     'provhf =', provhf, 'provha =', provha,
     >                     'nbheco =', nbheco
      write (ulsort,90006) 'nouvpe =', nouvpe, 'provpe =', provpe,
     >                     'nbpeco =', nbpeco
      write (ulsort,90006) 'nouvpy =', nouvpy, 'provpy =', provpy,
     >                     'provyf =', provyf, 'provya =', provya
#endif
c
c====
c 2. recuperation des pointeurs
c====
c
c 2.1. ==> structure generale
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTNOMH', nompro
#endif
c
      call utnomh ( nomail,
     >                sdim,   mdim,
     >               degre, maconf, homolo, hierar,
     >              rafdef, nbmane, typcca, typsfr, maextr,
     >              mailet,
     >              norenu,
     >              nhnoeu, nhmapo, nharet,
     >              nhtria, nhquad,
     >              nhtetr, nhhexa, nhpyra, nhpent,
     >              nhelig,
     >              nhvois, nhsupe, nhsups,
     >              ulsort, langue, codret)
c
      endif
c
c 2.2. ==> tableaux
c
      if ( codret.eq.0 ) then
c
      if ( nouvno.eq.nbnoto ) then
        iaux = 5
      else
        iaux = 210
      endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD01', nompro
#endif
      call utad01 ( iaux, nhnoeu,
     >              phetno,
     >              pfamno, pcfano,   jaux,
     >              pcoono, pareno,   jaux,   jaux,
     >              ulsort, langue, codret )
c
      iaux = 210
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD02_ar', nompro
#endif
      call utad02 ( iaux, nharet,
     >              phetar, psomar, pfilar, pmerar,
     >              pfamar,   jaux,   jaux,
     >                jaux,   jaux,   jaux,
     >                jaux,   jaux,   jaux,
     >              ulsort, langue, codret )
c
      if ( nouvtr.ne.0 ) then
c
        iaux = 85470
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD02_tr', nompro
#endif
        call utad02 ( iaux, nhtria,
     >                phettr, paretr, pfiltr, ppertr,
     >                pfamtr, pcfatr,   jaux,
     >                pnivtr,   jaux,   jaux,
     >                  jaux,   jaux,   jaux,
     >                ulsort, langue, codret )
c
      endif
c
      if ( nbquto.ne.0 ) then
c
        iaux = 85470
        if ( mod(mailet,3).eq.0 ) then
          iaux = iaux*19
        endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD02_qu', nompro
#endif
        call utad02 ( iaux, nhquad,
     >                phetqu, parequ, pfilqu, pperqu,
     >                pfamqu, pcfaqu,   jaux,
     >                pnivqu,   jaux,   jaux,
     >                adnmqu,   jaux,   jaux,
     >                ulsort, langue, codret )
c
      endif
c
      if ( provte.ne.0 ) then
c
        iaux = 2730
        if ( nbheco.ne.0 .or. nbpeco.ne.0 ) then
          iaux = iaux*17
        endif
        if ( taopti(30).ge.0 .and. nbteca.gt.0 ) then
          iaux = iaux*31
        endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD02_te', nompro
#endif
        call utad02 ( iaux, nhtetr,
     >                phette, ptrite, pfilte, pperte,
     >                pfamte,   jaux,   jaux,
     >                  jaux, pcotrt, adtes2,
     >                  jaux,   jaux, parete,
     >                ulsort, langue, codret )
c
      endif
c
      if ( nbheto.ne.0 ) then
c
        iaux = 101010
        if ( nbheco.ne.0 ) then
          iaux = iaux*17
        endif
        if ( taopti(30).ge.0 .and. nbheca.gt.0 ) then
          iaux = iaux*31
        endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD02_he', nompro
#endif
        call utad02 ( iaux, nhhexa,
     >                phethe, pquahe, pfilhe, pperhe,
     >                pfamhe, pcfahe,   jaux,
     >                  jaux, pcoquh, adhes2,
     >                  jaux,   jaux, parehe,
     >                ulsort, langue, codret )
c
      endif
c
      if ( nbpeto.ne.0 ) then
c
        iaux = 101010
        if ( nbpeco.ne.0 ) then
          iaux = iaux*17
        endif
        if ( taopti(30).ge.0 .and. nbpeca.gt.0 ) then
          iaux = iaux*31
        endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD02_pe', nompro
#endif
        call utad02 ( iaux, nhpent,
     >                phetpe, pfacpe, pfilpe, pperpe,
     >                pfampe, pcfape,   jaux,
     >                  jaux, pcofap, adpes2,
     >                  jaux,   jaux, parepe,
     >                ulsort, langue, codret )
c
      endif
c
      if ( provpy.ne.0 ) then
c
        iaux = 101010
        if ( nbheco.ne.0 .or. nbpeco.ne.0 ) then
          iaux = iaux*17
        endif
        if ( taopti(30).ge.0 .and. nbpyca.gt.0 ) then
          iaux = iaux*31
        endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD02_py', nompro
#endif
        call utad02 ( iaux, nhpyra,
     >                phetpy, pfacpy, pfilpy, pperpy,
     >                pfampy,   jaux,   jaux,
     >                  jaux, pcofay, adpys2,
     >                  jaux,   jaux, parepy,
     >                ulsort, langue, codret )
c
      endif
c
      endif
c
      if ( codret.eq.0 ) then
c
      ntrav1 = taopts(12)
      call gmadoj ( ntrav1, pdecfa, iaux, codre0 )
      codret = max ( abs(codre0), codret )
c
      endif
c
c 2.3. ==> indice de depart des volumes decrits par aretes
c
      if ( codret.eq.0 ) then
c
      indtea = nouvtf
      indhea = nouvhf
      indpya = nouvyf
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'indtet, indtea', indtet, indtea
#endif
c
      endif
c
c====
c 3. decoupage des triangles en 2
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3. triangles ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      if ( nbtrto.ne.0 .and. provtr.gt.0 ) then
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'CMCDTR', nompro
#endif
c
        call cmcdtr ( indare, indtri, imem(pdecfa),
     >                imem(phetar), imem(psomar),
     >                imem(pfilar), imem(pmerar), imem(pfamar),
     >                imem(phettr), imem(paretr),
     >                imem(pfiltr), imem(ppertr), imem(pfamtr),
     >                imem(pnivtr),
     >                imem(pcfatr),
     >                ulsort, langue, codret )
c
      endif
c
      endif
c
c====
c 4. decoupage des quadrangles en 3 triangles, en 2 ou 3 quadrangles
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '4. quadrangles ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      if ( nbquto.ne.0 .and. ( provtr.gt.0 .or. provqu.gt.0 ) ) then
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'CMCDQU', nompro
#endif
c
        call cmcdqu ( indnoe, indare, indtri, indqua, imem(pdecfa),
     >                rmem(pcoono), imem(phetno), imem(pareno),
     >                imem(pfamno),
     >                imem(phetar), imem(psomar),
     >                imem(pfilar), imem(pmerar), imem(pfamar),
     >                imem(phettr), imem(paretr),
     >                imem(pfiltr), imem(ppertr), imem(pfamtr),
     >                imem(pnivtr),
     >                imem(phetqu), imem(parequ),
     >                imem(pfilqu), imem(pperqu), imem(pfamqu),
     >                imem(pnivqu), imem(adnmqu),
     >                imem(pcfaqu),
     >                ulsort, langue, codret )
c
      endif
c
      endif
c
c====
c 5. decoupage des tetraedres en 2 ou 4 tetraedres
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '5. tetraedres ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      if ( nbteto.ne.0 .and. provte.gt.0 ) then
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'CMCDTE', nompro
#endif
c
        call cmcdte ( indare, indtri, indtet,
     >                imem(phetar), imem(psomar),
     >                imem(pfilar), imem(pmerar), imem(pfamar),
     >                imem(phettr), imem(paretr),
     >                imem(pfiltr), imem(ppertr), imem(pfamtr),
     >                imem(pnivtr),
     >                imem(phette), imem(ptrite), imem(pcotrt),
     >                imem(pfilte), imem(pperte), imem(pfamte),
     >                ulsort, langue, codret )
c
      endif
c
      endif
c
c====
c 6. decoupage des hexaedres en pyramides, tetraedres, hexaedres
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '6. hexaedres ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      if ( nbheto.ne.0 .and.
     > ( provte.gt.0 .or. provpy.gt.0 .or. provhe.gt.0 ) ) then
c
c 6.1. ==> conforme, avec des boites pour les hexaedres
c
        if ( taopti(30).eq.-1 ) then
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) 'conforme, avec des boites pour les hexaedres'
#endif
#ifdef _DEBUG_HOMARD_
          write (ulsort,texte(langue,3)) 'CMCDHB', nompro
#endif
c
          call cmcdhb ( indnoe, indare, indtri, indtet, indpyr,
     >                  rmem(pcoono), imem(phetno), imem(pareno),
     >                  imem(pfamno),
     >                  imem(phetar), imem(psomar),
     >                  imem(pfilar), imem(pmerar), imem(pfamar),
     >                  imem(phettr), imem(paretr),
     >                  imem(pfiltr), imem(ppertr), imem(pfamtr),
     >                  imem(pnivtr),
     >                  imem(phetqu), imem(parequ),
     >                  imem(pfilqu),
     >                  imem(phette), imem(ptrite), imem(pcotrt),
     >                  imem(pfilte), imem(pperte), imem(pfamte),
     >                  imem(adtes2),
     >                  imem(phetpy), imem(pfacpy), imem(pcofay),
     >                  imem(pfilpy), imem(pperpy), imem(pfampy),
     >                  imem(adpys2),
     >                  imem(pquahe), imem(pcoquh), imem(phethe),
     >                  imem(pfilhe), imem(adhes2),
     >                  imem(pfamhe), imem(pcfahe),
     >                  ulsort, langue, codret )
c
c 6.2. ==> conforme general
c
        else
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) nompro, ' - conforme'
#endif
#ifdef _DEBUG_HOMARD_
          write (ulsort,texte(langue,3)) 'CMCDHE', nompro
#endif
c
          call cmcdhe ( indnoe, indare, indtea, indpya, indhea,
     >                  rmem(pcoono), imem(phetno), imem(pareno),
     >                  imem(pfamno),
     >                  imem(phetar), imem(psomar),
     >                  imem(pfilar), imem(pmerar), imem(pfamar),
     >                  imem(paretr),
     >                  imem(parequ),
     >                  imem(pfilqu),
     >                  imem(phette), imem(parete),
     >                  imem(pfilte), imem(pperte), imem(pfamte),
     >                  imem(adtes2),
     >                  imem(phetpy), imem(parepy),
     >                  imem(pfilpy), imem(pperpy), imem(pfampy),
     >                  imem(adpys2),
     >                  imem(phethe), imem(parehe),
     >                  imem(pfilhe), imem(adhes2), imem(pperhe),
     >                  imem(pfamhe), imem(pcfahe),
     >                  imem(pquahe), imem(pcoquh),
     >                  ulsort, langue, codret )
c
        endif
c
      endif
c
      endif
cgn      call gmprsx (nompro,nhhexa//'.ConnDesc')
cgn      call gmprsx (nompro,nhhexa//'.ConnAret')
cgn      call gmprsx (nompro,nhhexa//'.InfoSupp')
cgn      call gmprsx (nompro,nhpyra//'.ConnAret')
cgn      call gmprsx (nompro,nhpyra//'.ConnDesc')
cgn      call gmprsx (nompro,nhpyra//'.InfoSup2')
cgn      call gmprsx (nompro,nhhexa//'.InfoSup2')
cgn      call gmprsx (nompro,nhvois)
cgn      call gmprsx (nompro,nhvois//'.Vol/Tri')
cgn      call gmprsx (nompro,nhvois//'.Vol/Qua')
cgn      call gmprsx (nompro,nhvois//'.PyPe/Tri')
cgn      call gmprsx (nompro,nhvois//'.PyPe/Qua')
c
c====
c 7. decoupage des pentaedres en pyramides et tetraedres
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '7. pentaedres ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      if ( nbpeto.ne.0 .and. ( provte.gt.0 .or. provpy.gt.0 ) ) then
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'CMCDPE', nompro
#endif
c
        call cmcdpe ( indnoe, indare, indtri, indtet, indpyr,
     >                rmem(pcoono), imem(phetno), imem(pareno),
     >                imem(pfamno),
     >                imem(phetar), imem(psomar),
     >                imem(pfilar), imem(pmerar), imem(pfamar),
     >                imem(phettr), imem(paretr),
     >                imem(pfiltr), imem(ppertr), imem(pfamtr),
     >                imem(pnivtr),
     >                imem(phetqu), imem(parequ),
     >                imem(pfilqu),
     >                imem(phette), imem(ptrite), imem(pcotrt),
     >                imem(pfilte), imem(pperte), imem(pfamte),
     >                imem(adtes2),
     >                imem(phetpy), imem(pfacpy), imem(pcofay),
     >                imem(pfilpy), imem(pperpy), imem(pfampy),
     >                imem(adpys2),
     >                imem(pfacpe), imem(pcofap), imem(phetpe),
     >                imem(pfilpe), imem(adpes2),
     >                imem(pfampe), imem(pcfape),
     >                ulsort, langue, codret )
c
      endif
c
      endif
cgn      call gmprsx (nompro,nhpyra//'.ConnDesc')
cgn      call gmprsx (nompro,nhhexa//'.InfoSup2')
cgn      call gmprsx (nompro,nhvois)
cgn      call gmprsx (nompro,nhvois//'.Vol/Tri')
cgn      call gmprsx (nompro,nhvois//'.Vol/Qua')
cgn      call gmprsx (nompro,nhvois//'.PyPe/Tri')
cgn      call gmprsx (nompro,nhvois//'.PyPe/Qua')
c
c====
c 8. verifications des nombres d'entites crees et impressions
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '8. verifications ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      indtet = indtea
      indhex = indhea
      indpyr = indpya
c
      iaux = 0
c
c  attention : on ne sait pas verifier avec des noeuds P2
c
      if ( degre.eq.1 ) then
      if ( provp1.ne.0 ) then
        write (ulsort,texte(langue,6)) mess14(langue,3,-1),
     >                                 indnoe-permno
        if ( indnoe.ne.nouvno ) then
          write (ulsort,texte(langue,7)) provp1
          iaux = iaux + 1
        endif
      endif
      endif
c
      if ( provar.ne.0 ) then
        write (ulsort,texte(langue,6)) mess14(langue,3,1),
     >                                 indare-permar
        if ( indare.ne.nouvar ) then
          write (ulsort,texte(langue,7)) provar
          iaux = iaux + 1
        endif
      endif
c
      if ( provtr.ne.0 ) then
        write (ulsort,texte(langue,6)) mess14(langue,3,2),
     >                                 indtri-permtr
        if ( indtri.ne.nouvtr ) then
          write (ulsort,texte(langue,7)) provtr
          iaux = iaux + 1
        endif
      endif
c
      if ( provqu.ne.0 ) then
        write (ulsort,texte(langue,6)) mess14(langue,3,4),
     >                                 indqua-permqu
        if ( indqua.ne.nouvqu ) then
          write (ulsort,texte(langue,7)) provqu
          iaux = iaux + 1
        endif
      endif
c
      if ( provte.ne.0 ) then
        write (ulsort,texte(langue,6)) mess14(langue,3,3),
     >                                 indtet-permte
        if ( indtet.ne.nouvte ) then
          write (ulsort,texte(langue,7)) provte
          iaux = iaux + 1
        endif
      endif
c
      if ( provpy.ne.0 ) then
        write (ulsort,texte(langue,6)) mess14(langue,3,5),
     >                                 indpyr-permpy
        if ( indpyr.ne.nouvpy ) then
          write (ulsort,texte(langue,7)) provpy
          iaux = iaux + 1
        endif
      endif
c
      if ( iaux.gt.0 ) then
        codret = 4
      endif
c
      endif
c
c====
c 9. la fin
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
