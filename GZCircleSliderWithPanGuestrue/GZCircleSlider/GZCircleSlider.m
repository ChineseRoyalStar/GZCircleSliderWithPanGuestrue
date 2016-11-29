//
//  GZCircleSlider.m
//  GZCircleSliderWithPanGuestrue
//
//  Created by armada on 2016/11/29.
//  Copyright © 2016年 com.zlot.gz. All rights reserved.
//

#import "GZCircleSlider.h"

#define kDefaultFontColor [UIColor colorWithWhite:0.5 alpha:0.3]
#define kHighlightedFontColor [UIColor cyanColor]

#define ToRad(deg) ((M_PI*(deg))/180.00)
#define ToDeg(rad) ((180*rad)/M_PI)
#define SQR(x) ((x)*(x))

#define kImgWidth 270.0f
#define kImgHeight 270.0f

#define kPadding 40.0f

#define kFontSize 20

@interface GZCircleSlider()

{
    int previousIndex;
}

@property(nonatomic,assign) int currentIndex;

@property(nonatomic,strong) CAShapeLayer *shapeLayer;

@property(nonatomic,strong) UIImageView *handleImgView;

@property(readonly,assign)  float radius;

@property(readonly,assign)  CGPoint centerInSelf;

@property(nonatomic,strong) NSMutableArray<CAShapeLayer *> *dialsLayers;

@property(nonatomic,strong) NSMutableArray<CATextLayer *> *textLayers;

@property(nonatomic,strong) CATextLayer *remarkTextLayer;

@property(nonatomic,strong) NSTimer *timer;

@end

@implementation GZCircleSlider

- (instancetype)initWithFrame:(CGRect)frame lineWidth:(float)lineWidth currentIndex:(int)currentIndex {
    
    if(self = [super initWithFrame:frame]) {
        _lineWidth = lineWidth;
        
        [self drawCircle];
        [self addDialLayer];
        [self addTextLayers];
        
        _currentIndex = currentIndex;
        
        previousIndex = -1;
        _timer = [NSTimer scheduledTimerWithTimeInterval:2.0/12 target:self selector:@selector(animationInAdvance) userInfo:nil repeats:YES];
        [self performSelector:@selector(setup) withObject:nil afterDelay:2.0];
    }
    
    return self;
}

- (void)setup {
    
    [self addCircleHandle];
    [self addRemarkTextLayerAt:self.currentIndex];
    [self moveHandleAtIndex:self.currentIndex];
}

#pragma mark - Getter/Setter

- (float)radius {
    return kImgHeight/2.0-_lineWidth/2-4;
}

- (CGPoint)centerInSelf {
    return CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
}

#pragma mark - Setup

- (void)drawCircle {
    
    CAShapeLayer *circleLayer = [CAShapeLayer layer];
    circleLayer.bounds = self.bounds;
    
    CGPoint circleCenter = self.centerInSelf;
    circleLayer.position = circleCenter;
    circleLayer.backgroundColor = [UIColor clearColor].CGColor;
    
    UIBezierPath *bezierPath = [UIBezierPath bezierPathWithArcCenter:circleCenter radius:self.radius startAngle:0 endAngle:M_PI*2 clockwise:YES];
    circleLayer.lineWidth = self.lineWidth;
    circleLayer.lineJoin = kCALineCapRound;
    circleLayer.strokeColor = [UIColor blueColor].CGColor;
    circleLayer.fillColor = [UIColor clearColor].CGColor;
    circleLayer.path = bezierPath.CGPath;
    
    [self.layer addSublayer:circleLayer];
}

//draw the dial
- (void)addDialLayer {
    
    _dialsLayers = [NSMutableArray array];
    
    for(int i=0;i<12;i++) {
        
        CGFloat radian = M_PI/6.0*i;
        
        CAShapeLayer *shapeLayer = [CAShapeLayer layer];
        shapeLayer.frame = CGRectMake(0, 0, 6, 6);
        
        CGFloat centerX = self.centerInSelf.x + (self.radius - 20)*sin(radian);
        CGFloat centerY = self.centerInSelf.y - (self.radius - 20)*cos(radian);
        shapeLayer.position = CGPointMake(centerX, centerY);
        
        shapeLayer.backgroundColor = [UIColor blueColor].CGColor;
        shapeLayer.cornerRadius = shapeLayer.bounds.size.width/2.0;
        shapeLayer.masksToBounds = YES;
        
        [self.layer addSublayer:shapeLayer];
        
        [_dialsLayers addObject:shapeLayer];
    }
}

- (void)addTextLayers {
    
    _textLayers = [NSMutableArray array];
    
    for(int i=0;i<12;i++) {
        
        CGFloat radian = M_PI/6.0*i;
        
        CATextLayer *textLayer = [CATextLayer layer];
        textLayer.frame = CGRectMake(0, 0, 30, 15);
        
        CGFloat centerX = self.centerInSelf.x + (self.radius - 40)*sin(radian);
        CGFloat centerY = self.centerInSelf.y - (self.radius - 40)*cos(radian);
        textLayer.position = CGPointMake(centerX, centerY);
        
        if(i==0){
            textLayer.string = @"12";
        }else {
            textLayer.string = [NSString stringWithFormat:@"%d",i];
        }
        textLayer.fontSize = 15;
        textLayer.foregroundColor = kDefaultFontColor.CGColor;
        textLayer.alignmentMode = @"center";
        
        [self.layer addSublayer:textLayer];
        
        [_textLayers addObject:textLayer];
    }
}

- (void)addCircleHandle {
    
    _handleImgView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"circleHandle"]];
    self.handleImgView.frame = CGRectMake(0, 0, kImgWidth, kImgHeight);
    self.handleImgView.center = self.centerInSelf;
    self.handleImgView.userInteractionEnabled = YES;
    
    //add pan guesture
    UIPanGestureRecognizer *panGuesture = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panGestureAction:)];
    [self.handleImgView addGestureRecognizer:panGuesture];
    
    [self.self addSubview:self.handleImgView];
}

- (void)addRemarkTextLayerAt:(int)index {
    
    if(self.remarkTextLayer) {
        [self.remarkTextLayer removeFromSuperlayer];
        self.remarkTextLayer = nil;
    }
    
    NSString *str;
    if(index == 0){
        str = [NSString stringWithFormat:@"12个月"];
    }else {
        str = [NSString stringWithFormat:@"%d个月",index];
    }
    
    CGSize size = CGSizeOfString(str, kFontSize);
    
    _remarkTextLayer = [CATextLayer layer];
    self.remarkTextLayer.frame = CGRectMake(0, 0, size.width, size.height);
    
    float angle = index * 30.0f;
    float radian = ToRad(angle);
    CGFloat positionX = self.centerInSelf.x + (self.radius+kPadding)*sin(radian);
    CGFloat positionY = self.centerInSelf.y - (self.radius+kPadding)*cos(radian);
    self.remarkTextLayer.position = CGPointMake(positionX, positionY);
    
    self.remarkTextLayer.backgroundColor = [UIColor clearColor].CGColor;
    self.remarkTextLayer.foregroundColor = [UIColor yellowColor].CGColor;
    self.remarkTextLayer.alignmentMode = @"center";
    self.remarkTextLayer.fontSize = kFontSize;
    self.remarkTextLayer.string = str;
    
    [self.layer addSublayer:self.remarkTextLayer];
}

#pragma mark - Animation
- (void)animationInAdvance {
    
    if(previousIndex == 11) {
        
        self.dialsLayers[previousIndex].backgroundColor = [UIColor blueColor].CGColor;
        
        self.textLayers[previousIndex].foregroundColor = kDefaultFontColor.CGColor;
        
        //destory timer and skip
        [self.timer invalidate];
        self.timer = nil;
        
        return;
    }
    
    if(previousIndex != -1) {
        self.dialsLayers[previousIndex].backgroundColor = [UIColor blueColor].CGColor;
        
        self.textLayers[previousIndex].foregroundColor = kDefaultFontColor.CGColor;
    }
    
    previousIndex += 1;
    
    self.dialsLayers[previousIndex].backgroundColor = [UIColor cyanColor].CGColor;
    
    self.textLayers[previousIndex].foregroundColor = kHighlightedFontColor.CGColor;
}

#pragma mark - Operation

- (void)moveHandleAtIndex:(int)index {
    
    CGFloat radian = ToRad(index*30.0f);
    self.handleImgView.transform = CGAffineTransformMakeRotation(radian);
    
    
    if(index==12) {
        index = 0;
    }
    //change dialLayer background color
    self.dialsLayers[self.currentIndex].backgroundColor = [UIColor blueColor].CGColor;
    CAShapeLayer *currentDialLayer = self.dialsLayers[index];
    currentDialLayer.backgroundColor = kHighlightedFontColor.CGColor;
    
    //change textLayer forground color
    self.textLayers[self.currentIndex].foregroundColor = kDefaultFontColor.CGColor;
    CATextLayer *currentTextLayer = self.textLayers[index];
    currentTextLayer.foregroundColor = kHighlightedFontColor.CGColor;
    
    self.currentIndex = index;
    
}

#pragma mark PanGestureAction
- (void)panGestureAction:(UIPanGestureRecognizer *)pan {
    
    CGPoint currentPoint = [pan locationInView:self];
    CGFloat ang = AngleFromNorth(self.centerInSelf, currentPoint);
    
    CGFloat radians = ToRad(ang+90);
    int index = round((double)((int)(ang+90)%(int)360)/30);
    
    if(pan.state == UIGestureRecognizerStateBegan) {
        //when pan gesture begun
        [self.remarkTextLayer removeFromSuperlayer];
        self.remarkTextLayer = nil;
        
    }else if(pan.state == UIGestureRecognizerStateChanged){
        
        self.handleImgView.transform = CGAffineTransformMakeRotation(radians);
        
        if(index!=self.currentIndex) {
            
            if(index==12) {
                index = 0;
            }
            //change dialLayer background color
            self.dialsLayers[self.currentIndex].backgroundColor = [UIColor blueColor].CGColor;
            CAShapeLayer *currentDialLayer = self.dialsLayers[index];
            currentDialLayer.backgroundColor = kHighlightedFontColor.CGColor;
            
            //change textLayer forground color
            self.textLayers[self.currentIndex].foregroundColor = kDefaultFontColor.CGColor;
            CATextLayer *currentTextLayer = self.textLayers[index];
            currentTextLayer.foregroundColor = kHighlightedFontColor.CGColor;
            
            self.currentIndex = index;
        }
        
    }else if(pan.state ==  UIGestureRecognizerStateEnded){
        
        
        float radians = ToRad(round((double)((int)(ang+90)%(int)360)/30)*30.0);
        
        self.handleImgView.transform = CGAffineTransformMakeRotation(radians);
        
        [self addRemarkTextLayerAt:index];
    }
}

#pragma mark - Helper Functions
static inline float AngleFromNorth(CGPoint p1, CGPoint p2) {
    CGPoint v = CGPointMake(p2.x-p1.x,p2.y-p1.y);
    float vmag = sqrt(SQR(v.x) + SQR(v.y));
    v.x /= vmag;
    v.y /= vmag;
    double radians = atan2(v.y,v.x);
    CGFloat result = ToDeg(radians);
    return (result >=0  ? result : result + 360.0);
}

static inline CGSize CGSizeOfString(NSString *str, int fontSize) {
    
    CGRect rect = [str boundingRectWithSize:CGSizeMake(999, 999) options: NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:fontSize]} context:nil];
    
    return CGSizeMake(rect.size.width, rect.size.height);
}

@end
