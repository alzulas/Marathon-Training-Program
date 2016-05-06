//
//  TrainingProgramExampleViewController.m
//  Marathon Training Program
//
//  Created by Leah Zulas on 5/3/16.
//  Copyright © 2016 Leah Zulas. All rights reserved.
//

#import "TrainingProgramExampleViewController.h"
#import "ViewController.h"

@interface TrainingProgramExampleViewController ()

@end

@implementation TrainingProgramExampleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _programDescription.text = _descritionForLabel;
    _intermediateProgram.image = _imageToUse;
    NSLog(@"which level picked %@", _whichLevelPicked);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)unwindForSegue:(UIStoryboardSegue *)unwindSegue towardsViewController:(UIViewController *)subsequentVS{
    
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([[segue identifier] isEqualToString:@"toDatePickers"]){
        ViewController *controller = (ViewController *) [segue destinationViewController];
        controller.levelAccepted = _whichLevelPicked;
    }
    
}


@end
