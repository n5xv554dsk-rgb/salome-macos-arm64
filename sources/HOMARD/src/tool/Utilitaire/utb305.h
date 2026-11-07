c
c 2.3.2. ==> le noeud est-il coincident avec un des sommets ?
c
            if ( logaux(7) ) then
c
              if ( nbpbco(-1).gt.0 ) then
c
                nucoin = numcoi(lenoeu)
c
                if ( nucoin.ne.0 ) then
c
                  ptcode = coinpt(nucoin)+1
                  ptcofi = coinpt(nucoin+1)
                  do 232 , ptcoin = ptcode, ptcofi
                    jaux = coinnn(ptcoin)
                    do 2321 , iaux = 1 , nbsomm
                      if ( jaux.eq.sommet(iaux) ) then
                        goto 23
                      endif
 2321               continue
  232             continue
c
                endif
c
              endif
c
            endif
