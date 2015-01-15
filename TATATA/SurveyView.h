//
//  SurveyView.h
//  Darkball
//
//  Created by Che-Wei Wang on 1/15/15.
//
//

#import <UIKit/UIKit.h>
#import "Dots.h"

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

}
@property (strong, nonatomic) NSArray *ages;
@property (strong, nonatomic) IBOutlet UIPickerView *agePicker;

@property(strong, nonatomic)  IBOutlet UIButton *checkbox;
-(void)checkboxSelected:(id)sender;



@end
