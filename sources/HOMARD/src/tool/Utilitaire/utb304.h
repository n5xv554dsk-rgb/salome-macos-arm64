c
c 2.3.1. ==> filtrage initial
c
            logaux(7) = .false.
c
            vn(1) = coonoe(lenoeu,1)
            if ( vn(1).ge.xmin .and. vn(1).le.xmax ) then
              vn(2) = coonoe(lenoeu,2)
              if ( vn(2).ge.ymin .and. vn(2).le.ymax ) then
                vn(3) = coonoe(lenoeu,3)
                if ( vn(3).ge.zmin .and. vn(3).le.zmax ) then
                  logaux(7) = .true.
                  do 231 , iaux = 1 , nbsomm
                    if ( lenoeu.eq.sommet(iaux) ) then
                      logaux(7) = .false.
                    endif
  231             continue
                endif
              endif
            endif
