      subroutine mmagf0 ( nbjoto, nbjois, nbjoit, nbjoiq,
     >                    nbjp06, nbjp09, nbjp12,
     >                    nhnoeu, nhmapo, nharet, nhtria, nhquad,
     >                    nhtetr, nhhexa, nhpyra, nhpent,
     >                    nhsupe, nhsups,
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
c    Modification de Maillage - AGregat - Famille - phase 0
c    -               -          --        -               -
c    Creation des nouvelles familles MED
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nbjoto . e   .   1    . nombre total de joints                     .
c . nbjois . e   .   1    . nombre de joints simples                   .
c . nbjoit . e   .   1    . nombre de joints triples                   .
c . nbjoiq . e   .   1    . nombre de joints quadruples                .
c . nbjp06 . e   .   1    . nombre de joints ponctuels ordre 6         .
c . nbjp09 . e   .   1    . nombre de joints ponctuels ordre 9         .
c . nbjp12 . e   .   1    . nombre de joints ponctuels ordre 12        .
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
      parameter ( nompro = 'MMAGF0' )
c
#include "nblang.h"
#include "consts.h"
c
c 0.2. ==> communs
c
#include "meddc0.h"
#include "envex1.h"
c
#include "gmenti.h"
#include "gmstri.h"
c
#include "coftex.h"
#include "nbfami.h"
#include "dicfen.h"
c
#ifdef _DEBUG_HOMARD_
#include "nombmp.h"
#include "nombhe.h"
#include "nombpe.h"
#include "nombpy.h"
#endif
c
#include "impr02.h"
c
c 0.3. ==> arguments
c
      integer nbjoto, nbjois, nbjoit, nbjoiq
      integer nbjp06, nbjp09, nbjp12
c
      character*8 nhnoeu, nhmapo, nharet, nhtria, nhquad
      character*8 nhtetr, nhhexa, nhpyra, nhpent
      character*8 nhsupe, nhsups
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux
      integer codre1, codre2, codre3, codre4, codre5
      integer codre0
c
      integer nbfmed, nbfme0, nbfmaj
      integer lgte6n, lgte60
      integer lgts2n, lgts20
      integer adtae5, adtae6, adtae9, adtas2, adtas4
      integer typenh
      integer nctfen, nbfaen, pcfaen
      integer nbfte0
      integer pcfaqu
      integer pcfate
      integer pcfahe
      integer pcfape
#ifdef _DEBUG_HOMARD_
      integer pfamno, pcfano
      integer pfammp, pcfamp
      integer pfamar, pcfaar
      integer pfamtr, pcfatr
      integer pfamqu
      integer pfamte
      integer pfamhe
      integer pfampy, pcfapy
      integer pfampe
#endif
c
      integer decafa
c
      character*8 nhqufa, nhtefa, nhpefa, nhhefa
      character*8 nhenti
c
      integer nbmess
      parameter ( nbmess = 10 )
      character*80 texte(nblang,nbmess)
c
c 0.5. ==> initialisations
c ______________________________________________________________________
c
c====
c 1. prealables
c====
c 1.1. ==> messages
c
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
      texte(1,4) = '(''Decalage dans les numeros des familles :'',i5)'
      texte(1,5) =
     >'(''Ancien nombre de familles HOMARD de  '',a,'' :'',i5)'
      texte(1,6) =
     >'(''Nouveau nombre de familles HOMARD de '',a,'' :'',i5)'
      texte(1,7) = '(''Nombre de familles MED '',a,'' :'',i5)'
c
      texte(2,4) = '(''Shift with numbers of the families :'',i5)'
      texte(2,5) =
     >'(''Old number of HOMARD families of '',a,'' :'',i5)'
      texte(2,6) =
     >'(''New number of HOMARD families of '',a,'' :'',i5)'
      texte(2,7) = '(''Number of MED families '',a,'' :'',i5)'
c
      codret = 0
c
c====
c 2. Gestion des tableaux
c====
c 2.1. ==> Familles des quadrangles : uniquement la famille libre
c
      nbfqua = 1
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,6)) mess14(langue,3,4), nbfqua
#endif
c
      if ( codret.eq.0 ) then
c
      call gmnomc ( nhquad//'.Famille', nhqufa, codret )
c
      endif
c
      if ( codret.eq.0 ) then
c
      nctfqu = ncffqu
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTFAM1_qu', nompro
#endif
      iaux = 4
      call utfam1 ( iaux, nhqufa, pcfaqu,
     >              nctfqu, jaux, nbfqua,
     >              ulsort, langue, codret )
c
      endif
c
c 2.2. ==> Familles des tetraedres
c
      nbfte0 = nbftet
c
      if ( nbjp06.ne.0 ) then
c
        nbftet = nbfte0 + nbjp06
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,5)) mess14(langue,3,3), nbfte0
      write (ulsort,texte(langue,6)) mess14(langue,3,3), nbftet
#endif
c
        if ( codret.eq.0 ) then
c
        call gmnomc ( nhtetr//'.Famille', nhtefa, codret )
c
        endif
c
        if ( codret.eq.0 ) then
c
        nctfhe = ncffhe
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'UTFAM1_te', nompro
#endif
        iaux = 3
        call utfam1 ( iaux, nhtefa, pcfate,
     >                nctfte, nbfte0, nbftet,
     >                ulsort, langue, codret )
c
        endif
c
      endif
c
c 2.3. ==> Familles des pentaedres
c
      nbfpen = 1 + nbjois + nbjoit + nbjp09
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,6)) mess14(langue,3,7), nbfpen
#endif
c
      if ( codret.eq.0 ) then
c
      call gmnomc ( nhpent//'.Famille', nhpefa, codret )
c
      endif
c
      if ( codret.eq.0 ) then
c
      nctfpe = ncffpe
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTFAM1_pe', nompro
#endif
      iaux = 7
      call utfam1 ( iaux, nhpefa, pcfape,
     >              nctfpe, jaux, nbfpen,
     >              ulsort, langue, codret )
c
      endif
c
c 2.4. ==> Familles des hexaedres
c
      if ( nbjoiq.ne.0 ) then
c
        nbfhex = 1 + nbjoiq + nbjp12
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,6)) mess14(langue,3,7), nbfhex
#endif
c
        if ( codret.eq.0 ) then
c
        call gmnomc ( nhhexa//'.Famille', nhhefa, codret )
c
        endif
c
        if ( codret.eq.0 ) then
c
        nctfhe = ncffhe
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'UTFAM1_he', nompro
#endif
        iaux = 6
        call utfam1 ( iaux, nhhefa, pcfahe,
     >                nctfhe, jaux, nbfhex,
     >                ulsort, langue, codret )
c
        endif
c
      endif
c
c====
c 3. Memorisation des familles MED
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '5.2. ; codret = ', codret
#endif
cgn      call gmprsx(nompro,nhpefa//'.Codes')
cgn      call gmprsx(nompro,nhsupe)
cgn      call gmprsx(nompro,nhsupe//'.Tab5')
cgn      call gmprsx(nompro,nhsupe//'.Tab6')
cgn      call gmprsx(nompro,nhsupe//'.Tab9')
cgn      call gmprsx(nompro,nhsups)
cgn      call gmprsx(nompro,nhsups//'.Tab2')
cgn      call gmprsx(nompro,nhsups//'.Tab4')
c
c 3.1. ==> Nombre de familles MED
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '3.1. Nombre familles MED ; codret = ', codret
#endif
c
c     Ancien nombre
c
      if ( codret.eq.0 ) then
c
      call gmliat ( nhsupe, 9, nbfme0, codret )
c
      endif
c
c     Nombre de familles MED ajoute :
c     Pour un type de mailles, il y a 1 famille MED de moins que
c     de familles HOMARD
c
      nbfmaj = nbfpen - 1
      if ( nbfhex.gt.0 ) then
        nbfmaj = nbfmaj + nbfhex - 1
      endif
      nbfmaj = nbfmaj + nbjp06
c
      nbfmed = nbfme0 + nbfmaj
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,7)) 'avant', nbfme0
      write (ulsort,texte(langue,5)) mess14(langue,3,3), nbfte0
      write (ulsort,texte(langue,6)) mess14(langue,3,3), nbftet
      write (ulsort,texte(langue,6)) mess14(langue,3,6), nbfhex
      write (ulsort,texte(langue,6)) mess14(langue,3,7), nbfpen
      write (ulsort,texte(langue,7)) 'apres', nbfmed
#endif
c
c 3.1. ==> Gestions des groupes
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '3.1. Groupes ; codret = ', codret
#endif
c
      if ( codret.eq.0 ) then
c
      call gmliat ( nhsupe, 6, lgte60, codre1 )
      call gmliat ( nhsups, 2, lgts20, codre2 )
c
      codre0 = min ( codre1, codre2 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2 )
c
      endif
c
      if ( codret.eq.0 ) then
c
      call gmecat ( nhsupe, 5, nbfmed, codre1 )
      lgte6n = lgte60 + 10*2*nbfmaj
      call gmecat ( nhsupe, 6, lgte6n, codre2 )
      call gmecat ( nhsupe, 9, nbfmed, codre3 )
      lgts2n = lgts20 + 10*2*nbfmaj
      call gmecat ( nhsups, 2, lgts2n, codre4 )
      iaux = 10*nbfmed
      call gmecat ( nhsups, 4, iaux, codre5 )
c
      codre0 = min ( codre1, codre2, codre3, codre4, codre5 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2, codre3, codre4, codre5 )
c
      endif
c
      if ( codret.eq.0 ) then
c
      call gmmod ( nhsupe//'.Tab5', adtae5,
     >             1, 1, nbfme0+1, nbfmed+1, codre1 )
      call gmmod ( nhsupe//'.Tab6', adtae6,
     >             1, 1, lgte60, lgte6n, codre2 )
      call gmmod ( nhsupe//'.Tab9', adtae9,
     >             1, 1, nbfme0, nbfmed, codre3 )
      call gmmod ( nhsups//'.Tab2', adtas2,
     >             1, 1, lgts20, lgts2n, codre4 )
      call gmmod ( nhsups//'.Tab4', adtas4,
     >             1, 1, 10*nbfme0, 10*nbfmed, codre5 )
c
      codre0 = min ( codre1, codre2, codre3, codre4, codre5 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2, codre3, codre4, codre5 )
c
      endif
c
c====
c 4. Recherche du decalage dans les numeros de familles MED de mailles
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '4. decalage ; codret = ', codret
#endif
c
      if ( codret.eq.0 ) then
c
      decafa = 0
c
      do 40 , typenh = 0 , 4
c
        if ( codret.eq.0 ) then
c
        if ( typenh.eq.0 ) then
          nhenti = nhmapo
          nctfen = nctfmp
          nbfaen = nbfmpo
        elseif ( typenh.eq.1 ) then
          nhenti = nharet
          nctfen = nctfar
          nbfaen = nbfare
        elseif ( typenh.eq.2 ) then
          nhenti = nhtria
          nctfen = nctftr
          nbfaen = nbftri
        elseif ( typenh.eq.3 ) then
          nhenti = nhtetr
          nctfen = nctfte
          nbfaen = nbfte0
        elseif ( typenh.eq.4 ) then
          nhenti = nhquad
          nctfen = nctfqu
          nbfaen = nbfqua
        endif
c
        endif
c
        if ( nbfaen.gt.0 ) then
c
#ifdef _DEBUG_HOMARD_
          write (ulsort,*) ' '
          write (ulsort,*) mess14(langue,4,typenh)
          write (ulsort,*) 'nbfaen', nbfaen
          write (ulsort,*) 'nctfen', nctfen
#endif
c
          if ( codret.eq.0 ) then
c
          call gmadoj ( nhenti//'.Famille.Codes',
     >                  pcfaen, iaux, codret )
c
          endif
c
          if ( codret.eq.0 ) then
c
          do 401 , iaux = 1 , nbfaen
c
cgn          write (ulsort,*)imem(pcfaen+(iaux-1)*nctfen+cofamd-1)
            decafa = min(decafa,imem(pcfaen+(iaux-1)*nctfen+cofamd-1))
c
  401     continue
c
          endif
c
        endif
c
   40 continue
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) decafa
#endif
c
      endif
c
c====
c 5. Creation des tableaux
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '5. Creation des tableaux ; codret = ', codret
#endif
c
      if ( codret.eq.0 ) then
c
cgn      call gmprsx(nompro,nhpefa//'.Codes')
cgn      call gmprsx(nompro,nhsupe)
cgn      call gmprsx(nompro,nhsupe//'.Tab5')
cgn      call gmprsx(nompro,nhsupe//'.Tab6')
cgn      call gmprsx(nompro,nhsupe//'.Tab9')
cgn      call gmprsx(nompro,nhsups)
cgn      call gmprsx(nompro,nhsups//'.Tab2')
cgn      call gmprsx(nompro,nhsups//'.Tab4')
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'MMAGF1', nompro
#endif
      call mmagf1 ( decafa,
     >              imem(pcfaqu),
     >              imem(pcfate), nbfte0, imem(pcfape), imem(pcfahe),
     >              nbfme0, nbfmed,
     >              nbjois, nbjoit, nbjoiq,
     >              nbjp06, nbjp09, nbjp12,
     >              imem(adtae5), imem(adtae6), smem(adtas2),
     >              imem(adtae9), smem(adtas4),
     >              nbjoto,
     >              ulsort, langue, codret )
cgn      call gmprsx(nompro,nhtefa//'.Codes')
cgn      call gmprsx(nompro,nhpefa//'.Codes')
cgn      call gmprsx(nompro,nhsupe)
cgn      call gmprsx(nompro,nhsupe//'.Tab5')
cgn      call gmprsx(nompro,nhsupe//'.Tab6')
cgn      call gmprsx(nompro,nhsupe//'.Tab9')
cgn      call gmprsx(nompro,nhsups)
cgn      call gmprsx(nompro,nhsups//'.Tab2')
cgn      call gmprsx(nompro,nhsups//'.Tab4')
c
      endif
c
#ifdef _DEBUG_HOMARD_
c====
c 6. Impression eventuelle
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '6. Impression eventuelle ; codret = ', codret
#endif
c
c 6.1.==> Pointeurs
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD01', nompro
#endif
      iaux = 7
      call utad01 ( iaux, nhnoeu,
     >                jaux,
     >              pfamno, pcfano,   jaux,
     >                jaux,   jaux,   jaux,  jaux,
     >              ulsort, langue, codret )
c
      if ( nbmpto.ne.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD02_mp', nompro
#endif
        iaux = 259
        call utad02 ( iaux, nhmapo,
     >                  jaux,   jaux, jaux  , jaux,
     >                pfammp, pcfamp,   jaux,
     >                  jaux,   jaux,   jaux,
     >                  jaux,   jaux,   jaux,
     >                ulsort, langue, codret )
c
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD02_ar', nompro
#endif
      iaux = 259
      call utad02 ( iaux, nharet,
     >                jaux,   jaux,   jaux,   jaux,
     >              pfamar, pcfaar,   jaux,
     >                jaux,   jaux,   jaux,
     >                jaux,   jaux,   jaux,
     >              ulsort, langue, codret )
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD02_tr', nompro
#endif
      iaux = 259
      call utad02 ( iaux, nhtria,
     >                jaux,   jaux,   jaux,   jaux,
     >              pfamtr, pcfatr,   jaux,
     >                jaux,   jaux,   jaux,
     >                jaux,   jaux,   jaux,
     >              ulsort, langue, codret )
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD02_qu', nompro
#endif
      iaux = 259
      call utad02 ( iaux, nhquad,
     >                jaux,   jaux,   jaux,   jaux,
     >              pfamqu, pcfaqu,   jaux,
     >                jaux,   jaux,   jaux,
     >                jaux,   jaux,   jaux,
     >              ulsort, langue, codret )
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD02_te', nompro
#endif
      iaux = 259
      call utad02 ( iaux, nhtetr,
     >                jaux,   jaux,   jaux,   jaux,
     >              pfamte, pcfate,   jaux,
     >                jaux,   jaux,   jaux,
     >                jaux,   jaux,   jaux,
     >              ulsort, langue, codret )
c
      if ( nbheto.ne.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD02_he', nompro
#endif
        iaux = 259
        call utad02 ( iaux, nhhexa,
     >                  jaux,   jaux,   jaux,   jaux,
     >                pfamhe, pcfahe,   jaux,
     >                  jaux,   jaux,   jaux,
     >                  jaux,   jaux,   jaux,
     >                ulsort, langue, codret )
c
      endif
c
      if ( nbpyto.ne.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD02_py', nompro
#endif
        iaux = 259
        call utad02 ( iaux, nhpyra,
     >                  jaux,   jaux,   jaux,   jaux,
     >                pfampy, pcfapy,   jaux,
     >                  jaux,   jaux,   jaux,
     >                  jaux,   jaux,   jaux,
     >                ulsort, langue, codret )
c
      endif
c
      if ( nbpeto.ne.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD02_pe', nompro
#endif
        iaux = 259
        call utad02 ( iaux, nhpent,
     >                  jaux,   jaux,   jaux,   jaux,
     >                pfampe, pcfape,  jaux,
     >                  jaux,   jaux,  jaux,
     >                  jaux,   jaux,   jaux,
     >                ulsort, langue, codret )
c
      endif
c
      endif
c
c 6.2 ==> Impressions
c
      if ( codret.eq.0 ) then
c
      iaux = 0
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTECFE', nompro
#endif
      call utecfe ( iaux,
     >              imem(pfamno), imem(pcfano),
     >              imem(pfammp), imem(pcfamp),
     >              imem(pfamar), imem(pcfaar),
     >              imem(pfamtr), imem(pcfatr),
     >              imem(pfamqu), imem(pcfaqu),
     >              imem(pfamte), imem(pcfate),
     >              imem(pfamhe), imem(pcfahe),
     >              imem(pfampy), imem(pcfapy),
     >              imem(pfampe), imem(pcfape),
     >              ulsort, langue, codret )
c
      endif
c
#endif
c====
c 7. la fin
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
