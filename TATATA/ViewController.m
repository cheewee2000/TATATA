#import "ViewController.h"
#import "Reachability.h"

#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IS_IPHONE_4 (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 480.0)
#define IS_IPHONE_5 (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 568.0)
#define IS_IPHONE_6 (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 667.0)
#define IS_IPHONE_6_PLUS (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 736.0)

#define IS_OS_7_OR_LATER    ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)

#define ARC4RANDOM_MAX 0x100000000

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
    bgColor=[UIColor colorWithRed:14/255.0 green:14/255.0 blue:15/255.0 alpha:1];
    fgColor=[UIColor colorWithRed:255/255 green:163/255.0 blue:0 alpha:1];
    flashColor=[UIColor colorWithWhite:1 alpha:1];
    strokeColor=[UIColor colorWithWhite:.8 alpha:1];

    allowBallResize=false;
    dimAlpha=.04;
    
    aTimer = [MachTimer timer];
    viewLoaded=false;
    
    [self authenticateLocalPlayer];

    self.view.backgroundColor=bgColor;
    
   #pragma mark - Persistent Variables
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if([defaults objectForKey:@"best"] == nil) best=0;
    else best = (int)[defaults integerForKey:@"best"];
    
    if([defaults objectForKey:@"showIntro1"] == nil) showIntro=true;
    else showIntro = (int)[defaults integerForKey:@"showIntro1"];

    if([defaults objectForKey:@"showSurvey"] == nil) showSurvey=true;
    else showSurvey = (int)[defaults integerForKey:@"showSurvey"];


    

#pragma mark - Ball
    startY=screenHeight*.5-190.0;
    endY=screenHeight*.5+190.0;
    
    catchZone=[[Dots alloc] initWithFrame:CGRectMake(0,0, 88, 88)];
    catchZone.center=CGPointMake(screenWidth*.5, screenHeight*.5);
    catchZone.backgroundColor = [UIColor clearColor];
    catchZone.alpha=0;
    [catchZone setColor:strokeColor];
    [catchZone setFill:NO];
    [self.view addSubview:catchZone];
    

    crosshair=[[Crosshair alloc] initWithFrame:CGRectMake(0,0, 80, 80)];
    crosshair.center=CGPointMake(catchZone.frame.size.width*.5, catchZone.frame.size.height*.5);
    crosshair.backgroundColor = [UIColor clearColor];
    crosshair.alpha=1;
    [crosshair setColor:fgColor];
    [catchZone addSubview:crosshair];
    
    
//    catchZoneCenter=[[Dots alloc] initWithFrame:CGRectMake(0,0, 8, 8)];
//    catchZoneCenter.center=catchZone.center;
//    catchZoneCenter.backgroundColor = [UIColor clearColor];
//    catchZoneCenter.alpha=0;
//    [catchZoneCenter setColor:strokeColor];
//    [catchZoneCenter setFill:YES];
//    [self.view addSubview:catchZoneCenter];
//    

    ballAlpha=.9;
    ball=[[Dots alloc] initWithFrame:CGRectMake(0, 0, 85, 85)];
    ball.center=CGPointMake(screenWidth*.5, startY);
    ball.backgroundColor = [UIColor clearColor];
    ball.alpha=0;
    [ball setColor:strokeColor];
    [ball setFill:NO];
    //ball.lineWidth=ball.frame.size.width*.5-2;
    
    [self.view addSubview:ball];
    [self.view bringSubviewToFront:ball];
    
    
    ballAnnotation=[[UILabel alloc] initWithFrame:CGRectMake(0,0,150,80)];
    ballAnnotation.backgroundColor=[UIColor clearColor];
    ballAnnotation.textAlignment=NSTextAlignmentRight;
    ballAnnotation.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:15];
    ballAnnotation.textColor=strokeColor;
    ballAnnotation.alpha=0;
    [self.view addSubview:ballAnnotation];
    dimension=[[Dimension alloc] initWithFrame:self.view.frame];
    dimension.backgroundColor=[UIColor clearColor];
    dimension.targetPosition=CGPointMake(screenWidth*.5, endY);
    dimension.lineWidth=1;
    [dimension setColor:strokeColor];
    dimension.alpha=0;
    [self.view addSubview:dimension];
    
    
    //catchzone diameter label
    catchZoneLabel=[[UICountingLabel alloc] initWithFrame:CGRectMake(screenWidth*.5,endY-115, 120, 115)];
    catchZoneLabel.backgroundColor=[UIColor clearColor];
    catchZoneLabel.textAlignment=NSTextAlignmentRight;
    catchZoneLabel.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:15];
    catchZoneLabel.textColor=strokeColor;
    //catchZoneLabel.text=@"±0.000s";
    catchZoneLabel.format = @"%.1f%%";
    catchZoneLabel.method = UILabelCountingMethodLinear;

    catchZoneLabel.alpha=0;
    
    int dh=50;
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(0.0, catchZoneLabel.frame.size.height)];
    [path addLineToPoint:CGPointMake(dh, catchZoneLabel.frame.size.height-dh)];
    [path addLineToPoint:CGPointMake(catchZoneLabel.frame.size.width, catchZoneLabel.frame.size.height-dh)];

    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.path = [path CGPath];
    shapeLayer.strokeColor = [strokeColor CGColor];
    shapeLayer.lineWidth = 0.5;
    shapeLayer.fillColor = [[UIColor clearColor] CGColor];
    [catchZoneLabel.layer addSublayer:shapeLayer];
    
    [self.view addSubview:catchZoneLabel];
    [self.view sendSubviewToBack:catchZoneLabel];


//    UIBezierPath *circle = [UIBezierPath bezierPath];
//    [circle addArcWithCenter:CGPointMake(0.0, catchZone.frame.size.height)
//                    radius:2.0
//                startAngle:0.0
//                  endAngle:M_PI * 2.0
//                 clockwise:YES];
//
//    CAShapeLayer *circleLayer = [CAShapeLayer layer];
//    circleLayer.path = [circle CGPath];
//    circleLayer.strokeColor = [[UIColor clearColor] CGColor];
//    circleLayer.fillColor = [strokeColor CGColor];
//    [catchZone.layer addSublayer:circleLayer];

    
    
    
    
    
    arc=[[Arc alloc] initWithFrame:CGRectMake(0,0, 88,88)];
    arc.backgroundColor=[UIColor clearColor];
    arc.center=ball.center;
    [self.view addSubview:arc];
    arc.alpha=dimAlpha;
    

#pragma mark - Labels

    int labelHeight=190;
    int labelOffset=110;
    
    currentScoreLabel=[[UILabel alloc] initWithFrame:CGRectMake(0,0, screenWidth, labelHeight)];
    //currentScoreLabel.center=CGPointMake(screenWidth/2.0, screenHeight/2.0);
    currentScoreLabel.center=CGPointMake(screenWidth/2.0, screenHeight*.5-labelOffset-labelHeight*.25);

    currentScoreLabel.text=@"0";
    currentScoreLabel.textAlignment = NSTextAlignmentCenter;
    currentScoreLabel.backgroundColor = [UIColor clearColor];
    currentScoreLabel.font = [UIFont fontWithName:@"HelveticaNeue-Ultralight" size:78];
    currentScoreLabel.textColor=strokeColor;
    currentScoreLabel.alpha=0;
    [self.view addSubview:currentScoreLabel];
    
    
    scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    scrollView.delegate = self;
    [scrollView setContentSize:CGSizeMake(scrollView.bounds.size.width, scrollView.bounds.size.height*2.5)];
    [self.view addSubview:scrollView];

    catchZoneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [catchZoneButton addTarget:self
                        action:@selector(buttonPressed)
              forControlEvents:UIControlEventTouchUpInside];
    catchZoneButton.frame=CGRectMake(0, 0, ball.frame.size.width, ball.frame.size.height);
    catchZoneButton.center=CGPointMake(screenWidth*.5, screenHeight*.5);
    catchZoneButton.backgroundColor=[UIColor clearColor];
    
    [scrollView addSubview:catchZoneButton];
    


    
    scoreLabel=[[UILabel alloc] initWithFrame:CGRectMake(0,0, screenWidth, labelHeight)];
    scoreLabel.center=CGPointMake(screenWidth/2.0, screenHeight*.5-labelOffset-labelHeight*.25);
    scoreLabel.text=@"0";
    scoreLabel.textAlignment = NSTextAlignmentCenter;
    scoreLabel.backgroundColor = [UIColor clearColor];
    scoreLabel.font = [UIFont fontWithName:@"HelveticaNeue-Ultralight" size:78];
    scoreLabel.textColor=strokeColor;
    scoreLabel.alpha=0;
    [scrollView addSubview:scoreLabel];
    
    UILabel* scoreLabelLabel=[[UILabel alloc] initWithFrame:CGRectMake(0,0, 100, 40)];
    //scoreLabelLabel.center=CGPointMake(screenWidth/2.0, scoreLabel.center.y+80);
    scoreLabelLabel.center=CGPointMake(scoreLabel.frame.size.width/2.0, scoreLabel.frame.size.height-scoreLabelLabel.frame.size.height+20);
    scoreLabelLabel.text=@"SCORE";
    scoreLabelLabel.textAlignment = NSTextAlignmentCenter;
    scoreLabelLabel.backgroundColor = [UIColor clearColor];
    scoreLabelLabel.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:15];
    scoreLabelLabel.textColor=strokeColor;
    scoreLabelLabel.alpha=1;
    [scoreLabel addSubview:scoreLabelLabel];
    
    UILabel* scoreLabelLine=[[UILabel alloc] initWithFrame:CGRectMake(0,0, scoreLabelLabel.frame.size.width, .5)];
    scoreLabelLine.backgroundColor = strokeColor;
    [scoreLabelLabel addSubview:scoreLabelLine];
    
    scoreGraph=[[Sparkline alloc] initWithFrame:CGRectMake(0,-20, scoreLabelLabel.frame.size.width, 20)];
    [scoreLabelLabel addSubview:scoreGraph];

    
    bestLabel=[[UILabel alloc] initWithFrame:CGRectMake(0,0, screenWidth, labelHeight)];
    bestLabel.center=CGPointMake(screenWidth*.5, screenHeight*.5+labelOffset);
    bestLabel.text=@"0";
    bestLabel.textAlignment = NSTextAlignmentCenter;
    bestLabel.backgroundColor = [UIColor clearColor];
    bestLabel.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:78];
    bestLabel.textColor=strokeColor;
    bestLabel.alpha=0;
    [scrollView addSubview:bestLabel];
    
    UILabel* bestLabelLabel=[[UILabel alloc] initWithFrame:CGRectMake(0,0, 100, 40)];
    //bestLabelLabel.center=CGPointMake(bestLabel.frame.size.width*.5, bestLabel.frame.size.height);
    bestLabelLabel.center=CGPointMake(bestLabel.frame.size.width/2.0, bestLabel.frame.size.height-bestLabelLabel.frame.size.height+20);
    bestLabelLabel.text=@"BEST";
    bestLabelLabel.textAlignment = NSTextAlignmentCenter;
    bestLabelLabel.backgroundColor = [UIColor clearColor];
    bestLabelLabel.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:15];
    bestLabelLabel.textColor=strokeColor;
    bestLabelLabel.alpha=1;
    [bestLabelLabel setUserInteractionEnabled:NO];
    [bestLabel addSubview:bestLabelLabel];
    
    UILabel* bestLabelLine=[[UILabel alloc] initWithFrame:CGRectMake(0,0, bestLabelLabel.frame.size.width, .5)];
    bestLabelLine.backgroundColor = strokeColor;
    [bestLabelLabel addSubview:bestLabelLine];
    
    
    
    labelHeight=120;
    
    accuracyLabel=[[UILabel alloc] initWithFrame:CGRectMake(0,0, screenWidth, labelHeight)];
    accuracyLabel.center=CGPointMake(screenWidth*.5, screenHeight);
    accuracyLabel.text=@"0";
    accuracyLabel.textAlignment = NSTextAlignmentCenter;
    accuracyLabel.backgroundColor = [UIColor clearColor];
    accuracyLabel.font = [UIFont fontWithName:@"HelveticaNeue-Ultralight" size:39];
    accuracyLabel.textColor=strokeColor;
    accuracyLabel.alpha=0;
    [scrollView addSubview:accuracyLabel];
    
    UILabel* accuracyLabelLabel=[[UILabel alloc] initWithFrame:CGRectMake(0,0, 100, 40)];
    accuracyLabelLabel.center=CGPointMake(accuracyLabel.frame.size.width/2.0, accuracyLabel.frame.size.height/2.0+labelHeight*.5);
    accuracyLabelLabel.text=@"ACCURACY";
    accuracyLabelLabel.textAlignment = NSTextAlignmentCenter;
    accuracyLabelLabel.backgroundColor = [UIColor clearColor];
    accuracyLabelLabel.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:15];
    accuracyLabelLabel.textColor=strokeColor;
    accuracyLabelLabel.alpha=1;
    [accuracyLabelLabel setUserInteractionEnabled:NO];
    [accuracyLabel addSubview:accuracyLabelLabel];
    
    UILabel* accuracyLabelLine=[[UILabel alloc] initWithFrame:CGRectMake(0,0, accuracyLabelLabel.frame.size.width, .5)];
    accuracyLabelLine.backgroundColor = strokeColor;
    [accuracyLabelLabel addSubview:accuracyLabelLine];
    
    
    trialCountLabel=[[UILabel alloc] initWithFrame:CGRectMake(0,0, screenWidth, labelHeight)];
    trialCountLabel.center=CGPointMake(screenWidth*.5, screenHeight+labelOffset+25);
    trialCountLabel.text=@"0";
    trialCountLabel.textAlignment = NSTextAlignmentCenter;
    trialCountLabel.backgroundColor = [UIColor clearColor];
    trialCountLabel.font = [UIFont fontWithName:@"HelveticaNeue-Ultralight" size:39];
    trialCountLabel.textColor=strokeColor;
    trialCountLabel.alpha=0;
    [scrollView addSubview:trialCountLabel];
    
    UILabel* trialCountLabelLabel=[[UILabel alloc] initWithFrame:CGRectMake(0,0, 100, 40)];
    trialCountLabelLabel.center=CGPointMake(trialCountLabel.frame.size.width/2.0, trialCountLabel.frame.size.height/2.0+labelHeight*.5);
    trialCountLabelLabel.text=@"TRIALS";
    trialCountLabelLabel.textAlignment = NSTextAlignmentCenter;
    trialCountLabelLabel.backgroundColor = [UIColor clearColor];
    trialCountLabelLabel.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:15];
    trialCountLabelLabel.textColor=strokeColor;
    trialCountLabelLabel.alpha=1;
    [trialCountLabelLabel setUserInteractionEnabled:NO];
    [trialCountLabel addSubview:trialCountLabelLabel];
    
    UILabel* trialCountLabelLine=[[UILabel alloc] initWithFrame:CGRectMake(0,0, trialCountLabelLabel.frame.size.width, .5)];
    trialCountLabelLine.backgroundColor = strokeColor;
    [trialCountLabelLabel addSubview:trialCountLabelLine];
    
    
    
    
    
    
    
#pragma mark - Buttons

    showScoreboardButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [showScoreboardButton addTarget:self
                         action:@selector(showScoreboard)
               forControlEvents:UIControlEventTouchUpInside];
    
    showScoreboardButton.titleLabel.font=[UIFont fontWithName:@"Helvetica" size:24];
    [showScoreboardButton setTitle:@"▾\U0000FE0E" forState:UIControlStateNormal];
    [showScoreboardButton setTitleColor:fgColor forState:UIControlStateNormal];
    showScoreboardButton.frame = CGRectMake(0,0, 88.0, 88.0);
    showScoreboardButton.center=CGPointMake(screenWidth*.5, screenHeight+88);
    [scrollView addSubview:showScoreboardButton];
    

    gameCenterButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [gameCenterButton addTarget:self
               action:@selector(showGlobalLeaderboard)
     forControlEvents:UIControlEventTouchUpInside];
    
    [gameCenterButton setImage:[UIImage imageNamed:@"leaderboard"] forState:UIControlStateNormal];

    [gameCenterButton setTitleColor:fgColor forState:UIControlStateNormal];
    gameCenterButton.frame = CGRectMake(screenWidth*.5-44-60, screenHeight*1.5-88, 88.0, 88.0);
    float inset=33.0f;
    [gameCenterButton setImageEdgeInsets:UIEdgeInsetsMake(inset,inset,inset,inset)];
    [scrollView addSubview:gameCenterButton];

    [self updateHighscore];
    
    
    infoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [infoButton addTarget:self
                         action:@selector(showIntroView)
               forControlEvents:UIControlEventTouchUpInside];
    
    [infoButton setImage:[[UIImage imageNamed:@"infoicon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    
    [infoButton setTitleColor:fgColor forState:UIControlStateNormal];
    infoButton.frame = CGRectMake(screenWidth*.5-44+60, screenHeight*1.5-88, 88.0, 88.0);
    [infoButton setImageEdgeInsets:UIEdgeInsetsMake(inset,inset,inset,inset)];

    infoButton.tintColor=fgColor;

    [scrollView addSubview:infoButton];

    
    
    
    
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
    intro=[[UIView alloc] initWithFrame:CGRectMake(0, screenHeight*1.5, screenWidth, screenHeight)];
    //intro.backgroundColor=bgColor;
    intro.userInteractionEnabled=NO;
    intro.backgroundColor=[UIColor clearColor];
    [scrollView addSubview:intro];
    
    int m=10;
    //int w=screenWidth-m*2.0;
    int w=280;
    //instructions

    
    introTitle=[[UILabel alloc] initWithFrame:CGRectMake(m, startY, w, 35)];
    introTitle.center=CGPointMake(screenWidth*.5, introTitle.center.y);
    introTitle.font = [UIFont fontWithName:@"DIN Condensed" size:31];
    //introTitle.adjustsFontSizeToFitWidth=YES;
    introTitle.textAlignment=NSTextAlignmentCenter;
    introTitle.text=@"BOOST YOUR BRAIN SENSORS";
    introTitle.textColor=strokeColor;
    [intro addSubview:introTitle];

    
//    introSubtitle=[[UILabel alloc] initWithFrame:CGRectMake(m, 15, w, 90)];
//    introSubtitle.font = [UIFont fontWithName:@"DIN Condensed" size:32];
//    introSubtitle.numberOfLines=3;
//    introSubtitle.text=@"TEST";
//    introSubtitle.textColor=strokeColor;
//    [intro addSubview:introSubtitle];
    
    
    NSMutableParagraphStyle *paragraphStyles = [[NSMutableParagraphStyle alloc] init];
    paragraphStyles.alignment                = NSTextAlignmentLeft;
    paragraphStyles.firstLineHeadIndent      = 0.05;    // Very IMP
    
    introParagraph=[[UILabel alloc] initWithFrame:CGRectMake(m, introTitle.frame.origin.y+introTitle.frame.size.height+10, w, 280)];
    introParagraph.center=CGPointMake(screenWidth*.5, introParagraph.center.y);
    introParagraph.font = [UIFont fontWithName:@"Helvetica" size:15];
    introParagraph.numberOfLines=20;
    introParagraph.textColor=strokeColor;
    
    NSString *stringTojustify                = @"Darkball boils down eye-hand coordination, reaction speed and timing into the most fundamental elements.\n\nCristiano Ronaldo can famously volley a corner kick in total darkness. At the root of this superpower is sensorimotor integration of advance cues. \n\nAthletic performance combines strength, technique, skill, and mental ability. Darkball is about challenging your mental ability. In this simple task, we isolate and focus on your ability to use advance cues and prediction to build up your eye-hand coordination.";
    NSDictionary *attributes                 = @{NSParagraphStyleAttributeName: paragraphStyles};
    NSAttributedString *attributedString     = [[NSAttributedString alloc] initWithString:stringTojustify attributes:attributes];
    
    introParagraph.attributedText             = attributedString;
    intro.alpha=1;
    [intro addSubview:introParagraph];
    
    
    surveyView=[[SurveyView alloc] initWithFrame:CGRectMake(0, screenHeight*1.5, screenWidth, screenHeight*5)];
    surveyView.backgroundColor=bgColor;
    surveyView.alpha=0;
    [scrollView addSubview:surveyView];
    
    
    
//    credits=[[UILabel alloc] initWithFrame:CGRectMake(m, screenHeight-55, w, 40)];
//    credits.font = [UIFont fontWithName:@"HelveticaNeue" size:9];
//    credits.numberOfLines=3;
//    credits.textAlignment=NSTextAlignmentCenter;
//    credits.text=@"TATATA";
//    //credits.textColor=[self getForegroundColor:0];
//    [intro addSubview:credits];
//    
    
//    UITapGestureRecognizer *tapGestureRecognizer3 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(buttonPressed)];
//    tapGestureRecognizer3.numberOfTouchesRequired = 1;
//    tapGestureRecognizer3.numberOfTapsRequired = 1;
//    [self.view addGestureRecognizer:tapGestureRecognizer3];
//    self.view.userInteractionEnabled=YES;
    
    
    
    if([defaults objectForKey:@"flashDuration"] == nil){
        flashDuration=0.08;
        [defaults setObject:[NSNumber numberWithFloat:flashDuration] forKey:@"flashDuration"];
    }
    else flashDuration = (float)[defaults floatForKey:@"flashDuration"];

    if([defaults objectForKey:@"accuracyStart"] == nil) {
        accuracyStart=0.125;
        [defaults setObject:[NSNumber numberWithFloat:accuracyStart] forKey:@"accuracyStart"];

    }
    else accuracyStart = (float)[defaults floatForKey:@"accuracyStart"];

    if([defaults objectForKey:@"accuracyMax"] == nil){
        accuracyMax=0.05;
        [defaults setObject:[NSNumber numberWithFloat:accuracyMax] forKey:@"accuracyMax"];
    }
    else accuracyMax = (float)[defaults floatForKey:@"accuracyMax"];

    if([defaults objectForKey:@"accuracyIncrement"] == nil){
        accuracyIncrement=0.01;
        [defaults setObject:[NSNumber numberWithFloat:accuracyIncrement] forKey:@"accuracyIncrement"];
    }
    else accuracyIncrement = (float)[defaults floatForKey:@"accuracyIncrement"];
    
    if([defaults objectForKey:@"nTrialsInStage"] == nil){
        nTrialsInStage=10.0;
        [defaults setObject:[NSNumber numberWithFloat:nTrialsInStage] forKey:@"nTrialsInStage"];
    }
    else nTrialsInStage = (float)[defaults floatForKey:@"nTrialsInStage"];
    
//    if([defaults objectForKey:@"ballDiameter"] == nil) ballDiameter=80;
//    else ballDiameter = (int)[defaults integerForKey:@"ballDiameter"];
    
    //load configs. defaults in case no internet. too slow
    NSLog(@"Getting the latest config...");
    [PFConfig getConfigInBackgroundWithBlock:^(PFConfig *config, NSError *error) {
        if (!error) {
            NSLog(@"Yay! Config was fetched from the server.");
        } else {
            NSLog(@"Failed to fetch. Using Cached Config.");
            config = [PFConfig currentConfig];
        }
        
        if(config[@"flashDuration"]!=nil){
            flashDuration=[config[@"flashDuration"]floatValue];
            [defaults setObject:[NSNumber numberWithFloat:flashDuration] forKey:@"flashDuration"];
            
            accuracyStart=[config[@"accuracyStart"]floatValue];
            [defaults setObject:[NSNumber numberWithFloat:accuracyStart] forKey:@"accuracyStart"];

            accuracyMax=[config[@"accuracyMax"]floatValue];
            [defaults setObject:[NSNumber numberWithFloat:accuracyMax] forKey:@"accuracyMax"];

            accuracyIncrement=[config[@"accuracyIncrement"]floatValue];
            [defaults setObject:[NSNumber numberWithFloat:accuracyIncrement] forKey:@"accuracyIncrement"];
            
            nTrialsInStage=[config[@"nTrialsInStage"]floatValue];
            [defaults setObject:[NSNumber numberWithFloat:nTrialsInStage] forKey:@"nTrialsInStage"];
        }
//        ballDiameter=[config[@"ballDiameter"]floatValue];
//        [defaults setObject:[NSNumber numberWithFloat:ballDiameter] forKey:@"ballDiameter"];

        
    }];
    
    trialCount=[defaults integerForKey:@"trialsPlayed"];
    trialCountLabel.text=[NSString stringWithFormat:@"%li",trialCount];
    accuracyLabel.text=[NSString stringWithFormat:@"%.3f%%",[defaults floatForKey:@"accuracyScore"]*100.0];
    
//    [[PFUser currentUser] fetchInBackgroundWithBlock:^(PFObject *object, NSError *error) {
//        if (!error){
//            trialCountLabel.text=[NSString stringWithFormat:@"%i",[_currentUser[@"trialsPlayed"] intValue]];
//            accuracyLabel.text=[NSString stringWithFormat:@"%.3f%%",[_currentUser[@"accuracyScore"]floatValue]*100.0];
//        }
//    }];
    
    //currentLevel=11;
    //[self restart];
    

    
}


#pragma mark - touch

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {


    if(trialSequence>0)[self buttonPressed];
    
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
        touched=NO;
        [self trialStopped];
    }

    

}

- (void)scrollViewDidScroll:(UIScrollView *)_scrollView{
 
    //ignore flicks
    if(trialSequence==0){
        catchZone.center=CGPointMake(catchZone.center.x, -scrollView.contentOffset.y+screenHeight*.5);
        //crosshair.center=CGPointMake(catchZone.frame.size.width*.5, catchZone.frame.size.height*.5);
        //catchZoneButton.center=CGPointMake(catchZone.center.x, -scrollView.contentOffset.y+screenHeight*.5);
        catchZoneButton.center=CGPointMake(screenWidth*.5, screenHeight*.5);

    }
    //arrow
    float d=((screenHeight*.5)-scrollView.contentOffset.y)/(float)(screenHeight*.5);
    showScoreboardButton.alpha=d;
    accuracyLabel.alpha=1.0-d;
    trialCountLabel.alpha=1.0-d;

    //bestLabel.center=CGPointMake(screenWidth*.5, screenHeight*.5+110);

   float startPos=screenHeight*.5+110;
   float endPos=screenHeight-110-47.5-startPos;
   bestLabel.center=CGPointMake(screenWidth*.5, startPos+(endPos)*(1.0-d));
//
    
    //show catchzone in introview
    if(scrollView.contentOffset.y>screenHeight*.75){
        catchZone.center=CGPointMake(catchZone.center.x, -scrollView.contentOffset.y+screenHeight*1.5+endY);
        //crosshair.center=CGPointMake(catchZone.frame.size.width*.5, catchZone.frame.size.height*.5);
        catchZoneButton.center=CGPointMake(screenWidth*.5, screenHeight*1.5+endY);
    }
    
}

- (void)scrollViewWillEndDragging:(UIScrollView *)_scrollView withVelocity: (CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
//    if(velocity.y==0){
//        if (_scrollView.contentOffset.y>screenHeight*.25) targetContentOffset->y = screenHeight*.5;
//        else targetContentOffset->y = 0;
//    }
    //[_aboutScroller setContentOffset:CGPointMake(0, 568) animated:YES];
    if (velocity.y == 0.f)
    {
        if(scrollView.contentOffset.y<screenHeight*.25){
            targetContentOffset->y = 0;
        }else if(scrollView.contentOffset.y<screenHeight*1.25){
            targetContentOffset->y = screenHeight*.5;
        }
        else{
        //    targetContentOffset->y = screenHeight*1.5;
        }
    }
    

}




#pragma mark - restart

-(void) restart{
    trialSequence=-1;
    [self performSelector:@selector(showStartScreen) withObject:self afterDelay:0.8];
}

-(void)showStartScreen{
    currentLevel=0;
	
    [UIView animateWithDuration:0.4
                          delay:0.0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         //catchZone.alpha=0;
                         catchZoneCenter.alpha=0;
                         crosshair.alpha=0;

                         [scrollView setContentOffset:CGPointMake(0, 0)];

                         ball.alpha=0;
                         ballAnnotation.alpha=0;
                         dimension.alpha=0;
                         
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
                                              [self setCatchZoneDiameter];

                                              catchZone.alpha=1;
                                              catchZone.center=CGPointMake(screenWidth*.5,screenHeight*.5);
                                              catchZoneCenter.center=catchZone.center;
                                              catchZoneButton.center=catchZone.center;
                                              crosshair.frame=catchZone.frame;
                                              crosshair.center=CGPointMake(catchZone.frame.size.width*.5, catchZone.frame.size.height*.5);

                                              showScoreboardButton.center=CGPointMake(screenWidth*.5, screenHeight-44);

                                          }
                                          completion:^(BOOL finished){
                                              [self showLabels:YES];

                                              //[self animateLevelReset];
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

    if(trialSequence<0)return;

    
    //dismiss intro view
    if(scrollView.contentOffset.y>=screenHeight*1.5){
        [scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
        return;
    }
    
    
    //START
    if(trialSequence==0){
        touched=NO;
        trialSequence=-1;
        [self showLabels:NO];
        
        if(currentLevel==0) [self hideStartScreen];
        else [self startTrialSequence];
        
    }
    //STOP
    else if(trialSequence==1){
        touched=YES;
        [self stop];
    }
    

    
}

-(void)hideStartScreen{

    [self animateLevelReset];
    [self setLevel:currentLevel];

    [UIView animateWithDuration:0.4
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         [self setCatchZoneDiameter];
                     }
                     completion:^(BOOL finished){
        [UIView animateWithDuration:0.4
                              delay:0.2
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             //catchZone.alpha=0;
                             catchZoneCenter.alpha=0;
                             crosshair.alpha=0;
                             showScoreboardButton.center=CGPointMake(screenWidth*.5, screenHeight+88);

                         }
                         completion:^(BOOL finished){
                             //[catchZone setFill:NO];
                             //[catchZone setColor:strokeColor];
                             trialSequence=-1;
                             
                             
                             [UIView animateWithDuration:0.2
                                                   delay:0.0
                                                 options:UIViewAnimationOptionCurveEaseOut
                                              animations:^{
                                                  //catchZone.alpha=.5;
                                                  catchZoneCenter.alpha=1;
                                              }
                                              completion:^(BOOL finished){
                                                  [UIView animateWithDuration:0.2
                                                                        delay:0.0
                                                                      options:UIViewAnimationOptionCurveEaseOut
                                                                   animations:^{
                                                                       [catchZone bringSubviewToFront:crosshair];
                                                                       crosshair.alpha=1;
                                                                       midMarkL.alpha=.3;
                                                                       midMarkR.alpha=.3;
                                                                   }
                                                                   completion:^(BOOL finished){
                                                                       [UIView animateWithDuration:0.2
                                                                                             delay:0.0
                                                                                           options:UIViewAnimationOptionCurveEaseOut
                                                                                        animations:^{
                                                                                            arc.alpha=.3;
                                                                                            [self setCatchZoneDiameter];//in case catchzone is in wrong place

                                                                                        }
                                                                                        completion:^(BOOL finished){
                                                                                            trialSequence=-1;

                                                                                            //reset scoreboard
                                                                                            [self updateHighscore];
                                                                                            [self startTrialSequence];
                                                                                        }];
                                                                   }];
                                              }];
                         }];
                }];
}


-(void)stop{
    elapsed=[aTimer elapsedSeconds];
    trialSequence=-1;
    
    
    if([self isAccurate]){
        if([self getAccuracyFloat]<.9) [ball setColor:[UIColor colorWithRed:0 green:.78 blue:0 alpha:1]];//green
        else [ball setColor:[UIColor yellowColor]];
        [ball setNeedsDisplay];
        
        if([[NSUserDefaults standardUserDefaults] boolForKey:@"hideExample"] && currentLevel==0)currentLevel=1;

        currentScoreLabel.text=[NSString stringWithFormat:@"%i",currentLevel];
        
        if(currentLevel>0){
            [UIView animateWithDuration:0.2
                                  delay:0.0
                                options:UIViewAnimationOptionCurveLinear
                             animations:^{
                                 currentScoreLabel.alpha=1;
                             }
                             completion:^(BOOL finished){
                                 
                             }];

        }
        
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
        
        //hide example trial
        if(currentLevel>3){
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setBool:YES forKey:@"hideExample"];
            [defaults synchronize];
        }else if(currentLevel==0){
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setBool:NO forKey:@"hideExample"];
            [defaults synchronize];
        }
        
    }
    
    [self positionBall:NO];
    ball.alpha=ballAlpha;
    
    
    
    dimension.ballPosition=ball.center;
    dimension.dimLineOffsetX=catchZone.frame.size.width*.5+8;
    dimension.alpha=1;
    [dimension setNeedsDisplay];
    
    float annotationHeight= ballAnnotation.frame.size.height;
    float annotationWidth= ballAnnotation.frame.size.width;
    float midpointToTargetY=endY+(ball.center.y-endY)/2.0;
    
    ballAnnotation.frame=CGRectMake(ball.center.x-annotationWidth-dimension.dimLineOffsetX-15, midpointToTargetY-annotationHeight*.5, annotationWidth, annotationHeight);
    
    float diff=elapsed-timerGoal;
    if(diff<0) ballAnnotation.text=[NSString stringWithFormat:@"%5fs", diff];
    else ballAnnotation.text=[NSString stringWithFormat:@"+%5fs", diff];
   
    ballAnnotation.alpha=1;
    

    
    
    
    [self.view.layer removeAllAnimations];
}

-(void)saveTrialData{
    

    
    NSDate* localDateTime = [NSDate dateWithTimeInterval:[[NSTimeZone systemTimeZone] secondsFromGMT] sinceDate:[NSDate date]];

    
    PFConfig * config = [PFConfig currentConfig];
    NSString *configVersion=config[@"configVersion"];
    
    
    //save to disk
    NSMutableDictionary *myDictionary = [[NSMutableDictionary alloc] init];
    float diff=elapsed-timerGoal;
    [myDictionary setObject:[NSNumber numberWithFloat:diff] forKey:@"offset"];
    [myDictionary setObject:[NSNumber numberWithFloat:timerGoal] forKey:@"goal"];
    [myDictionary setObject:[NSNumber numberWithFloat:trialDelay] forKey:@"trialDelay"];
    [myDictionary setObject:[NSNumber numberWithFloat:flashT] forKey:@"flashT"];
    [myDictionary setObject:[NSNumber numberWithFloat:[currentTrial[@"d1"]floatValue]] forKey:@"d1"];
    [myDictionary setObject:[NSNumber numberWithFloat:[currentTrial[@"d2"]floatValue]] forKey:@"d2"];
    [myDictionary setObject:[NSNumber numberWithFloat:[currentTrial[@"duration"]floatValue]] forKey:@"duration"];

    [myDictionary setObject:[NSNumber numberWithInteger:currentLevel] forKey:@"level"];
    [myDictionary setObject:[NSNumber numberWithBool:([self isAccurate])? YES:NO] forKey:@"win"];
    [myDictionary setObject:localDateTime forKey:@"date"];
    [myDictionary setObject:[NSTimeZone localTimeZone].abbreviation forKey:@"timezone"];
    [myDictionary setObject:[NSNumber numberWithBool: (touched)? YES:NO ] forKey:@"didTouch"];
    //if(touched){
    [myDictionary setObject:[NSNumber numberWithFloat: touchX ] forKey:@"touchX"];
    [myDictionary setObject:[NSNumber numberWithFloat: touchY ] forKey:@"touchY"];
    [myDictionary setObject:[NSNumber numberWithFloat: touchLength ] forKey:@"touchLength"];
    if(configVersion!=nil)[myDictionary setObject:configVersion forKey:@"configVersion"];

    //}
    [self.allTrialData addObject:myDictionary];
    [self.allTrialData writeToFile:allTrialDataFile atomically:YES];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    //save to parse
    if([_currentUser[@"iAgree"] boolValue]){
        PFObject *pObject = [PFObject objectWithClassName:@"results"];
        pObject[@"offset"] = [NSNumber numberWithFloat:diff];
        pObject[@"goal"] = [NSNumber numberWithFloat:timerGoal];
        pObject[@"flashT"]=[NSNumber numberWithFloat:flashT];
        pObject[@"trialDelay"]=[NSNumber numberWithFloat:trialDelay];
        pObject[@"trials"]=currentTrial;
        pObject[@"level"]=[NSNumber numberWithInteger:currentLevel];
        pObject[@"win"]=([self isAccurate])? @YES:@NO;
        pObject[@"date"]=localDateTime;
        pObject[@"timezone"]=[NSString stringWithFormat:@"%@",[NSTimeZone localTimeZone].abbreviation];
        pObject[@"didTouch"]=(touched)? @YES:@NO;
        //if(touched){
        pObject[@"touchX"]=[NSNumber numberWithFloat: touchX ];
        pObject[@"touchY"]=[NSNumber numberWithFloat: touchY ];
        pObject[@"touchLength"]=[NSNumber numberWithFloat:touchLength];
        pObject[@"configVersion"]=configVersion;

        //}
        NSString*uuid;
        if([defaults stringForKey:@"uuid"] == nil){
            uuid=CFBridgingRelease(CFUUIDCreateString(NULL, CFUUIDCreate(NULL)));
            [defaults setObject:uuid forKey:@"uuid"];
            [defaults synchronize];
        }
        else uuid =[defaults stringForKey:@"uuid"];
        pObject[@"uuid"]=uuid;
        
        if(_currentUser!=nil) pObject[@"user"]=_currentUser;
        
        PFInstallation *currentInstallation = [PFInstallation currentInstallation];
        if(currentInstallation!=nil)pObject[@"installation"]=currentInstallation;
        
        [pObject saveEventually];
    }

    //[_currentUser incrementKey:@"trialsPlayed"];
    trialCount++;
    trialCountLabel.text=[NSString stringWithFormat:@"%li",trialCount];
    [defaults setObject:[NSNumber numberWithLong:trialCount] forKey:@"trialsPlayed"];
    _currentUser[@"trialsPlayed"]=[NSNumber numberWithLong:trialCount];

    
    _currentUser[@"best"]=[NSNumber numberWithFloat:best];
    
    float d2Duration=[currentTrial[@"duration"]floatValue]*[currentTrial[@"d2"]floatValue];
    accuracyScore=(d2Duration-fabs(diff))/(float)d2Duration;
    accuracyScore=([_currentUser[@"accuracyScore"] floatValue]+accuracyScore)/2.0;
    
    _currentUser[@"accuracyScore"]=[NSNumber numberWithFloat:accuracyScore];
    accuracyLabel.text=[NSString stringWithFormat:@"%.3f%%",accuracyScore*100.0];
    [defaults setObject:[NSNumber numberWithFloat:[_currentUser[@"accuracyScore"] floatValue] ] forKey:@"accuracyScore"];
    [defaults synchronize];
    
    [_currentUser saveEventually];
    
 
    
    
}


-(void)showIntroView{
    [scrollView setContentOffset:CGPointMake(0, screenHeight*1.5) animated:YES];
    
    if(showIntro){
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"showIntro1"];
        showIntro=false;
        
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"showSurvey"];
        showSurvey=true;
        [[NSUserDefaults standardUserDefaults] synchronize];
        
    }
    else if(showSurvey){
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"showSurvey"];
        showSurvey=false;
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
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

-(void)showScoreboard{
    
    [scrollView setContentOffset:CGPointMake(0, screenHeight*.5) animated:YES];
    
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

    touchX=0;
    touchY=0;
    touchLength=0;
    
    //double initDelay=.4;
    double flashDelay=timerGoal*(float)flashT;
    //float flashDuration=[config[@"flashDuration"]floatValue];
    float ballDim=.8;
    
    [ball setColor:strokeColor];
    [ball setNeedsDisplay];
    
    trialDelay =.8+((double)arc4random() / ARC4RANDOM_MAX)*1.4;
    float objAlpha=.4;

    //ambient lights
    UIColor *bg=bgColor;
    if( currentLevel==0  && [[NSUserDefaults standardUserDefaults] boolForKey:@"hideExample"] == NO){
        CGFloat hue, saturation, brightness, alpha ;
        BOOL ok = [ bgColor getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha ] ;
        if ( !ok ) {
            // handle error
        }
        brightness=.4;
        
        bg = [ UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:alpha ] ;
        objAlpha=1.0;
    }
    
    if(currentLevel<=1)trialDelay=1.6;
    if(currentLevel%(int)nTrialsInStage==0 && currentLevel!=0)trialDelay+=1.6;
    
    [UIView animateWithDuration:.8
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         
                         //dim background
                         self.view.backgroundColor=bg;
                         catchZone.alpha=.5;
                         midMarkL.alpha=objAlpha;
                         midMarkR.alpha=objAlpha;
                         arc.alpha=objAlpha;
                         
                         //dim ball after example level
                         ball.alpha=0;
                         [ball setNeedsDisplay];
                         
                         //hide annotation
                         ballAnnotation.alpha=0;
                         dimension.alpha=0;
                         
                         if(currentLevel==0  && [[NSUserDefaults standardUserDefaults] boolForKey:@"hideExample"] == NO){
                             ball.alpha=1.0;
                         }

                     }
                     completion:^(BOOL finished){
                         
                         //set catchzone and show dims
                         [UIView animateWithDuration:0.4
                                               delay:0.0
                                             options:UIViewAnimationOptionCurveEaseOut
                                          animations:^{
                                              if(currentLevel%(int)nTrialsInStage==0 && currentLevel!=0){
                                                  catchZoneLabel.alpha=1;
                                                  catchZone.alpha=1;
                                              }
                                          }
                                          completion:^(BOOL finished){
                                              

                                              float catchZoneDuration=0;
                                              if(currentLevel%(int)nTrialsInStage==0 && currentLevel!=0){
                                                [catchZoneLabel countFrom:[self getLevelAccuracy:currentLevel-1]/timerGoal*200.0  to:[self getLevelAccuracy:currentLevel]/timerGoal*200.0 withDuration:.2f];
                                                catchZoneDuration=.4;
                                              }
                                              
                                              
                                              [UIView animateWithDuration:catchZoneDuration
                                                                    delay:0.0
                                                                  options:UIViewAnimationOptionCurveEaseOut
                                                               animations:^{
                                                                   [self setCatchZoneDiameter];
                                                               }
                                                               completion:^(BOOL finished){
                                                                   [UIView animateWithDuration:0.4
                                                                                         delay:0.4
                                                                                       options:UIViewAnimationOptionCurveEaseOut
                                                                                    animations:^{
                                                                                        catchZoneLabel.alpha=0;
                                                                                        catchZone.alpha=.5;
                                                                                    }
                                                                                    completion:^(BOOL finished){
                                                     
                                                                                    }];
                                                               }];
                                          }];

                         
                         
                         
                         
                     }];
    
    
    
    CFTimeInterval currentTime = CACurrentMediaTime();
    CFTimeInterval currentTimeInSuperLayer = [self.view.layer convertTime:currentTime fromLayer:nil];


    //first flash
    [CATransaction begin];
    CABasicAnimation *startFlash = [CABasicAnimation animationWithKeyPath:@"opacity"];
    [startFlash setDuration:flashDuration];
    [startFlash setFromValue:[NSNumber numberWithFloat:(currentLevel>0)?0.0f:ballDim]];
    [startFlash setToValue:[NSNumber numberWithFloat:1.0f]];
    [startFlash setBeginTime:currentTimeInSuperLayer+trialDelay];
    [CATransaction setCompletionBlock:^{
        [aTimer start];
        
        if(currentLevel==0 && [[NSUserDefaults standardUserDefaults] boolForKey:@"hideExample"] == NO)
        {
            ball.alpha=ballDim;
            trialSequence=-2;
            [self updateBall];
        }
        else [self performSelector:@selector(updateBall) withObject:self afterDelay:timerGoal];

        //float msOff=[aTimer elapsedSeconds];
        //NSLog(@"startFlash accuracy: %f sec",msOff);
        if(currentLevel>0 || [[NSUserDefaults standardUserDefaults] boolForKey:@"hideExample"] )ball.center=CGPointMake(screenWidth*.5, startY+(endY-startY)*flashT);
    }];
    [ball.layer addAnimation:startFlash forKey:@"startFlash"];

    //second flash
    CABasicAnimation *midFlash = [CABasicAnimation animationWithKeyPath:@"opacity"];
    [midFlash setDuration:flashDuration];
    [midFlash setFromValue:[NSNumber numberWithFloat:(currentLevel>0)?0.0f:ballDim]];
    [midFlash setToValue:[NSNumber numberWithFloat:1.0f]];
    [midFlash setBeginTime:currentTimeInSuperLayer+trialDelay+flashDelay];
    [CATransaction setCompletionBlock:^{
        if(currentLevel==0 && [[NSUserDefaults standardUserDefaults] boolForKey:@"hideExample"] == NO) ball.alpha=ballDim;
        trialSequence=1;
        //float msOff=[aTimer elapsedSeconds]-flashDelay;
        //NSLog(@"midFlash   accuracy: %f sec",msOff);
    }];
    [ball.layer addAnimation:midFlash forKey:@"midFlash"];
    [midMarkLine.layer addAnimation:midFlash forKey:@"midFlash"];

    
    
    [CATransaction commit];
    
    
}

-(void)positionBall:(BOOL)animate{
    CGPoint p;
    if(elapsed==0)p=CGPointMake(screenWidth*.5, startY);
    else p=CGPointMake(screenWidth*.5, startY+(endY-startY)*(float)elapsed/(float)timerGoal );
    if(animate){
        [UIView animateWithDuration:0.6
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseOut
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
    //float l=[currentTrial[@"d1"] floatValue]+[currentTrial[@"d2"] floatValue];
    float l=[currentTrial[@"duration"] floatValue] * [currentTrial[@"d2"] floatValue]+[currentTrial[@"duration"] floatValue] * [currentTrial[@"d1"] floatValue];

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
    //float f=[currentTrial[@"d1"] floatValue]/([currentTrial[@"d1"] floatValue]+[currentTrial[@"d2"] floatValue]);
    
    float f=[currentTrial[@"d1"] floatValue]/([currentTrial[@"d1"] floatValue]+[currentTrial[@"d2"] floatValue]);
    return f;
}

-(float)getLevelAccuracy:(int)level{
    
    //return .2;
    
    //return timerGoal*.1;
    if(level<=0 && [[NSUserDefaults standardUserDefaults] boolForKey:@"hideExample"]==NO )return timerGoal*accuracyStart;
    //int stage=(5+level)/10.0;
    //float accuracy=accuracyStart-accuracyIncrement*level/25.0;
    float accuracy=accuracyStart-accuracyIncrement*floor(level/nTrialsInStage)*nTrialsInStage;

    if(accuracy<accuracyMax)accuracy=accuracyMax;
    float levelAccuracy=timerGoal*accuracy;
    return levelAccuracy;
    
    
}






# pragma mark LABELS
-(void)showLabels:(BOOL) show{
    
    
    [UIView animateWithDuration:0.4
                          delay:0.0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         if(show){
                             scrollView.alpha=1;

                             scoreLabel.alpha=1;

                             if(![bestLabel.text isEqualToString:@"0"]) bestLabel.alpha=1;
                             else{
                                 scoreLabel.alpha=0;
                                 bestLabel.alpha=0;
                             }
                         }
                         else{
                             scrollView.alpha=0;
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
        [self performSelector:@selector(animateLevelReset) withObject:self afterDelay:0.3];
        
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
    //insequence
    //currentTrial=[trialArray objectAtIndex: ([_currentUser[@"trialsPlayed"] integerValue]+level)%[trialArray count]];
    
    //random
    currentTrial=[trialArray objectAtIndex: arc4random()%[trialArray count]];

    timerGoal=[self getLevel:level];
    flashT=[self getFlashT:level];
}



-(void)animateLevelReset{
    elapsed=0;
    //[self positionBall:YES];

    [UIView animateWithDuration:0.4
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         //set ball position
                         ball.center=CGPointMake(screenWidth*.5, startY);
                         [ball setColor:strokeColor];
                         
                         if(currentLevel>1)ball.alpha=dimAlpha;
                         [ball setNeedsDisplay];
                         currentScoreLabel.alpha=0;
                         
//                         if(currentLevel%(int)nTrialsInStage==0 && currentLevel!=0){
//                             catchZoneLabel.alpha=1;
//                             catchZone.alpha=1;
//                         }
                     }
                     completion:^(BOOL finished){

//                         float catchZoneDuration=0;
//                         if(currentLevel%(int)nTrialsInStage==0 && currentLevel!=0)catchZoneDuration=.8;
//                         
//            
//                         [UIView animateWithDuration:catchZoneDuration
//                                        delay:0.0
//                                      options:UIViewAnimationOptionCurveEaseOut
//                                   animations:^{
//                                       [self setCatchZoneDiameter];
//                                       //ball.alpha=0;
//                                       //[ball setNeedsDisplay];
//                                   }
//                                   completion:^(BOOL finished){
                                       [UIView animateWithDuration:0.4
                                                             delay:0.0
                                                           options:UIViewAnimationOptionCurveEaseOut
                                                        animations:^{
                                                            catchZoneLabel.alpha=0;
                                                            catchZone.alpha=.5;
                                                            //set mid markers
                                                            midMarkL.center=CGPointMake(midMarkL.center.x, startY+(endY-startY)*flashT);
                                                            midMarkR.center=CGPointMake(midMarkR.center.x, startY+(endY-startY)*flashT);
                                                            midMarkLine.center=CGPointMake(midMarkLine.center.x, startY+(endY-startY)*flashT);
                                                        }
                                                        completion:^(BOOL finished){
                                                            //autostart next level
                                                            if(currentLevel>0){
                                                                trialSequence=0;
                                                                [self buttonPressed];
                                                            }
                                                            
                                                        }];
                                   }];
                     //}];


}

-(void)setCatchZoneDiameter{
    float catchZoneDiameter=[self getLevelAccuracy:currentLevel]*(endY-startY)/timerGoal*2.0;
    
    catchZone.frame=CGRectMake(0, 0, catchZoneDiameter, catchZoneDiameter);
    //catchZoneLabel.frame=CGRectMake(catchZone.frame.size.width*.5, catchZone.frame.size.height*.5-catchZoneLabel.frame.size.height,catchZoneLabel.frame.size.width,catchZoneLabel.frame.size.height);
    ball.frame=CGRectMake(0,0, catchZoneDiameter*.9, catchZoneDiameter*.9);
    ball.center=CGPointMake(screenWidth*.5, startY);
    ball.lineWidth=ball.frame.size.width*.33-.75;
    

    catchZone.center=CGPointMake(screenWidth*.5, endY);
    catchZoneCenter.center=catchZone.center;
    crosshair.frame=catchZone.frame;
    crosshair.center=CGPointMake(catchZone.frame.size.width*.5, catchZone.frame.size.height*.5);

    [catchZone setNeedsDisplay];
    
    arc.frame=CGRectMake(0,0, catchZoneDiameter,catchZoneDiameter);
    arc.center=ball.center;
    [arc setNeedsDisplay];
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

    currentLevel=0;
    trialSequence=-1;
    [self setLevel:currentLevel];
    [self restart];

    
    Reachability *reach = [Reachability reachabilityForInternetConnection];
    
    NetworkStatus netStatus = [reach currentReachabilityStatus];
    if (netStatus == NotReachable) {
        NSLog(@"No internet connection!");
    } else {
        NSLog(@"netstatus: %ld",netStatus);
    }
    
    
    if(showIntro){
        [self performSelector:@selector(showIntroView) withObject:self afterDelay:1.5];
    }
    else
        if (netStatus != NotReachable) {//there is internet!
            if(showSurvey){
                surveyView.alpha=1;
                [scrollView setContentSize:CGSizeMake(scrollView.bounds.size.width, 2400 +screenHeight*1.5 )];
                [self performSelector:@selector(showIntroView) withObject:self afterDelay:1.5];
            }else{
                surveyView.alpha=1;
                [scrollView setContentSize:CGSizeMake(scrollView.bounds.size.width, 2400 +screenHeight*1.5)];
            }
        }

   [super viewDidAppear:animated];
}


-(void)getTrialSequence{
    NSArray *libPath = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    trialArrayDataFile=[[libPath objectAtIndex:0] stringByAppendingPathComponent:@"trialSequence.dat"];

    //temporary load
    [self loadLocalTrialSequence];

    
    PFQuery *query = [PFQuery queryWithClassName:@"trials"];
    [query addAscendingOrder:@"index"];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *results, NSError *error) {
        if(!error){
            NSLog(@"updated trial sequence");
            trialArray = [NSMutableArray arrayWithArray: results];
            
            //save to disk
            for( int i=0; i<trialArray.count; i++){
                PFObject *t=[trialArray objectAtIndex:i];

                NSDictionary *trial=[[NSDictionary alloc] initWithObjectsAndKeys:t[@"d1"],@"d1", t[@"d2"],@"d2", t[@"duration"],@"duration",nil];
                [trialArray replaceObjectAtIndex:i withObject:trial];
                
            }
            [trialArray writeToFile:trialArrayDataFile atomically:YES];
        }
        else{
            NSLog(@"load trial sequence fron disk");
            [self loadLocalTrialSequence];
        }
    
    }];
    
}

-(void)loadLocalTrialSequence{
    
    //load locally
    trialArray = [[NSMutableArray alloc] initWithContentsOfFile: trialArrayDataFile];

    //if local file doesn't exists, make one
    if(trialArray == nil){
        trialArray = [[NSMutableArray alloc] init];
        
        [trialArray addObject:[[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithFloat:1],@"d1", [NSNumber numberWithFloat:1],@"d2",[NSNumber numberWithFloat:0.6],@"duration",  nil]];
        
        [trialArray addObject:[[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithFloat:1],@"d1", [NSNumber numberWithFloat:1.5],@"d2",[NSNumber numberWithFloat:0.6],@"duration",  nil]];

        [trialArray writeToFile:trialArrayDataFile atomically:YES];
    
    }
    
    
     
}

-(void)logIn{
    [PFUser enableAutomaticUser];
    
    _currentUser = [PFUser currentUser];
    if (_currentUser) {
        // do stuff with the user
        _currentUser[@"best"]=[NSNumber numberWithFloat:best];
        [_currentUser saveEventually];
        
    } else {
        // show the signup or login screen
        [PFAnonymousUtils logInWithBlock:^(PFUser *user, NSError *error) {
            if (error) {
                NSLog(@"Anonymous login failed.");
            } else {
                NSLog(@"Anonymous user logged in.");
                _currentUser = [PFUser currentUser];

                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                NSString*uuid;
                if([defaults stringForKey:@"uuid"] == nil){
                    uuid=CFBridgingRelease(CFUUIDCreateString(NULL, CFUUIDCreate(NULL)));
                    [defaults setObject:uuid forKey:@"uuid"];
                    [defaults synchronize];
                }
                else uuid =[defaults stringForKey:@"uuid"];
                _currentUser[@"uuid"]=uuid;
                
                PFInstallation *currentInstallation = [PFInstallation currentInstallation];
                _currentUser[@"installation"]=currentInstallation;
//                currentInstallation[@"user"]=currentUser;
//                [currentInstallation saveEventually];
                
                [_currentUser saveEventually];

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
