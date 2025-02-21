//
//  Detect_and_Track.h
//  CameraTest
//
//  Created by Guixiang Zhang on 2021/5/13.
//

#ifndef Detect_and_Track_h
#define Detect_and_Track_h

#include <iostream>
#include <vector>
#include <algorithm>
#include <cmath>
#include <map>
#include <opencv2/aruco.hpp>
#include <opencv2/core.hpp>
#include <opencv2/video/tracking.hpp>
#include <opencv2/calib3d.hpp>
#include <chrono>
#include <ctime> 


class BoardCornerTrackingState
{
public:
	BoardCornerTrackingState();
	BoardCornerTrackingState(std::vector<int> board_ids) : marker_ids_(board_ids)
	{
		for (int i = 0; i < board_ids.size(); i++)
		{
			markerid2key_.insert(std::pair<int, int>(board_ids[i], i));
		}
		corner_status_ = std::vector<std::vector<uchar>>{ board_ids.size(), std::vector<uchar>(4) };
		corner_pts_ = std::vector<std::vector<cv::Point2f>>{ board_ids.size(), std::vector<cv::Point2f>(4) };
	};

	bool isinvalid(void);
	bool isfull(void);
	void exportMarkers(std::vector<std::vector<cv::Point2f>>& corners, std::vector<int>& ids);
	void updateWithDetectState(std::vector<std::vector<cv::Point2f>> imgcorners, std::vector<int> imgids);
	std::vector<cv::Point2f> exportForTracking();
	void updateWithTrackingState(std::vector<cv::Point2f> cur_track_pts, std::vector<uchar> cur_track_stat);
	std::map<int, int> get_markerid2key() { return markerid2key_; };

private:	
	std::vector<int> marker_ids_;
	std::map<int, int> markerid2key_;
	std::vector<std::vector<cv::Point2f>> corner_pts_;
	std::vector<std::vector<uchar>> corner_status_; 
	
};
BoardCornerTrackingState::BoardCornerTrackingState() {}

bool BoardCornerTrackingState::isinvalid()
{
	int sum = 0;
	for (int i = 0; i < 4; i++)
	{
		for (int j = 0; j < 4; j++)
		{
			sum += corner_status_[i][j];
		}
	}
	if (sum <= 0)
		return true;
	else
		return false;
}

bool BoardCornerTrackingState::isfull()
{
	int sum = 0;
	for (int i = 0; i < 4; i++)
	{
		for (int j = 0; j < 4; j++)
		{
			sum += corner_status_[i][j];
		}
	}
	if (sum == 16)
		return true;
	else
		return false;
}

void BoardCornerTrackingState::exportMarkers(std::vector<std::vector<cv::Point2f>>& markercorners, std::vector<int>& markerids)
{
	for (int i = 0; i < 4; i++)
	{
		int sum = 0;
		for (int j = 0; j < 4; j++)
		{
			sum += corner_status_[i][j];
		}
		if (sum == 4)
		{
			markercorners.push_back(corner_pts_[i]);
			markerids.push_back(marker_ids_[i]);
		}			
	}
}

void BoardCornerTrackingState::updateWithDetectState(std::vector<std::vector<cv::Point2f>> imgcorners, std::vector<int> imgids)
{

	std::vector<std::vector<cv::Point2f>> updated_pts(4, std::vector<cv::Point2f>(4));
	std::vector<std::vector<uchar>> updated_status(4, std::vector<uchar>(4));
	updated_status = corner_status_;
	updated_pts = corner_pts_;

	if (imgids.empty())
		return;
	else
	{
		for (int i = 0; i < imgids.size(); i++)
		{
			std::map<int, int>::iterator iter;
			iter = markerid2key_.find(imgids[i]);
			if (iter != markerid2key_.end())
			{
				int primaryKey = markerid2key_[imgids[i]];
				updated_pts[primaryKey] = imgcorners[i];
				updated_status[primaryKey] = {1,1,1,1};
			}	
			else
				continue;	
		}
	}
	corner_status_ = updated_status;
	corner_pts_ = updated_pts;
}

std::vector<cv::Point2f> BoardCornerTrackingState::exportForTracking()
{
	std::vector<cv::Point2f> prev_track_pts;
	for (int i = 0; i < 4; i++)
	{
		for (int j = 0; j < 4; j++)
		{
			if (corner_status_[i][j] > 0)
				prev_track_pts.push_back(corner_pts_[i][j]);
		}
	}
	return prev_track_pts;
}

void BoardCornerTrackingState::updateWithTrackingState(std::vector<cv::Point2f> cur_track_pts, std::vector<uchar> cur_track_stat)
{
	// Once a point lose track by optical flow, it will never get back unless using aruco marker detector.
	std::vector<std::vector<cv::Point2f>> updated_pts(4, std::vector<cv::Point2f>(4));
	std::vector<std::vector<uchar>> updated_status(4, std::vector<uchar>(4));

	int k = 0;
	for (int i = 0; i < 4; i++)
	{
		for (int j = 0; j < 4; j++)
		{
			if (corner_status_[i][j] > 0)
			{
				updated_status[i][j] = cur_track_stat[k];
				updated_pts[i][j] = cur_track_pts[k];
				k += 1;
			}
		}
	};
	corner_status_ = updated_status;
	corner_pts_ = updated_pts;
}

class FrameProcess
{
public:
	FrameProcess(std::vector<int> board_ids, std::vector<std::vector< cv::Point3f>> board_pts, std::vector<double> dist, cv::Size winSize, cv::TermCriteria termcrit, float ratio)
		: dist_(dist), termcrit_(termcrit), winSize_(winSize), 
		timestamp_(-1), mode2times_(0), mode3times_(0), optimalZ_(0.0), tolerance_(0.05), rescale_ratio_(ratio)
	{
		set_board(board_ids, board_pts);
		parameters_ = cv::aruco::DetectorParameters::create();
		dictionary_ = cv::aruco::getPredefinedDictionary(cv::aruco::DICT_4X4_100);
		board_ = cv::aruco::Board::create(board_pts, dictionary_, board_ids);
		prevState_ = BoardCornerTrackingState(board_ids);
		curState_ = BoardCornerTrackingState(board_ids);
		imageState_ = BoardCornerTrackingState(board_ids);
	};
	inline void set_K(cv::Matx33d Kmat,float rescale_ratio) 
	{
		K_ = Kmat;
		K_(0, 0) /= rescale_ratio;
		K_(0, 2) /= rescale_ratio;
		K_(1, 1) /= rescale_ratio;
		K_(1, 2) /= rescale_ratio;
	};
	inline void set_board(std::vector<int> board_ids, std::vector<std::vector< cv::Point3f>> board_pts)
	{
		board_ids_ = board_ids;
		board_pts_ = board_pts;
		float minx=0.0, miny=0.0, maxx=0.0, maxy=0.0;
		for (int i = 0; i < board_ids.size(); i++)
		{
			for (int j = 0; j < 4; j++)
			{
				minx = std::min(minx, board_pts[i][j].x);
				miny = std::min(miny, board_pts[i][j].y);
				maxx = std::max(maxx, board_pts[i][j].x);
				maxy = std::max(maxy, board_pts[i][j].y);
			}
			
		}
		tagWidth_ = maxx - minx;
		tagHeight_ = maxy - miny;
	}
	inline void set_tolerance(float tolerance) { tolerance_ = tolerance; };
	inline void set_dist(std::vector<double> dist) { dist_ = dist; };
	inline void set_winSize(cv::Size winSize) { winSize_ = winSize; };
	inline void set_rescale_ratio(float rescale_ratio) { rescale_ratio_ = rescale_ratio; };
	inline void set_termcrit(cv::TermCriteria termcrit) { termcrit_ = termcrit; };
	inline void set_termcrit(int count, float eps) { termcrit_ = cv::TermCriteria(cv::TermCriteria::COUNT | cv::TermCriteria::EPS, count, eps); };
	inline void set_parameters(cv::Ptr<cv::aruco::DetectorParameters> parameters) { parameters_ = parameters; };
	inline void set_dictionary(cv::Ptr<cv::aruco::Dictionary> dictionary) { dictionary_ = dictionary; };

	void InitCheck();
	cv::Mat ProcessFrame(cv::Mat frame, cv::Matx33d K, bool* isOk);
	cv::Mat WarpImage(cv::Mat frame, cv::Matx33d K);
	void ComputeOptimalParameters(float FRAME_WIDTH, float FRAME_HEIGHT);
	bool getPlanarMoveGuidance(cv::Vec3d C);
	double getNearFarMoveGuidance(cv::Vec3d C);
    void project_square_pts(cv::Vec3d rvec, cv::Vec3d tvec, cv::Mat& canvas, std::map<int, int> markerid2key);
	bool SquareCheck(cv::Vec3d C);

private:
	cv::Mat prevFrame_;
	cv::Matx33d K_;
	std::vector<int> board_ids_;
	std::vector<double> dist_;
	cv::Size winSize_;
	cv::TermCriteria termcrit_;
	int timestamp_;
	int mode2times_;
	int mode3times_;
	float optimalZ_;
	std::vector<float> minXYZ_, maxXYZ_;
	cv::Matx33d optimalR_;
	cv::Vec3d optimalC_;
	float tolerance_;
	float tagWidth_, tagHeight_;
	float rescale_ratio_;
	std::vector<std::vector< cv::Point3f>> board_pts_;
	cv::Ptr<cv::aruco::DetectorParameters> parameters_;
	cv::Ptr<cv::aruco::Dictionary> dictionary_;
	cv::Ptr<cv::aruco::Board> board_;
	BoardCornerTrackingState prevState_;
	BoardCornerTrackingState curState_;
	BoardCornerTrackingState imageState_; 
};

void FrameProcess::InitCheck()
{
	if (board_ids_.size() == 0)
		throw std::string("Please give at least one board tag ID.");
	if (board_pts_.size() == 0)
		throw std::string("Please give at least one board tag with 4 corner points.");
	if (board_pts_.size() != board_ids_.size())
		throw std::string("The number of the tags and the IDs is different");
	if (dist_.size() != 4 && dist_.size() != 5 && dist_.size() != 8 && dist_.size() != 12)
		throw std::string("Please give the distortion coefficients with 4, 5, 8 or 12 elements");
	if (winSize_.width == 0 || winSize_.height == 0)
		throw std::string("Invalid window size for optical flow.");
	if (!termcrit_.isValid())
		throw std::string("Invalid termination criteria for optical flow.");
}

std::string type2str(int type) {
  std::string r;

  uchar depth = type & CV_MAT_DEPTH_MASK;
  uchar chans = 1 + (type >> CV_CN_SHIFT);

  switch ( depth ) {
    case CV_8U:  r = "8U"; break;
    case CV_8S:  r = "8S"; break;
    case CV_16U: r = "16U"; break;
    case CV_16S: r = "16S"; break;
    case CV_32S: r = "32S"; break;
    case CV_32F: r = "32F"; break;
    case CV_64F: r = "64F"; break;
    default:     r = "User"; break;
  }

  r += "C";
  r += (chans+'0');

  return r;
}

cv::Mat FrameProcess::ProcessFrame(cv::Mat frame, cv::Matx33d K, bool* isOk)
{
	auto start = std::chrono::system_clock::now();
    
    // Guarantee frame is CV_8UC3
    if(frame.type()==CV_8UC4)
    {
        cv::cvtColor(frame, frame,  cv::COLOR_BGRA2BGR);
    }
    
	InitCheck();
	set_K(K, rescale_ratio_);
	float FRAME_HEIGHT_ori = frame.rows;
	float FRAME_WIDTH_ori = frame.cols;
	cv::Mat frame_small;
	resize(frame, frame_small, cv::Size(FRAME_WIDTH_ori / rescale_ratio_, FRAME_HEIGHT_ori/ rescale_ratio_), 0, 0, cv::INTER_CUBIC);
	float FRAME_HEIGHT = frame_small.rows;
	float FRAME_WIDTH = frame_small.cols;
	ComputeOptimalParameters(FRAME_WIDTH,FRAME_HEIGHT);
	cv::Mat canvas = frame.clone();
	timestamp_ += 1;

	// Detect
	int MODE = 0;
	if (prevState_.isinvalid())
		MODE = 1;
	else if (prevState_.isfull())
		MODE = 2;
	else
		MODE = 3;
	std::vector<std::vector<cv::Point2f>> detmarkers, detrejected, markercorners;
	std::vector<int> detids, markerids;
	if (MODE == 1) // Mode 1: First frame or lost the target
	{
		cv::aruco::detectMarkers(frame_small, dictionary_, detmarkers, detids, parameters_, detrejected, K_, dist_);
		curState_.updateWithDetectState(detmarkers, detids);
		curState_.exportMarkers(markercorners, markerids);
		mode2times_ = 0;
		mode3times_ = 0;
	}
	else if (MODE == 2) // Mode 2: All corners are detected in the previous frame
	{
		// Tracking from previous state
		mode2times_ += 1;
		std::vector<cv::Point2f> prev_track_pts = prevState_.exportForTracking();
		std::vector<cv::Point2f> cur_track_pts(prev_track_pts.size());
		std::vector<uchar> cur_track_stat(prev_track_pts.size());
		std::vector<float> track_err(prev_track_pts.size());
		cv::calcOpticalFlowPyrLK(prevFrame_, frame_small, prev_track_pts, cur_track_pts, cur_track_stat, track_err, winSize_, 3, termcrit_);
		curState_.updateWithTrackingState(cur_track_pts, cur_track_stat);
		int sum = 0;
		for (int i = 0; i < cur_track_stat.size(); i++)
		{
			sum += cur_track_stat[i];
		}
		if (mode2times_ == 30 || (sum < 4))
		{
			// Use marker detector 
			cv::aruco::detectMarkers(frame_small, dictionary_, detmarkers, detids, parameters_, detrejected, K_, dist_);
			// Fuse with optical flow result
			curState_.updateWithDetectState(detmarkers, detids);
			if (mode2times_ == 30)
				mode2times_ = 0;
		}
		curState_.exportMarkers(markercorners, markerids);
	}
	else // Mode 3: Not all corners are detected in the previous frame
	{
		// Tracking from previous state
		mode3times_ += 1;
		std::vector<cv::Point2f> prev_track_pts = prevState_.exportForTracking();
		std::vector<cv::Point2f> cur_track_pts;
		std::vector<uchar> cur_track_stat;
		std::vector<float> track_err;
		cv::calcOpticalFlowPyrLK(prevFrame_, frame_small, prev_track_pts, cur_track_pts, cur_track_stat, track_err, winSize_, 3, termcrit_);
		curState_.updateWithTrackingState(cur_track_pts, cur_track_stat);
		int sum = 0;
		for (int i = 0; i < cur_track_stat.size(); i++)
		{
			sum += cur_track_stat[i];
		}
		if (mode3times_ == 5 || (sum < 4))
		{
			// Use marker detector 
			cv::aruco::detectMarkers(frame_small, dictionary_, detmarkers, detids, parameters_, detrejected, K_, dist_);
			// Fuse with optical flow result
			curState_.updateWithDetectState(detmarkers, detids);
			if (mode3times_ == 5)
				mode3times_ = 0;
		}
		curState_.exportMarkers(markercorners, markerids);
	}
	prevState_ = curState_;
	prevFrame_ = frame_small.clone();
	cv::Vec3d rvec, tvec, board_center, board_center_camera, camera_center, board_center_image;
	cv::Matx33d R;
	std::stringstream ss;
	ss.precision(3);
	ss.setf(std::ios::fixed);
    bool success = false;
    
	if (markercorners.size() > 1) // camera post estimation
	{

        cv::aruco::estimatePoseBoard(markercorners, markerids, board_, K_, dist_, rvec, tvec);
        set_K(K_, 1/rescale_ratio_);
        for (int i = 0; i < markercorners.size(); i++)
        {
            for (int j = 0; j < 4; j++)
            {
                markercorners[i][j].x *= rescale_ratio_;
                markercorners[i][j].y *= rescale_ratio_;
            }
        }
        
		// Show information
		cv::Rodrigues(rvec, R);
		camera_center = -R.t() * tvec;
		ss << "Camera: [" << camera_center[0] << ' ' << camera_center[1]  << ' ' << camera_center[2] << ']';
		cv::putText(canvas, ss.str(), cv::Point(50, 150), cv::FONT_HERSHEY_SIMPLEX, 1.5, cv::Scalar(255,0,0), 5);
		ss.str("");
		ss << "TimeStamp: " << timestamp_;
		cv::putText(canvas, ss.str(), cv::Point(FRAME_WIDTH_ori - 400, FRAME_HEIGHT_ori-100), cv::FONT_HERSHEY_SIMPLEX, 1.5, cv::Scalar(255,0,0), 5);
		ss.str("");
		ss << "R1: " << R(0, 0) << ' ' << R(0, 1) << ' ' << R(0, 2);
		cv::putText(canvas, ss.str(), cv::Point(50, 200), cv::FONT_HERSHEY_SIMPLEX, 1.5, cv::Scalar(255,0,0), 5);
		ss.str("");
		ss << "R2: " << R(1, 0) << ' ' << R(1, 1) << ' ' << R(1, 2);
		cv::putText(canvas, ss.str(), cv::Point(50, 250), cv::FONT_HERSHEY_SIMPLEX, 1.5, cv::Scalar(255,0,0), 5);
		ss.str("");
		ss << "R3: " << R(2, 0) << ' ' << R(2, 1) << ' ' << R(2, 2);
		cv::putText(canvas, ss.str(), cv::Point(50, 300), cv::FONT_HERSHEY_SIMPLEX, 1.5, cv::Scalar(255,0,0), 5);

		// User Guide
		board_center = { 300,200,0 };
		board_center_camera = (R * board_center + tvec);
		bool moveGuide = getPlanarMoveGuidance(board_center_camera);
		double nearfarGuide = getNearFarMoveGuidance(board_center_camera);
		bool squarecheck = SquareCheck(board_center_camera);
        *isOk = false;
        
		if (moveGuide)
        {
            board_center_image = K_ * board_center_camera;
            board_center_image /= board_center_image[2];
            cv::Point2i imagecenter(int(FRAME_WIDTH_ori / 2), int(FRAME_HEIGHT_ori / 2));
            cv::Point2d boardcenter(board_center_image[0] , board_center_image[1] );
            cv::arrowedLine(canvas, imagecenter, boardcenter, cv::Scalar(255, 200, 0), 16);
            ss.str("");
            ss << "Please Move Camera Along The Arrow";
            cv::putText(canvas, ss.str(), cv::Point(0, 900), cv::FONT_HERSHEY_SIMPLEX, 1.7, cv::Scalar(255,0,0), 5);
        }
        else if (nearfarGuide > 0)
        {
            ss.str("");
            ss << "Please Move Farther Away";
            cv::putText(canvas, ss.str(), cv::Point(0, 900), cv::FONT_HERSHEY_SIMPLEX, 1.7, cv::Scalar(255,0,0), 5);
        }
        else if (nearfarGuide < 0)
        {
            ss.str("");
            ss << "Please Move Closer";
            cv::putText(canvas, ss.str(), cv::Point(0, 900), cv::FONT_HERSHEY_SIMPLEX, 1.7, cv::Scalar(255,0,0), 5);
        }
        else if (squarecheck)
        {
            if( markercorners.size() == 4 )
            {
                ss.str("");
                ss << "Good";
                cv::putText(canvas, ss.str(), cv::Point(0, 900), cv::FONT_HERSHEY_SIMPLEX, 1.7, cv::Scalar(255,0,0), 5);
                success = true;
                *isOk = true;
            }
        }
        else
		{
            ss.str("");
            ss << "Please Match The Tags To The Squares";
            cv::putText(canvas, ss.str(), cv::Point(0, 900), cv::FONT_HERSHEY_SIMPLEX, 1.7, cv::Scalar(255,0,0), 5);
            
		}
		auto end = std::chrono::system_clock::now();
		std::chrono::duration<double> elapsed_seconds = end - start;
		double FPS = 1 / elapsed_seconds.count();
		ss.str("");
		ss << "FPS: "<< FPS;
		cv::putText(canvas, ss.str(), cv::Point(FRAME_WIDTH_ori - 400, FRAME_HEIGHT_ori-150), cv::FONT_HERSHEY_SIMPLEX, 1.5, cv::Scalar(255,0,0), 5);
	}
    else
    {
        set_K(K_, 1/rescale_ratio_);
        ss.str("");
        ss << "Can't Detect Enough Tags";
        cv::putText(canvas, ss.str(), cv::Point(0, 900), cv::FONT_HERSHEY_SIMPLEX, 1.7, cv::Scalar(255,0,0), 5);
    }
    
    // Draw optimal squares
    if(success)
    {
        std::vector<std::vector<cv::Point>> bottom_contour;
        for (int i = 0; i < 4; i++)
        {
            std::vector<cv::Point> bottom_points;
            for(int j = 0; j < 4; j++)
            {
                bottom_points.push_back(markercorners[i][j]);
            }
            bottom_contour.push_back(bottom_points);

        }
        drawContours(canvas, bottom_contour, -1, cv::Scalar(0, 255, 0), 10);
        
    }
    else
    {
        cv::Vec3d optimal_tvec =  -optimalR_ * optimalC_;
        cv::Vec3d optimal_rvec;
        cv::Rodrigues(optimalR_, optimal_rvec);
        std::map<int, int> markerid2key = curState_.get_markerid2key();
        project_square_pts(optimal_rvec, optimal_tvec, canvas, markerid2key);
    }
    
	return canvas;
}

cv::Mat FrameProcess::WarpImage(cv::Mat frame, cv::Matx33d K)
{
    // Guarantee frame is CV_8UC3
    if(frame.type()==CV_8UC4)
    {
        cv::cvtColor(frame, frame,  cv::COLOR_BGRA2BGR);
    }
	InitCheck();
	// Detect
	std::vector<std::vector<cv::Point2f>> detmarkers, detrejected, markercorners;
	std::vector<int> detids, markerids;
	cv::aruco::detectMarkers(frame, dictionary_, detmarkers, detids, parameters_, detrejected, K, dist_);
	imageState_.updateWithDetectState(detmarkers, detids);
	imageState_.exportMarkers(markercorners, markerids);
	cv::Vec3d rvec, tvec, C;
	cv::Matx33d R, H;
	cv::Mat warp;
	if (markercorners.size() > 0) // camera post estimation 
	{
		cv::aruco::estimatePoseBoard(markercorners, markerids, board_, K, dist_, rvec, tvec);
		// Pt_cam = K * (R * Pt_world + tvec)
		// Convert to the convention : Pt_cam = K * R * (Pt_world - C)
		cv::Rodrigues(rvec, R);

		for (int i = 0; i < 3; i++)
		{
			H(i, 0) = R(i, 0);
			H(i, 1) = R(i, 1);
			H(i, 2) = tvec(i);

		}
		H = (K * H).inv();
		H = H / H(2, 2);
		cv::warpPerspective(frame, warp, H, cv::Size(tagWidth_, tagHeight_));
		return warp;
    }else{
        return frame;
    }
}

void FrameProcess::ComputeOptimalParameters(float FRAME_WIDTH, float FRAME_HEIGHT)
{
	float minRatioVec1 = std::min(FRAME_WIDTH / tagHeight_, FRAME_HEIGHT / tagWidth_);
	float minRatioVec2 = std::min(FRAME_WIDTH / tagWidth_, FRAME_HEIGHT / tagHeight_);
	bool isTranspose = minRatioVec1 > minRatioVec2;
	float maxImgTagRatio = isTranspose ? minRatioVec1 : minRatioVec2;

	float minZ = K_(0, 0) / maxImgTagRatio;
	float maxZ = minZ * 1.50;

	optimalZ_ = minZ * 1.25;
	optimalC_ = { tagWidth_ /2, tagHeight_ /2, -optimalZ_ };
	if (isTranspose)
	{
		minXYZ_ = { -tolerance_ * tagHeight_,  -tolerance_ * tagWidth_, minZ };
		maxXYZ_ = {  tolerance_ * tagHeight_,   tolerance_ * tagWidth_, maxZ };
	}
	else
	{
		minXYZ_ = { -tolerance_ * tagWidth_,  -tolerance_ * tagHeight_, minZ };
		maxXYZ_ = {  tolerance_ * tagWidth_,   tolerance_ * tagHeight_, maxZ };
	}

	if (isTranspose)
		optimalR_ = { 0,-1,0,1,0,0,0,0,1 };
	else
		optimalR_ = { 1,0,0,0,1,0,0,0,1 };
}

bool FrameProcess::getPlanarMoveGuidance(cv::Vec3d C)
{
	bool guide = false;
	double minx = C[0] - minXYZ_[0];
	double maxx = maxXYZ_[0] - C[0];
	double miny = C[1] - minXYZ_[1];
	double maxy = maxXYZ_[1] - C[1];
	if ((minx > 0) && (maxx > 0) && (miny > 0) && (maxy > 0))
		return guide;
	else
	{
		guide = true;
		return guide;
	}
}

double FrameProcess::getNearFarMoveGuidance(cv::Vec3d C)
{
	double Z = C[2];
	double minZ = minXYZ_[2];
	double maxZ = maxXYZ_[2];
	if (Z < minZ)
		return minZ - Z;
	else if (Z > maxZ)
		return maxZ - Z;
	else
		return 0;
}

bool FrameProcess::SquareCheck(cv::Vec3d C)
{
	double Z = C[2];
	double minZ = optimalZ_ * 0.96;
	double maxZ = optimalZ_ * 1.04;
	if ((Z > minZ) && (Z < maxZ))
		return true;
	else
		return false;
}

void FrameProcess::project_square_pts(cv::Vec3d rvec, cv::Vec3d tvec, cv::Mat& canvas, std::map<int, int> markerid2key)
{

	std::vector< cv::Point3f> bottom_points;
	cv::Point3f point;
    for (int i = 0; i < 4; i++)
	{
		std::map<int, int>::iterator iter;
		iter = markerid2key.find(board_ids_[i]);
		if (iter != markerid2key.end())
		{
			int primaryKey = markerid2key[board_ids_[i]];
			for (int j = 0; j < 4; j++)
			{
				point = board_pts_[primaryKey][j];
				bottom_points.push_back(point);
			}
		}
		else
			continue;
	}
	std::vector<cv::Point2f> proj_bottom_points;
	cv::projectPoints(bottom_points, rvec, tvec, K_, dist_, proj_bottom_points);

    std::vector<std::vector<cv::Point>> bottom_contour;
    for (int i = 0; i < 4; i++)
    {
        std::vector<cv::Point> bottom_points(proj_bottom_points.begin() + 4 * i, proj_bottom_points.begin() + 4 * i + 4);
        bottom_contour.push_back(bottom_points);
    }
    drawContours(canvas, bottom_contour, -1, cv::Scalar(255, 0, 0), 3);
    
}

#endif /* Detect_and_Track_h */
