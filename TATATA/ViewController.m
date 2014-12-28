#import "ViewController.h"

#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IS_IPHONE_4 (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 480.0)
#define IS_IPHONE_5 (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 568.0)
#define IS_IPHONE_6 (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 667.0)
#define IS_IPHONE_6_PLUS (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 736.0)

#define IS_OS_7_OR_LATER    ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)


@interface ViewController () {
    
}
@end

@implementation ViewController


- (void)didReceiveMemoryWarning
{
   [super didReceiveMemoryWarning];
   // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
   [super viewDidLoad];
    
    screenHeight=self.view.frame.size.height;
    screenWidth=self.view.frame.size.width;
    bgColor=[UIColor colorWithWhite:.15 alpha:1];
    fgColor=[UIColor colorWithRed:255/255 green:163/255.0 blue:0 alpha:1];
    flashColor=[UIColor colorWithWhite:1 alpha:1];
    strokeColor=[UIColor colorWithWhite:.8 alpha:1];

    allowBallResize=false;
    dimAlpha=.04;
    
    aTimer = [MachTimer timer];
    viewLoaded=false;
    
    [self authenticateLocalPlayer];

   #pragma mark - Persistent Variables
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if([defaults objectForKey:@"best"] == nil) best=0;
    else best = (int)[defaults integerForKey:@"best"];
    
    if([defaults objectForKey:@"showIntro"] == nil) showIntro=true;
    else showIntro = (int)[defaults integerForKey:@"showIntro"];


#pragma mark - Ball
    startY=screenHeight*.5-200;
    endY=screenHeight*.5+200;
    
    catchZone=[[Dots alloc] initWithFrame:CGRectMake(0,0, 88, 88)];
    catchZone.center=CGPointMake(screenWidth*.5, endY);
    catchZone.backgroundColor = [UIColor clearColor];
    catchZone.alpha=1;
    [catchZone setColor:strokeColor];
    [catchZone setFill:NO];
    [self.view addSubview:catchZone];
    
    catchZoneCenter=[[Dots alloc] initWithFrame:CGRectMake(0,0, 8, 8)];
    catchZoneCenter.center=catchZone.center;
    catchZoneCenter.backgroundColor = [UIColor clearColor];
    catchZoneCenter.alpha=1;
    [catchZoneCenter setColor:strokeColor];
    [catchZoneCenter setFill:YES];
    [self.view addSubview:catchZoneCenter];
    
//    catchZoneFlash=[[Dots alloc] initWithFrame:CGRectMake(0,0, 88, 88)];
//    catchZoneFlash.center=catchZone.center;
//    catchZoneFlash.backgroundColor = [UIColor clearColor];
//    catchZoneFlash.alpha=0;
//    [catchZoneFlash setColor:flashColor];
//    [catchZoneFlash setFill:YES];
//    [self.view addSubview:catchZoneFlash];
//    [self.view sendSubviewToBack:catchZoneFlash];
    
    ballAlpha=.9;
    ball=[[Dots alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
    ball.center=CGPointMake(screenWidth*.5, startY);
    ball.backgroundColor = [UIColor clearColor];
    ball.alpha=0;
    [ball setColor:strokeColor];
    [ball setFill:NO];
    //ball.lineWidth=ball.frame.size.width*.5-2;
    
    [self.view addSubview:ball];
    [self.view bringSubviewToFront:ball];
    
    
    arc=[[Arc alloc] initWithFrame:CGRectMake(0,0, ball.frame.size.width+20,ball.frame.size.height+30)];
    arc.backgroundColor=[UIColor clearColor];
    arc.center=ball.center;
    [self.view addSubview:arc];
    arc.alpha=dimAlpha;
    
//    startZoneFlash=[[Dots alloc] initWithFrame:arc.frame];
//    startZoneFlash.center=ball.center;
//    startZoneFlash.backgroundColor = [UIColor clearColor];
//    startZoneFlash.alpha=0;
//    [startZoneFlash setColor:flashColor];
//    [startZoneFlash setFill:YES];
//    [self.view addSubview:startZoneFlash];
//    [self.view sendSubviewToBack:startZoneFlash];
    
#pragma mark - Labels
    
    
    scoreLabel=[[UILabel alloc] initWithFrame:CGRectMake(0,0, screenWidth, 160)];
    scoreLabel.center=CGPointMake(screenWidth/2.0, startY);
    scoreLabel.text=@"0";
    scoreLabel.textAlignment = NSTextAlignmentCenter;
    scoreLabel.backgroundColor = [UIColor clearColor];
    scoreLabel.font = [UIFont fontWithName:@"HelveticaNeue-Ultralight" size:78];
    scoreLabel.textColor=strokeColor;
    scoreLabel.alpha=0;
    [self.view addSubview:scoreLabel];
    
    scoreLabelLabel=[[UILabel alloc] initWithFrame:CGRectMake(0,0, 100, 40)];
    scoreLabelLabel.center=CGPointMake(screenWidth/2.0, scoreLabel.center.y+80);
    scoreLabelLabel.text=@"SCORE";
    scoreLabelLabel.textAlignment = NSTextAlignmentCenter;
    scoreLabelLabel.backgroundColor = [UIColor clearColor];
    scoreLabelLabel.font = [UIFont fontWithName:@"HelveticaNeue-Ultralight" size:14];
    scoreLabelLabel.textColor=strokeColor;
    scoreLabelLabel.alpha=0;
    [self.view addSubview:scoreLabelLabel];
    
    scoreLabelLine=[[UILabel alloc] initWithFrame:CGRectMake(0,0, scoreLabelLabel.frame.size.width, .5)];
    scoreLabelLine.backgroundColor = strokeColor;
    [scoreLabelLabel addSubview:scoreLabelLine];
    
    scoreGraph=[[Sparkline alloc] initWithFrame:CGRectMake(0,-20, scoreLabelLabel.frame.size.width, 20)];
    [scoreLabelLabel addSubview:scoreGraph];

    
    bestLabel=[[UILabel alloc] initWithFrame:CGRectMake(0,0, screenWidth, 160)];
    bestLabel.center=CGPointMake(screenWidth/2.0, screenHeight*.5);
    bestLabel.text=@"0";
    bestLabel.textAlignment = NSTextAlignmentCenter;
    bestLabel.backgroundColor = [UIColor clearColor];
    bestLabel.font = [UIFont fontWithName:@"HelveticaNeue-Ultralight" size:78];
    bestLabel.textColor=strokeColor;
    bestLabel.alpha=0;
    [self.view addSubview:bestLabel];
    
    bestLabelLabel=[[UILabel alloc] initWithFrame:CGRectMake(0,0, 100, 40)];
    bestLabelLabel.center=CGPointMake(screenWidth/2.0, bestLabel.center.y+80);
    bestLabelLabel.text=@"BEST";
    bestLabelLabel.textAlignment = NSTextAlignmentCenter;
    bestLabelLabel.backgroundColor = [UIColor clearColor];
    bestLabelLabel.font = [UIFont fontWithName:@"HelveticaNeue-Ultralight" size:14];
    bestLabelLabel.textColor=strokeColor;
    bestLabelLabel.alpha=0;
    [bestLabelLabel setUserInteractionEnabled:YES];
    
    [self.view addSubview:bestLabelLabel];
    
    bestLabelLine=[[UILabel alloc] initWithFrame:CGRectMake(0,0, bestLabelLabel.frame.size.width, .5)];
    bestLabelLine.backgroundColor = strokeColor;
    [bestLabelLabel addSubview:bestLabelLine];
    

    gameCenterButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [gameCenterButton addTarget:self
               action:@selector(showGlobalLeaderboard)
     forControlEvents:UIControlEventTouchUpInside];
    
    gameCenterButton.titleLabel.font=[UIFont fontWithName:@"Entypo" size:14];
    [gameCenterButton setTitle:@"▸\U0000FE0E" forState:UIControlStateNormal];
    //gameCenterButton.backgroundColor=[UIColor redColor];
    [gameCenterButton setTitleColor:fgColor forState:UIControlStateNormal];
    gameCenterButton.frame = CGRectMake(bestLabelLabel.frame.size.width-58, -25, 88.0, 88.0);
    [bestLabelLabel addSubview:gameCenterButton];
    

    [self updateHighscore];
    
    
#pragma mark - Mid Marks
    int markWidth=20;
    int markHeight=5;
    int courtWidth=320;
    

    midMarkLine=[[UIView alloc] initWithFrame:CGRectMake(screenWidth*.5-courtWidth*.5, 0, courtWidth, 1)];
    midMarkLine.backgroundColor=strokeColor;
    midMarkLine.alpha=dimAlpha;
    [self.view addSubview:midMarkLine];
    
    
    midMarkL=[[UIView alloc] initWithFrame:CGRectMake(screenWidth*.5-courtWidth*.5, 0, markWidth, markHeight)];
    midMarkL.backgroundColor=strokeColor;
    [self.view addSubview:midMarkL];
    
    midMarkR=[[UIView alloc] initWithFrame:CGRectMake(screenWidth*.5+courtWidth*.5-markWidth, 0, markWidth, markHeight)];
    midMarkR.backgroundColor=strokeColor;
    [self.view addSubview:midMarkR];
    
    midMarkL.alpha=dimAlpha;
    midMarkR.alpha=dimAlpha;

    
#pragma mark - intro
    intro=[[UIView alloc] initWithFrame:self.view.frame];
    intro.backgroundColor=bgColor;
    [self.view addSubview:intro];
    
    int m=15;
    int w=screenWidth-m*2.0;
    //instructions

    
    introTitle=[[UILabel alloc] initWithFrame:CGRectMake(m, screenWidth*.22, w, screenWidth*.20)];
    introTitle.font = [UIFont fontWithName:@"DIN Condensed" size:screenWidth*.22];
    introTitle.adjustsFontSizeToFitWidth=YES;
    introTitle.text=@"THIS IS TATATA";
    //introTitle.textColor=[self getForegroundColor:0];
    [intro addSubview:introTitle];

    
    introSubtitle=[[UILabel alloc] initWithFrame:CGRectMake(m, 15, w, 90)];
    introSubtitle.font = [UIFont fontWithName:@"DIN Condensed" size:32];
    introSubtitle.numberOfLines=3;
    introSubtitle.text=@"TEST";
    //introSubtitle.textColor=[self getForegroundColor:0];
    [intro addSubview:introSubtitle];
    
    
    introParagraph=[[UILabel alloc] initWithFrame:CGRectMake(m, introSubtitle.frame.origin.y+introSubtitle.frame.size.height+10, w, 180)];
    introParagraph.font = [UIFont fontWithName:@"DIN Condensed" size:20];
    introParagraph.numberOfLines=10;
    introParagraph.textAlignment=NSTextAlignmentJustified;
    introParagraph.text=@"For each trial..";
    //introParagraph.textColor=[self getForegroundColor:0];
    [intro addSubview:introParagraph];
    
    credits=[[UILabel alloc] initWithFrame:CGRectMake(m, screenHeight-55, w, 40)];
    credits.font = [UIFont fontWithName:@"HelveticaNeue" size:9];
    credits.numberOfLines=3;
    credits.textAlignment=NSTextAlignmentCenter;
    credits.text=@"TATATA";
    //credits.textColor=[self getForegroundColor:0];
    [intro addSubview:credits];
    
    intro.alpha=0;
    
//    UITapGestureRecognizer *tapGestureRecognizer3 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(buttonPressed)];
//    tapGestureRecognizer3.numberOfTouchesRequired = 1;
//    tapGestureRecognizer3.numberOfTapsRequired = 1;
//    [self.view addGestureRecognizer:tapGestureRecognizer3];
//    self.view.userInteractionEnabled=YES;
    
    NSLog(@"Getting the latest config...");
    [PFConfig getConfigInBackgroundWithBlock:^(PFConfig *config, NSError *error) {
        if (!error) {
            NSLog(@"Yay! Config was fetched from the server.");
        } else {
            NSLog(@"Failed to fetch. Using Cached Config.");
            config = [PFConfig currentConfig];
        }
        
        float catchZoneDiameter = [config[@"catchZoneDiameter"]floatValue];
        if(catchZoneDiameter){
            
            catchZone.frame=CGRectMake(0, 0, catchZoneDiameter, catchZoneDiameter);
            catchZone.center=CGPointMake(screenWidth*.5, endY);
        }

    }];
    

    
    //currentLevel=11;
    [self restart];
}
#pragma mark - touch

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self buttonPressed];
    
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint touchPoint = [touch locationInView:self.view];
    //NSLog(@"Touch x : %f y : %f", touchPoint.x, touchPoint.y);
    touchX=touchPoint.x;
    touchY=touchPoint.y;
    
    touchStartTime=[aTimer elapsedSeconds];
    
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    touchLength=[aTimer elapsedSeconds]-touchStartTime;
    if(touched){
        [self trialStopped];
    }

}

#pragma mark - restart

-(void) restart{
    trialSequence=-1;
    [self performSelector:@selector(showStartScreen) withObject:self afterDelay:0.4];
}

-(void)showStartScreen{
    currentLevel=0;
    [UIView animateWithDuration:0.4
                          delay:0.0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         catchZone.alpha=0;
                         catchZoneCenter.alpha=0;

                         ball.alpha=0;
                         midMarkL.alpha=dimAlpha;
                         midMarkR.alpha=dimAlpha;
                         arc.alpha=dimAlpha;
                     }
                     completion:^(BOOL finished){
                         [catchZone setFill:YES];
                         [catchZone setColor:fgColor];

                         
                         [UIView animateWithDuration:0.4
                                               delay:0.0
                                             options:UIViewAnimationOptionCurveLinear
                                          animations:^{
                                              catchZone.alpha=1;

                                          }
                                          completion:^(BOOL finished){
                                              [self showLabels:YES];
                                              [self animateLevelReset];
                                              trialSequence=0;
                                          }];
                     }];
    
    
}



-(void)updateHighscore{
    bestLabel.text=[NSString stringWithFormat:@"%i",best];
    scoreLabel.text=[NSString stringWithFormat:@"%i",currentLevel];
}


#pragma mark - Action



//volume buttons
-(void)buttonPressed{
    
    if(showIntro){
        showIntro=false;

        [UIView animateWithDuration:0.4
                              delay:0.0
                            options:UIViewAnimationOptionCurveLinear
                         animations:^{
                             intro.alpha=0;
                         }
                         completion:^(BOOL finished){
                             NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                             [defaults setInteger:showIntro forKey:@"showIntro"];
                             [defaults synchronize];

                         }];
        return;
    }
    
    if(trialSequence<0)return;

    //START
    if(trialSequence==0){
        touched=NO;
        trialSequence=-1;
        [self showLabels:NO];

        if(currentLevel==0){


            [UIView animateWithDuration:0.4
                                  delay:0.0
                                options:UIViewAnimationOptionCurveLinear
                             animations:^{
                                 catchZone.alpha=0;
                                 catchZoneCenter.alpha=0;
                             }
                             completion:^(BOOL finished){
                                 [catchZone setFill:NO];
                                 [catchZone setColor:strokeColor];
            
                                 [self setLevel:currentLevel];
                                 [self animateLevelReset];
                                 trialSequence=-1;

                    [UIView animateWithDuration:0.4
                                          delay:0.0
                                        options:UIViewAnimationOptionCurveLinear
                                     animations:^{
                                         catchZone.alpha=1;
                                         catchZoneCenter.alpha=1;
                                         midMarkL.alpha=1;
                                         midMarkR.alpha=1;
                                         arc.alpha=1;
                                     }
                                     completion:^(BOOL finished){
                                         trialSequence=-1;

                                         //rest scoreboard
                                         [self updateHighscore];
                                         [self startTrialSequence];
                                     }];
                             }];
        }
        else{
            [self startTrialSequence];
        }

    }
    //STOP
    else if(trialSequence==1){
        touched=YES;
        [self stop];
    }
    
}

-(void)stop{
    elapsed=[aTimer elapsedSeconds];
    trialSequence=-1;
    
    
    if([self isAccurate]){
        //            if([self getAccuracyFloat]<.5) [ball setColor:[UIColor greenColor]];
        //            else [ball setColor:[UIColor yellowColor]];
        [ball setColor:[UIColor greenColor]];
        [ball setNeedsDisplay];
    }else{
        [ball setColor:[UIColor redColor]];
        [ball setNeedsDisplay];
        
        //flash background
        [UIView animateWithDuration:0.1
                              delay:0.0
                            options:UIViewAnimationOptionCurveLinear
                         animations:^{
                             self.view.backgroundColor=flashColor;
                         }
                         completion:^(BOOL finished){
                             [UIView animateWithDuration:0.4
                                                   delay:0.0
                                                 options:UIViewAnimationOptionCurveLinear
                                              animations:^{
                                                  self.view.backgroundColor=bgColor;
                                              }
                                              completion:^(BOOL finished){
                                                  
                                              }];
                         }];
        
    }
    
    [self positionBall:NO];
    ball.alpha=ballAlpha;

//    [self trialStopped];
    
    [self.view.layer removeAllAnimations];
}

-(void)saveTrialData{
    

    
    NSDate* localDateTime = [NSDate dateWithTimeInterval:[[NSTimeZone systemTimeZone] secondsFromGMT] sinceDate:[NSDate date]];

    //save to disk
    NSMutableDictionary *myDictionary = [[NSMutableDictionary alloc] init];
    float diff=elapsed-timerGoal;
    [myDictionary setObject:[NSNumber numberWithFloat:diff] forKey:@"accuracy"];
    [myDictionary setObject:[NSNumber numberWithFloat:timerGoal] forKey:@"goal"];
    [myDictionary setObject:[NSNumber numberWithFloat:flashT] forKey:@"flashT"];
    [myDictionary setObject:[NSNumber numberWithFloat:[currentTrial[@"d1"]floatValue]] forKey:@"d1"];
    [myDictionary setObject:[NSNumber numberWithFloat:[currentTrial[@"d2"]floatValue]] forKey:@"d2"];
    [myDictionary setObject:[NSNumber numberWithInteger:currentLevel] forKey:@"level"];
    [myDictionary setObject:[NSNumber numberWithBool:([self isAccurate])? YES:NO] forKey:@"win"];
    [myDictionary setObject:localDateTime forKey:@"date"];
    [myDictionary setObject:[NSTimeZone localTimeZone].abbreviation forKey:@"timezone"];
    [myDictionary setObject:[NSNumber numberWithBool: (touched)? YES:NO ] forKey:@"didTouch"];
    if(touched){
        [myDictionary setObject:[NSNumber numberWithFloat: touchX ] forKey:@"touchX"];
        [myDictionary setObject:[NSNumber numberWithFloat: touchY ] forKey:@"touchY"];
        [myDictionary setObject:[NSNumber numberWithFloat: touchLength ] forKey:@"touchLength"];
    }
    [self.allTrialData addObject:myDictionary];
    [self.allTrialData writeToFile:allTrialDataFile atomically:YES];

    //save to parse
    PFObject *pObject = [PFObject objectWithClassName:@"results"];
    pObject[@"accuracy"] = [NSNumber numberWithFloat:diff];
    pObject[@"goal"] = [NSNumber numberWithFloat:timerGoal];
    pObject[@"flashT"]=[NSNumber numberWithFloat:flashT];
    pObject[@"trial"]=currentTrial;
    pObject[@"level"]=[NSNumber numberWithInteger:currentLevel];
    pObject[@"win"]=([self isAccurate])? @YES:@NO;
    pObject[@"date"]=localDateTime;
    pObject[@"timezone"]=[NSString stringWithFormat:@"%@",[NSTimeZone localTimeZone].abbreviation];
    pObject[@"didTouch"]=(touched)? @YES:@NO;
    if(touched){
        pObject[@"touchX"]=[NSNumber numberWithFloat: touchX ];
        pObject[@"touchY"]=[NSNumber numberWithFloat: touchY ];
        pObject[@"touchLength"]=[NSNumber numberWithFloat:touchLength];
    }
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString*uuid;
    if([defaults stringForKey:@"uuid"] == nil){
        uuid=CFBridgingRelease(CFUUIDCreateString(NULL, CFUUIDCreate(NULL)));
        [defaults setObject:uuid forKey:@"uuid"];
        [defaults synchronize];
    }
    else uuid =[defaults stringForKey:@"uuid"];
    pObject[@"uuid"]=uuid;
    
    if(currentUser!=nil) pObject[@"user"]=currentUser;
    
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    if(currentInstallation!=nil)pObject[@"installation"]=currentInstallation;
    
    [pObject saveEventually];

    [currentUser incrementKey:@"trialsPlayed"];
    currentUser[@"best"]=[NSNumber numberWithFloat:best];
    [currentUser saveEventually];
    
}


-(void)showIntroView{
    [self.view bringSubviewToFront:intro];
    
    [UIView animateWithDuration:0.4
                          delay:0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         intro.alpha=1.0;
                     }
                     completion:^(BOOL finished){

                     }];
    
}

#pragma mark DATA
-(void)loadTrialData{
    
    NSArray *docPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);

    self.allTrialData = [[NSMutableArray alloc] init];
    allTrialDataFile = [[docPath objectAtIndex:0] stringByAppendingPathComponent:@"allTrialData.dat"];
    self.allTrialData = [[NSMutableArray alloc] initWithContentsOfFile: allTrialDataFile];
    if(self.allTrialData == nil){
        
        self.allTrialData = [[NSMutableArray alloc] init];
        //for (int i = 0; i <1 ; i++) {
        NSMutableDictionary *myDictionary = [[NSMutableDictionary alloc] init];
        [myDictionary setObject:[NSNumber numberWithFloat:0.0] forKey:@"accuracy"];
        [myDictionary setObject:[NSNumber numberWithFloat:0.0] forKey:@"goal"];
        [myDictionary setObject:[NSDate date] forKey:@"date"];
        [myDictionary setObject:[NSNumber numberWithFloat:0.0] forKey:@"flashT"];

        [self.allTrialData addObject:myDictionary];
    
        [self.allTrialData writeToFile:allTrialDataFile atomically:YES];
    }
    
    NSArray *libPath = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    scoreHistory = [[NSMutableArray alloc] init];
    scoreHistoryDataFile = [[libPath objectAtIndex:0] stringByAppendingPathComponent:@"scoreHistory.dat"];
    scoreHistory = [[NSMutableArray alloc] initWithContentsOfFile: scoreHistoryDataFile];
    if(scoreHistory == nil){
        
        scoreHistory = [[NSMutableArray alloc] init];
        [scoreHistory addObject:[NSNumber numberWithInteger:0]];
        [scoreHistory writeToFile:scoreHistoryDataFile atomically:YES];
    }
    
    scoreGraph.yValues=scoreHistory;
    [scoreGraph setNeedsDisplay];
    

}





#pragma mark - GameCenter
-(void)reportScore{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if(currentLevel>0){
        if(currentLevel>=best){
            best=currentLevel;
            [defaults setInteger:best forKey:@"best"];
        }
    }
    [self updateHighscore];
    [defaults synchronize];
    
    
    if(_leaderboardIdentifier){
        GKScore *score = [[GKScore alloc] initWithLeaderboardIdentifier:@"global.tatata"];
        score.value = best;
        
        [GKScore reportScores:@[score] withCompletionHandler:^(NSError *error) {
            if (error != nil) {
                NSLog(@"%@", [error localizedDescription]);
            }
        }];

  
    }
}


-(void)showGlobalLeaderboard{
    GKGameCenterViewController *gcViewController = [[GKGameCenterViewController alloc] init];
    gcViewController.gameCenterDelegate = self;
    gcViewController.viewState = GKGameCenterViewControllerStateLeaderboards;
    gcViewController.leaderboardIdentifier = @"global.tatata";
    [self presentViewController:gcViewController animated:YES completion:nil];
}


-(void)gameCenterViewControllerDidFinish:(GKGameCenterViewController *)gameCenterViewController
{
    [gameCenterViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark BALL

-(void)startTrialSequence{
    
    double initDelay=.8;
    double flashDelay=timerGoal*(float)flashT;
    double flashDuration=.07;
    
    [ball setColor:strokeColor];
    [ball setNeedsDisplay];
    
    CFTimeInterval currentTime = CACurrentMediaTime();
    CFTimeInterval currentTimeInSuperLayer = [self.view.layer convertTime:currentTime fromLayer:nil];

    //first flash
    [CATransaction begin];
    CABasicAnimation *startFlash = [CABasicAnimation animationWithKeyPath:@"opacity"];
    [startFlash setDuration:flashDuration];
    [startFlash setFromValue:[NSNumber numberWithFloat:0.0f]];
    [startFlash setToValue:[NSNumber numberWithFloat:1.0f]];
    [startFlash setBeginTime:currentTimeInSuperLayer+initDelay];
    [CATransaction setCompletionBlock:^{
        [aTimer start];
        if(currentLevel==0){
            ball.alpha=dimAlpha;
            trialSequence=-2;
            [self updateBall];
        }
        else [self performSelector:@selector(updateBall) withObject:self afterDelay:timerGoal];

        float msOff=[aTimer elapsedSeconds];
        NSLog(@"startFlash accuracy: %f sec",msOff);
        if(currentLevel>0)ball.center=CGPointMake(screenWidth*.5, startY+(endY-startY)*flashT);
    }];
    [ball.layer addAnimation:startFlash forKey:@"startFlash"];

    //second flash
    CABasicAnimation *midFlash = [CABasicAnimation animationWithKeyPath:@"opacity"];
    [midFlash setDuration:flashDuration];
    [midFlash setFromValue:[NSNumber numberWithFloat:(currentLevel>0)?0.0f:ballAlpha]];
    [midFlash setToValue:[NSNumber numberWithFloat:1.0f]];
    [midFlash setBeginTime:currentTimeInSuperLayer+initDelay+flashDelay];
    [CATransaction setCompletionBlock:^{
        if(currentLevel==0) ball.alpha=dimAlpha;
        trialSequence=1;
        float msOff=[aTimer elapsedSeconds]-flashDelay;
        NSLog(@"midFlash   accuracy: %f sec",msOff);
    }];
    [ball.layer addAnimation:midFlash forKey:@"midFlash"];
    [midMarkLine.layer addAnimation:midFlash forKey:@"midFlash"];

    
    //flash midMarks
//    CABasicAnimation *flagFlash = [CABasicAnimation animationWithKeyPath:@"backgroundColor"];
//    [flagFlash setDuration:flashDuration];
//    flagFlash.fromValue = (id)[midMarkL.layer backgroundColor];
//    flagFlash.toValue = (id)flashColor.CGColor;
//    [flagFlash setBeginTime:currentTimeInSuperLayer+initDelay+flashDelay];
//    [CATransaction setCompletionBlock:^{
//
//        
//    }];
//    [midMarkL.layer addAnimation:flagFlash forKey:@"backgroundColor"];
    
    
    
    [CATransaction commit];
    
    
}

-(void)positionBall:(BOOL)animate{
    CGPoint p;
    if(elapsed==0)p=CGPointMake(screenWidth*.5, startY);
    else p=CGPointMake(screenWidth*.5, startY+(endY-startY)*(float)elapsed/(float)timerGoal );
    if(animate){
        [UIView animateWithDuration:0.2
                              delay:0.0
                            options:UIViewAnimationOptionCurveLinear
                         animations:^{
                             ball.center=p;
                         }
                         completion:^(BOOL finished){
                         }];
    }
    else{
        ball.center=p;
    }
    
}


-(float)getLevel:(int)level{
    //userdefault last level
    float l=[currentTrial[@"d1"] floatValue]+[currentTrial[@"d2"] floatValue];
    return l;
    
    
//    float l;
//
//    if (level==0)l=1.5;
//    else {
//        //l=.7+level*0.1;
//        NSInteger randomNumber = arc4random() % 25;
//        NSInteger coinFlip = arc4random() % 1;
//        
//        if(coinFlip==0)coinFlip=1;
//        else coinFlip=-1;
//
//        l=1.5+level*randomNumber/100.0*coinFlip;
//        
//        if(l<.5)l=.5;
//        
//    }
//    return l;
}

-(float)getFlashT:(int)level{
    //    float f=.5;
    //    NSInteger random = arc4random() % 3;
    //
    //    if (level>=3) f=.5-random*.1;
    float f=[currentTrial[@"d1"] floatValue]/([currentTrial[@"d1"] floatValue]+[currentTrial[@"d2"] floatValue]);
    
    
    return f;
}

-(float)getLevelAccuracy:(int)level{
    
    //return .2;
    
    //return timerGoal*.1;
    
    //int stage=(5+level)/10.0;
    float accuracy=.125-.075*level/25.0;
    if(level>25)accuracy=.05;
    return timerGoal*accuracy;
    
    
}






# pragma mark LABELS
-(void)showLabels:(BOOL) show{
    
    
    [UIView animateWithDuration:0.4
                          delay:0.0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         if(show){
                             scoreLabel.alpha=1;
                             scoreLabelLabel.alpha=1;
                             bestLabel.alpha=1;
                             bestLabelLabel.alpha=1;
                         }
                         else{
                             scoreLabel.alpha=0;
                             scoreLabelLabel.alpha=0;
                             bestLabel.alpha=0;
                             bestLabelLabel.alpha=0;
                         }
                     }
                     completion:^(BOOL finished){
                         
                     }];
    
    
}


# pragma mark

-(void)updateBall{
    
    if(trialSequence==1 || trialSequence==-2){
        [self performSelector:@selector(updateBall) withObject:self afterDelay:0.001];
        elapsed=[aTimer elapsedSeconds];
        [self positionBall:NO];
        
        if(ball.center.y>=screenHeight){
            [self stop];
            [self trialStopped];
        }
    }

}




-(void)trialStopped{

    //save trial data now
    [self saveTrialData];
    
    if([self isAccurate]){
        [self reportScore];

        currentLevel++;
        [self setLevel:currentLevel];
        [self loadTrialData];
        [self performSelector:@selector(animateLevelReset) withObject:self afterDelay:0.8];
        
    }
    else{
        [scoreHistory  addObject:[NSNumber numberWithInteger:currentLevel]];
        [scoreHistory writeToFile:scoreHistoryDataFile atomically:YES];
        scoreGraph.yValues=scoreHistory;

        [scoreGraph setNeedsDisplay];

        
        [self setLevel:currentLevel];
        [self restart];
    }
    
    
}



-(void)setLevel:(int)level{
    currentTrial=[trialArray objectAtIndex: ([currentUser[@"trialsPlayed"] integerValue]+level)%[trialArray count]];
    timerGoal=[self getLevel:level];
    flashT=[self getFlashT:level];
}



-(void)animateLevelReset{
    elapsed=0;
    [self positionBall:YES];
    
    [UIView animateWithDuration:0.2
                          delay:0.0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         //set ball position
                         ball.center=CGPointMake(screenWidth*.5, startY);
                     }
                     completion:^(BOOL finished){

            
                [UIView animateWithDuration:0.4
                                        delay:0.0
                                      options:UIViewAnimationOptionCurveLinear
                                   animations:^{
                                       float catchZoneDiameter=[self getLevelAccuracy:currentLevel]*(startY-endY)/timerGoal*2.0;

                                       //if(allowBallResize)
                                        catchZone.frame=CGRectMake(0, 0, catchZoneDiameter, catchZoneDiameter);
                                       catchZone.center=CGPointMake(screenWidth*.5, endY);
                                       [catchZone setNeedsDisplay];

                                       if(allowBallResize)ball.frame=CGRectMake(0,0, catchZoneDiameter*.8, catchZoneDiameter*.8);
                                       ball.center=CGPointMake(screenWidth*.5, startY);
                                       ball.lineWidth=ball.frame.size.width*.33-2;
                                       [ball setNeedsDisplay];
                                       
                                       arc.frame=CGRectMake(50,50, ball.frame.size.width+20,ball.frame.size.height+30);
                                       arc.center=ball.center;
                                       [arc setNeedsDisplay];

                                       //set mid markers
                                       midMarkL.center=CGPointMake(midMarkL.center.x, startY+(endY-startY)*flashT);
                                       midMarkR.center=CGPointMake(midMarkR.center.x, startY+(endY-startY)*flashT);
                                       midMarkLine.center=CGPointMake(midMarkLine.center.x, startY+(endY-startY)*flashT);

                                       
                                   }
                                   completion:^(BOOL finished){

                                       [UIView animateWithDuration:0.4
                                                             delay:0.0
                                                           options:UIViewAnimationOptionCurveLinear
                                                        animations:^{
                                                            
                                                            ball.alpha=0;
                                                        }
                                                        completion:^(BOOL finished){
                                                            //autostart next level
                                                            if(currentLevel>0){                                                            trialSequence=0;
                                                                [self performSelector:@selector(buttonPressed) withObject:self afterDelay:.5];
                                                            }

                                                        }];
                                   }];
                     }];
    

}


# pragma mark Helpers

-(bool)isAccurate{
    float diff=fabs(timerGoal-elapsed);
    if( diff<=[self getLevelAccuracy:currentLevel] ) return YES;
    else return NO;
}
-(float)getAccuracyFloat{
    float f;
    f=fabs(elapsed-timerGoal)/[self getLevelAccuracy:currentLevel];
    return f;
}

-(int)getAccuracyPercentage{
    float accuracyPercent;
    accuracyPercent=100.0-fabs(elapsed-timerGoal)/(float)timerGoal*100.0;
    if(accuracyPercent<0)accuracyPercent=0;
    return ceilf(accuracyPercent);
}


#pragma mark - ViewController Delegate

- (void)viewDidUnload
{
    viewLoaded=false;

   [super viewDidUnload];
   // Release any retained subviews of the main view.
   // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    
    NSLog(@"view will appear");

    [self logIn];
    [self getTrialSequence];

    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self loadTrialData];

    //if(viewLoaded==false)
    {
        currentLevel=0;
        trialSequence=-1;
        [self setLevel:currentLevel];
        [self animateLevelReset];
    }
    
//    if(showIntro){
//        [self performSelector:@selector(showIntroView) withObject:self afterDelay:1.5];
//    }

   [super viewDidAppear:animated];
}


-(void)getTrialSequence{
//temporary load
    [self loadDefaultSequence];

    PFQuery *query = [PFQuery queryWithClassName:@"trials"];
    //[query selectKeys:@[@"d1", @"d2"]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *results, NSError *error) {
        if(!error){
            NSLog(@"updated trial sequence");
            trialArray = [NSMutableArray arrayWithArray: results];
            
            //save to disk
            NSArray *libPath = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
            trialArrayDataFile=[[libPath objectAtIndex:0] stringByAppendingPathComponent:@"trialSequence.dat"];
            [trialArray writeToFile:trialArrayDataFile atomically:YES];
        }
        else{
            NSLog(@"load trial sequence fron disk");
            [self loadDefaultSequence];
        }
    
    }];
    
}

-(void)loadDefaultSequence{
    
    //load locally
  trialArray = [[NSMutableArray alloc] initWithContentsOfFile: trialArrayDataFile];
    
    //if local file doesn't exists, make one
    if(trialArray == nil){
        NSLog(@"save default trial sequence to disk");

        trialArray = [[NSMutableArray alloc] init];
        for (int i=0; i<24; i++){
            PFObject *trialObject = [PFObject objectWithClassName:@"trial"];
            trialObject[@"d1"] = [NSNumber numberWithFloat:.5];
            trialObject[@"d2"] = [NSNumber numberWithFloat:.5];
            [trialArray addObject:trialObject];
        }
        [trialArray writeToFile:scoreHistoryDataFile atomically:YES];
    
    }
    
    
    
}

-(void)logIn{
    currentUser = [PFUser currentUser];
    if (currentUser) {
        // do stuff with the user
        currentUser[@"best"]=[NSNumber numberWithFloat:best];
        [currentUser saveEventually];
        
    } else {
        // show the signup or login screen
        [PFAnonymousUtils logInWithBlock:^(PFUser *user, NSError *error) {
            if (error) {
                NSLog(@"Anonymous login failed.");
            } else {
                NSLog(@"Anonymous user logged in.");
                currentUser = [PFUser currentUser];

                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                NSString*uuid;
                if([defaults stringForKey:@"uuid"] == nil){
                    uuid=CFBridgingRelease(CFUUIDCreateString(NULL, CFUUIDCreate(NULL)));
                    [defaults setObject:uuid forKey:@"uuid"];
                    [defaults synchronize];
                }
                else uuid =[defaults stringForKey:@"uuid"];
                currentUser[@"uuid"]=uuid;
                
                PFInstallation *currentInstallation = [PFInstallation currentInstallation];
                currentUser[@"installation"]=currentInstallation;
//                currentInstallation[@"user"]=currentUser;
//                [currentInstallation saveEventually];
                
                [currentUser saveEventually];

            }
        }];
    }

    
}


- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return NO;
    
}


-(void)authenticateLocalPlayer{
    GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];
    
    localPlayer.authenticateHandler = ^(UIViewController *viewController, NSError *error){
        if (viewController != nil) {
            [self presentViewController:viewController animated:YES completion:nil];
        }
        else{
            if ([GKLocalPlayer localPlayer].authenticated) {
                _gameCenterEnabled = YES;
                
                // Get the default leaderboard identifier.
                [[GKLocalPlayer localPlayer] loadDefaultLeaderboardIdentifierWithCompletionHandler:^(NSString *leaderboardIdentifier, NSError *error) {
                    
                    if (error != nil) {
                        NSLog(@"%@", [error localizedDescription]);
                    }
                    else{
                        _leaderboardIdentifier = leaderboardIdentifier;
                    }
                }];
            }
            
            else{
                _gameCenterEnabled = NO;
            }
        }
    };
}



@end
