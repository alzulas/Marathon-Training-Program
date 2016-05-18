//
//  ViewController.m
//  Marathon Training Program
//
//  Created by Leah Zulas on 4/28/16.
//  Copyright © 2016 Leah Zulas. All rights reserved.
//

#import "ViewController.h"
#import <EventKit/EventKit.h>
#import <EventKitUI/EventKitUI.h>

@interface ViewController ()

//@property (strong, nonatomic) NSArray* descriptionMidWeekRun3;
//NSArray *yesArray = [NSArray arrayWithObjects:yes0, yes1, yes2, nil];
//@property (strong, nonatomic) NSMutableArray* dates;
//@property (strong, nonatomic) NSMutableArray* weekdays;
@property int weekdays;
@property BOOL* weekbools;

@property BOOL midWeekSundayClickedBool;
@property BOOL midWeekMondayClickedBool;
@property BOOL midWeekTuesdayClickedBool;
@property BOOL midWeekWednesdayClickedBool;
@property BOOL midWeekThursdayClickedBool;
@property BOOL midWeekFridayClickedBool;
@property BOOL midWeekSaturdayClickedBool;
@property BOOL matchingDays;



@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    _midWeekSundayClickedBool = false;
    _midWeekMondayClickedBool = false;
    _midWeekTuesdayClickedBool = false;
    _midWeekWednesdayClickedBool = false;
    _midWeekThursdayClickedBool = false;
    _midWeekFridayClickedBool = false;
    _midWeekSaturdayClickedBool = false;
    _matchingDays = false;
    NSLog(@"I started properly");
   //NSMutableArray* weekdays[7];
    _weekdays = 0;
    if(_levelAccepted == [NSNumber numberWithInt:3]){
        _midweekLabel.text = @"Pick 4 days of the week for your midweek runs";
    }
    
    //BOOL weekbools[7];
    //BOOL[7] weekbools;
    
    
    //[_midWeekSegControl setTitleTextAttributes:attributes forState:UIControlStateNormal];
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                [UIFont boldSystemFontOfSize:17], NSFontAttributeName,
                                [UIColor whiteColor], NSForegroundColorAttributeName,
                                nil];
    [_midWeekSegControl setTitleTextAttributes:attributes forState:UIControlStateNormal];
    NSDictionary *highlightedAttributes = [NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];
    [_midWeekSegControl setTitleTextAttributes:highlightedAttributes forState:UIControlStateHighlighted];
    //_midWeekSundayClicked.contentEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(int)nextDatePickedByButtons{
    int midWeek = 0;
    if(_midWeekSundayClickedBool){
        midWeek = 0;
        _midWeekSundayClickedBool = false;
    }else if (_midWeekMondayClickedBool){
        midWeek = 1;
        _midWeekMondayClickedBool = false;
    }else if (_midWeekTuesdayClickedBool){
        midWeek = 2;
        _midWeekTuesdayClickedBool = false;
    }else if (_midWeekWednesdayClickedBool){
        midWeek = 3;
        _midWeekWednesdayClickedBool = false;
    }else if (_midWeekThursdayClickedBool){
        midWeek = 4;
        _midWeekThursdayClickedBool = false;
    }else if (_midWeekFridayClickedBool){
        midWeek = 5;
        _midWeekFridayClickedBool = false;
    }else if (_midWeekSaturdayClickedBool){
        midWeek = 6;
        _midWeekSaturdayClickedBool = false;
    }
    return midWeek;
}

-(NSDate*)findFirstDayFromMarathon: (long) weekdayOfSegment{
    NSDateComponents *comps = [_datePicker.calendar components:NSCalendarUnitWeekday fromDate:_datePicker.date]; //we need to figure out what day the date picker picked. When is the marathon
    int weekdayOfMarathon = [comps weekday];
    NSLog(@"day of marathon %d", weekdayOfMarathon);
    NSLog(@"day of picker %ld", weekdayOfSegment);
    NSDate* firstDay = [[NSDate alloc] init];
    
    NSTimeInterval secondsPerWeek = (7 * 24 * 60 * 60)-60;
    NSTimeInterval secondsPerDay = 24 * 60 * 60;
    
    if(weekdayOfMarathon == weekdayOfSegment+1){ //So if it is the marathon day, when.
        firstDay = [_datePicker.date dateByAddingTimeInterval:-secondsPerWeek];
    }else if (weekdayOfMarathon > weekdayOfSegment+1){ //If the next one is to the right in a 7 day week
        NSTimeInterval secondsBeforeMarathon = (secondsPerDay * (weekdayOfMarathon-(weekdayOfSegment+1)));
        firstDay = [_datePicker.date dateByAddingTimeInterval:-secondsBeforeMarathon];
    }else{//to the left in a 7 day week
        NSTimeInterval secondsAfterMarathon = secondsPerWeek - (secondsPerDay * ((weekdayOfSegment+1) - weekdayOfMarathon));
        firstDay = [_datePicker.date dateByAddingTimeInterval:-secondsAfterMarathon];
    }

    return firstDay;
}


- (IBAction)sendToCalendar:(UIButton *)sender {
    EKEventStore *eventstore = [[EKEventStore alloc] init];
    if([eventstore respondsToSelector:@selector(requestAccessToEntityType:completion:)])
    {
        [eventstore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error)
         {
             if(granted)
             {
                 //To understand this data you have to understand a marathon training program.
                 //You run 5 times a week, there is one long run and one long-ish run, then 3 midweek runs
                 //Usually it's t-w-th midweek runs like... 3 miles, then 5 miles, then 3 miles, two short runs and one mid
                 //Then sa-su are sorta long, then long, like 8 miles then 10 miles.
                 //For people to be able to pick their own days for these runs, I have saved the different kinds of runs in 5 arrays
                 //This way if they pick monday for their first midweek run, I just push that array into all the Mondays of the calendar.
                 //And so on with the rest.
                 //They all have descriptions of their runs that go with them too. And this gets put into the notes field.
                 NSTimeInterval secondsPerWeek = (7 * 24 * 60 * 60)-60;
                 NSTimeInterval secondsPerDay = 24 * 60 * 60;
                 
                 NSArray* longRuns;
                 NSArray* midLongRuns;
                 NSArray* midWeekRun1;
                 NSArray* midWeekRun2;
                 NSArray* midWeekRun3;
                 
                 NSArray* longRunsNovice = [NSArray arrayWithObjects: @"Cross", @"Cross", @"Cross", @"Cross", @"Cross", @"Cross", @"Cross", @"Cross", @"Run 13 miles", @"Cross", @"Cross", @"Cross", @"Cross", @"Cross", @"Cross", @"Cross", @"Cross", nil];
                 NSArray* midLongRunsNovice = [NSArray arrayWithObjects: @"Run 2 miles", @"Run 8 miles", @"Run 12 miles", @"Run 20 miles", @"Run 12 miles", @"Run 19 miles", @"Run 13 miles", @"Run 18 miles", @"Run 17 miles", @"REST DAY", @"Run 15 miles", @"Run 14 miles", @"Run 9 miles", @"Run 12 miles", @"Run 11 miles", @"Run 6 miles", @"Run 9 miles", @"Run 8 miles", nil];
                 NSArray* midWeekRun1Novice = [NSArray arrayWithObjects: @"Run 3 miles", @"Run 4 miles", @"Run 5 miles", @"Run 5 miles", @"Run 5 miles", @"Run 5 miles", @"Run 5 miles", @"Run 5 miles", @"Run 4 miles", @"Run 4 miles", @"Run 4 miles", @"Run 4 miles", @"Run 3 miles", @"Run 3 miles", @"Run 3 miles", @"Run 3 miles", @"Run 3 miles", @"Run 3 miles", nil];
                 NSArray* midWeekRun2Novice = [NSArray arrayWithObjects: @"Run 2 miles", @"Run 3 miles", @"Run 4 miles", @"Run 5 miles", @"Run 8 miles", @"Run 5 miles", @"Run 8 miles", @"Run 8 miles", @"Run 8 miles", @"Run 7 miles", @"Run 7 miles", @"Run 7 miles", @"Run 6 miles", @"Run 6 miles", @"Run 6 miles", @"Run 5 miles", @"Run 5 miles", @"Run 5 miles", nil];
                 NSArray* midWeekRun3Novice = [NSArray arrayWithObjects: @"REST DAY!", @"Run 4 miles", @"Run 5 miles", @"Run 5 miles", @"Run 5 miles", @"Run 5 miles", @"Run 5 miles", @"Run 5 miles", @"Run 4 miles", @"Run 4 miles", @"Run 4 miles", @"Run 4 miles", @"Run 3 miles", @"Run 3 miles", @"Run 3 miles", @"Run 3 miles", @"Run 3 miles", @"Run 3 miles", nil];
                
                 NSArray* longRunsIntermediate = [NSArray arrayWithObjects: @"Run 8 miles", @"Run 12 miles", @"Run 20 miles", @"Run 12 miles", @"Run 20 miles", @"Run 13 miles", @"Run 18 miles", @"Run 17 miles", @"Run 13 miles", @"Run 15 miles", @"Run 14 miles", @"Run 9 miles", @"Run 12 miles", @"Run 11 miles", @"Run 6 miles", @"Run 9 miles", @"Run 8 miles", nil];
                 NSArray* midLongRunsIntermediate = [NSArray arrayWithObjects: @"Run 2 miles", @"Run 3 miles", @"Run 4 miles", @"Run 5 miles", @"Run 8 miles", @"Run 5 miles", @"Run 8 miles", @"Run 8 miles", @"Run 8 miles", @"REST DAY", @"Run 7 miles", @"Run 7 miles", @"Run 6 miles", @"Run 6 miles", @"Run 6 miles", @"Run 5 miles", @"Run 5 miles", @"Run 5 miles", nil];
                 NSArray* midWeekRun1Intermediate = [NSArray arrayWithObjects: @"Run 3 miles", @"Run 4 miles", @"Run 5 miles", @"Run 5 miles", @"Run 5 miles", @"Run 5 miles", @"Run 5 miles", @"Run 5 miles", @"Run 4 miles", @"Run 4 miles", @"Run 4 miles", @"Run 4 miles", @"Run 3 miles", @"Run 3 miles", @"Run 3 miles", @"Run 3 miles", @"Run 3 miles", @"Run 3 miles", nil];
                 NSArray* midWeekRun2Intermediate = [NSArray arrayWithObjects: @"Run 4 miles", @"Run 5 miles", @"Run 6 miles", @"Run 8 miles", @"Run 5 miles", @"Run 8 miles", @"Run 5 miles", @"Run 8 miles", @"Run 8 miles", @"Run 5 miles", @"Run 7 miles", @"Run 7 miles", @"Run 5 miles", @"Run 6 miles", @"Run 6 miles", @"Run 5 miles", @"Run 5 miles", @"Run 5 miles", nil];
                 NSArray* midWeekRun3Intermediate = [NSArray arrayWithObjects: @"REST DAY!", @"Run 4 miles", @"Run 5 miles", @"Run 5 miles", @"Run 5 miles", @"Run 5 miles", @"Run 5 miles", @"Run 5 miles", @"Run 4 miles", @"Run 4 miles", @"Run 4 miles", @"Run 4 miles", @"Run 3 miles", @"Run 3 miles", @"Run 3 miles", @"Run 3 miles", @"Run 3 miles", @"Run 3 miles", nil];
                 
                 NSArray* longRunsAdvanced = [NSArray arrayWithObjects: @"Run 8 miles", @"Run 12 miles", @"Run 20 miles", @"Run 12 miles", @"Run 20 miles", @"Run 12 miles", @"Run 20 miles", @"Run 19 miles", @"Run 13 miles", @"Run 17 miles", @"Run 16 miles", @"Run 10 miles", @"Run 14 miles", @"Run 13 miles", @"Run 8 miles", @"Run 11 miles", @"Run 10 miles", nil];
                 NSArray* midLongRunsAdvanced = [NSArray arrayWithObjects: @"Run 2 miles", @"Run 4 miles", @"Run 4 miles", @"Run 10 miles", @"Run 6 miles", @"Run 10 miles", @"Run 6 miles", @"Run 10 miles", @"Run 9 miles", @"REST DAY", @"Run 8 miles", @"Run 8 miles", @"Run 7 miles", @"Run 7 miles", @"Run 6 miles", @"Run 6 miles", @"Run 5 miles", @"Run 5 miles", nil];
                 NSArray* midWeekRun1Advanced = [NSArray arrayWithObjects: @"Run 3 miles", @"Run 4 miles", @"Run 5 miles", @"Run 5 miles", @"Run 5 miles", @"Run 4 miles", @"Run 4 miles", @"Run 4 miles", @"Run 3 miles", @"Run 3 miles", @"Run 3 miles", @"Run 3 miles", @"Run 3 miles", @"Run 3 miles", @"Run 3 miles", @"Run 3 miles", @"Run 3 miles", @"Run 3 miles", nil];
                 NSArray* midWeekRun2Advanced = [NSArray arrayWithObjects: @"Run 4x400", @"Run 6 miles", @"Run 8 miles", @"Run 10 miles", @"Run 6 miles", @"Run 10 miles", @"Run 6 miles", @"Run 10 miles", @"Run 9 miles", @"Run 9 miles", @"Run 8 miles", @"Run 8 miles", @"Run 7 miles", @"Run 7 miles", @"Run 6 miles", @"Run 6 miles", @"Run 5 miles", @"Run 5 miles", nil];
                 NSArray* midWeekRun3Advanced = [NSArray arrayWithObjects: @"Run 2 miles", @"Run 4 miles", @"Run 5 miles", @"Run 5 miles", @"Run 5 miles", @"Run 5 miles", @"Run 5 miles", @"Run 5 miles", @"Run 4 miles", @"Run 4 miles", @"Run 4 miles", @"Run 4 miles", @"Run 3 miles", @"Run 3 miles", @"Run 3 miles", @"Run 3 miles", @"Run 3 miles", @"Run 3 miles", nil];
                 NSArray* midWeekRun4Advanced = [NSArray arrayWithObjects: @"REST DAY!", @"30 tempo", @"6 x hill", @"8 x 800", @"45 tempo", @"7 x hill", @"7 x 800", @"45 tempo", @"6 x hill", @"6 x 800", @"40 tempo", @"5 x hill", @"5 x 800", @"35 tempo", @"4 x hill", @"4 x 800", @"30 tempo", @"3 x hill", nil];
                 
                 NSArray* descriptionLongRun;
                 NSArray* descriptionMidLongRuns;
                 NSArray* descriptionMidWeekRun1;
                 NSArray* descriptionMidWeekRun2;
                 NSArray* descriptionMidWeekRun3;
                 
                 NSArray* descriptionLongRunNovice = [NSArray arrayWithObjects:@"Cross Training today! Anything but running!", @"Cross Training today! Anything but running!", @"Cross Training today! Anything but running!", @"Cross Training today! Anything but running!", @"Cross Training today! Anything but running!", @"Cross Training today! Anything but running!", @"Cross Training today! Anything but running!", @"Cross Training today! Anything but running!", @"Run 13 miles at race pace. This week you might schedule a half marathon to take part in!", @"Cross Training today! Anything but running!", @"Cross Training today! Anything but running!", @"Cross Training today! Anything but running!", @"Cross Training today! Anything but running!", @"Cross Training today! Anything but running!", @"Cross Training today! Anything but running!", @"Cross Training today! Anything but running!", @"Cross Training today! Anything but running!", nil];
                 NSArray* descriptionMidLongRunsNovice = [NSArray arrayWithObjects:@"Run 2 miles at steady pace", @"Run 8 miles at steady pace", @"Run 12 miles at steady pace", @"Run 20 miles at steady pace", @"Run 12 miles at steady pace", @"Run 19 miles at steady pace", @"Run 13 miles at steady pace", @"Run 18 miles at steady pace", @"Run 17 miles at steady pace", @"Take a break today and rest. No working out today!", @"Run 15 miles at steady pace", @"Run 14 miles at steady pace", @"Run 9 miles at steady pace", @"Run 12 miles at steady pace", @"Run 11 miles at steady pace", @"Run 6 miles at steady pace", @"Run 9 miles at steady pace", @"Run 8 miles at steady pace", nil];
                 NSArray* descriptionMidWeekRun1Novice = [NSArray arrayWithObjects:@"Run 3 miles at steady pace", @"Run 4 miles at steady pace", @"Run 5 miles at steady pace", @"Run 5 miles at steady pace", @"Run 5 miles at steady pace", @"Run 5 miles at steady pace", @"Run 5 miles at steady pace", @"Run 5 miles at steady pace", @"Run 4 miles at steady pace", @"Run 4 miles at steady pace", @"Run 4 miles at steady pace", @"Run 4 miles at steady pace", @"Run 3 miles at steady pace", @"Run 3 miles at steady pace", @"Run 3 miles at steady pace", @"Run 3 miles at steady pace", @"Run 3 miles at steady pace", @"Run 3 miles at steady pace", nil];
                 NSArray* descriptionMidWeekRun2Novice = [NSArray arrayWithObjects:@"Run 2 miles at steady pace", @"Run 3 miles at steady pace", @"Run 4 miles at steady pace", @"Run 5 miles at steady pace", @"Run 8 miles at steady pace", @"Run 5 miles at steady pace", @"Run 8 miles at steady pace", @"Run 8 miles at steady pace", @"Run 8 miles at steady pace", @"Run 7 miles at steady pace", @"Run 7 miles at steady pace", @"Run 7 miles at steady pace", @"Run 6 miles at steady pace", @"Run 6 miles at steady pace", @"Run 6 miles at steady pace", @"Run 5 miles at steady pace", @"Run 5 miles at steady pace", @"Run 5 miles at steady pace", nil];
                 NSArray* descriptionMidWeekRun3Novice = [NSArray arrayWithObjects:@"Take a break today and rest. No working out today!", @"Run 4 miles at steady pace", @"Run 5 miles at steady pace", @"Run 5 miles at steady pace", @"Run 5 miles at steady pace", @"Run 5 miles at steady pace", @"Run 5 miles at steady pace", @"Run 5 miles at steady pace", @"Run 4 miles at steady pace", @"Run 4 miles at steady pace", @"Run 4 miles at steady pace", @"Run 4 miles at steady pace", @"Run 3 miles at steady pace", @"Run 3 miles at steady pace", @"Run 3 miles at steady pace", @"Run 3 miles at steady pace", @"Run 3 miles at steady pace", @"Run 3 miles at steady pace", nil];
                 
                 NSArray* descriptionLongRunIntermediate = [NSArray arrayWithObjects:@"Run 8 miles at race pace", @"Run 12 miles at race pace", @"Run 20 miles at race pace", @"Run 12 miles at race pace", @"Run 20 miles at race pace", @"Run 13 miles at race pace", @"Run 18 miles at race pace", @"Run 17 miles at race pace", @"Run 13 miles at race pace. This week you might schedule a half marathon to take part in!", @"Run 15 miles at race pace", @"Run 14 miles at race pace", @"Run 9 miles at race pace", @"Run 12 miles at race pace", @"Run 11 miles at race pace", @"Run 6 miles at race pace", @"Run 9 miles at race pace", @"Run 8 miles at race pace", nil];
                 NSArray* descriptionMidLongRunsIntermediate = [NSArray arrayWithObjects:@"Run 2 miles at steady pace", @"Run 3 miles at steady pace", @"Run 4 miles at race pace", @"Run 5 miles at race pace", @"Run 8 miles at steady pace", @"Run 5 miles at race pace", @"Run 8 miles at race pace", @"Run 8 miles at steady pace", @"Run 8 miles at race pace", @"Take a break today and rest. No working out today!", @"Run 7 miles at steady pace", @"Run 7 miles at race pace", @"Run 6 miles at race pace", @"Run 6 miles at steady pace", @"Run 6 miles at race pace", @"Run 5 miles at race pace", @"Run 5 miles at steady pace", @"Run 5 miles at race pace", nil];
                 NSArray* descriptionMidWeekRun1Intermediate = [NSArray arrayWithObjects:@"Run 3 miles at steady pace", @"Run 4 miles at steady pace", @"Run 5 miles at steady pace", @"Run 5 miles at steady pace", @"Run 5 miles at steady pace", @"Run 5 miles at steady pace", @"Run 5 miles at steady pace", @"Run 5 miles at steady pace", @"Run 4 miles at steady pace", @"Run 4 miles at steady pace", @"Run 4 miles at steady pace", @"Run 4 miles at steady pace", @"Run 3 miles at steady pace", @"Run 3 miles at steady pace", @"Run 3 miles at steady pace", @"Run 3 miles at steady pace", @"Run 3 miles at steady pace", @"Run 3 miles at steady pace", nil];
                 NSArray* descriptionMidWeekRun2Intermediate = [NSArray arrayWithObjects:@"Run 4 miles at steady pace", @"Run 5 miles at steady pace", @"Run 6 miles at steady pace", @"Run 8 miles at steady pace", @"Run 5 miles at steady pace", @"Run 8 miles at steady pace", @"Run 5 miles at steady pace", @"Run 8 miles at steady pace", @"Run 8 miles at steady pace", @"Run 5 miles at steady pace", @"Run 7 miles at steady pace", @"Run 7 miles at steady pace", @"Run 5 miles at steady pace", @"Run 6 miles at steady pace", @"Run 6 miles at steady pace", @"Run 5 miles at steady pace", @"Run 5 miles at steady pace", @"Run 5 miles at steady pace", nil];
                 NSArray* descriptionMidWeekRun3Intermediate = [NSArray arrayWithObjects:@"Take a break today and rest. No working out today!", @"Run 4 miles at steady pace", @"Run 5 miles at steady pace", @"Run 5 miles at steady pace", @"Run 5 miles at steady pace", @"Run 5 miles at steady pace", @"Run 5 miles at steady pace", @"Run 5 miles at steady pace", @"Run 4 miles at steady pace", @"Run 4 miles at steady pace", @"Run 4 miles at steady pace", @"Run 4 miles at steady pace", @"Run 3 miles at steady pace", @"Run 3 miles at steady pace", @"Run 3 miles at steady pace", @"Run 3 miles at steady pace", @"Run 3 miles at steady pace", @"Run 3 miles at steady pace", nil];
                 
                 NSArray* descriptionLongRunAdvanced = [NSArray arrayWithObjects:@"Run 8 miles at race pace", @"Run 12 miles at race pace", @"Run 20 miles at race pace", @"Run 12 miles at race pace", @"Run 20 miles at race pace", @"Run 12 miles at race pace", @"Run 20 miles at race pace", @"Run 19 miles at race pace", @"Run 13 miles at race pace. This week you might schedule a half marathon to take part in!", @"Run 17 miles at race pace", @"Run 16 miles at race pace", @"Run 10 miles at race pace", @"Run 14 miles at race pace", @"Run 13 miles at race pace", @"Run 8 miles at race pace", @"Run 11 miles at race pace", @"Run 10 miles at race pace", nil];
                 NSArray* descriptionMidLongRunsAdvanced = [NSArray arrayWithObjects:@"Run 2 miles at steady pace", @"Run 4 miles at steady pace", @"Run 4 miles at race pace", @"Run 10 miles at race pace", @"Run 6 miles at steady pace", @"Run 10 miles at race pace", @"Run 6 miles at race pace", @"Run 10 miles at steady pace", @"Run 9 miles at race pace", @"Take a break today and rest. No working out today!", @"Run 8 miles at steady pace", @"Run 8 miles at race pace", @"Run 7 miles at race pace", @"Run 7 miles at steady pace", @"Run 6 miles at race pace", @"Run 6 miles at race pace", @"Run 5 miles at steady pace", @"Run 5 miles at race pace", nil];
                 NSArray* descriptionMidWeekRun1Advanced = [NSArray arrayWithObjects:@"Run 3 miles at steady pace", @"Run 4 miles at steady pace", @"Run 5 miles at steady pace", @"Run 5 miles at steady pace", @"Run 5 miles at steady pace", @"Run 4 miles at steady pace", @"Run 4 miles at steady pace", @"Run 4 miles at steady pace", @"Run 3 miles at steady pace", @"Run 3 miles at steady pace", @"Run 3 miles at steady pace", @"Run 3 miles at steady pace", @"Run 3 miles at steady pace", @"Run 3 miles at steady pace", @"Run 3 miles at steady pace", @"Run 3 miles at steady pace", @"Run 3 miles at steady pace", @"Run 3 miles at steady pace", nil];
                 NSArray* descriptionMidWeekRun2Advanced = [NSArray arrayWithObjects:@"Run 4 x 400 intervals", @"Run 6 miles at steady pace", @"Run 8 miles at steady pace", @"Run 10 miles at steady pace", @"Run 6 miles at steady pace", @"Run 10 miles at steady pace", @"Run 6 miles at steady pace", @"Run 10 miles at steady pace", @"Run 9 miles at steady pace", @"Run 9 miles at steady pace", @"Run 8 miles at steady pace", @"Run 8 miles at steady pace", @"Run 7 miles at steady pace", @"Run 7 miles at steady pace", @"Run 6 miles at steady pace", @"Run 6 miles at steady pace", @"Run 5 miles at steady pace", @"Run 5 miles at steady pace", nil];
                 NSArray* descriptionMidWeekRun3Advanced = [NSArray arrayWithObjects:@"Run 2 miles today steady", @"Run 4 miles at steady pace", @"Run 5 miles at steady pace", @"Run 5 miles at steady pace", @"Run 5 miles at steady pace", @"Run 5 miles at steady pace", @"Run 5 miles at steady pace", @"Run 5 miles at steady pace", @"Run 4 miles at steady pace", @"Run 4 miles at steady pace", @"Run 4 miles at steady pace", @"Run 4 miles at steady pace", @"Run 3 miles at steady pace", @"Run 3 miles at steady pace", @"Run 3 miles at steady pace", @"Run 3 miles at steady pace", @"Run 3 miles at steady pace", @"Run 3 miles at steady pace", nil];
                 NSArray* descriptionMidWeekRun4Advanced = [NSArray arrayWithObjects:@"Take a break today and rest. No working out today!", @"30 minute tempo run", @"Run 6 x hill intervals", @"Run 8 x 800 intervals", @"45 minute tempo run", @"Run 7 x hill intervals", @"Run 7 x 800 intervals", @"45 minute tempo run", @"Run 6 x hill intervals", @"Run 6 x 800 intervals", @"40 minute tempo run", @"Run 5 x hill intervals", @"Run 5 x 800 intervals", @"35 minute tempo run", @"Run 4 x hill intervals", @"Run 4 x 800 intervals", @"30 minute tempo run", @"Run 3 x hill intervals", nil];
                 
                 //Need to set up which level of runs you selected, so that it fills the correct information in for the level you picked. Filling the arrays that vary with the arrays of information that is set.
                 if (_levelAccepted == [NSNumber numberWithInt:1]) {
                     longRuns = longRunsNovice;
                     midLongRuns = midLongRunsNovice;
                     midWeekRun1 = midWeekRun1Novice;
                     midWeekRun2 = midWeekRun2Novice;
                     midWeekRun3 = midWeekRun3Novice;
                     descriptionLongRun = descriptionLongRunNovice;
                     descriptionMidLongRuns = descriptionMidLongRunsNovice;
                     descriptionMidWeekRun1 = descriptionMidWeekRun1Novice;
                     descriptionMidWeekRun2 = descriptionMidWeekRun2Novice;
                     descriptionMidWeekRun3 = descriptionMidWeekRun3Novice;
                 }else if (_levelAccepted == [NSNumber numberWithInt:2]){
                     longRuns = longRunsIntermediate;
                     midLongRuns = midLongRunsIntermediate;
                     midWeekRun1 = midWeekRun1Intermediate;
                     midWeekRun2 = midWeekRun2Intermediate;
                     midWeekRun3 = midWeekRun3Intermediate;
                     descriptionLongRun = descriptionLongRunIntermediate;
                     descriptionMidLongRuns = descriptionMidLongRunsIntermediate;
                     descriptionMidWeekRun1 = descriptionMidWeekRun1Intermediate;
                     descriptionMidWeekRun2 = descriptionMidWeekRun2Intermediate;
                     descriptionMidWeekRun3 = descriptionMidWeekRun3Intermediate;
                 }else if (_levelAccepted == [NSNumber numberWithInt:3]){
                     longRuns = longRunsAdvanced;
                     midLongRuns = midLongRunsAdvanced;
                     midWeekRun1 = midWeekRun1Advanced;
                     midWeekRun2 = midWeekRun2Advanced;
                     midWeekRun3 = midWeekRun3Advanced;
                     descriptionLongRun = descriptionLongRunAdvanced;
                     descriptionMidLongRuns = descriptionMidLongRunsAdvanced;
                     descriptionMidWeekRun1 = descriptionMidWeekRun1Advanced;
                     descriptionMidWeekRun2 = descriptionMidWeekRun2Advanced;
                     descriptionMidWeekRun3 = descriptionMidWeekRun3Advanced;
                 }
                 
                 //checking to make sure that none of the days from the days are matching. You don't want long runs and midlong runs on the same day. That would suck.
                 if((_midWeekSundayClickedBool && _longRunPicker.selectedSegmentIndex == 0) || (_midWeekSundayClickedBool && _mediumRunPicker.selectedSegmentIndex == 0)){
                     _matchingDays = true;
                 }else if((_midWeekMondayClickedBool && _longRunPicker.selectedSegmentIndex == 1) || (_midWeekMondayClickedBool && _mediumRunPicker.selectedSegmentIndex == 1)){
                     _matchingDays = true;
                 }else if((_midWeekTuesdayClickedBool && _longRunPicker.selectedSegmentIndex == 2) || (_midWeekTuesdayClickedBool && _mediumRunPicker.selectedSegmentIndex == 2)){
                     _matchingDays = true;
                 }else if((_midWeekWednesdayClickedBool && _longRunPicker.selectedSegmentIndex == 3) || (_midWeekWednesdayClickedBool && _mediumRunPicker.selectedSegmentIndex == 3)){
                     _matchingDays = true;
                 }else if((_midWeekThursdayClickedBool && _longRunPicker.selectedSegmentIndex == 4) || (_midWeekThursdayClickedBool && _mediumRunPicker.selectedSegmentIndex == 4)){
                     _matchingDays = true;
                 }else if((_midWeekFridayClickedBool && _longRunPicker.selectedSegmentIndex == 5) || (_midWeekThursdayClickedBool && _mediumRunPicker.selectedSegmentIndex == 5)){
                     _matchingDays = true;
                 }else if((_midWeekSaturdayClickedBool && _longRunPicker.selectedSegmentIndex == 6) || (_midWeekSaturdayClickedBool && _mediumRunPicker.selectedSegmentIndex == 6)){
                     _matchingDays = true;
                     NSLog(@"set match");
                 }else{
                     _matchingDays = false;
                 }
                 
                 //So, now, so long as you have 3 week day run times picked, or four if you're advanced
                 if(_weekdays ==3 || (_weekdays == 4 && _levelAccepted == [NSNumber numberWithInt:3])){
                     if(!(_longRunPicker.selectedSegmentIndex==_mediumRunPicker.selectedSegmentIndex) && !(_matchingDays)){//And you don't have any overlapping days
                         NSString* thisRun;
                         int i = 0;
                         
                         NSDateComponents *comps = [_datePicker.calendar components:NSCalendarUnitWeekday fromDate:_datePicker.date]; //we need to figure out what day the date picker picked. When is the marathon
                         int weekdayOfMarathon = [comps weekday];
                         NSLog(@"%d", weekdayOfMarathon);
                         NSLog(@"%ld", _longRunPicker.selectedSegmentIndex);
                         NSDate* firstDay = [[NSDate alloc] init];
                         //Then you need to calculate when the first, whatever day of the week you picked for your long run is, so you can start posting to the calendar from that date.

                         firstDay = [self findFirstDayFromMarathon:_longRunPicker.selectedSegmentIndex];
                         
                         //filling in the calendar with the information for the long runs. This is the part that actually does the posting.
                         for (thisRun in longRuns)
                         {
                             EKEvent *event  = [EKEvent eventWithEventStore: eventstore];
                             event.title = thisRun;
                             event.notes = [descriptionLongRun objectAtIndex: i];
                             //NSDate *date = [dateFormat dateFromString:@"2016-04-29 11:59:00"];
                             event.startDate = firstDay;
                             event.endDate = [firstDay dateByAddingTimeInterval:3600];
                             event.availability = EKEventAvailabilityFree;
                         
                             [event setCalendar:[eventstore defaultCalendarForNewEvents]];
                             NSError *err;
                             [eventstore saveEvent:event span:EKSpanThisEvent error:&err];
                             i++;
                             
                             //tomorrow = [today dateByAddingTimeInterval: secondsPerDay]
                             NSDate* newDate = [firstDay dateByAddingTimeInterval:-secondsPerWeek-60];
                             //[firstDay release];
                             firstDay = newDate;
                         }
                         
                         //Now, to do it all again. But for the medium long run.
                         
                         //figuring out what day to start on coming from marathon day.
                         i = 0;

                         firstDay = [self findFirstDayFromMarathon:_mediumRunPicker.selectedSegmentIndex];
                         
                         //posting to the calendar
                         for (thisRun in midLongRuns)
                         {
                             EKEvent *event  = [EKEvent eventWithEventStore: eventstore];
                             event.title = thisRun;
                             event.notes = [descriptionMidLongRuns objectAtIndex: i];
                             //NSDate *date = [dateFormat dateFromString:@"2016-04-29 11:59:00"];
                             event.startDate = firstDay;
                             event.endDate = [firstDay dateByAddingTimeInterval:3600];
                             event.availability = EKEventAvailabilityFree;
                             
                             [event setCalendar:[eventstore defaultCalendarForNewEvents]];
                             NSError *err;
                             [eventstore saveEvent:event span:EKSpanThisEvent error:&err];
                             i++;
                             
                             //tomorrow = [today dateByAddingTimeInterval: secondsPerDay]
                             NSDate* newDate = [firstDay dateByAddingTimeInterval:-secondsPerWeek-60];
                             //[firstDay release];
                             firstDay = newDate;
                         }
                         
                         
                         //This part takes the weird set of buttons that look like a segmented control and finds the next button selected from left to right so we know what day of the week we care about.
                         int firstMidWeek = 0;
                         firstMidWeek = [self nextDatePickedByButtons];
                         firstDay = [self findFirstDayFromMarathon:firstMidWeek];
                         
                         //figuring out what day to start on coming from marathon day.
                         i = 0;
                         
                         //post to calendar
                         for (thisRun in midWeekRun1)
                         {
                             EKEvent *event  = [EKEvent eventWithEventStore: eventstore];
                             event.title = thisRun;
                             event.notes = [descriptionMidWeekRun1 objectAtIndex: i];
                             //NSDate *date = [dateFormat dateFromString:@"2016-04-29 11:59:00"];
                             event.startDate = firstDay;
                             event.endDate = [firstDay dateByAddingTimeInterval:3600];
                             event.availability = EKEventAvailabilityFree;
                             
                             [event setCalendar:[eventstore defaultCalendarForNewEvents]];
                             NSError *err;
                             [eventstore saveEvent:event span:EKSpanThisEvent error:&err];
                             i++;
                             
                             //tomorrow = [today dateByAddingTimeInterval: secondsPerDay]
                             NSDate* newDate = [firstDay dateByAddingTimeInterval:-secondsPerWeek-60];
                             //[firstDay release];
                             firstDay = newDate;
                         }
                         
                         //rinse repeat. I need to make these into functions somewhere.
                         int secondMidWeek = 0;
                         
                         secondMidWeek = [self nextDatePickedByButtons];
                         firstDay = [self findFirstDayFromMarathon:secondMidWeek];
                         
                         i = 0;
                         
                         for (thisRun in midWeekRun2)
                         {
                             EKEvent *event  = [EKEvent eventWithEventStore: eventstore];
                             event.title = thisRun;
                             event.notes = [descriptionMidWeekRun2 objectAtIndex: i];
                             //NSDate *date = [dateFormat dateFromString:@"2016-04-29 11:59:00"];
                             event.startDate = firstDay;
                             event.endDate = [firstDay dateByAddingTimeInterval:3600];
                             event.availability = EKEventAvailabilityFree;
                             
                             [event setCalendar:[eventstore defaultCalendarForNewEvents]];
                             NSError *err;
                             [eventstore saveEvent:event span:EKSpanThisEvent error:&err];
                             i++;
                             
                             //tomorrow = [today dateByAddingTimeInterval: secondsPerDay]
                             NSDate* newDate = [firstDay dateByAddingTimeInterval:-secondsPerWeek-60];
                             //[firstDay release];
                             firstDay = newDate;
                         }
                         
                         int thirdMidWeek = 0;
                         
                         thirdMidWeek = [self nextDatePickedByButtons];
                         firstDay = [self findFirstDayFromMarathon:thirdMidWeek];
                         
                         i = 0;
                         
                         for (thisRun in midWeekRun3)
                         {
                             EKEvent *event  = [EKEvent eventWithEventStore: eventstore];
                             event.title = thisRun;
                             event.notes = [descriptionMidWeekRun3 objectAtIndex: i];
                             //NSDate *date = [dateFormat dateFromString:@"2016-04-29 11:59:00"];
                             event.startDate = firstDay;
                             event.endDate = [firstDay dateByAddingTimeInterval:3600];
                             event.availability = EKEventAvailabilityFree;
                             
                             [event setCalendar:[eventstore defaultCalendarForNewEvents]];
                             NSError *err;
                             [eventstore saveEvent:event span:EKSpanThisEvent error:&err];
                             i++;
                             
                             //tomorrow = [today dateByAddingTimeInterval: secondsPerDay]
                             NSDate* newDate = [firstDay dateByAddingTimeInterval:-secondsPerWeek-60];
                             //[firstDay release];
                             firstDay = newDate;
                         }
                         
                         if(_levelAccepted == [NSNumber numberWithInt: 3]){
                             int fourthMidWeek = 0;
                             
                             fourthMidWeek = [self nextDatePickedByButtons];
                             firstDay = [self findFirstDayFromMarathon:fourthMidWeek];
                             
                             i = 0;
                             
                             for (thisRun in midWeekRun4Advanced)
                             {
                                 EKEvent *event  = [EKEvent eventWithEventStore: eventstore];
                                 event.title = thisRun;
                                 event.notes = [descriptionMidWeekRun4Advanced objectAtIndex: i];
                                 //NSDate *date = [dateFormat dateFromString:@"2016-04-29 11:59:00"];
                                 event.startDate = firstDay;
                                 event.endDate = [firstDay dateByAddingTimeInterval:3600];
                                 event.availability = EKEventAvailabilityFree;
                                 
                                 [event setCalendar:[eventstore defaultCalendarForNewEvents]];
                                 NSError *err;
                                 [eventstore saveEvent:event span:EKSpanThisEvent error:&err];
                                 i++;
                                 
                                 //tomorrow = [today dateByAddingTimeInterval: secondsPerDay]
                                 NSDate* newDate = [firstDay dateByAddingTimeInterval:-secondsPerWeek-60];
                                 //[firstDay release];
                                 firstDay = newDate;
                             }

                         }
                         UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Success!"
                                                                                        message:@"Dates have been successfully posted to your calendar. Enjoy your workouts!"
                                                                                 preferredStyle:UIAlertControllerStyleAlert];
                         
                         UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                                               handler:^(UIAlertAction * action) {}];
                         
                         [alert addAction:defaultAction];
                         [self presentViewController:alert animated:YES completion:nil];
                         
                     }else{
                         UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Two or more selected days overlap"
                                                                                        message:@"There is some overlap in the days you have picked for runs. Please fix this issue and try again."
                                                                                 preferredStyle:UIAlertControllerStyleAlert];
                         
                         UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                                               handler:^(UIAlertAction * action) {}];
                         
                         [alert addAction:defaultAction];
                         [self presentViewController:alert animated:YES completion:nil];
                     }
                     
                 }else{
                     UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Too many or too few weekdays"
                                                                                    message:@"Please select exactly 3 midweek days for runs."
                                                                             preferredStyle:UIAlertControllerStyleAlert];
                     
                     UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                                           handler:^(UIAlertAction * action) {}];
                     
                     [alert addAction:defaultAction];
                     [self presentViewController:alert animated:YES completion:nil];
                     
                 }
             }
                 
             else
             {
                 NSLog(@"Calender not called");
                 // if user did not your app to use calendar control will reach over hare
             }
         }];
    }
    
}




- (IBAction)midWeekSunday:(UIButton *)sender {
    if(_midWeekSundayClickedBool == true){
        _midWeekSundayClicked.backgroundColor = nil;
        _midWeekSundayClicked.titleLabel.textColor = [UIColor blueColor];
        _midWeekSundayClickedBool = false;
        _weekdays--;
    }
    else{
        _midWeekSundayClicked.backgroundColor = [UIColor colorWithRed:40.0f/255.0f green:103.0f/255.0f blue:249.0f/255.0f alpha:1.0];
        _midWeekSundayClicked.titleLabel.textColor = [UIColor whiteColor];
        _midWeekSundayClickedBool = true;
        _weekdays++;
    }
    NSLog(@"weekdays = %d", _weekdays);
}

- (IBAction)midWeekMonday:(UIButton *)sender {
    if(_midWeekMondayClickedBool == true){
        _midWeekMondayClicked.backgroundColor = nil;
        _midWeekMondayClicked.titleLabel.textColor = [UIColor blueColor];
        _midWeekMondayClickedBool=false;
        _weekdays--;
    }else{
        _midWeekMondayClicked.backgroundColor = [UIColor colorWithRed:40.0f/255.0f green:103.0f/255.0f blue:249.0f/255.0f alpha:1.0];
        _midWeekMondayClicked.titleLabel.textColor = [UIColor whiteColor];
        _midWeekMondayClickedBool = true;
        _weekdays++;
    }
}

- (IBAction)midWeekTuesday:(UIButton *)sender {
    if(_midWeekTuesdayClickedBool == true){
        _midWeekTuesdayClicked.backgroundColor = nil;
        _midWeekTuesdayClicked.titleLabel.textColor = [UIColor blueColor];
        _midWeekTuesdayClickedBool=false;
        _weekdays--;
    }else{
        _midWeekTuesdayClicked.backgroundColor = [UIColor colorWithRed:40.0f/255.0f green:103.0f/255.0f blue:249.0f/255.0f alpha:1.0];
        _midWeekTuesdayClicked.titleLabel.textColor = [UIColor whiteColor];
        _midWeekTuesdayClickedBool = true;
        _weekdays++;
    }
}

- (IBAction)midWeekWednesday:(UIButton *)sender {
    if(_midWeekWednesdayClickedBool == true){
        _midWeekWednesdayClicked.backgroundColor = nil;
        _midWeekWednesdayClicked.titleLabel.textColor = [UIColor blueColor];
        _midWeekWednesdayClickedBool=false;
        _weekdays--;
    }else{
        _midWeekWednesdayClicked.backgroundColor = [UIColor colorWithRed:40.0f/255.0f green:103.0f/255.0f blue:249.0f/255.0f alpha:1.0];
        _midWeekWednesdayClicked.titleLabel.textColor = [UIColor whiteColor];
        _midWeekWednesdayClickedBool = true;
        _weekdays++;
    }
}

- (IBAction)midWeekThursday:(UIButton *)sender {
    if(_midWeekThursdayClickedBool == true){
        _midWeekThursdayClicked.backgroundColor = nil;
        _midWeekThursdayClicked.titleLabel.textColor = [UIColor blueColor];
        _midWeekThursdayClickedBool=false;
        _weekdays--;
    }else{
        _midWeekThursdayClicked.backgroundColor = [UIColor colorWithRed:40.0f/255.0f green:103.0f/255.0f blue:249.0f/255.0f alpha:1.0];
        _midWeekThursdayClicked.titleLabel.textColor = [UIColor whiteColor];
        _midWeekThursdayClickedBool = true;
        _weekdays++;
    }
}

- (IBAction)midWeekFriday:(UIButton *)sender {
    if(_midWeekFridayClickedBool == true){
        _midWeekFridayClicked.backgroundColor = nil;
        _midWeekFridayClicked.titleLabel.textColor = [UIColor blueColor];
        _midWeekFridayClickedBool=false;
        _weekdays--;
    }else{
        _midWeekFridayClicked.backgroundColor = [UIColor colorWithRed:40.0f/255.0f green:103.0f/255.0f blue:249.0f/255.0f alpha:1.0];
        _midWeekFridayClicked.titleLabel.textColor = [UIColor whiteColor];
        _midWeekFridayClickedBool = true;
        _weekdays++;
    }
}

- (IBAction)midWeekSaturday:(UIButton *)sender {
    if(_midWeekSaturdayClickedBool == true){
        _midWeekSaturdayClicked.backgroundColor = nil;
        _midWeekSaturdayClicked.titleLabel.textColor = [UIColor blueColor];
        _midWeekSaturdayClickedBool=false;
        _weekdays--;
    }else{
        _midWeekSaturdayClicked.backgroundColor = [UIColor colorWithRed:40.0f/255.0f green:103.0f/255.0f blue:249.0f/255.0f alpha:1.0];
        _midWeekSaturdayClicked.titleLabel.textColor = [UIColor whiteColor];
        _midWeekSaturdayClickedBool = true;
        _weekdays++;
    }
}
@end
