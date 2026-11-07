c
c=======================================================================
c nombres d'entites du maillage adapte
c-----------------------------------------------------------------------
c nouvno : nombre de noeuds du maillage adapte
c permno : nombre de noeuds permanents du maillage adapte (nouvno en p1)
c permp1 : nombre de noeuds p1 permanents du maillage adapte
c provp1 : nombre de noeuds p1 provisoires du maillage adapte
c nouvp2 : nombre de noeuds p2 (milieux) du maillage adapte
c permp2 : nombre de noeuds p2 (milieux) permanents du maillage adapte
c provp2 : nombre de noeuds p2 (milieux) provisoires du maillage adapte
c nouvim : nombre de noeuds internes aux mailles du maillage adapte
c permim : nombre de noeuds internes permanents du maillage adapte
c provim : nombre de noeuds internes provisoires du maillage adapte
c nouvar : nombre d'aretes du maillage adapte
c permar : nombre d'aretes permanentes du maillage adapte
c provar : nombre d'aretes provisoires du maillage adapte
c nouvtr : nombre de triangles du maillage adapte
c permtr : nombre de triangles permanents du maillage adapte
c provtr : nombre de triangles provisoires du maillage adapte
c nouvqu : nombre de quadrangles du maillage adapte
c permqu : nombre de quadrangles permanents du maillage adapte
c provqu : nombre de quadangles provisoires du maillage adapte
c nouvte : nombre de tetraedres du maillage adapte
c nouvtf : nombre de tetraedres du maillage adapte decrits par face
c nouvta : nombre de tetraedres du maillage adapte decrits par arete
c permte : nombre de tetraedres permanents du maillage adapte
c provte : nombre de tetraedres provisoires du maillage adapte
c provtf : nombre de tetraedres provisoires decrits par face
c provta : nombre de tetraedres provisoires decrits par arete
c nouvhe : nombre d'hexaedres du maillage adapte
c permhe : nombre d'hexaedres permanents du maillage adapte
c nouvhf : nombre d'hexaedres du maillage adapte decrits par face
c nouvha : nombre d'hexaedres du maillage adapte decrits par arete
c provhe : nombre d'hexaedres provisoires du maillage adapte
c provhf : nombre d'hexaedres provisoires decrits par face
c provha : nombre d'hexaedres provisoires decrits par arete
c nouvpy : nombre de pyramides du maillage adapte
c permpy : nombre de pyramides permanentes du maillage adapte
c nouvyf : nombre de pyramides du maillage adapte decrits par face
c nouvya : nombre de pyramides du maillage adapte decrits par arete
c provpy : nombre de pyramides provisoires du maillage adapte
c provyf : nombre de pyramides provisoires decrits par face
c provya : nombre de pyramides provisoires decrits par arete
c nouvpe : nombre de pentaedres du maillage adapte
c nouvpf : nombre de pentaedres du maillage adapte decrits par face
c nouvpa : nombre de pentaedres du maillage adapte decrits par arete
c permpe : nombre de pentaedres permanents du maillage adapte
c provpe : nombre de pentaedres provisoires du maillage adapte
c provpf : nombre de pentaedres provisoires decrits par face
c provpa : nombre de pentaedres provisoires decrits par arete
c-----------------------------------------------------------------------
      integer         nouvno, permno, permp1, provp1,
     >                nouvp2, permp2, provp2,
     >                nouvim, permim, provim,
     >                nouvar, permar, provar,
     >                nouvtr, permtr, provtr,
     >                nouvqu, permqu, provqu,
     >                nouvte, permte, nouvtf, nouvta,
     >                provte, provtf, provta,
     >                nouvhe, permhe, nouvhf, nouvha,
     >                provhe, provhf, provha,
     >                nouvpy, permpy, nouvyf, nouvya,
     >                provpy, provyf, provya,
     >                nouvpe, permpe, nouvpf, nouvpa,
     >                provpe, provpf, provpa
      common /nouvnb/ nouvno, permno, permp1, provp1,
     >                nouvp2, permp2, provp2,
     >                nouvim, permim, provim,
     >                nouvar, permar, provar,
     >                nouvtr, permtr, provtr,
     >                nouvqu, permqu, provqu,
     >                nouvte, permte, nouvtf, nouvta,
     >                provte, provtf, provta,
     >                nouvhe, permhe, nouvhf, nouvha,
     >                provhe, provhf, provha,
     >                nouvpy, permpy, nouvyf, nouvya,
     >                provpy, provyf, provya,
     >                nouvpe, permpe, nouvpf, nouvpa,
     >                provpe, provpf, provpa
