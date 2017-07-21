# HZCarouselFigure

要求: Swift 3.0, Xcode 8.0

三种思路实现无限轮播

1. 前后添加图片;

2. 图片展示分为左,中,右三部分, 展示部分永远放到中间位置, 左右备用;

3. 创建一个足够多cell的UICollectionView, 分组重复展示(此方法适合UICollectionView(cell重用机制), UIScrollView + UIImageView的方式存在内存占用高的问题);
