//
//  CFDanmakuView.m
//  31- CFDanmakuDemo
//
//  Created by 于 传峰 on 15/7/9.
//  Copyright (c) 2015年 于 传峰. All rights reserved.
//

#import "CFDanmakuView.h"
#import "CFDanmakuInfo.h"
#define X(view) view.frame.origin.x
#define Y(view) view.frame.origin.y
#define Width(view) view.frame.size.width
#define Height(view) view.frame.size.height
#define Left(view) X(view)
#define Right(view) (X(view) + Width(view))
#define Top(view) Y(view)
#define Bottom(view) (Y(view) + Height(view))
#define CenterX(view) (Left(view) + Right(view))/2
#define CenterY(view) (Top(view) + Bottom(view))/2


@interface CFDanmakuView(){
    NSTimer* _timer;
}
@property(nonatomic, strong) NSMutableArray* danmakus;
@property(nonatomic, strong) NSMutableArray* currentDanmakus;
//@property(nonatomic, strong) NSMutableArray* foregroundInfos;
@property(nonatomic, strong) NSMutableDictionary* linesDict;

@property(nonatomic, assign) BOOL animationing;

@end

static NSTimeInterval const timeMargin = 0.5;
@implementation CFDanmakuView

- (NSMutableDictionary *)linesDict
{
    if (!_linesDict) {
        _linesDict = [[NSMutableDictionary alloc] init];
    }
    return _linesDict;
}

//- (NSMutableArray *)foregroundInfos
//{
//    if (!_foregroundInfos) {
//        _foregroundInfos = [[NSMutableArray alloc] init];
//    }
//    return _foregroundInfos;
//}


- (NSMutableArray *)currentDanmakus
{
    if (!_currentDanmakus) {
        _currentDanmakus = [NSMutableArray array];
    }
    return _currentDanmakus;
}

- (void)prepareDanmakus:(NSArray *)danmakus
{
    
    self.danmakus = [[danmakus sortedArrayUsingComparator:^NSComparisonResult(CFDanmaku* obj1, CFDanmaku* obj2) {
        if (obj1.timePoint > obj2.timePoint) {
            return NSOrderedDescending;
        }
        return NSOrderedAscending;
    }] mutableCopy];
    
}

- (void)getCurrentTime
{
    if([self.delegate danmakuViewIsBuffering:self]) return;
    
    [self.linesDict enumerateKeysAndObjectsUsingBlock:^(NSNumber* key, CFDanmakuInfo* obj, BOOL *stop) {
        CGRect labelFrame = obj.labelFrame;
        labelFrame.origin.x -= [self getSpeedFromLabel:obj.playLabel] * timeMargin;
        obj.labelFrame = labelFrame;
    }];
    
    [self.currentDanmakus removeAllObjects];
    NSTimeInterval timeInterval = [self.delegate danmakuViewGetPlayTime:self];
    
    [self.danmakus enumerateObjectsUsingBlock:^(CFDanmaku* obj, NSUInteger idx, BOOL *stop) {
        if (obj.timePoint >= timeInterval && obj.timePoint < timeInterval + timeMargin) {
            [self.currentDanmakus addObject:obj];
        }else if( obj.timePoint > timeInterval){
            *stop = YES;
        }
    }];
    
    if (self.currentDanmakus.count > 0) {
        for (CFDanmaku* danmaku in self.currentDanmakus) {
            [self playDanmaku:danmaku];
            NSLog(@"%zd----------", self.currentDanmakus.count);
        }
    }
}

- (void)playDanmaku:(CFDanmaku *)danmaku
{
    UILabel* playerLabel = [[UILabel alloc] init];
    playerLabel.attributedText = danmaku.contentStr;
    [playerLabel sizeToFit];
    [self addSubview:playerLabel];
//    [self.foregroundInfos addObject:playerLabel];
    playerLabel.backgroundColor = [UIColor yellowColor];
    
    playerLabel.frame = CGRectMake(Width(self), 0, Width(playerLabel), Height(playerLabel));
    
    if (self.linesDict.allKeys.count == 0) {
        [self addAnimationToView:playerLabel danmaku:danmaku withLineCount:0];
        return;
    }
    
    NSInteger valueCount = self.linesDict.allKeys.count;
    for (int i = 0; i<valueCount; i++) {
        CFDanmakuInfo* info = self.linesDict[@(i)];
        if (!info) break;
        if (![self judgeIsRunintoWithFirstDanmakuInfo:info behindLabel:playerLabel]) {
            [self addAnimationToView:playerLabel danmaku:danmaku withLineCount:i];
            break;
        }else if (i == valueCount - 1){
            if (valueCount < self.maxShowLineCount) {
                
                [self addAnimationToView:playerLabel danmaku:danmaku withLineCount:i+1];
            }else{
                [self.danmakus removeObject:danmaku];
                NSLog(@"同一时间评论太多--排不开了--------------------------");
            }
        }
    }
    
}

- (void)addAnimationToView:(UILabel *)label danmaku:(CFDanmaku *)danmaku withLineCount:(NSInteger)lineCount
{
    
    label.frame = CGRectMake(Width(self), (self.lineHeight + self.lineMargin) * lineCount, Width(label), Height(label));
    
    CFDanmakuInfo* info = [[CFDanmakuInfo alloc] init];
    info.playLabel = label;
    info.labelFrame = label.frame;
    self.linesDict[@(lineCount)] = info;
    
    [self performAnimationWithDuration:self.duration label:label];
}

- (void)performAnimationWithDuration:(NSTimeInterval)duration label:(UILabel *)label
{
    self.animationing = YES;
    
    CGRect endFrame = CGRectMake(-Width(label), Y(label), Width(label), Height(label));
    
    [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        label.frame = endFrame;
    } completion:^(BOOL finished) {
        if (finished) {
            [label removeFromSuperview];
        }
        //        [self.foregroundInfos removeObject:label];
    }];
}

// 检测碰撞 -- 默认从右到左
- (BOOL)judgeIsRunintoWithFirstDanmakuInfo:(CFDanmakuInfo *)info behindLabel:(UILabel *)last
{
    CGRect firstFrame = info.labelFrame;
    
    if(firstFrame.origin.x <= 50) return NO;
    
    if(Left(last) - (firstFrame.origin.x + firstFrame.size.width) > 10 && [self getSpeedFromLabel:last] <= [self getSpeedFromLabel:info.playLabel]) return NO;
    
    
    NSTimeInterval leftTime = firstFrame.origin.x + firstFrame.size.width / [self getSpeedFromLabel:info.playLabel];
    CGFloat lastEndLeft = Left(last) - [self getSpeedFromLabel:last] * leftTime;
    if (lastEndLeft >  10) return NO;
    
    return YES;
}

// 计算速度
- (CGFloat)getSpeedFromLabel:(UILabel *)label
{
    return (self.bounds.size.width + label.bounds.size.width) / self.duration;
}


#pragma mark -
- (BOOL)isPrepared
{
    return self.danmakus.count > 0;
}

- (BOOL)isPlaying
{
    return self.subviews.count > 0 && self.animationing;
}

- (void)start
{
//    self.finishiAnimation = YES;
    
    if ([self isPrepared]) {
        if (!_timer) {
            _timer = [NSTimer timerWithTimeInterval:timeMargin target:self selector:@selector(getCurrentTime) userInfo:nil repeats:YES];
            [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
        }
        [_timer fire];
    }
}
- (void)pause
{
    if(!_timer || !_timer.isValid) return;
    
    self.animationing = NO;
    
    [_timer invalidate];
    _timer = nil;
    
    for (UILabel* label in self.subviews) {
        
        CALayer *layer = label.layer;
        CGRect rect = label.frame;
        if (layer.presentationLayer) {
            rect = ((CALayer *)layer.presentationLayer).frame;
        }
        label.frame = rect;
        [label.layer removeAllAnimations];
    }
}
- (void)resume
{
    if(self.animationing || ![self isPrepared]) return;
    
    for (UILabel* label in self.subviews) {
        NSTimeInterval leftTime = Right(label) / [self getSpeedFromLabel:label];
        [self performAnimationWithDuration:leftTime label:label];
    }
    
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(timeMargin * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
         [self start];
    });
}
- (void)stop
{
    self.animationing = NO;
    
    [_timer invalidate];
    _timer = nil;
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.currentDanmakus removeAllObjects];
    [self.danmakus removeAllObjects];
    self.linesDict = nil;
}

- (void)sendDanmakuSource:(CFDanmaku *)danmaku
{
    [self playDanmaku:danmaku];
}


@end
