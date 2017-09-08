# 项目&论文：VideoSegmentation
  这是我们的视频分割项目的代码，交流可加QQ：584062295

Introduction
---
This paper presents a fully automatic technique for handling unconstrained video (e.g., rigid/non-rigid motion, fast/slow moving objects, motion blur, and cluttered background) in a superpixel-level coarse-to-fine segmentation framework. In the coarse segmentation stage, hyper-edge structure is used to build novel pairwise potentials that spatially and temporally enhance intra-consistency of foreground object, effectively helping improve the segmentation. In the refinement segmentation stage, a similarity prior enhancing intra-connectivity of object is integrated into the segmentation framework as a novel unary potential, and it more effectively indicates the likelihood of foreground than those of [1]. Moreover, this unary potential can help segment object in frames where it is static. The above two motivations are actually in terms of the gestalt principles “proximity” and “similarity”, respectively. Our method is thoroughly evaluated in experiments on the two popular datasets, and outperforms other state-of-the-art methods, especially for the fully automatic algorithms [1, 2] and the supervised [3].


[1] A. Papazoglou, and V. Ferrari, “Fast object segmentation in unconstrained video,” in IEEE International Conference on Computer Vision,    2013, pp. 1777-1784.

[2]	W. Wang, J. Shen, and F. Porikli, "Saliency-aware geodesic video object segmentation." pp. 3395-3402.

[3]	J. Chang, D. Wei, and J. W. F. Iii, “A video representation using temporal superpixels,” in IEEE Conference on Computer Vision and Pattern Recognition, 2013, pp. 2051-2058.


## 算法介绍
整体来说，我们提出了一个coarse-to-fine视频分割框架，它是建立在基于MRF的GrabCut分割框架上的。关键地，这个算法需要构建有效的一元和二元势能。我们提出了增强目标连通性的一元势能，它利用了随机游走模型，想法是：视频中前景目标中的区域块在所有帧上都是连通的（除非遮挡或跑出图像）。另外，还构建了利用外观模型和位置模型交互信息的一元势能。  对于二元势能，我们利用超边结构，并量化了人眼视觉原则“proximity”, 增强了目标内的一致性。算法流程图如下：
![](https://github.com/sun521521/VideoSegmentation/blob/master/test/figure1.png)

### 分析
1. 创新之一就是设计了一个基于随机游走和交互信息的两个前景模型。前者增强了目标内部的连通性，后者利用了外观模型和位置模型的交互信息。我们还做了验证有效性的实验，结果表明我们的前景模型比先进算法[1]优良，算法[1]中的前景模型经常会出现噪声。实验如下图所示：
![](https://github.com/sun521521/VideoSegmentation/blob/master/test/figure9.png)

在此基础上，考虑到物体可能会在某些帧静止，那么基于运动特征建模的方法就会失效。避免失误，我们利用了光流的繁衍模型，即使静止，目标也会被检测到。例如，作为支撑的右腿，如果没有用繁衍模型，那么检测效果很差（middle），但是经过繁衍模型修正后，效果变优（right）.
![](https://github.com/sun521521/VideoSegmentation/blob/master/test/figure5.png)

2. 另外一个创新是利用超边结构，设计了一个增强目标在时空域内一致性的二元度量。并量化了人眼视觉原则“proximity”。效果如下：
  ![](https://github.com/sun521521/VideoSegmentation/blob/master/test/bottom-left.png)
  ![](https://github.com/sun521521/VideoSegmentation/blob/master/test/bottom-right.png)
我们的度量在不会提升异类超像素块一致性的前提下（绿色），可以显著提升同类的超像素块的一致性（红色）

3.一般来说，具有相似运动方向的区域，我们会认为他们是来自同一个物体，这符合人眼的认知机制，求出每个像素点的运动速度方向（颜色相近，表明物体运动方向近似）：
![](https://github.com/sun521521/VideoSegmentation/blob/master/test/figure41.png)
可以看出，运动的滑翔伞具有相似的速度。我们设计了一个针对运动方向的一致性度量，实验表明它可以很好地区分来自同类和异类的超像素块：
![](https://github.com/sun521521/VideoSegmentation/blob/master/test/figure42.png)

### 总结
我们在两个流行的数据集davis 和segTrack v2上做了大量实验，分割准确度已经超过了很多优秀算法：
![](https://github.com/sun521521/VideoSegmentation/blob/master/test/figure7.png)
![](https://github.com/sun521521/VideoSegmentation/blob/master/test/figure6.png)

