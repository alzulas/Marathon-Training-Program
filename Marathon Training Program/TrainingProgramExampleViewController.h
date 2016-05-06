//
//  TrainingProgramExampleViewController.h
//  Marathon Training Program
//
//  Created by Leah Zulas on 5/3/16.
//  Copyright © 2016 Leah Zulas. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TrainingProgramExampleViewController : UIViewController

@property (strong, nonatomic) IBOutlet UIImageView *intermediateProgram;
@property (strong, nonatomic) IBOutlet UILabel *programDescription;
@property (strong, nonatomic) NSString* descritionForLabel;
@property (strong, nonatomic) UIImage* imageToUse;
@property (strong, nonatomic) NSNumber* whichLevelPicked;


@end
