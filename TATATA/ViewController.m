#import "ViewController.h"

#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IS_IPHONE_4 (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 480.0)
#define IS_IPHONE_5 (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 568.0)
#define IS_IPHONE_6 (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 667.0)
#define IS_IPHONE_6_PLUS (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 736.0)

#define IS_OS_7_OR_LATER    ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)

#define NUMLEVELARROWS 5

#define TRIALSINSTAGE 5
#define NUMHEARTS 3
#define SHOWNEXTRASTAGES 3


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

    
    aTimer = [MachTimer timer];


    [self loadLevelProgress];

   #pragma mark - Persistent Variables

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if([defaults objectForKey:@"currentLevel"] == nil) currentLevel=0;
    else currentLevel = (int)[defaults integerForKey:@"currentLevel"];
    
    if([defaults objectForKey:@"best"] == nil) best=0;
    else best = (int)[defaults integerForKey:@"best"];
    
    if([defaults objectForKey:@"showIntro"] == nil) showIntro=true;
    else showIntro = (int)[defaults integerForKey:@"showIntro"];

 #pragma mark - Ball

     startY=200;
     endY=screenHeight-200;

    catchZone=[[Dots alloc] initWithFrame:CGRectMake(0,0, 100, 100)];
    catchZone.center=CGPointMake(screenWidth*.5, endY);
    catchZone.backgroundColor = [UIColor clearColor];
    catchZone.alpha=1;
    [catchZone setColor:[UIColor whiteColor]];
    [catchZone setFill:NO];
    [self.view addSubview:catchZone];
    
    ball=[[Dots alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    ball.center=CGPointMake(screenWidth*.5, -100);
    ball.backgroundColor = [UIColor clearColor];
    ball.alpha=1;
    [ball setColor:[UIColor whiteColor]];
    [ball setFill:YES];
    [self.view addSubview:ball];
    [self.view bringSubviewToFront:ball];
    

    [self authenticateLocalPlayer];
    
    
#pragma mark - intro
    intro=[[UIView alloc] initWithFrame:self.view.frame];
    //intro.backgroundColor=[self getBackgroundColor:0];
    [self.view addSubview:intro];
    
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
    [self performSelector:@selector(setupGame) withObject:self afterDelay:0.5];
}

-(void)setupGame{
    currentLevel=0;

    [self clearTrialData];
    
    [UIView animateWithDuration:0.4
                          delay:0.0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         catchZone.alpha=.15;
                     }
                     completion:^(BOOL finished){
                     }];
    
}



-(void)updateHighscore{
    if(best>0) bestLabel.text=[NSString stringWithFormat:@"BEST %.01f",best];
}

-(int)getCurrentStage{
    return floorf(currentLevel/TRIALSINSTAGE);
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
        [UIView animateWithDuration:0.4
                              delay:0.0
                            options:UIViewAnimationOptionCurveLinear
                         animations:^{
                             catchZone.alpha=1;
                         }
                         completion:^(BOOL finished){
                             //if(currentLevel>0)
                             [self startTrialSequence];
                             //else [self startFirstTrial];
                         }];
        

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
            
        }
        [self positionBall:NO];
        ball.alpha=1;
        
        
        [self.view.layer removeAllAnimations];

        [self trialStopped];

        
    }
    
}


-(void)saveTrialData{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    
    //save to disk
    NSMutableDictionary *myDictionary = [[NSMutableDictionary alloc] init];
    float diff=elapsed-timerGoal;
    [myDictionary setObject:[NSNumber numberWithFloat:diff] forKey:@"accuracy"];
    [myDictionary setObject:[NSNumber numberWithFloat:timerGoal] forKey:@"goal"];
    [myDictionary setObject:[NSDate date] forKey:@"date"];
    //[self.ArrayOfValues  insertObject:myDictionary atIndex:currentLevel];
    //dave data into continuous array
    [self.trialData addObject:myDictionary];
    //[self.trialData removeObjectAtIndex:0];
    
    //save into history
    [self.lastNTrialsData addObject:myDictionary];
    if([self.lastNTrialsData count]>100){
        [self.lastNTrialsData removeObjectAtIndex:0];
    }
    
    [self.lastNTrialsData addObject:myDictionary];
    
    
    //save data into clean array
    [self.levelData  insertObject:myDictionary atIndex:currentLevel];
    [self saveLevelProgress];
    
    //save to parse
    PFObject *pObject = [PFObject objectWithClassName:@"results"];
    pObject[@"goal"] = [NSNumber numberWithFloat:(timerGoal)];
    pObject[@"accuracy"] = [NSNumber numberWithFloat:(elapsed-timerGoal)];
    pObject[@"date"]=[NSDate date];
    //pObject[@"timezone"]=[NSTimeZone localTimeZone];

    NSString*uuid;
    //NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if([defaults stringForKey:@"uuid"] == nil){
        uuid=CFBridgingRelease(CFUUIDCreateString(NULL, CFUUIDCreate(NULL)));
        [defaults setObject:uuid forKey:@"uuid"];
    }
    else uuid =[defaults stringForKey:@"uuid"];
    pObject[@"uuid"]=uuid;
    [pObject saveEventually];
    


    [self saveValues];
    
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
    //timeValuesFile = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"timeData%i.dat",(int)level]];
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
            [self.allTrialData addObject:myDictionary];
        }
        [self saveValues];
    }
    
    
    
    self.lastNTrialsData = [[NSMutableArray alloc] init];
    lastNTrialDataFile = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"lastNTrialsData.dat"];
    self.lastNTrialsData = [[NSMutableArray alloc] initWithContentsOfFile: lastNTrialDataFile];
    if(self.lastNTrialsData == nil){
        
        self.lastNTrialsData = [[NSMutableArray alloc] init];
        for (int i = 0; i <2 ; i++) {
            NSMutableDictionary *myDictionary = [[NSMutableDictionary alloc] init];
            [myDictionary setObject:[NSNumber numberWithFloat:0.0] forKey:@"accuracy"];
            [myDictionary setObject:[NSNumber numberWithFloat:0.0] forKey:@"goal"];
            [myDictionary setObject:[NSDate date] forKey:@"date"];
            [self.lastNTrialsData addObject:myDictionary];
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
        [self.trialData addObject:myDictionary];
    }
    
    
    [self saveValues];
    
}

-(void)saveValues{
    [self.trialData writeToFile:timeValuesFile atomically:YES];
    [self.allTrialData writeToFile:allTrialDataFile atomically:YES];
    [self.lastNTrialsData writeToFile:lastNTrialDataFile atomically:YES];

}

#pragma mark - GameCenter
-(void)reportScore{
    if(_leaderboardIdentifier){
        //GKScore *score = [[GKScore alloc] initWithLeaderboardIdentifier:_leaderboardIdentifier];
        GKScore *score = [[GKScore alloc] initWithLeaderboardIdentifier:@"global"];
        score.value = best*10.0;
        
        [GKScore reportScores:@[score] withCompletionHandler:^(NSError *error) {
            if (error != nil) {
                NSLog(@"%@", [error localizedDescription]);
            }
        }];

        
        GKScore *sp = [[GKScore alloc] initWithLeaderboardIdentifier:@"starBank"];
        sp.value = starBank;
        
        [GKScore reportScores:@[sp] withCompletionHandler:^(NSError *error) {
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

-(void)showSBLeaderboard{
    GKGameCenterViewController *gcViewController = [[GKGameCenterViewController alloc] init];
    gcViewController.gameCenterDelegate = self;
    gcViewController.viewState = GKGameCenterViewControllerStateLeaderboards;
    gcViewController.leaderboardIdentifier = @"starBank";
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
                         ball.alpha=1;
                     }
                     completion:^(BOOL finished){
                         [aTimer start];
                         trialSequence=1;
                         [self updateBall];
                         
   
                     }];
    
}
-(void)startTrialSequence{
    float initDelay=.5;
    float flashT=.5;
    double motionDelay=(double)timerGoal*(double)flashT;
    float flashDuration=.02;

    
    [UIView animateWithDuration:0
                          delay:initDelay
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         ball.alpha=1;
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
                                              ball.alpha=1;
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




#pragma mark LEVELS
-(void)loadLevelProgress{
    //load values
    self.levelData = [[NSMutableArray alloc] init];
    
    //Creating a file path under iOS:
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *File = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"levelData.dat"];
    
    //Load the array
    self.levelData = [[NSMutableArray alloc] initWithContentsOfFile: File];
    
    if(self.levelData == nil)
    {
        //Array file didn't exist... create a new one
        self.levelData = [[NSMutableArray alloc] init];
        for (int i = 0; i < 2; i++) {
            
            NSMutableDictionary *myDictionary = [[NSMutableDictionary alloc] init];
            [myDictionary  setObject:[NSNumber numberWithInt:0] forKey:@"accuracy"];
            [myDictionary setObject:[NSNumber numberWithFloat:0.0] forKey:@"goal"];
            [myDictionary setObject:[NSDate date] forKey:@"date"];
            [self.levelData addObject:myDictionary];
 
        }
        [self saveLevelProgress];
    }
    
}

-(void)saveLevelProgress{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *File = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"levelData.dat"];
    [self.levelData writeToFile:File atomically:YES];
}




-(float)getLevel:(int)level{
    float l;
//    if(level<TRIALSINSTAGE)l=1.0+level*0.1;
//    else if(level<TRIALSINSTAGE*2)l=2.0+level%TRIALSINSTAGE*0.1;
//    else if(level<TRIALSINSTAGE*3)l=3.5+level%TRIALSINSTAGE*0.2;
//    else if(level<TRIALSINSTAGE*4)l=4.5+level%TRIALSINSTAGE*0.5;
//    else l=level*1.0-TRIALSINSTAGE*3+1.0;
//    
//    if(l>99999.0)l=99999.0;
    if (level==0)l=1.0;
    else {
        //l=.7+level*0.1;
        NSInteger randomNumber = arc4random() % 100;
        l=1.0+level*randomNumber/400.0;
    }
    
    return l;
}

-(float)getLevelAccuracy:(int)level{

    return .1;
}



-(void)showGameOver{

     [UIView animateWithDuration:0.8
                           delay:0.0
                         options:UIViewAnimationOptionCurveLinear
                      animations:^{

                      }
                      completion:^(BOOL finished){
                          [self restart];
                      }];

    
}



# pragma mark LABELS

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



# pragma mark 

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
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setInteger:currentLevel forKey:@"currentLevel"];
        [defaults synchronize];
        [self reportScore];
        
    }
    else{
        currentLevel=0;
        [self showGameOver];
    }
    

    
    [self saveAndSetLevel:currentLevel];
    [self loadTrialData];
    [self loadLevelProgress];
    [self animateLevelReset];

}


-(void)saveAndSetLevel:(int)level{
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:currentLevel forKey:@"currentLevel"];
    if(level>0){
        float lastSuccessfulGoal=fabs([[[self.levelData objectAtIndex:level-1] objectForKey:@"goal"] floatValue]);
        if(lastSuccessfulGoal>=best){
            best=lastSuccessfulGoal;
            [defaults setInteger:best forKey:@"best"];
        }
        [self updateHighscore];
    }
    [defaults synchronize];
    
    
    timerGoal=[self getLevel:level];
    
    
}



-(void)animateLevelReset{
    elapsed=0;
    [self positionBall:YES];
    
    [UIView animateWithDuration:0.4
                            delay:0.0
                          options:UIViewAnimationOptionCurveLinear
                       animations:^{

                           float catchZoneDiameter=[self getLevelAccuracy:currentLevel]*(startY-endY)/timerGoal*2.0;
                           catchZone.frame=CGRectMake(0, 0, catchZoneDiameter, catchZoneDiameter);
                           catchZone.center=CGPointMake(screenWidth*.5, endY);
                           
                           
                           [ball setFill:YES];
                           ball.alpha=1;
                           [ball setColor:[UIColor whiteColor]];

                           ball.frame=CGRectMake(ball.frame.origin.x, ball.frame.origin.y, catchZoneDiameter*.5, catchZoneDiameter*.5);
                           ball.center=CGPointMake(screenWidth*.5, startY);

                           
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
    
    if(showIntro){
        [self performSelector:@selector(showIntroView) withObject:self afterDelay:1.5];
    }
    
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
