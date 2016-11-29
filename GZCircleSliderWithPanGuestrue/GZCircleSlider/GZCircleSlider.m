//
//  GZCircleSlider.m
//  GZCircleSliderWithPanGuestrue
//
//  Created by armada on 2016/11/29.
//  Copyright © 2016年 com.zlot.gz. All rights reserved.
//

#import "GZCircleSlider.h"

#define ToRad(deg) ((M_PI*(deg))/180.00)
#define ToDeg(rad) ((180*rad)/M_PI)
#define SQR(x) ((x)*(x))

@interface GZCircleSlider()

{
    int angle;
    int previousIndex;
}

@property(nonatomic,strong) CAShapeLayer *shapeLayer;

@property(readonly,assign) float radius;

@property(readonly,assign) CGPoint centerInSelf;

@property(nonatomic,strong) UIImageView *handleImgView;

@property(nonatomic,strong) NSMutableArray<CAShapeLayer *> *dialsLayers;

@property(nonatomic,strong) NSMutableArray<CATextLayer *> *textLayers;

@end

@implementation GZCircleSlider

- (instancetype)initWithFrame:(CGRect)frame lineWidth:(float)lineWidth{
    
    if(self = [super initWithFrame:frame]) {
        
        self.backgroundColor = [UIColor clearColor];
        self.userInteractionEnabled = YES;
        
        _lineWidth = lineWidth;
        
        [self drawCircle];
        [self addDialLayer];
        [self addTextLayers];
        [self addCircleHandle];
    }
    
    return self;
}

#pragma mark - Getter/Setter

- (float)radius {
    return self.frame.size.height/2.0-_lineWidth/2-4;
}

- (CGPoint)centerInSelf {
    return CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
}

- (void)drawCircle {
    
    CAShapeLayer *circleLayer = [CAShapeLayer layer];
    circleLayer.bounds = self.bounds;
    
    CGPoint circleCenter = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
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
        textLayer.foregroundColor = [UIColor grayColor].CGColor;
        textLayer.alignmentMode = @"center";
        
        [self.layer addSublayer:textLayer];
        
        [_textLayers addObject:textLayer];
    }
}

- (void)addCircleHandle {
    
    _handleImgView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"circleHandle"]];
    self.handleImgView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    self.handleImgView.center = self.centerInSelf;
    self.handleImgView.userInteractionEnabled = YES;
    
    //add pan guesture
    UIPanGestureRecognizer *panGuesture = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panGestureAction:)];
    //panGuesture.delegate = self;
    [self.handleImgView addGestureRecognizer:panGuesture];
    
    [self.self addSubview:self.handleImgView];
}

#pragma mark PanGestureAction
- (void)panGestureAction:(UIPanGestureRecognizer *)pan {
    
    if(pan.state == UIGestureRecognizerStateBegan) {
        
        CGPoint currentPoint = [pan locationInView:self];
        
        NSLog(@"%f,%f",currentPoint.x,currentPoint.y);
    }else if(pan.state == UIGestureRecognizerStateChanged){
        
        CGPoint currentPoint = [pan locationInView:self];
        CGFloat ang = AngleFromNorth(self.centerInSelf, currentPoint);
        CGFloat radians = ToRad(ang+90);
        self.handleImgView.transform = CGAffineTransformMakeRotation(radians);
        
        //change current index color
        int index = round((double)((int)(ang+90)%(int)360)/30);
        
        if(index!=previousIndex) {
            
            if(index==12) {
                index = 0;
            }
            //change dialLayer background color
            self.dialsLayers[previousIndex].backgroundColor = [UIColor blueColor].CGColor;
            CAShapeLayer *currentDialLayer = self.dialsLayers[index];
            currentDialLayer.backgroundColor = [UIColor cyanColor].CGColor;
            
            //change textLayer forground color
            self.textLayers[previousIndex].foregroundColor = [UIColor grayColor].CGColor;
            CATextLayer *currentTextLayer = self.textLayers[index];
            currentTextLayer.foregroundColor = [UIColor cyanColor].CGColor;
            
            previousIndex = index;
        }
        
    }else if(pan.state ==  UIGestureRecognizerStateEnded){
        NSLog(@"ended");
    }
}


static inline float AngleFromNorth(CGPoint p1, CGPoint p2) {
    CGPoint v = CGPointMake(p2.x-p1.x,p2.y-p1.y);
    float vmag = sqrt(SQR(v.x) + SQR(v.y));
    v.x /= vmag;
    v.y /= vmag;
    double radians = atan2(v.y,v.x);
    CGFloat result = ToDeg(radians);
    return (result >=0  ? result : result + 360.0);
}


@end
