# HZCarouselFigure

三种思路实现无限轮播

1. 前后添加图片: 

2. 图片展示分为左,中,右三部分, 展示部分永远放到中间位置, 左右备用;

3. 创建一个足够多的展示imageView, 重复展示(此方法适合UICollectionView, UIScrollView + UIImageView的方式内存占用过高);
