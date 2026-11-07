c           .................         .................
c           .      . .      .         .               .
c           .     .   .     .         .               .
c           .    .     .    .         .               .
c           .   .       .   .  ===>   .               .
c           .  .         .  .         .               .
c           . .           . .         .               .
c           ..             ..         .               .
c           .................         .................
c
            qucnp1 = nqusca(quhnp1)
            prfcap(qucnp1) = 1
c
c quadrangle predecoupe en 3 triangles par l'arete A1
c
            if ( etan.eq.31 ) then
c
            do 2311 , nrofon = 1 , nbfonc
c
              vafott(nrofon,q1,qucnp1) = vatren(nrofon,q2t,prf3cn) 
              vafott(nrofon,q2,qucnp1) = vatren(nrofon,q3t,prf2cn)
              vafott(nrofon,q3,qucnp1) = 
     >                    unsde * ( vatren(nrofon,q1t,prf2cn)
     >                            + vatren(nrofon,q3t,prf1cn) )
              vafott(nrofon,q4,qucnp1) = 
     >                    unsde * ( vatren(nrofon,q1t,prf3cn)
     >                            + vatren(nrofon,q1t,prf1cn) )
              vafott(nrofon,q5,qucnp1) =
     >                    unstr * ( vatren(nrofon,q2t,prf1cn)
     >                            + vatren(nrofon,q2t,prf2cn)
     >                            + vatren(nrofon,q3t,prf3cn))
              vafott(nrofon,q6,qucnp1) = vatren(nrofon,q6t,prf2cn)
              vafott(nrofon,q7,qucnp1) = vatren(nrofon,q6t,prf1cn)
              vafott(nrofon,q8,qucnp1) = vatren(nrofon,q4t,prf3cn)
c
 2311       continue
c
c quadrangle predecoupe en 3 triangles par l'arete A2
c
            elseif ( etan.eq.32 ) then 
c
            do 2312 , nrofon = 1 , nbfonc
c
              vafott(nrofon,q1,qucnp1) =  
     >                    unsde * ( vatren(nrofon,q1t,prf3cn)
     >                            + vatren(nrofon,q1t,prf1cn) ) 
              vafott(nrofon,q2,qucnp1) = vatren(nrofon,q2t,prf3cn)              
              vafott(nrofon,q3,qucnp1) = vatren(nrofon,q3t,prf2cn)
              vafott(nrofon,q4,qucnp1) =  
     >                    unsde * ( vatren(nrofon,q1t,prf2cn)
     >                            + vatren(nrofon,q3t,prf1cn) ) 
              vafott(nrofon,q5,qucnp1) = vatren(nrofon,q4t,prf3cn)
              vafott(nrofon,q6,qucnp1) =
     >                    unstr * ( vatren(nrofon,q2t,prf1cn)
     >                            + vatren(nrofon,q2t,prf2cn)
     >                            + vatren(nrofon,q3t,prf3cn))               
              vafott(nrofon,q7,qucnp1) = vatren(nrofon,q6t,prf2cn)
              vafott(nrofon,q8,qucnp1) = vatren(nrofon,q6t,prf1cn)
c
 2312        continue
c
c quadrangle predecoupe en 3 triangles par l'arete A3
c
            elseif ( etan.eq.33 ) then 
c
            do 2313 , nrofon = 1 , nbfonc
            
              vafott(nrofon,q1,qucnp1) =  
     >                    unsde * ( vatren(nrofon,q1t,prf2cn)
     >                            + vatren(nrofon,q3t,prf1cn) ) 
              vafott(nrofon,q2,qucnp1) =   
     >                    unsde * ( vatren(nrofon,q1t,prf3cn)
     >                            + vatren(nrofon,q1t,prf1cn) )              
              vafott(nrofon,q3,qucnp1) = vatren(nrofon,q2t,prf3cn)
              vafott(nrofon,q4,qucnp1) = vatren(nrofon,q3t,prf2cn) 
              vafott(nrofon,q5,qucnp1) = vatren(nrofon,q6t,prf1cn)
              vafott(nrofon,q6,qucnp1) = vatren(nrofon,q4t,prf3cn)              
              vafott(nrofon,q7,qucnp1) = 
     >                    unstr * ( vatren(nrofon,q2t,prf1cn)
     >                            + vatren(nrofon,q2t,prf2cn)
     >                            + vatren(nrofon,q3t,prf3cn))
              vafott(nrofon,q8,qucnp1) = vatren(nrofon,q6t,prf2cn)
c
 2313       continue
c
c quadrangle predecoupe en 3 triangles par l'arete A4
c
            elseif ( etan.eq.34 ) then 
c
            do 2314 , nrofon = 1 , nbfonc
              vafott(nrofon,q1,qucnp1) = vatren(nrofon,q3t,prf2cn)  
              vafott(nrofon,q2,qucnp1) =   
     >                    unsde * ( vatren(nrofon,q1t,prf2cn)
     >                            + vatren(nrofon,q3t,prf1cn) )              
              vafott(nrofon,q3,qucnp1) =    
     >                    unsde * ( vatren(nrofon,q1t,prf3cn)
     >                            + vatren(nrofon,q1t,prf1cn) ) 
              vafott(nrofon,q4,qucnp1) = vatren(nrofon,q2t,prf3cn) 
              vafott(nrofon,q5,qucnp1) = vatren(nrofon,q6t,prf2cn)
              vafott(nrofon,q6,qucnp1) = vatren(nrofon,q6t,prf1cn)              
              vafott(nrofon,q7,qucnp1) = vatren(nrofon,q4t,prf3cn)
              vafott(nrofon,q8,qucnp1) =  
     >                    unstr * ( vatren(nrofon,q2t,prf1cn)
     >                            + vatren(nrofon,q2t,prf2cn)
     >                            + vatren(nrofon,q3t,prf3cn))
c
 2314       continue
c
            endif
