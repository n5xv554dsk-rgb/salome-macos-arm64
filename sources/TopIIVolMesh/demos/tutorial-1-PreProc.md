

In this tutorial  let us use `topIIvol_PreProc` to coarsen a point cloud cluster `./xyz/point-cloud-fine.xyz` which contains $(x\times y)=500 \times 451= 225500$ points.  To coarsen, we use skipping 10 rows of points in x direction and  skipping 10 rows of points y direction. We should roughly achieve $500/10 = 50$ points in $x$ and $451/10 \approx 46$ points in $y$, such that a total number of points now reduce to $50\times46 = 2300$. 

| ![space-1.jpg](./../etc/images/fine-point-cloud.png) |
| :--------------------------------------------------: |
|       **Point cloud with 225500 data points**        |

To run this tutorial, run the following on terminal: 

```bash
topIIvol_PreProc --xpoints 500 --ypoints 451 --xskip 10 --yskip 10 \
--in ./xyz/point-cloud-fine.xyz --out out-coarse.xyz 
```

After successfully running `topIIvol_PreProc` there will be a  coarsened point cloud `out-coarse.xyz` and an info file `<out-coarse.xyz>.info` that give the number of x an y points in the coarsened mesh cloud.  

| ![coarse-point-cloud](./../etc/images//coarse-point-cloud.png) |
| :----------------------------------------------------------: |
|        **Coarse  point cloud with 2300 data points**         |

*To report bugs, issues, feature-requests contact:* 

- **mohd-afeef.badri@cea.fr**
- **mohd-afeef.badri@hotmail.com**
