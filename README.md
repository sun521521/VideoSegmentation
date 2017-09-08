# 项目&论文：VideoSegmentation
  这是我们的视频分割项目的代码

Introduction
---
This paper presents a fully automatic technique for handling unconstrained video (e.g., rigid/non-rigid motion, fast/slow moving objects, motion blur, and cluttered background) in a superpixel-level coarse-to-fine segmentation framework. In the coarse segmentation stage, hyper-edge structure is used to build novel pairwise potentials that spatially and temporally enhance intra-consistency of foreground object, effectively helping improve the segmentation. In the refinement segmentation stage, a similarity prior enhancing intra-connectivity of object is integrated into the segmentation framework as a novel unary potential, and it more effectively indicates the likelihood of foreground than those of [1]. Moreover, this unary potential can help segment object in frames where it is static. The above two motivations are actually in terms of the gestalt principles “proximity” and “similarity”, respectively. Our method is thoroughly evaluated in experiments on the two popular datasets, and outperforms other state-of-the-art methods, especially for the fully automatic algorithms [1, 2] and the supervised [3].


[1] A. Papazoglou, and V. Ferrari, “Fast object segmentation in unconstrained video,” in IEEE International Conference on Computer Vision,    2013, pp. 1777-1784.

[2]	W. Wang, J. Shen, and F. Porikli, "Saliency-aware geodesic video object segmentation." pp. 3395-3402.

[3]	J. Chang, D. Wei, and J. W. F. Iii, “A video representation using temporal superpixels,” in IEEE Conference on Computer Vision and Pattern Recognition, 2013, pp. 2051-2058.


## 算法介绍
整体来说，我们提出了一个coarse-to-fine视频分割框架，它是建立在基于MRF的grabCut分割框架上的。关键地，这个算法需要构建有效的一元和二元势能。我们提出了增强目标连通性的一元势能，利用了随机游走模型，想法是：视频中的前景目标中的块在整个视频中都是连通的（除非遮挡或者消失）。另外，还构建了利用外观模型和位置模型交互信息的一元势能。  对于二元势能，我们利用超边，并量化了人眼视觉原则“proximity”,增强目标内的一致性。算法流程图如下：
![](https://github.com/sun521521/VideoSegmentation/blob/master/test/figure1.png)


