#import "OpenCVWrapper.h"
#import <opencv2/core.hpp>
#import <opencv2/imgproc.hpp>
#import <opencv2/imgcodecs/ios.h>
#import "Detect_and_Track.h"
#import "color.h"

@implementation OpenCVWrapper

FrameProcess *processor = nullptr;
+ (bool) initFrameProcessor
{
    if(processor !=nullptr)
    {
        delete processor;
        processor=nullptr;
    }
    std::vector<int> board_ids = { 19,92,7,12 };
    std::vector<std::vector< cv::Point3f>> board_pts = {
    {{0, 0, 0},{70, 0, 0},{70, 70, 0},{0, 70, 0}},
    {{530, 0, 0},{600, 0, 0},{600, 70, 0},{530, 70, 0}},
    {{530, 330, 0},{600, 330, 0},{600, 400, 0},{530, 400, 0}},
    {{0, 330, 0},{70, 330, 0},{70, 400, 0},{0, 400, 0}}
    };
    cv::Size winSize(21, 21);
    std::vector<double> dist(5);
    cv::TermCriteria termcrit = cv::TermCriteria(cv::TermCriteria::COUNT | cv::TermCriteria::EPS, 30, 0.01);
    float ratio = 4.0;
    processor = new FrameProcess(board_ids, board_pts, dist, winSize, termcrit, ratio);

    return true;
}

+ (NSDictionary *)detectPatternFromImage: (UIImage*)image with: (matrix_float3x3)Kmat{
    
    // Convert UIImage to OpenCV Mat: UIImageToMat
    cv::Mat frame;
    UIImageToMat(image, frame);
    
    cv::Matx33d K(Kmat.columns[0][0], Kmat.columns[1][0], Kmat.columns[2][0], Kmat.columns[0][1], Kmat.columns[1][1], Kmat.columns[2][1],Kmat.columns[0][2], Kmat.columns[1][2], Kmat.columns[2][2]); // Camera Calibration Matrix
    assert(processor);
    cv::Mat canvas;
    bool frameisOk = false;
    try{
        canvas = processor->ProcessFrame(frame, K, &frameisOk);
    }catch(std::exception e){
        canvas = frame;
        [self initFrameProcessor];
    }
 
    // Convert OpenCV Image to UIImage: MatToUIImage
    NSNumber *boolNumber = [NSNumber numberWithBool:frameisOk];
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          MatToUIImage(canvas), @"image",
                          boolNumber, @"status", nil];

    return dict;
}

+ (UIImage *)warpImageFromImage: (UIImage*) image with: (matrix_float3x3)Kmat{
    
    // Convert UIImage to OpenCV Mat: UIImageToMat
    cv::Mat frame;
    UIImageToMat(image, frame);
    
    cv::Matx33d K(Kmat.columns[0][0], Kmat.columns[1][0], Kmat.columns[2][0], Kmat.columns[0][1], Kmat.columns[1][1], Kmat.columns[2][1],Kmat.columns[0][2], Kmat.columns[1][2], Kmat.columns[2][2]); // Camera Calibration Matrix
    assert(processor);
    cv::Mat canvas;
    try{
        canvas = processor->WarpImage(frame, K);
    }catch(std::exception e){
        canvas = frame;
        [self initFrameProcessor];
    }
 
    // Convert OpenCV Image to UIImage
    return MatToUIImage(canvas);
}

+ (UIImage *)colorAdjustmentFrom: (UIImage*)image with: (UIImage*)stdboard{
    
    // Convert UIImage to OpenCV Mat: UIImageToMat
    cv::Mat _image, _stdboard;
    UIImageToMat(image, _image);
    UIImageToMat(stdboard, _stdboard);
    cv::Mat correctedboard = ColorAdjustment(_image, _stdboard);
    
    // Convert OpenCV Image to UIImage
    return MatToUIImage(correctedboard);
}
@end
