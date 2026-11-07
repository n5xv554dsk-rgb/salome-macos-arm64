c
c 2.3.1. ==> filtrage initial
c
            logaux(7) = .false.
c
            vn(1) = coonoe(lenoeu,1)
            if ( vn(1).gt.xmin .and. vn(1).lt.xmax ) then
              vn(2) = coonoe(lenoeu,2)
              if ( vn(2).gt.ymin .and. vn(2).lt.ymax ) then
                vn(3) = coonoe(lenoeu,3)
                if ( vn(3).gt.zmin .and. vn(3).lt.zmax ) then
                  logaux(7) = .true.
                  do 232 , iaux = 1 , nbsomm
                    if ( lenoeu.eq.sommet(iaux) ) then
                      logaux(7) = .false.
                    endif
  232             continue
                endif
              endif
            endif
