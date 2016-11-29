//
//  GZCircleSlider.h
//  GZCircleSliderWithPanGuestrue
//
//  Created by armada on 2016/11/29.
//  Copyright © 2016年 com.zlot.gz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GZCircleSlider : UIView

@property(nonatomic,assign) float lineWidth;

/*!
 * @brief initializer
 * @param frame The frame of GZCircleSlider
 * @param lineWidth Linewidth of circle
 * @param currentIndex Current highlighted index
 * @return Instance of GZCircleSlider
 */
- (instancetype)initWithFrame:(CGRect)frame
                    lineWidth:(float)lineWidth
                 currentIndex:(int)currentIndex;

@end
