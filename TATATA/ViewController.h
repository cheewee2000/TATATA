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

@interface ViewController : UIViewController <GKGameCenterControllerDelegate>

{
    int screenWidth,screenHeight;
    int trialSequence;

    Dots *ball;
    Dots *catchZone;
    Dots *catchZoneCenter;
    float ballAlpha;
    
    float startY;
    float endY;
    
    UILabel * scoreLabel;
    UILabel * scoreLabelLabel;
    UILabel * scoreLabelLine;

    UILabel * bestLabel;
    UILabel * bestLabelLabel;
    UILabel * bestLabelLine;

    UIView * midMarkL;
    UIView * midMarkR;
    
    int allTimeTotalTrials;
    int lastStage;
    Arc * arc;
    
    float flashT;
    UIColor *bgColor;
    UIColor *fgColor;
    
    UIButton *gameCenterButton;
    

#pragma mark - timing
    NSTimeInterval elapsed;
    NSTimeInterval timerGoal;
    NSString *timeValuesFile;
    NSString *allTrialDataFile;
    NSString *lastNTrialDataFile;

    MachTimer* aTimer;

    
    #pragma mark - points
    int best;
    int currentLevel;
    
    float start;
    CGPoint offset;
    
    
    #pragma mark - progressview
    //LevelProgressView *progressView;
//    UIVisualEffectView *gameOverBlur;

//    UILabel *highScoreLabel;
//    NSMutableArray *dots;
//    Dots *bestLevelDot;
    
//    float buttonYPos;
    
//    UIButton *restartButton;
//    UIButton *playButton;
//    UIButton *trophyButton;
//    UIButton *medalButton;
    
//    NSMutableArray * stageLabels;
//    int resetCountdown;

//    UIView *labelContainer;
//    UILabel *counterLabel;
//    UILabel *counterGoalLabel;
//    UILabel *goalPrecision;
//    NSMutableArray *hearts;

//    UILabel *questionMark;
    
    
//    #pragma mark - Labels
    //TextArrow* levelAlert;
    //NSMutableArray * levelArrows;

    
//    #pragma mark - Buttons

    //UIButton *nextButton;
    //UIButton *shareButton;
    
    
//    #pragma mark - Blob
//    UIImageView * xView;
//    UIImageView * oView;
//
//    NSInteger nPointsVisible;

    
//    #pragma mark - stats
//    UIView *stats;
//    UILabel *averageTime;
//    UILabel *accuracy;
//    UILabel *precision;
//    UILabel* precisionUnit;
//    UILabel* averageUnit;
//    UILabel* accuracyUnit;
//    UILabel* averageLabel;
//    UILabel* accuracyLabel;
//    UILabel *precisionLabel;
//    UILabel *myGraphLabel;
//
//    
//    UIView *allStats;
//    UILabel *allAverageTime;
//    UILabel *allAccuracy;
//    UILabel *allPrecision;
//    UILabel* allPrecisionUnit;
//    UILabel* allAverageUnit;
//    UILabel* allAccuracyUnit;
//    UILabel* allAverageLabel;
//    UILabel* allAccuracyLabel;
//    UILabel *allPrecisionLabel;
//    UILabel *allGraphLabel;
    
    #pragma mark - intro
    UIView *intro;
    UILabel* introTitle;
    UILabel* introSubtitle;
    UILabel* introParagraph;
    UILabel* credits;

    UIButton* feedbackButton;
    BOOL showIntro;
    
    
    BOOL viewLoaded;
    
}



@property (strong, nonatomic) NSMutableArray *trialData;
@property (strong, nonatomic) NSMutableArray *allTrialData;
@property (strong, nonatomic) NSMutableArray *lastNTrialsData;
//@property (strong, nonatomic) NSMutableArray *levelData;


@property BOOL gameCenterEnabled;
@property NSString *leaderboardIdentifier;



@end
