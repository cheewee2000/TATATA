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
    PFUser *currentUser;
    
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
    
    float dimAlpha;
    BOOL touched;
    
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
