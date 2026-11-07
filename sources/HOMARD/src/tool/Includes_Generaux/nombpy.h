c
c=======================================================================
c nombres propres aux pyramides
c-----------------------------------------------------------------------
c nbpyac : nombre de pyramides actives
c nbpyde : nombre de pyramides issues du decoupage de pyramides
c Pour un raffinement selon des boites :
c  nbpyh1 : issues d'un decoupage d'un hexaedre a partir d'une face
c  nbpyh2 : issues d'un decoupage d'un hexaedre a partir de 3 aretes
c  nbpyh3 : issues d'un decoupage d'un hexaedre a partir de 2 aretes
c  nbpyh4 : issues d'un decoupage d'un hexaedre a partir d'1 arete
c  nbpyp0 : issues d'un decoupage d'un pentaedre a partir d'1 ar tr
c  nbpyp1 : issues d'un decoupage d'un pentaedre a partir d'1 ar qu
c  nbpyp2 : issues d'un decoupage d'un pentaedre a partir de 2 ar tr/qu
c  nbpyp3 : issues d'un decoupage d'un pentaedre a partir de 2 ar qu/qu
c  nbpyp4 : issues d'un decoupage d'un pentaedre a partir d'1 face qu
c  nbpyp5 : issues d'un decoupage d'un pentaedre a partir d'1 face tr
c Sinon :
c  nbpydh : issues d'un decoupage d'un hexaedre
c  nbpydp : issues d'un decoupage d'un pentaedre
c nbpyma : nombre de pyramides du macro-maillage.
c nbpype : nombre de pyramides permanents du maillage (nbpyma+nbpyde).
c nbpyto : nombre total de pyramides du maillage (nbpycf+nbpyca)
c nbpycf : nombre de pyramides en connectivite par faces
c nbpyca : nombre de pyras en connectivite par aretes (nbpydh+nbpydp)
c-----------------------------------------------------------------------
      integer         nbpyac, nbpyde,
     >                nbpyh1, nbpyh2, nbpyh3, nbpyh4,
     >                nbpyp0, nbpyp1, nbpyp2, nbpyp3, nbpyp4, nbpyp5,
     >                nbpydh, nbpydp,
     >                nbpyma, nbpype, nbpyto, nbpycf, nbpyca
      common /nombpy/ nbpyac, nbpyde,
     >                nbpyh1, nbpyh2, nbpyh3, nbpyh4,
     >                nbpyp0, nbpyp1, nbpyp2, nbpyp3, nbpyp4, nbpyp5,
     >                nbpydh, nbpydp,
     >                nbpyma, nbpype, nbpyto, nbpycf, nbpyca
