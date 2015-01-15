//
//  SurveyView.m
//  Darkball
//
//  Created by Che-Wei Wang on 1/15/15.
//
//

#import "SurveyView.h"
#import "ViewController.h"

@implementation SurveyView


- (id)initWithFrame:(CGRect)theFrame {
    self = [super initWithFrame:theFrame];
    if (self) {
        //startFrame=self.frame;
        
        self.clipsToBounds=NO;
        
        int m=10;
        int w=300;


        //ViewController *dele = (ViewController *)[[UIApplication sharedApplication] delegate];
//        float screenHeight=[[UIScreen mainScreen] bounds].size.height;
        float screenWidth=[[UIScreen mainScreen] bounds].size.width;

//        float startY=screenHeight*.5-200;
//        //float endY=screenHeight*.5+200;
//        
//        UIColor * strokeColor=[UIColor colorWithWhite:.8 alpha:1];

        
//        introTitle=[[UILabel alloc] initWithFrame:CGRectMake(m, startY, w, 35)];
//        introTitle.center=CGPointMake(screenWidth*.5, introTitle.center.y);
//        introTitle.font = [UIFont fontWithName:@"DIN Condensed" size:32];
//        introTitle.textAlignment=NSTextAlignmentCenter;
//        introTitle.text=@"FOR SCIENCE!";
//        introTitle.textColor=strokeColor;
//        [self addSubview:introTitle];
//        
//
//        
//        NSMutableParagraphStyle *paragraphStyles = [[NSMutableParagraphStyle alloc] init];
//        paragraphStyles.alignment                = NSTextAlignmentJustified;
//        paragraphStyles.firstLineHeadIndent      = 0.05;    // Very IMP
//        
//        introParagraph=[[UILabel alloc] initWithFrame:CGRectMake(m, introTitle.frame.origin.y+introTitle.frame.size.height+10, w, 200)];
//        introParagraph.center=CGPointMake(screenWidth*.5, introParagraph.center.y);
//        introParagraph.font = [UIFont fontWithName:@"DIN Condensed" size:15];
//        introParagraph.numberOfLines=20;
//        introParagraph.textColor=strokeColor;
//        
//        NSString *stringTojustify                = @"Please answer the questions below to contribute your game play data towards science.\n\nYour answers are anonymous.  Your participation is not required to play, but science could use your help!";
//        NSDictionary *attributes                 = @{NSParagraphStyleAttributeName: paragraphStyles};
//        NSAttributedString *attributedString     = [[NSAttributedString alloc] initWithString:stringTojustify attributes:attributes];
//        
//        introParagraph.attributedText             = attributedString;
//        [self addSubview:introParagraph];
        
        UIView *survey = [[[NSBundle mainBundle] loadNibNamed:@"SurveyView" owner:self options:nil] firstObject];
        survey.frame=CGRectMake(0, 0, survey.frame.size.width, survey.frame.size.height);
        survey.center=CGPointMake(screenWidth*.5, survey.center.y);
        //survey.backgroundColor=[UIColor clearColor];
        
        [self addSubview:survey];
        
        NSMutableArray *numArray = [[NSMutableArray alloc] init];
        for(int i=0; i<120; i++){
            [numArray addObject:[NSString stringWithFormat:@"%i",i]];
        }
        
        _ages = numArray;
        [_agePicker selectRow:18 inComponent:0 animated:NO];
        //change picker selectionline color
        ((UIView *)[_agePicker.subviews objectAtIndex:1]).backgroundColor = [UIColor grayColor];
        ((UIView *)[_agePicker.subviews objectAtIndex:2]).backgroundColor = [UIColor grayColor];
        
        [_checkbox addTarget:self action:@selector(checkboxSelected:) forControlEvents:UIControlEventTouchUpInside];

        
    }
    return self;
}

#pragma mark - picker
- (NSInteger)numberOfComponentsInPickerView:
(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView
numberOfRowsInComponent:(NSInteger)component
{

    return _ages.count;
}

//-(NSString *) pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
//    return _ages[row];
//}

- (NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSString *title = _ages[row];
    NSAttributedString *attString = [[NSAttributedString alloc] initWithString:title attributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];

    
    return attString;
    
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 300, 37)];
    
    if (component == 0) {
        
        //label.font=[UIFont boldSystemFontOfSize:22];
        label.textAlignment = NSTextAlignmentCenter;
        label.backgroundColor = [UIColor clearColor];
        NSString *title = _ages[row];
        NSAttributedString *attString = [[NSAttributedString alloc] initWithString:title attributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
        label.attributedText=attString;
        
        //label.text = [NSString stringWithFormat:@"%@", [_ages objectAtIndex:row]];
        //label.font=[UIFont boldSystemFontOfSize:22];
        
    }
    return label;
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row
      inComponent:(NSInteger)component
{
//    float rate = [_exchangeRates[row] floatValue];
//    float dollars = [_dollarText.text floatValue];
//    float result = dollars * rate;
//    
//    NSString *resultString = [[NSString alloc] initWithFormat:
//                              @"%.2f USD = %.2f %@", dollars, result,
//                              _countryNames[row]];
//    _resultLabel.text = resultString;
}

-(IBAction)textFieldReturn:(id)sender
{
    [sender resignFirstResponder];
}

#pragma mark - checkboxes

-(void)checkboxSelected:(id)sender{
    
    
    if([_checkbox isSelected]==YES)
    {
        [_checkbox setSelected:NO];
    }
    else{
        [_checkbox setSelected:YES];
    }
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/



@end
