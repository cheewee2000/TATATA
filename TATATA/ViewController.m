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
    
    int vbuttonY=137;//5s
    if(IS_IPAD)vbuttonY=237;
    else if(IS_IPHONE_6)vbuttonY=145;
    else if(IS_IPHONE_6_PLUS)vbuttonY=155;
    else if(IS_IPHONE_5)vbuttonY=128;
    else if(IS_IPHONE_4)vbuttonY=95;

    screenHeight=self.view.frame.size.height;
    screenWidth=self.view.frame.size.width;
    bgColor=[UIColor colorWithWhite:.15 alpha:1];
    
    aTimer = [MachTimer timer];
    viewLoaded=false;
    
    [self authenticateLocalPlayer];

   #pragma mark - Persistent Variables
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if([defaults objectForKey:@"currentLevel"] == nil) currentLevel=0;
    else currentLevel = (int)[defaults integerForKey:@"currentLevel"];
    
    if([defaults objectForKey:@"best"] == nil) best=0;
    else best = (int)[defaults integerForKey:@"best"];
    
    if([defaults objectForKey:@"showIntro"] == nil) showIntro=true;
    else showIntro = (int)[defaults integerForKey:@"showIntro"];

#pragma mark - Ball
    startY=100;
    endY=screenHeight*.8;

    catchZone=[[Dots alloc] initWithFrame:CGRectMake(0,0, 88, 88)];
    catchZone.center=CGPointMake(screenWidth*.5, endY);
    catchZone.backgroundColor = [UIColor clearColor];
    catchZone.alpha=1;
    [catchZone setColor:[UIColor whiteColor]];
    [catchZone setFill:NO];
    [self.view addSubview:catchZone];
    
    catchZoneCenter=[[Dots alloc] initWithFrame:CGRectMake(0,0, 8, 8)];
    catchZoneCenter.center=catchZone.center;
    catchZoneCenter.backgroundColor = [UIColor clearColor];
    catchZoneCenter.alpha=1;
    [catchZoneCenter setColor:[UIColor whiteColor]];
    [catchZoneCenter setFill:YES];
    [self.view addSubview:catchZoneCenter];
    
    
    ballAlpha=.9;
    ball=[[Dots alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    ball.center=CGPointMake(screenWidth*.5, startY);
    ball.backgroundColor = [UIColor clearColor];
    ball.alpha=0;
    [ball setColor:[UIColor whiteColor]];
    [ball setFill:NO];
    //ball.lineWidth=ball.frame.size.width*.5-2;
    
    [self.view addSubview:ball];
    [self.view bringSubviewToFront:ball];
    
    
    arc=[[Arc alloc] initWithFrame:CGRectMake(0,0, ball.frame.size.width+20,ball.frame.size.height+30)];
    arc.backgroundColor=[UIColor clearColor];
    arc.center=ball.center;
    [self.view addSubview:arc];
    arc.alpha=.15;
    
    
#pragma mark - Labels
    
    scoreLabel=[[UILabel alloc] initWithFrame:CGRectMake(0,0, screenWidth, 160)];
    scoreLabel.center=CGPointMake(screenWidth/2.0, screenHeight*.25);
    scoreLabel.text=@"0";
    scoreLabel.textAlignment = NSTextAlignmentCenter;
    scoreLabel.backgroundColor = [UIColor clearColor];
    scoreLabel.font = [UIFont fontWithName:@"HelveticaNeue-Ultralight" size:78];
    scoreLabel.textColor=[UIColor colorWithWhite:.8 alpha:1];
    scoreLabel.alpha=0;
    [self.view addSubview:scoreLabel];
    
    scoreLabelLabel=[[UILabel alloc] initWithFrame:CGRectMake(0,0, 100, 15)];
    scoreLabelLabel.center=CGPointMake(screenWidth/2.0, scoreLabel.center.y+60);
    scoreLabelLabel.text=@"SCORE";
    scoreLabelLabel.textAlignment = NSTextAlignmentCenter;
    scoreLabelLabel.backgroundColor = [UIColor clearColor];
    scoreLabelLabel.font = [UIFont fontWithName:@"HelveticaNeue-Ultralight" size:14];
    scoreLabelLabel.textColor=[UIColor colorWithWhite:.8 alpha:1];
    scoreLabelLabel.alpha=0;
    [self.view addSubview:scoreLabelLabel];
    
    bestLabel=[[UILabel alloc] initWithFrame:CGRectMake(0,0, screenWidth, 160)];
    bestLabel.center=CGPointMake(screenWidth/2.0, screenHeight*.5);
    bestLabel.text=@"0";
    bestLabel.textAlignment = NSTextAlignmentCenter;
    bestLabel.backgroundColor = [UIColor clearColor];
    bestLabel.font = [UIFont fontWithName:@"HelveticaNeue-Ultralight" size:78];
    bestLabel.textColor=[UIColor colorWithWhite:.8 alpha:1];
    bestLabel.alpha=0;
    [self.view addSubview:bestLabel];
    
    bestLabelLabel=[[UILabel alloc] initWithFrame:CGRectMake(0,0, 100, 15)];
    bestLabelLabel.center=CGPointMake(screenWidth/2.0, bestLabel.center.y+60);
    bestLabelLabel.text=@"BEST";
    bestLabelLabel.textAlignment = NSTextAlignmentCenter;
    bestLabelLabel.backgroundColor = [UIColor clearColor];
    bestLabelLabel.font = [UIFont fontWithName:@"HelveticaNeue-Ultralight" size:14];
    bestLabelLabel.textColor=[UIColor colorWithWhite:.8 alpha:1];
    bestLabelLabel.alpha=0;
    [self.view addSubview:bestLabelLabel];
    
    [self updateHighscore];
    
    
#pragma mark - Mid Marks
    midMarkL=[[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 15)];
    midMarkL.backgroundColor=[UIColor whiteColor];
    [self.view addSubview:midMarkL];
    
    midMarkR=[[UIView alloc] initWithFrame:CGRectMake(screenWidth-5, 0, 5, 15)];
    midMarkR.backgroundColor=[UIColor whiteColor];
    [self.view addSubview:midMarkR];
    
    midMarkL.alpha=.15;
    midMarkR.alpha=.15;
    
#pragma mark - intro
    intro=[[UIView alloc] initWithFrame:self.view.frame];
    //intro.backgroundColor=[self getBackgroundColor:0];
    //[self.view addSubview:intro];
    
    int m=15;
    int w=screenWidth-m*2.0;
    //instructions

    
    introTitle=[[UILabel alloc] initWithFrame:CGRectMake(m, screenWidth*.22, w, screenWidth*.20)];
    introTitle.font = [UIFont fontWithName:@"DIN Condensed" size:screenWidth*.22];
    introTitle.adjustsFontSizeToFitWidth=YES;
    introTitle.text=@"THIS IS TEMPRA";
    //introTitle.textColor=[self getForegroundColor:0];
    [intro addSubview:introTitle];

    
    introSubtitle=[[UILabel alloc] initWithFrame:CGRectMake(m, 15, w, 90)];
    introSubtitle.font = [UIFont fontWithName:@"DIN Condensed" size:32];
    introSubtitle.numberOfLines=3;
    introSubtitle.text=@"TEST AND INCREASE YOUR TIME PERCEPTION";
    //introSubtitle.textColor=[self getForegroundColor:0];
    [intro addSubview:introSubtitle];
    
    
    introParagraph=[[UILabel alloc] initWithFrame:CGRectMake(m, introSubtitle.frame.origin.y+introSubtitle.frame.size.height+10, w, 180)];
    introParagraph.font = [UIFont fontWithName:@"DIN Condensed" size:20];
    introParagraph.numberOfLines=10;
    introParagraph.textAlignment=NSTextAlignmentJustified;
    introParagraph.text=@"For each trial, your goal is to get as close as possible to the displayed target time. Tap the screen or press the volume button to start the counter, then press stop when you think the right amount of time has elapsed. \n\nBreathe... relax, and focus on your internal sense of time.";
    //introParagraph.textColor=[self getForegroundColor:0];
    [intro addSubview:introParagraph];
    
    credits=[[UILabel alloc] initWithFrame:CGRectMake(m, screenHeight-55, w, 40)];
    credits.font = [UIFont fontWithName:@"HelveticaNeue" size:9];
    credits.numberOfLines=3;
    credits.textAlignment=NSTextAlignmentCenter;
    credits.text=@"TEMPRA, 2014\nDesigned and built by Che-Wei Wang\nMIT Media Lab, Playful Systems";
    //credits.textColor=[self getForegroundColor:0];
    [intro addSubview:credits];
    
    intro.alpha=0;
    
    UITapGestureRecognizer *tapGestureRecognizer3 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(buttonPressed)];
    tapGestureRecognizer3.numberOfTouchesRequired = 1;
    tapGestureRecognizer3.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:tapGestureRecognizer3];
    self.view.userInteractionEnabled=YES;
    
    //currentLevel=11;
    [self restart];
}


#pragma mark - restart

-(void) restart{
    trialSequence=-1;
    [self performSelector:@selector(showStartScreen) withObject:self afterDelay:0.5];
}

-(void)showStartScreen{
    currentLevel=0;

    [self clearTrialData];
    
    [UIView animateWithDuration:0.4
                          delay:0.4
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         catchZone.alpha=0;
                         catchZoneCenter.alpha=0;

                         ball.alpha=0;
                         midMarkL.alpha=.15;
                         midMarkR.alpha=.15;
                         arc.alpha=.15;
                     }
                     completion:^(BOOL finished){
                         [catchZone setFill:YES];
                         [catchZone setColor:[UIColor orangeColor]];

                         
                         [UIView animateWithDuration:0.4
                                               delay:0.4
                                             options:UIViewAnimationOptionCurveLinear
                                          animations:^{
                                              catchZone.alpha=1;

                                          }
                                          completion:^(BOOL finished){
                                              [self showLabels:YES];
                                              [self animateLevelReset];
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
                              delay:0.6
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
    
    //START
    if(trialSequence==0){
        trialSequence=-1;
        [self showLabels:NO];

        if(currentLevel==0){

            [UIView animateWithDuration:0.4
                                  delay:0.4
                                options:UIViewAnimationOptionCurveLinear
                             animations:^{
                                 catchZone.alpha=0;
                                 catchZoneCenter.alpha=0;
                             }
                             completion:^(BOOL finished){
                                 [catchZone setFill:NO];
                                 [catchZone setColor:[UIColor whiteColor]];
            
                                 [self saveAndSetLevel:currentLevel];
                                 [self animateLevelReset];
                                 
                    [UIView animateWithDuration:0.4
                                          delay:0.4
                                        options:UIViewAnimationOptionCurveLinear
                                     animations:^{
                                         catchZone.alpha=1;
                                         catchZoneCenter.alpha=1;

                                         midMarkL.alpha=1;
                                         midMarkR.alpha=1;
                                         arc.alpha=1;

                                     }
                                     completion:^(BOOL finished){
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
        trialSequence=-1;

        elapsed=[aTimer elapsedSeconds];
        if([self isAccurate]){
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
                                 self.view.backgroundColor=[UIColor whiteColor];
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
        
        [self trialStopped];

        [self.view.layer removeAllAnimations];

 
    }
    
}


-(void)saveTrialData{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    //save to disk
    NSMutableDictionary *myDictionary = [[NSMutableDictionary alloc] init];
    float diff=elapsed-timerGoal;
    [myDictionary setObject:[NSNumber numberWithFloat:diff] forKey:@"accuracy"];
    [myDictionary setObject:[NSNumber numberWithFloat:timerGoal] forKey:@"goal"];
    [myDictionary setObject:[NSNumber numberWithFloat:flashT] forKey:@"flashT"];
    [myDictionary setObject:[NSDate date] forKey:@"date"];
    [self.trialData addObject:myDictionary];
    [self saveValues];

    //save to parse
    PFObject *pObject = [PFObject objectWithClassName:@"results"];
    pObject[@"goal"] = [NSNumber numberWithFloat:(timerGoal)];
    pObject[@"accuracy"] = [NSNumber numberWithFloat:(elapsed-timerGoal)];
    pObject[@"date"]=[NSDate date];
    pObject[@"flashT"]=[NSNumber numberWithFloat:(flashT)];
    pObject[@"timezone"]=[NSString stringWithFormat:@"%@",[NSTimeZone localTimeZone]];

    NSString*uuid;
    if([defaults stringForKey:@"uuid"] == nil){
        uuid=CFBridgingRelease(CFUUIDCreateString(NULL, CFUUIDCreate(NULL)));
        [defaults setObject:uuid forKey:@"uuid"];
    }
    else uuid =[defaults stringForKey:@"uuid"];
    
    pObject[@"uuid"]=uuid;
    [pObject saveEventually];
    
    [defaults synchronize];
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
//-(void)loadData:(float) level{
-(void)loadTrialData{
    
    //load values
    self.trialData = [[NSMutableArray alloc] init];
    
    //Creating a file path under iOS:
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    timeValuesFile = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"trialData.dat"];

    //Load the array
    self.trialData = [[NSMutableArray alloc] initWithContentsOfFile: timeValuesFile];
    
    
    NSArray *docPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);

    self.allTrialData = [[NSMutableArray alloc] init];
    allTrialDataFile = [[docPath objectAtIndex:0] stringByAppendingPathComponent:@"allTrialData.dat"];
    self.allTrialData = [[NSMutableArray alloc] initWithContentsOfFile: allTrialDataFile];
    if(self.allTrialData == nil){
        
        self.allTrialData = [[NSMutableArray alloc] init];
        for (int i = 0; i <2 ; i++) {
            NSMutableDictionary *myDictionary = [[NSMutableDictionary alloc] init];
            [myDictionary setObject:[NSNumber numberWithFloat:0.0] forKey:@"accuracy"];
            [myDictionary setObject:[NSNumber numberWithFloat:0.0] forKey:@"goal"];
            [myDictionary setObject:[NSDate date] forKey:@"date"];
            [myDictionary setObject:[NSNumber numberWithFloat:0.0] forKey:@"flashT"];

            [self.allTrialData addObject:myDictionary];
        }
        [self saveValues];
    }
    
    
    if(self.trialData == nil)
    {
        [self clearTrialData];
    }
}

-(void)clearTrialData{
    //Array file didn't exist... create a new one
    self.trialData = [[NSMutableArray alloc] init];
    for (int i = 0; i <2 ; i++) {
        NSMutableDictionary *myDictionary = [[NSMutableDictionary alloc] init];
        [myDictionary setObject:[NSNumber numberWithFloat:0.0] forKey:@"accuracy"];
        [myDictionary setObject:[NSNumber numberWithFloat:0.0] forKey:@"goal"];
        [myDictionary setObject:[NSDate date] forKey:@"date"];
        [myDictionary setObject:[NSNumber numberWithFloat:0.0] forKey:@"flashT"];
        [self.trialData addObject:myDictionary];
    }
    
    
    [self saveValues];
    
}

-(void)saveValues{
    [self.trialData writeToFile:timeValuesFile atomically:YES];
    [self.allTrialData writeToFile:allTrialDataFile atomically:YES];
}

#pragma mark - GameCenter
-(void)reportScore{
    if(_leaderboardIdentifier){
        GKScore *score = [[GKScore alloc] initWithLeaderboardIdentifier:@"global"];
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
    gcViewController.leaderboardIdentifier = @"global";
    [self presentViewController:gcViewController animated:YES completion:nil];
}


-(void)gameCenterViewControllerDidFinish:(GKGameCenterViewController *)gameCenterViewController
{
    [gameCenterViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark BALL

-(void)startFirstTrial{
    float initDelay=.5;
    
    [UIView animateWithDuration:0
                          delay:initDelay
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         ball.alpha=ballAlpha;
                     }
                     completion:^(BOOL finished){
                         [aTimer start];
                         trialSequence=1;
                         [self updateBall];
                         
   
                     }];
    
}
-(void)startTrialSequence{
    float initDelay=.8;
    double motionDelay=(double)timerGoal*(double)flashT;
    float flashDuration=.02;
    [ball setColor:[UIColor whiteColor]];
    [ball setNeedsDisplay];
    
    [UIView animateWithDuration:0
                          delay:initDelay
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         ball.alpha=ballAlpha;
                     }
                     completion:^(BOOL finished){
                         [aTimer start];
                         if(currentLevel==0){
                             trialSequence=1;
                             [self updateBall];
                         }
                         
                         //first flash
                         [UIView animateWithDuration:0.0
                                               delay:flashDuration
                                             options:UIViewAnimationOptionCurveLinear
                                          animations:^{
                                              if(currentLevel>0)ball.alpha=0;
                                              else ball.alpha=.15;
                                          }
                                          completion:^(BOOL finished){
                                              if(currentLevel>0){ball.center=CGPointMake(screenWidth*.5, startY+(endY-startY)*flashT);
                                              }
                                          }];
    
                         //second flash
                         [UIView animateWithDuration:0.0
                                               delay:motionDelay
                                             options:UIViewAnimationOptionCurveLinear
                                          animations:^{
                                              ball.alpha=ballAlpha;
                                          }
                                          completion:^(BOOL finished){
                                              [UIView animateWithDuration:0.0
                                                                    delay:flashDuration
                                                                  options:UIViewAnimationOptionCurveLinear
                                                               animations:^{
                                                                   if(currentLevel>0)ball.alpha=0;
                                                                   else ball.alpha=.15;
                                                               }
                                                               completion:^(BOOL finished){
                                                                   
                                                                   if(currentLevel>0){
                                                                       //allow STOP button
                                                                       trialSequence=1;
                                                                       [self updateBall];
                                                                   }

                                                               }];
                                          }];
                         
                         
                     }];

    
}

-(void)positionBall:(BOOL)animate{
    CGPoint p;
    if(elapsed==0)p=CGPointMake(screenWidth*.5, startY);
    else p=CGPointMake(screenWidth*.5, startY+(endY-startY)*(float)elapsed/timerGoal );
    if(animate){
    
    [UIView animateWithDuration:0.4
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



//
//#pragma mark LEVELS
//-(void)loadLevelProgress{
//    //load values
//    self.levelData = [[NSMutableArray alloc] init];
//    
//    //Creating a file path under iOS:
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
//    NSString *File = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"levelData.dat"];
//    
//    //Load the array
//    self.levelData = [[NSMutableArray alloc] initWithContentsOfFile: File];
//    
//    if(self.levelData == nil)
//    {
//        //Array file didn't exist... create a new one
//        self.levelData = [[NSMutableArray alloc] init];
//        for (int i = 0; i < 2; i++) {
//            
//            NSMutableDictionary *myDictionary = [[NSMutableDictionary alloc] init];
//            [myDictionary  setObject:[NSNumber numberWithInt:0] forKey:@"accuracy"];
//            [myDictionary setObject:[NSNumber numberWithFloat:0.0] forKey:@"goal"];
//            [myDictionary setObject:[NSDate date] forKey:@"date"];
//            [self.levelData addObject:myDictionary];
// 
//        }
//        [self saveLevelProgress];
//    }
//    
//}
//
//-(void)saveLevelProgress{
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
//    NSString *File = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"levelData.dat"];
//    [self.levelData writeToFile:File atomically:YES];
//}




-(float)getLevel:(int)level{
    float l;

    if (level==0)l=1.0;
    else {
        //l=.7+level*0.1;
        NSInteger randomNumber = arc4random() % 100;
        l=1.0+level*randomNumber/1000.0;
    }
    
    return l;
}

-(float)getLevelAccuracy:(int)level{
    return .1;
}

-(float)getFlashT:(int)level{
    float f=.5;
    NSInteger randomNumber = arc4random() % 1;

    if (level>=2) f=.25+randomNumber*.25;
    //else if (level>=2) f=.4+randomNumber*.1;

    return f;
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
    
    if(trialSequence==1){
        [self performSelector:@selector(updateBall) withObject:self afterDelay:0.01];
        elapsed=[aTimer elapsedSeconds];
        [self positionBall:NO];
        
        if(ball.center.y+ball.frame.size.height*.5>=screenHeight){
            [self buttonPressed];
        }
    }

}




-(void)trialStopped{

    [self performSelector:@selector(checkLevelUp) withObject:self afterDelay:0.5];

    allTimeTotalTrials++;
    [[NSUserDefaults standardUserDefaults] setInteger:allTimeTotalTrials forKey:@"allTimeTotalTrials"];
    
}


-(void)checkLevelUp{
    
    //save trial data now
    [self saveTrialData];
    
    if([self isAccurate]){

        //save current level now
        currentLevel++;
        [self reportScore];
        [self saveAndSetLevel:currentLevel];
        [self loadTrialData];
        //[self loadLevelProgress];
        [self animateLevelReset];
        
    }
    else{
        [self saveAndSetLevel:currentLevel];
        [self restart];
    }
    



}


-(void)saveAndSetLevel:(int)level{
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:level forKey:@"currentLevel"];
    if(level>0){
        //float lastSuccessfulGoal=fabs([[[self.levelData objectAtIndex:level-1] objectForKey:@"goal"] floatValue]);
            if(level>=best){
            best=level;
            [defaults setInteger:best forKey:@"best"];
        }
    }
    [self updateHighscore];
    [defaults synchronize];
    
    
    timerGoal=[self getLevel:level];
    flashT=[self getFlashT:level];
    
}



-(void)animateLevelReset{
    elapsed=0;
    [self positionBall:YES];
    
    [UIView animateWithDuration:0.4
                          delay:0.0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         //set ball position
                         ball.center=CGPointMake(screenWidth*.5, startY);
                     }
                     completion:^(BOOL finished){

            
    [UIView animateWithDuration:0.4
                            delay:0.2
                          options:UIViewAnimationOptionCurveLinear
                       animations:^{
                           float catchZoneDiameter=[self getLevelAccuracy:currentLevel]*(startY-endY)/timerGoal*2.0;

                           catchZone.frame=CGRectMake(0, 0, catchZoneDiameter, catchZoneDiameter);
                           catchZone.center=CGPointMake(screenWidth*.5, endY);
                           
                           ball.frame=CGRectMake(0,0, catchZoneDiameter*.8, catchZoneDiameter*.8);
                           ball.center=CGPointMake(screenWidth*.5, startY);
                           ball.lineWidth=ball.frame.size.width*.33-2;

                           
                           arc.frame=CGRectMake(0,0, ball.frame.size.width+20,ball.frame.size.height+30);
                           arc.center=ball.center;

                           //set mid markers
                           midMarkL.center=CGPointMake(midMarkL.center.x, startY+(endY-startY)*flashT);
                           midMarkR.center=CGPointMake(midMarkR.center.x, startY+(endY-startY)*flashT);

                           
                       }
                       completion:^(BOOL finished){

                           [UIView animateWithDuration:0.4
                                                 delay:0.2
                                               options:UIViewAnimationOptionCurveLinear
                                            animations:^{
                                                
                                                ball.alpha=0;
                                            }
                                            completion:^(BOOL finished){
                                                trialSequence=0;
                                                if(currentLevel>0)[self performSelector:@selector(buttonPressed) withObject:self afterDelay:.5];

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

    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{

    if(viewLoaded==false){
        trialSequence=-1;
        [self saveAndSetLevel:currentLevel];
        [self animateLevelReset];
    }
    
//    if(showIntro){
//        [self performSelector:@selector(showIntroView) withObject:self afterDelay:1.5];
//    }
    
   [super viewDidAppear:animated];
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
