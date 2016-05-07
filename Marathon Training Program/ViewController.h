//
//  ViewController.h
//  Marathon Training Program
//
//  Created by Leah Zulas on 4/28/16.
//  Copyright © 2016 Leah Zulas. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

- (IBAction)sendToCalendar:(UIButton *)sender;

@property (strong, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (strong, nonatomic) IBOutlet UISegmentedControl *longRunPicker;
@property (strong, nonatomic) IBOutlet UISegmentedControl *mediumRunPicker;
@property (strong, nonatomic) IBOutlet UISegmentedControl *midWeekSegControl;
- (IBAction)midWeekSunday:(UIButton *)sender;
- (IBAction)midWeekMonday:(UIButton *)sender;
- (IBAction)midWeekTuesday:(UIButton *)sender;
- (IBAction)midWeekWednesday:(UIButton *)sender;
- (IBAction)midWeekThursday:(UIButton *)sender;
- (IBAction)midWeekFriday:(UIButton *)sender;
- (IBAction)midWeekSaturday:(UIButton *)sender;
@property (strong, nonatomic) IBOutlet UIButton *midWeekSundayClicked;
@property (strong, nonatomic) IBOutlet UIButton *midWeekMondayClicked;
@property (strong, nonatomic) IBOutlet UIButton *midWeekTuesdayClicked;
@property (strong, nonatomic) IBOutlet UIButton *midWeekWednesdayClicked;
@property (strong, nonatomic) IBOutlet UIButton *midWeekThursdayClicked;
@property (strong, nonatomic) IBOutlet UIButton *midWeekFridayClicked;
@property (strong, nonatomic) IBOutlet UIButton *midWeekSaturdayClicked;

@property (strong, nonatomic) NSNumber* levelAccepted;
@property (strong, nonatomic) IBOutlet UILabel *midweekLabel;
-(int)nextDatePickedByButtons;
-(NSDate*)findFirstDayFromMarathon: (long) weekdayOfSegment;


@end

