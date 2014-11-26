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
    double ballAlpha;
    
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
    NSString *allTrialDataFile;
    MachTimer* aTimer;

    
    #pragma mark - points
    int best;
    int currentLevel;

    
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


@property (strong, nonatomic) NSMutableArray *allTrialData;
@property BOOL gameCenterEnabled;
@property NSString *leaderboardIdentifier;



@end
