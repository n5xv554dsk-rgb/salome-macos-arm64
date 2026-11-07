      subroutine gballo ( nom, typeob, long, adress,
     >                    nbcain, carint, codret )
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
c     allocation de l'objet terminal d'un nom etendu "nom"
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nom    .  s  . char*8 . nom de l'objet alloue                      .
c . typeob . e   .char(*) . type de l'objet a allouer                  .
c . long   . e   .   1    . 0 si on veut un objet structure            .
c .        .     .        . longueur si on veut un objet simple        .
c . adress .  s  . ent    . 0 si on veut un objet structure            .
c .        .     .        . adresse de l'objet simple alloue           .
c . nbcain . e   .   1    . nombre de premiers caracteres interdits    .
c . carint . e   . char*1 . liste de caracteres interdits              .
c . codret .  s  . ent    . code retour de l'operation                 .
c .        .     .        .  0 : OK                                    .
c .        .     .        . -1 : dimensionnement des tables insuffisant.
c .        .     .        . -2 : le type de l'objet-terminal est celui .
c .        .     .        .      d'un objet structure et long /= 0     .
c .        .     .        . -3 : "nom" a plus d'un element et "typeob" .
c .        .     .        .      ne correspond pas au type du champ    .
c .        .     .        .      terminal sauf si "typeob" = ' ' alors .
c .        .     .        .      c'est le type du champ-terminal       .
c .        .     .        .      qui serait considere                  .
c .        .     .        . -4 : "nom" a un seul element et "typeob"   .
c .        .     .        .      n'est pas connu                       .
c .        .     .        . -5 : l'objet-terminal est deja alloue      .
c .        .     .        . -6 : nom etendu invalide                   .
c .        .     .        . -7 : premier caractere interdit            .
c .        .     .        . -8 : le nom doit avoir un seul element     .
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
      parameter ( nompro = 'GBALLO' )
c
#include "gmmatc.h"
#include "genbla.h"
c
c 0.2. ==> communs
c
#include "gmtori.h"
#include "gmtoai.h"
#include "gmtors.h"
#include "gmtoas.h"
#include "gmimpr.h"
c
#include "envex1.h"
#include "gmlang.h"
#include "gmcoer.h"
c
c 0.3. ==> arguments
c
      character*(*) nom, typeob
      character*1 carint(*)
c
      integer long, adress, codret, nbcain
c
c 0.4. ==> variables locales
c
      character*8  objrep, objter, chater, nomloc
      character*8  typem, nomt
      character*60 mess
c
      integer iaux
      integer idec, ialo, iptr, ierr, ioal, itoc
      integer iob, ityp, ityc, nbc, k, ich, ioc
      integer nroobj, nrocha, nfois, ntry, kcha
c
      integer nbmess
      parameter ( nbmess = 10 )
      character*80 texte(nblang,nbmess)
c
c 0.5. ==> initialisations
c
#include "alphnu.h"
c
      data nfois / 0 /
c
      adress = 0
      codret = 0
c
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
c====
c 1.  decodage du nom etendu
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'GBDNOE', nompro
#endif
      call gbdnoe(nom,objrep,objter,chater,idec)
c
      if (idec.lt.0) then
c
c        nom etendu invalide
c
         codret = -6
c
      else if (idec.eq.3) then
c
c        objet-terminal alloue
c
         codret = -5
c
      else if (idec.eq.0) then
c
c        'nom' n'a qu'un seul element
c
c        verification du nom
c
         iaux = nbcain
         call gmntve ( objter, nomloc, iaux, carint, codret )
c
         if ( codret.ne.0 ) then
           codret = -7
           goto 9999
         endif
c
c        on alloue en structure. Si ca ne marche pas, on essaiera
c        en simple
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'GBALOJ', nompro
#endif
         call gbaloj(nomloc,typeob,ialo)
c
         if (ialo.eq.0) then
            codret = 0
            adress = 0
         else if (ialo.eq.-1) then
            codret = -1
            if (nfois.eq.0) then
              nfois = 1
              write(ulsort,*)
     >                   'dimensionnement des tables gm insuffisant'
              write(ulsort,*)
     >                   'augmenter nobjx ou nobcx'
              write(ulsort,*)
     >                 '(fichier a inclure gmmatc.h)'
              codret = 5
              goto 9999
            endif
         else if (ialo.eq.-2) then
            codret = -5
         else
c
c 2.        typeob peut etre simple : appel gmalo*
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'GBMINU', nompro
#endif
            call gbminu(typeob,typem)
            codret = 0
            if (typem.eq.nomtyb(1)) then
               call gmaloi(nomloc,iptr,long)
            else if (typem.eq.nomtyb(2)) then
               call gmalor(nomloc,iptr,long)
            else if (typem.eq.nomtyb(3)) then
               call gmalos(nomloc,iptr,long)
            else
               codret = -4
               goto 9999
            endif
            if ( coergm.ne.0 ) then
               codret = coergm
               goto 9999
            endif
            adress = iptr
         endif
c
      else
c
c        'nom' a plusieurs elements
c
c        rechercher le type du champ-terminal de l'objet-repertoire
c
         do 21 , iob = 1,iptobj-1
            if (nomobj(iob).eq.objrep) then
               nroobj = iob
               goto 20
            endif
   21    continue
c
         codret = -6
         goto 9999
c
   20    continue
c
         ityp = typobj(nroobj)
         nbc  = nbcham(ityp)
         do 22 k = 1, nbc
            ich = adrdst(ityp)+k-1
            if (nomcha(ich).eq.chater) then
               nrocha = ich
               kcha = k
               goto 40
            endif
   22    continue
c
         codret = -6
         goto 9999
c
c 3.     verification la concordance de 'typeob' avec le type du
c        champ-terminal
c
   40    continue
c
         ityc = typcha(nrocha)
c
         if (ityc.gt.0) then
            if (long.ne.0) then
               codret = -2
               goto 9999
            endif
            nomt  = nomtyp(ityc)
            typem = typeob
         else
            if (ityc.eq.-1) then
               nomt = nomtyb(1)
            else if (ityc.eq.-2) then
               nomt = nomtyb(2)
            else if (ityc.eq.-3) then
               nomt = nomtyb(3)
            endif
            call gbminu(typeob,typem)
         endif
c
         if ((typeob.ne.' ').and.(typem.ne.nomt)) then
            codret = -3
            goto 9999
         endif
c
c 4.     generation d'un nom si l'objet-terminal est indefini
c
         if (idec.eq.1) then
c
            ntry = 1
            iaux = 0
   41       continue
c
            call gbgeno(nom,' ',objter,ierr)
c
c        verification du nom
c        attention : on ne controle plus la premiere lettre
c                    car c'est la meme que celle de l'objet de tete
c
            call gmntve ( objter, nomloc, iaux, carint, codret )
c
            if ( codret.ne.0 ) then
              codret = -6
              goto 9999
            endif
c
            if (ierr.lt.0) then
               mess = ' gballo -> gbgeno -> ierr : '
               write(mess(29:30),'(i2)') ierr
               write(ulsort,*) mess
               write(ulsort,*) nom
               codret = 42
               goto 9999
            endif
c
            call gbobal(nomloc,itoc,ioal)
c
            if (ioal.gt.0) then
               if (ntry.lt.lgaln4) then
c
c le generateur de noms gbgeno ne sait pas generer plus de lgaln4
c noms differents ...
c
                 ntry = ntry + 1
                 goto 41
               else
                 mess = ' gballo -> nom '//nomloc//' deja utilise '
                 write(ulsort,*) mess
                 codret = 42
                 goto 9999
               endif
            endif
c
c 5.        attacher ce nom a sa place
c
            ioc = adrdso(nroobj)+kcha-1
            nomobc(ioc) = nomloc
c
         endif
c
c 6.     allocation  de l'objet attache
c
         if (ityc.gt.0) then
c
c           on alloue en structure. Si ca ne marche pas, on essaiera
c           en simple
c
            call gbaloj(nomloc,nomt,ialo)
c
            if (ialo.lt.0) then
               if (ialo.eq.-1) then
                 codret = -1
                 if (nfois.eq.0) then
                 nfois = 1
                   write(ulsort,*)
     >                   'dimensionnement des tables gm insuffisant'
                   write(ulsort,*)
     >                   'augmenter nobjx ou nobcx'
                   write(ulsort,*)
     >                   '(fichier a inclure gmmatc.h)'
                   codret = 61
                   goto 9999
                 endif
               else
                 mess = ' gballo -> gbaloj pour '//nomloc//' -> ialo : '
                 write(mess(43:44),'(i2)') ialo
                 write(ulsort,*) mess
                 codret = 62
                 goto 9999
               endif
            endif
c
         else
c
c           objet de type simple
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'gmalo.', nompro
      write (ulsort,*) 'ityc = ', ityc
#endif
            if (ityc.eq.-1) then
               call gmaloi(nomloc,iptr,long)
            else if (ityc.eq.-2) then
               call gmalor(nomloc,iptr,long)
            else if (ityc.eq.-3) then
               call gmalos(nomloc,iptr,long)
            endif
            if ( coergm.ne.0 ) then
              codret = coergm
              goto 9999
            endif
c
            adress = iptr
c
         endif
c
      endif
c
c====
c 4. Fin
c====
c
 9999 continue
c
      if ( codret.ne.0 ) then
c
#include "envex2.h"
c
      endif
c
      end
