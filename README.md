# 项目&论文：VideoSegmentation
  这是我们的视频分割项目的代码

Introduction
---
This paper presents a fully automatic technique for handling unconstrained video (e.g., rigid/non-rigid motion, fast/slow moving objects, motion blur, and cluttered background) in a superpixel-level coarse-to-fine segmentation framework. In the coarse segmentation stage, hyper-edge structure is used to build novel pairwise potentials that spatially and temporally enhance intra-consistency of foreground object, effectively helping improve the segmentation. In the refinement segmentation stage, a similarity prior enhancing intra-connectivity of object is integrated into the segmentation framework as a novel unary potential, and it more effectively indicates the likelihood of foreground than those of [1]. Moreover, this unary potential can help segment object in frames where it is static. The above two motivations are actually in terms of the gestalt principles “proximity” and “similarity”, respectively. Our method is thoroughly evaluated in experiments on the two popular datasets, and outperforms other state-of-the-art methods, especially for the fully automatic algorithms [1, 2] and the supervised [3].


[1] A. Papazoglou, and V. Ferrari, “Fast object segmentation in unconstrained video,” in IEEE International Conference on Computer Vision,    2013, pp. 1777-1784.

[2]	W. Wang, J. Shen, and F. Porikli, "Saliency-aware geodesic video object segmentation." pp. 3395-3402.

[3]	J. Chang, D. Wei, and J. W. F. Iii, “A video representation using temporal superpixels,” in IEEE Conference on Computer Vision and Pattern Recognition, 2013, pp. 2051-2058.
