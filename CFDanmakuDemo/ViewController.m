//
//  ViewController.m
//  CFDanmakuDemo
//
//  Created by 于 传峰 on 15/7/17.
//  Copyright (c) 2015年 于 传峰. All rights reserved.
//

#import "ViewController.h"
#import "CFDanmakuView.h"
#define kRandomColor [UIColor colorWithRed:arc4random_uniform(256) / 255.0 green:arc4random_uniform(256) / 255.0 blue:arc4random_uniform(256) / 255.0 alpha:1]
@interface ViewController () <CFDanmakuDelegate> {
    IBOutlet UIImageView *_imgView;
    IBOutlet UILabel *_curTime;
    IBOutlet UISlider *_slider;
    
    CFDanmakuView *_danmakuView;
    NSDate *_startDate;
    
    NSTimer *_timer;
}

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSMutableArray *newArr = [NSMutableArray arrayWithCapacity:6];
    for (int i=0; i<6; i++) {
        UIImage *img = [UIImage imageNamed:[NSString stringWithFormat:@"%d.jpg", i]];
        [newArr addObject:img];
    }
    _imgView.animationImages = newArr;
    _imgView.animationDuration = 20;
    [_imgView startAnimating];
    
    CGRect rect =  CGRectMake(0, 2, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds)-4);
    _danmakuView = [[CFDanmakuView alloc] initWithFrame:rect];
    _danmakuView.duration = 6.5;
    _danmakuView.lineHeight = 21;
    _danmakuView.maxShowLineCount = 15;
    
    _danmakuView.delegate = self;
    [self.view insertSubview:_danmakuView aboveSubview:_imgView];
    _danmakuView.backgroundColor = [UIColor clearColor];
    
    NSString *danmakufile = [[NSBundle mainBundle] pathForResource:@"danmakufile" ofType:nil];
    NSArray *danmakusDicts = [NSArray arrayWithContentsOfFile:danmakufile];
    
    NSMutableArray* danmakus = [NSMutableArray array];
    for (NSDictionary* dict in danmakusDicts) {
        CFDanmaku* danmaku = [[CFDanmaku alloc] init];
        danmaku.contentStr = [[NSMutableAttributedString alloc] initWithString:dict[@"m"] attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:15], NSForegroundColorAttributeName : kRandomColor}];
        
        NSString* attributesStr = dict[@"p"];
        danmaku.timePoint = [[[attributesStr componentsSeparatedByString:@","] firstObject] doubleValue] / 1000;
        //        NSLog(@"+++++++++++%f", danmaku.timePoint);
        [danmakus addObject:danmaku];
    }
    
    [_danmakuView prepareDanmakus:danmakus];
}

- (void)onTimeCount
{
    _slider.value+=0.1/120;
    if (_slider.value>120.0) {
        _slider.value=0;
    }
    [self onTimeChange:nil];
}

- (IBAction)onTimeChange:(id)sender
{
    _curTime.text = [NSString stringWithFormat:@"%.0fs", _slider.value*120.0];
}

- (IBAction)onStartClick:(id)sender
{
    if (_danmakuView.isPrepared) {
        if (!_timer) {
            _timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(onTimeCount) userInfo:nil repeats:YES];
        }
        [_danmakuView start];
    }
}

- (IBAction)onPauseClick:(id)sender
{
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
    [_danmakuView pause];
}

- (IBAction)resume:(id)sender {
    
    [_danmakuView resume];
    
    if (_danmakuView.isPrepared) {
        if (!_timer) {
            _timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(onTimeCount) userInfo:nil repeats:YES];
        }
    }
}


- (IBAction)onSendClick:(id)sender
{
    int time = ([self danmakuViewGetPlayTime:nil]+1);
    NSString *mString = @"😊😊olinone.com😊😊----------------";
    CFDanmaku* danmaku = [[CFDanmaku alloc] init];
    danmaku.contentStr = [[NSMutableAttributedString alloc] initWithString:mString attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:15], NSForegroundColorAttributeName : kRandomColor}];
    
    //    NSString* attributesStr = dict[@"p"];
    danmaku.timePoint = time;
    [_danmakuView sendDanmakuSource:danmaku];
}

#pragma mark -
- (NSTimeInterval)danmakuViewGetPlayTime:(CFDanmakuView *)danmakuView
{
    if(_slider.value == 1.0) [_danmakuView stop]
        ;
    return _slider.value*120.0;
}

- (BOOL)danmakuViewIsBuffering:(CFDanmakuView *)danmakuView
{
    return NO;
}

- (void)danmakuViewPerpareComplete:(CFDanmakuView *)danmakuView
{
    [_danmakuView start];
}

@end