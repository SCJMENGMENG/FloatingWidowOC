//
//  FloatingView.m
//  FloatingWidow
//
//  Created by chengjie on 2018/4/24.
//  Copyright © 2018年 chengjie. All rights reserved.
//

#import "FloatingView.h"
#import <Masonry.h>

@interface FloatingView()
@property (nonatomic,strong) UILabel *versionLabel;
@property (nonatomic,strong) UILabel *fpsLabel;
@property (nonatomic,strong) CADisplayLink *fpsLink;
@property (nonatomic,assign) double fpsCount;
@property (nonatomic,assign) NSTimeInterval fpsLastTime;
@property (nonatomic,strong) NSArray *distanceArray;

@end

@implementation FloatingView

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:CGRectMake(0, 100, 100, 100)]) {
        
        [self commonInit];
        self.fpsCount = 0.0;
        self.fpsLastTime = 0.0;
        __weak typeof(self) weakSelf = self;
        self.fpsLink = [CADisplayLink displayLinkWithTarget:weakSelf selector:@selector(fpsLinkTick)];
        
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGesture:)];
        [self addGestureRecognizer:pan];
        [self showFPS];
    }
    return self;
}
-(void)panGesture:(UIPanGestureRecognizer *)panGesture{
    
    switch (panGesture.state) {
        case UIGestureRecognizerStateBegan:
        {
            self.distanceArray = @[@(self.center.x),@(self.center.y)];
            
        }
            break;
        case UIGestureRecognizerStateChanged:{
            CGPoint location = [panGesture translationInView:self.superview];
            self.center = CGPointMake(location.x + [self.distanceArray[0] floatValue], location.y + [self.distanceArray[1] floatValue]);
        }
            break;
        case UIGestureRecognizerStateEnded:{
            CGRect frame = self.frame;
            CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
            CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
            CGFloat frameWidth = frame.size.width;
            CGFloat frameHeight = frame.size.height;
            CGFloat frameX = frame.origin.x;
            CGFloat frameY = frame.origin.y;
            if (frameX <= (screenWidth - frameWidth) / 2.0 && frameY > frameHeight && frameY <screenHeight - 2 * frameHeight) {
                frame.origin.x = 0;
            }else if (frameX > (screenWidth - frameWidth) / 2.0 && frameY > frameHeight && frameY < screenHeight - 2 * frameHeight){
                frame.origin.x = screenWidth - frameWidth;
            }else if (frameY <= frameHeight){
                frame.origin.y = 0;
            }else if (frameY >= screenHeight - 2 * frameHeight){
                frame.origin.y = screenHeight - frameHeight;
            }
            
            [UIView animateWithDuration:0.3 animations:^{
                self.frame = frame;
            }];
        }
            break;
        default:
            break;
    }
}
-(void)commonInit{
    self.backgroundColor = [UIColor yellowColor];
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = 3.0;
    [self addSubview:self.versionLabel];
    [self addSubview:self.fpsLabel];
    [self.versionLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(self).insets(UIEdgeInsetsMake(15, 0, 0, 0));
    }];
    [self.fpsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(15);
        make.top.equalTo(self.versionLabel.mas_bottom).offset(15);
    }];
}
-(void)showFPS{
    [self.fpsLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}
-(void)fpsLinkTick{
    if (self.fpsLastTime == 0) {
        self.fpsLastTime = self.fpsLink.timestamp;
        return;
    }
    self.fpsCount += 1;
    double delta = self.fpsLink.timestamp - self.fpsLastTime;
    if (delta < 1.0) {
        return;
    }
    self.fpsLastTime = self.fpsLink.timestamp;
    double fps = self.fpsCount / delta;
    self.fpsCount = 0;
    
    _fpsLabel.attributedText = [self attributedOneString:@"FPS:" oneColor:[UIColor redColor] twoString:[NSString stringWithFormat:@"%.2f", fps] twoColor:[UIColor colorWithRed:40.0/255.0 green:129.0/255.0 blue:187.0/255.0 alpha:1.0]];
}
-(void)removeFromSuperview{
    [self.fpsLink removeFromRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    [super removeFromSuperview];
}

- (NSMutableAttributedString *)attributedOneString:(NSString *)oneString oneColor:(UIColor *)oneColor twoString:(NSString *)twoString twoColor:(UIColor *)twoColor {
    NSMutableAttributedString *oneAttString = [[NSMutableAttributedString alloc] initWithString:oneString attributes:@{NSForegroundColorAttributeName: oneColor}];
    NSMutableAttributedString *twoAttString = [[NSMutableAttributedString alloc] initWithString:twoString attributes:@{NSForegroundColorAttributeName: twoColor}];
    [oneAttString appendAttributedString:twoAttString];
    return oneAttString;
}

#pragma mark -- getter
-(UILabel *)versionLabel{
    if (!_versionLabel) {
        _versionLabel = [[UILabel alloc] init];
        _versionLabel.textAlignment = NSTextAlignmentCenter;
        _versionLabel.font = [UIFont systemFontOfSize:11];
        _versionLabel.userInteractionEnabled = NO;
        _versionLabel.attributedText = [self attributedOneString:@"版本号:" oneColor:[UIColor redColor] twoString:[NSString stringWithFormat:@"%@", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]] twoColor:[UIColor colorWithRed:40.0/255.0 green:129.0/255.0 blue:187.0/255.0 alpha:1.0]];
    }
    return _versionLabel;
}

-(UILabel *)fpsLabel{
    if (!_fpsLabel) {
        _fpsLabel = [[UILabel alloc] init];
        _fpsLabel.textAlignment = NSTextAlignmentLeft;
        _fpsLabel.font = [UIFont systemFontOfSize:11];
        _fpsLabel.userInteractionEnabled = NO;
    }
    return _fpsLabel;
}

@end
