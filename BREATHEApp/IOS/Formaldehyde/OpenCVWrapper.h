#ifndef OpenCVWrapper_h
#define OpenCVWrapper_h

#import <UIKit/UIKit.h>
#import <Vision/Vision.h>
#import <Foundation/Foundation.h>

@interface OpenCVWrapper: NSObject
+ (bool) initFrameProcessor;
+ (NSDictionary *)detectPatternFromImage: (UIImage*)image with: (matrix_float3x3)K;
+ (UIImage *)warpImageFromImage: (UIImage*)image with: (matrix_float3x3)K;
+ (UIImage *)colorAdjustmentFrom: (UIImage*)image with: (UIImage*)stdboard;
@end

#endif /* OpenCVWrapper_h */
