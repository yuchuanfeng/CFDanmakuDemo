//
//  CFDanmakuInfo.h
//  HJDanmakuDemo
//
//  Created by 于 传峰 on 15/7/10.
//  Copyright (c) 2015年 olinone. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CFDanmakuInfo : NSObject

// 弹幕内容label
@property(nonatomic, weak) UILabel  *playLabel;
// 弹幕label frame
@property(nonatomic, assign) CGRect labelFrame;
// 
@property(nonatomic, assign) NSTimeInterval currentTime;

@end
