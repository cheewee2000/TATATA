//
//  SurveyView.h
//  Darkball
//
//  Created by Che-Wei Wang on 1/15/15.
//
//

#import <UIKit/UIKit.h>
#import "Dots.h"
#import <Parse/Parse.h>


@interface SurveyView : UIView <UIPickerViewDelegate, UIPickerViewDataSource>
{
    #pragma mark - intro
    //UIView *intro;
    //    UILabel* introTitle;
    //    UILabel* introSubtitle;
    //    UILabel* introParagraph;
    //UILabel* credits;
    //IBOutlet UIPickerView *agePicker;
    Dots *catchZone;
    UIButton *catchZoneButton;
    PFUser *currentUser;
    

}
@property (strong, nonatomic) NSArray *ages;
@property (strong, nonatomic) IBOutlet UILabel *surveyParagraph;

@property (strong, nonatomic) IBOutlet UIPickerView *agePicker;
@property(strong, nonatomic)  IBOutlet UISegmentedControl *sex;
@property(strong, nonatomic)  IBOutlet UISegmentedControl *handed;


@property(strong, nonatomic)  IBOutlet UIButton *frequentHeadaches;
@property(strong, nonatomic)  IBOutlet UIButton *dizziness;
@property(strong, nonatomic)  IBOutlet UIButton *lossOfConsciousness;
@property(strong, nonatomic)  IBOutlet UIButton *seizures;
@property(strong, nonatomic)  IBOutlet UIButton *mentalHealth;

@property(strong, nonatomic)  IBOutlet UIButton *narcotics;
@property(strong, nonatomic)  IBOutlet UIButton *stimulants;
@property(strong, nonatomic)  IBOutlet UIButton *cocain;
@property(strong, nonatomic)  IBOutlet UIButton *lsd;
@property(strong, nonatomic)  IBOutlet UIButton *marijuana;
@property(strong, nonatomic)  IBOutlet UIButton *streetDrugs;

@property(strong, nonatomic)  IBOutlet UIButton *professional;
@property(strong, nonatomic)  IBOutlet UIButton *collegiate;
@property(strong, nonatomic)  IBOutlet UIButton *amateur;
@property(strong, nonatomic)  IBOutlet UIButton *intramural;
@property(strong, nonatomic)  IBOutlet UIButton *casual;
@property(strong, nonatomic)  IBOutlet UIButton *none;

@property(strong, nonatomic)  IBOutlet UIButton *iAgree;
@property(strong, nonatomic)  IBOutlet UIButton *iDoNotAgree;


-(void)checkboxSelected:(id)sender;



@end
