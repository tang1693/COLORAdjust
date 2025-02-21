#ifndef COLOR_H
#define COLOR_H

void getVal(cv::Mat stdboard, std::vector<std::vector<int>>& ValPts, std::vector<std::vector<uchar>>& ValStdColor)
{
    for (int j = 85; j < 316; j += 10)
    {
        for (int i = 85; i < 516; i += 10)
        {
            std::vector<int> ValPt;
            std::vector<uchar> RGB;
            ValPt.push_back(j);
            ValPt.push_back(i);
            ValPts.push_back(ValPt);
            cv::Vec3b px = stdboard.at<cv::Vec3b>(j, i);
            RGB.push_back(px[0]);
            RGB.push_back(px[1]);
            RGB.push_back(px[2]);
            ValStdColor.push_back(RGB);
        }
    }
}

void getCali(cv::Mat stdboard, std::vector<std::vector<int>>& CalibPts, std::vector<std::vector<uchar>>& CalibStdColor)
{
    for (int i = 5; i < 66; i += 10)
    {
        for (int j = 85; j < 316; j += 10)
        {
            std::vector<int> CalileftPt;
            std::vector<uchar> RGB;
            CalileftPt.push_back(j);
            CalileftPt.push_back(i);
            CalibPts.push_back(CalileftPt);
            cv::Vec3b px = stdboard.at<cv::Vec3b>(j, i);
            RGB.push_back(px[0]);
            RGB.push_back(px[1]);
            RGB.push_back(px[2]);
            CalibStdColor.push_back(RGB);
        }
    };

    for (int i = 535; i < 596; i += 10)
    {
        for (int j = 85; j < 316; j += 10)
        {
            std::vector<int> CalirightPt;
            std::vector<uchar> RGB;
            CalirightPt.push_back(j);
            CalirightPt.push_back(i);
            CalibPts.push_back(CalirightPt);
            cv::Vec3b px = stdboard.at<cv::Vec3b>(j, i);
            RGB.push_back(px[0]);
            RGB.push_back(px[1]);
            RGB.push_back(px[2]);
            CalibStdColor.push_back(RGB);
        }
    };

    for (int i = 85; i < 516; i += 10)
    {
        std::vector<int> CalitopPt;
        std::vector<uchar> RGB;
        CalitopPt.push_back(35);
        CalitopPt.push_back(i);
        CalibPts.push_back(CalitopPt);
        cv::Vec3b px = stdboard.at<cv::Vec3b>(35, i);
        RGB.push_back(px[0]);
        RGB.push_back(px[1]);
        CalibStdColor.push_back(RGB);
    };

    for (int i = 85; i < 516; i += 10)
    {
        std::vector<int> CalibottomPt;
        std::vector<uchar> RGB;
        CalibottomPt.push_back(365);
        CalibottomPt.push_back(i);
        CalibPts.push_back(CalibottomPt);
        cv::Vec3b px = stdboard.at<cv::Vec3b>(365, i);
        RGB.push_back(px[0]);
        RGB.push_back(px[1]);
        RGB.push_back(px[2]);
        CalibStdColor.push_back(RGB);
    };
}

void FirstOrderCorrection(std::vector<std::vector<int>>CalibPts, std::vector<std::vector<uchar>>CalibStdColor, cv::Mat& detectedboard, cv::Mat& firstcorrectedboard)
{
    cv::Mat A = cv::Mat::zeros(cv::Size(6, CalibPts.size()), CV_64FC1);
    cv::Mat B = cv::Mat::zeros(cv::Size(1, CalibPts.size()), CV_64FC1);
    firstcorrectedboard = detectedboard.clone();
    for (int b = 0; b < 3; b++)
    {
        for (int i = 0; i < CalibPts.size(); i++)
        {
            double t = double(CalibStdColor[i][b]);
            double y = double(CalibPts[i][0]);
            double x = double(CalibPts[i][1]);
            double s = double(detectedboard.at<cv::Vec3b>(y, x)[b]);

            cv::Mat A_row = (cv::Mat_<double>(1, 6) << s * x, s * y, s, x, y, 1);
            cv::Mat dsttemp1 = A.row(i);
            A_row.copyTo(dsttemp1);
            cv::Mat B_row = (cv::Mat_<double>(1, 1) << t);
            cv::Mat dsttemp2 = B.row(i);
            B_row.copyTo(dsttemp2);
        }
        cv::Mat H = (A.t() * A).inv() * A.t() * B;
        for (int j = 0; j < detectedboard.rows; j++)
        {
            for (int k = 0; k < detectedboard.cols; k++)
            {
                double s = double(detectedboard.at<cv::Vec3b>(j, k)[b]);
                double value = s * k * H.at<double>(0, 0) + s * j * H.at<double>(1, 0) + s * H.at<double>(2, 0)
                    + k * H.at<double>(3, 0) + j * H.at<double>(4, 0) + H.at<double>(5, 0);
                if (value > 255)
                    value = 255;
                if (value < 0)
                    value = 0;
                firstcorrectedboard.at<cv::Vec3b>(j, k)[b] = uchar(value);
            }
        }
    }
}

void SecondOrderCorrection(std::vector<std::vector<int>>CalibPts, std::vector<std::vector<uchar>>CalibStdColor, cv::Mat& detectedboard, cv::Mat& secondcorrectedboard)
{
    cv::Mat A = cv::Mat::zeros(cv::Size(12, CalibPts.size()), CV_64FC1);
    cv::Mat B = cv::Mat::zeros(cv::Size(1, CalibPts.size()), CV_64FC1);
    secondcorrectedboard = detectedboard.clone();
    for (int b = 0; b < 3; b++)
    {
        for (int i = 0; i < CalibPts.size(); i++)
        {
            double t = double(CalibStdColor[i][b]);
            double y = double(CalibPts[i][0]);
            double x = double(CalibPts[i][1]);
            double s = double(detectedboard.at<cv::Vec3b>(y, x)[b]);

            cv::Mat A_row = (cv::Mat_<double>(1, 12) << s * x * x, s * y * y, s * x * y, s * x, s * y, s, x * x, y * y, x * y, x, y, 1);
            cv::Mat dsttemp1 = A.row(i);
            A_row.copyTo(dsttemp1);
            cv::Mat B_row = (cv::Mat_<double>(1, 1) << t);
            cv::Mat dsttemp2 = B.row(i);
            B_row.copyTo(dsttemp2);
        }
        cv::Mat H = (A.t() * A).inv() * A.t() * B;
        for (int j = 0; j < detectedboard.rows; j++)
        {
            for (int k = 0; k < detectedboard.cols; k++)
            {
                double s = double(detectedboard.at<cv::Vec3b>(j, k)[b]);
                double value = s * k * k * H.at<double>(0, 0) + s * j * j * H.at<double>(1, 0) + s * j * k * H.at<double>(2, 0)
                    + s * k * H.at<double>(3, 0) + s * j * H.at<double>(4, 0) + s * H.at<double>(5, 0)
                    + k * k * H.at<double>(6, 0) + j * j * H.at<double>(7, 0) + j * k * H.at<double>(8, 0)
                    + k * H.at<double>(9, 0) + j * H.at<double>(10, 0) + H.at<double>(11, 0);

                if (value > 255)
                    value = 255;
                if (value < 0)
                    value = 0;
                secondcorrectedboard.at<cv::Vec3b>(j, k)[b] = uchar(value);
            }
        }
    }
}

void EvaluateFirst(cv::Mat firstcorrectedboard, std::vector<std::vector<int>> ValPts, std::vector<std::vector<uchar>> ValStdColor)
{
    std::vector<std::vector<double>> ValColor;
    std::vector<double> RMSE;
    for (int i = 0; i < ValPts.size(); i++)
    {
        std::vector<double> RGB;
        int x = ValPts[i][1];
        int y = ValPts[i][0];
        RGB.push_back(double(firstcorrectedboard.at<cv::Vec3b>(y, x)[0]));
        RGB.push_back(double(firstcorrectedboard.at<cv::Vec3b>(y, x)[1]));
        RGB.push_back(double(firstcorrectedboard.at<cv::Vec3b>(y, x)[2]));
        ValColor.push_back(RGB);
    }
    for (int b = 0; b < 3; b++)
    {
        double sum = 0.0;
        for (int j = 0; j < ValPts.size(); j++)
        {
            sum += pow((ValColor[j][b] - ValStdColor[j][b]), 2);
        }
        RMSE.push_back(sqrt(sum / ValPts.size()));
    }

    std::cout << "1st-order RMSE(R,G,B): " << RMSE[0] << ' ' << RMSE[1] << ' ' << RMSE[2] << ' ' << std::endl;
}

void EvaluateSecond(cv::Mat secondcorrectedboard, std::vector<std::vector<int>> ValPts, std::vector<std::vector<uchar>> ValStdColor)
{
    std::vector<std::vector<double>> ValColor;
    std::vector<double> RMSE;
    for (int i = 0; i < ValPts.size(); i++)
    {
        std::vector<double> RGB;
        int x = ValPts[i][1];
        int y = ValPts[i][0];
        RGB.push_back(double(secondcorrectedboard.at<cv::Vec3b>(y, x)[0]));
        RGB.push_back(double(secondcorrectedboard.at<cv::Vec3b>(y, x)[1]));
        RGB.push_back(double(secondcorrectedboard.at<cv::Vec3b>(y, x)[2]));
        ValColor.push_back(RGB);
    }
    for (int b = 0; b < 3; b++)
    {
        double sum = 0.0;
        for (int j = 0; j < ValPts.size(); j++)
        {
            sum += pow((ValColor[j][b] - ValStdColor[j][b]), 2);
        }
        RMSE.push_back(sqrt(sum / ValPts.size()));
    }

    std::cout << "2nd-order RMSE(R,G,B): " << RMSE[0] << ' ' << RMSE[1] << ' ' << RMSE[2] << ' ' << std::endl;
}

cv::Mat ColorAdjustment(cv::Mat warp, cv::Mat stdboard)
{
    if(warp.type()==CV_8UC4)
    {
        cv::cvtColor(warp, warp,  cv::COLOR_BGRA2BGR);
    }
    if(stdboard.type()==CV_8UC4)
    {
        cv::cvtColor(stdboard, stdboard,  cv::COLOR_BGRA2BGR);
    }
    //// Color adjustment
    std::vector<std::vector<int>> ValPts;
    std::vector<std::vector<uchar>> ValStdColor;
    getVal(stdboard, ValPts, ValStdColor);
    std::vector<std::vector<int>> CalibPts;
    std::vector<std::vector<uchar>> CalibStdColor;
    getCali(stdboard, CalibPts, CalibStdColor);

    cv::Mat firstcorrectedboard, secondcorrectedboard, detectedboard;
//    cv::cvtColor(warp, detectedboard, cv::COLOR_BGR2RGB);
    detectedboard = warp.clone();
    FirstOrderCorrection(CalibPts, CalibStdColor, detectedboard, firstcorrectedboard);
    SecondOrderCorrection(CalibPts, CalibStdColor, detectedboard, secondcorrectedboard);
    EvaluateFirst(firstcorrectedboard, ValPts, ValStdColor);
    EvaluateSecond(secondcorrectedboard, ValPts, ValStdColor);
    return firstcorrectedboard;
}

#endif
