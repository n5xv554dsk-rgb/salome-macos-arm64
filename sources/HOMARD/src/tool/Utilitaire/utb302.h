                nbpbco(typenh) = nbpbco(typenh) + 1
c
                write (ulbila,10100)
                write (ulbila,11101) mess54(langue,2)(1:37),
     >                               mess14(langue,3,typenh)
                write (ulbila,12101) mess14(langue,2,-1)
                if ( sdim.eq.1 ) then
                  write (ulbila,14201) lenoeu, vn(1)
                elseif ( sdim.eq.2 ) then
                  write (ulbila,14202) lenoeu, vn(1), vn(2)
                else
                  write (ulbila,14203) lenoeu, vn(1), vn(2), vn(3)
                endif
                write (ulbila,12102) mess08(langue,1),
     >                               mess08(langue,2),
     >                               mess14(langue,1,typenh), iaux,
     >                               mess08(langue,3),
     >                               mess08(langue,4)
c
