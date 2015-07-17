//
//  CFDanmaku.h
//  31- CFDanmakuDemo
//
//  Created by 于 传峰 on 15/7/9.
//  Copyright (c) 2015年 于 传峰. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    CFDanmakuPositionTop = 0,
    CFDanmakuPositionBottom,
    CFDanmakuPositionFromLeft
} CFDanmakuPosition;

@interface CFDanmaku : NSObject

// 对应视频的时间戳
@property(nonatomic, assign) NSTimeInterval timePoint;
// 弹幕内容
@property(nonatomic, copy) NSAttributedString* contentStr;
@property(nonatomic, copy) NSString* userID;
// 弹幕类型(暂时不支持)
@property(nonatomic, assign) CFDanmakuPosition position;

@end
