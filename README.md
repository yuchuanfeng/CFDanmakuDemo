# CFDanmakuDemo
简单的弹幕实现
===================================
现在实现了从右往左滚动的弹幕效果, 并且添加了中间的弹幕

弹幕内容为AttributeString 支持表情图片等等

具体里面的实现思路来自: 大家可以参考下
[点击这里查看](http://www.olinone.com/?p=186)<br />

效果如下:

![image](https://raw.githubusercontent.com/yuchuanfeng/CFDanmakuDemo/master/CFDanmakuDemoTests/001.gif)


使用方法:
-----------------------------------
### 创建CFDanmakuView对象, 进行配置, 并添加到View上 

    _danmakuView = [[CFDanmakuView alloc] initWithFrame:rect];
    _danmakuView.duration = 6.5;
    _danmakuView.centerDuration = 2.5;
    _danmakuView.lineHeight = 25;
    _danmakuView.maxShowLineCount = 15;
    _danmakuView.maxCenterLineCount = 5;
    
    _danmakuView.delegate = self;
    [self.view addSubview:_danmakuView];
    
### 配置弹幕的数据
    CFDanmaku* danmaku = [[CFDanmaku alloc] init];
    [danmakus addObject:danmaku];
    [_danmakuView prepareDanmakus:danmakus];
    // 对应视频的时间戳
    @property(nonatomic, assign) NSTimeInterval timePoint;
    // 弹幕内容
    @property(nonatomic, copy) NSAttributedString* contentStr;
    // 弹幕类型(如果不设置 默认情况下只是从右到左滚动)
    @property(nonatomic, assign) CFDanmakuPosition position;

### 遵守协议, 并实现代理方法
    // 获取视频播放时间
    - (NSTimeInterval)danmakuViewGetPlayTime:(CFDanmakuView *)danmakuView
    {
      if(_slider.value == 1.0) [_danmakuView stop]
        ;
      return _slider.value*120.0;
    }
    // 是否正在加载视频中
    - (BOOL)danmakuViewIsBuffering:(CFDanmakuView *)danmakuView
    {
      return NO;
    }

具体用法, 请参考Demo
