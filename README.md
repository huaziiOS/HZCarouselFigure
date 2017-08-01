# HZCarouselFigure

要求: Swift 3.0, Xcode 8.0

三种思路实现无限轮播

![效果图](http://upload-images.jianshu.io/upload_images/1674402-64eae4a5117d1b53.gif?imageMogr2/auto-orient/strip)

##实现思路:
###第一种: 在原图片集合的基础上, 分别在原数据的开始及结尾处插入一张图片, 内容分别是原图片集合的最后一张和第一张, 新图片集合.count = 原图片集合.count + 2; 当滑动到第一张或者最后一张图片时, "偷偷地"将当前偏移位置切换到对应图片的位置(展示第一张图片或者最后一张图片的ImageView所在位置), 详见下图:
![无限轮播方式一.png](http://upload-images.jianshu.io/upload_images/1674402-ee05a8a24af7f303.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

###第二种: 只需要左, 中, 右三个UIImageView, 默认只展示中间位置的UIImageView, 然后动态调整UIImageView上应该放置的image; 例如: 刚开始时, 左中右分别放置的是图片数组中最后一张,第0张,第1张图片, 此时用户看到是第0张图片, 当用户向右滑动时, 此时展示应该是第1张图片,当滑动结束时, "偷偷地"将scrollView的偏移量调整为中间UIImageView位置, 同时调整对应imageView上展示的图片, 此时左中右分别对应的应该是 第0, 1, 2张图片; 详见下图:

![无限轮播方式二.png](http://upload-images.jianshu.io/upload_images/1674402-0c28b09d5d936b3a.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

###第三种: 最简单, 最不费脑的实现方式了, 简单粗暴的将图片数组成倍的扩充, 没明白是吗? 举个简单例子: 新图片集合.count = 原图片集合.count * 150(一张图片的情况除外); 然后开始时默认展示的是偏移量为(新图片集合.count / 2) * 图片宽度的位置(也是原图片集合的第一张图片), 由于这种方法可能需要占用较多的内存, 所以建议使用UICOllectionView, 基于其cell的重用机制, 可以降低内存占用.
