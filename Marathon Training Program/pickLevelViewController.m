//
//  pickLevelViewController.m
//  Marathon Training Program
//
//  Created by Leah Zulas on 5/3/16.
//  Copyright © 2016 Leah Zulas. All rights reserved.
//

#import "pickLevelViewController.h"
#import "TrainingProgramExampleViewController.h"

@interface pickLevelViewController ()

@end

@implementation pickLevelViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(IBAction)unwindForSegue:(UIStoryboardSegue *)unwindSegue towardsViewController:(UIViewController *)subsequentVS{
    
}


#pragma mark - Navigation

//In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([[segue identifier] isEqualToString:@"noviceLevel"]){
        TrainingProgramExampleViewController *controller = (TrainingProgramExampleViewController *) [segue destinationViewController];
        controller.descritionForLabel = @"This is the novice running program";
        controller.imageToUse = [UIImage imageNamed: @"NoviceProgram"];
        controller.whichLevelPicked = [NSNumber numberWithInt:1];
    }else if ([[segue identifier] isEqualToString:@"intermediateLevel"]){
        TrainingProgramExampleViewController *controller = (TrainingProgramExampleViewController *) [segue destinationViewController];
        controller.descritionForLabel = @"This is the intermediate running program";
        controller.imageToUse = [UIImage imageNamed: @"IntermediateProgram"];
        controller.whichLevelPicked = [NSNumber numberWithInt:2];
    } else if ([[segue identifier] isEqualToString:@"advancedLevel"]){
        TrainingProgramExampleViewController *controller = (TrainingProgramExampleViewController *) [segue destinationViewController];
        controller.descritionForLabel = @"This is the advanced running program";
        controller.imageToUse = [UIImage imageNamed: @"AdvancedProgram"];
        controller.whichLevelPicked = [NSNumber numberWithInt:3];
    }
}


@end
