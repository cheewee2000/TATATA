//
//  ViewController.h
//  VolumeSnap
//
//  Created by Randall Brown on 11/17/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Dots.h"
#import <Parse/Parse.h>
#import <GameKit/GameKit.h>
#import "MachTimer.h"
#import "Arc.h"
#import "Sparkline.h"
#import "Crosshair.h"
#import "SurveyView.h"

@interface ViewController : UIViewController <GKGameCenterControllerDelegate,UIScrollViewDelegate>

{
    //PFUser *currentUser;
    PFObject *currentTrial;
    
    int screenWidth,screenHeight;
    int trialSequence;
    NSMutableArray* trialArray;
    NSString *trialArrayDataFile;
    
    Arc * arc;
    //Dots *startZoneFlash;
    
    Dots *ball;
    Dots *catchZone;
    Dots *catchZoneCenter;
    //Dots *catchZoneFlash;
    Crosshair *crosshair;
    UILabel * ballAnnotation;
    
    double ballAlpha;
    
    float startY;
    float endY;
    
    UILabel * scoreLabel;
    //UILabel * scoreLabelLabel;
    //UILabel * scoreLabelLine;

    UILabel * bestLabel;
//    UILabel * bestLabelLabel;
//    UILabel * bestLabelLine;

    UILabel * accuracyLabel;
//    UILabel * accuracyLabelLabel;
//    UILabel * accuracyLabelLine;
 
    UILabel * trialCountLabel;
//    UILabel * trialCountLabelLabel;
//    UILabel * trialCountLabelLine;
    
    
    UIView * midMarkL;
    UIView * midMarkR;
    UIView * midMarkLine;

    UILabel * currentScoreLabel;

    float flashT;
    UIColor *bgColor;
    UIColor *fgColor;
    UIColor *flashColor;
    UIColor *strokeColor;

    //config file
    float flashDuration;
    float accuracyStart;
    float accuracyIncrement;
    float accuracyMax;
    float ballDiameter;
    //float catchZoneDiameter;
    
    
    UIButton *gameCenterButton;
    UIButton *infoButton;

    UIButton *showScoreboardButton;
    UIButton *catchZoneButton;
    
    float dimAlpha;
    BOOL touched;
    float touchX,touchY;
    
    BOOL allowBallResize;
    
    float trialDelay;
    
    SurveyView *surveyView;
    
    
#pragma mark - timing
    NSTimeInterval elapsed;
    NSTimeInterval timerGoal;
    NSString *allTrialDataFile;
    MachTimer* aTimer;
    NSTimeInterval touchLength;
    NSTimeInterval touchStartTime;

    
    #pragma mark - points
    int best;
    float accuracyScore;
    int currentLevel;
    Sparkline *scoreGraph;
    NSMutableArray *scoreHistory;
    NSString *scoreHistoryDataFile;

    
    #pragma mark - intro
    UIView *intro;
    UILabel* introTitle;
    UILabel* introSubtitle;
    UILabel* introParagraph;
    UILabel* credits;

    UIButton* feedbackButton;
    BOOL showIntro;
    BOOL showSurvey;

    BOOL viewLoaded;
    
    int nExampleFails;
    
    UIScrollView *scrollView;
    
}

@property PFUser *currentUser;
@property (strong, nonatomic) NSMutableArray *allTrialData;
@property BOOL gameCenterEnabled;
@property NSString *leaderboardIdentifier;



@end
