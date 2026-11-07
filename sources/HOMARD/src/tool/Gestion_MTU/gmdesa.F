      subroutine gmdesa ( nomtab )
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
c ......................................................................
c . derniere modif octo 93 gn double precision
c .          modif juin 93 jyb prise en compte du type character*8
c .          modif 15/06/89 jc jyb
c ......................................................................
c .
c .  - interet:
c .     permet de liberer la place occupee par un tableau reel, entier
c .     ou caractere*8 en indiquant simplement
c .     le nom sous lequel il a ete cree.
c .     'attention' : ceci suppose que le nom apparaisse une fois
c .     et une seule
c .
c .  - arguments:
c .       nomtab --> chaine de 8 car. maxi contenant le nom du tableau
c .                      (reel ou entier) a liberer
c ......................................................................
c .
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
      parameter ( nompro = 'GMDESA' )
c
#include "genbla.h"
#include "gmmaxt.h"
c
c 0.2. ==> communs
c
#include "gmtrrl.h"
#include "gmtren.h"
#include "gmtrst.h"
#include "gmalrl.h"
#include "gmalen.h"
#include "gmalst.h"
#include "gmimpr.h"
#include "gmcoer.h"
#include "envex1.h"
#include "gmlang.h"
c
c 0.3. ==> arguments
c
      character *(*) nomtab
c
c 0.4. ==> variables locales
c
      character*1 carint(1)
      character*8   nomvar
c
      integer ilong
      integer iaux
c
      integer icptr, numr, icpti, numi, icpts, nums
      integer nbcain
c
      logical detlg0
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
c 2. recherche des caracteristiques associe au tableau demande
c====
c
c 2.1. ==> nature du nom
c          aucun caractere n'est interdit, mais on met un blanc
c          dans le tableau pour ne plus avoir de messages ftnchek
c
      nbcain = 0
      carint(1) = ' '
      call gmntve ( nomtab, nomvar, nbcain, carint, coergm )
c
      if ( coergm.ne.0 ) then
         write(ulsort,20000) nomtab
20000    format( 2x,' mauvais appel au spg gmdesa',
     >          /,4x,'   ===>  arret dans le gestionnaire de memoire')
        goto 9999
      endif
c
      ilong = 0
c
c 2.1. ==> controle de nom donne en double dans une categorie
c
      icptr = 0
      do 21  iaux = 1, nballr
        if ( nomvar.eq.nomalr(iaux) ) then
           icptr = icptr + 1
           numr = iaux
        endif
   21 continue
      if ( icptr.gt.1) then
        coergm = 1
        write(ulsort,21000) nomvar
21000   format(//2x,' =====  spg  gmdesa ======',/2x,' le tableau ',
     >  a8,' apparait plusieurs fois dans les reels')
      endif
c
      icpti = 0
      do 23  iaux = 1, nballi
        if ( nomvar.eq.nomali(iaux) ) then
           icpti = icpti + 1
           numi = iaux
        endif
   23 continue
      if ( icpti.gt.1) then
        coergm = 1
        write(ulsort,23000) nomvar
23000   format(//2x,' =====  spg  gmdesa ======',/2x,'le tableau ',
     >  a8,' apparait plusieurs fois dans les entiers')
      endif
c
      icpts = 0
      do 24  iaux = 1, nballs
        if ( nomvar.eq.nomals(iaux) ) then
           icpts = icpts + 1
           nums = iaux
        endif
 24   continue
      if ( icpts.gt.1) then
        coergm = 1
        write(ulsort,24000) nomvar
24000   format(//2x,' =====  spg  gmdesa ======',/2x,'le tableau ',
     >  a8,' apparait plusieurs fois dans les character*8')
      endif
c
      if ( coergm.eq.0 ) then
        iaux = icptr + icpti + icpts
        if ( iaux.eq.0 ) then
          write(ulsort,26001) nomvar
26001     format(//2x,' =====  spg  gmdesa  ======',/2x,'le tableau ',
     >  a8,' est inconnu')
          coergm = 1
        endif
        if ( iaux.gt.1 ) then
          write(ulsort,26002) nomvar
26002     format(//2x,' =====  spg  gmdesa  ======',/2x,'le tableau ',
     >  a8,' apparait dans plusieurs types simples.')
          coergm = 1
        endif
      endif
c
c  verification globale du code retour
c
      if ( coergm. ne .0)  then
           write(ulsort,20001) nomvar , coergm
20001      format(/2x,' =======  spg gmdesa  =======',/2x,
     >     'la recherche du tableau ', a8,' s''est mal passee ',i2)
        goto 9999
      endif
c
c====
c 3.la demande etant valide, on desalloue le tableau en fonction du type
c   on precise que l'on supprime la memoire
c====
c
c 3.1. ==> on precise que l'on supprime la memoire
c
      detlg0 = .true.
c
c 3.2. ==> c'est parti
c
c reel
c
      if ( icptr . ne . 0 ) then
c
        ilong = lgallr(numr)
        call gmdesr ( nomtab , ilong, detlg0 )
c
      endif
c
c entier
c
      if ( icpti . ne . 0 ) then
c
        ilong = lgalli(numi)
        call gmdesi ( nomtab , ilong, detlg0 )
c
      endif
c
c character*8
c
      if ( icpts . ne . 0 ) then
c
        ilong = lgalls(nums)
        call gmdess ( nomtab , ilong, detlg0 )
c
      endif
c
c====
c 3. Fin
c====
c
 9999 continue
c
      if ( coergm.ne.0 ) then
c
#include "envex2.h"
c
      endif
c
      end
