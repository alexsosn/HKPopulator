//
//  ViewController.m
//  hkPopulator
//
//  Created by Sosnovshchenko Alexander on 1/30/15.
//  Copyright (c) 2015 Sosnovshchenko Alexander. All rights reserved.
//

#import "ViewController.h"
#import <HealthKit/HealthKit.h>
#import "NSDate+Category.h"
#include <stdlib.h>

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIButton *button;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)start:(id)sender {
    self.button.enabled = NO;
    HKHealthStore *store = [HKHealthStore new];
    
    [store requestAuthorizationToShareTypes:self.writeTypes readTypes:nil completion:^(BOOL success, NSError *error) {
        NSDate *date = [NSDate date];
        
        for (NSUInteger i = 1; i < 366; i++) {
            NSMutableArray *array = [NSMutableArray array];

            for (NSString *str in self.types) {
                HKQuantityType *quantityType = [HKObjectType quantityTypeForIdentifier:str];
                
                HKUnit *unit = [self typesAndUnits][quantityType];
                HKQuantity *quantity = nil;
                
                if ([str isEqualToString:HKQuantityTypeIdentifierStepCount]) {
                    quantity = [HKQuantity quantityWithUnit:unit
                                                            doubleValue:(double)arc4random_uniform(30000)];
                } else {
                    quantity = [HKQuantity quantityWithUnit:unit
                                                            doubleValue:(double)arc4random_uniform(30)];
                }
                
                
                HKQuantitySample *sample =
                [HKQuantitySample quantitySampleWithType:quantityType
                                                quantity:quantity
                                               startDate:date
                                                 endDate:[date endOfDay]
                                                metadata:nil];
                [array addObject:sample];
            }
            date = [date dateBySubtractingDays:1];
            [store saveObjects:array withCompletion:^(BOOL success, NSError *error) {
                
                NSString *message = nil;
                if (error) {
                    message = error.localizedDescription;
                } if ([date isLaterDate:[date dateBySubstractingYears:1]]){
                    message = [date formattedStringWithFormat:@"YYYY MM dd"];
                } else {
                    message = @"Success!";
                }
                
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self.button setTitle:message forState:UIControlStateNormal];
                });
                
                
            }];
        }
    }];
    
    
}

- (NSSet *)writeTypes {
    return [NSSet setWithObjects:
            [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount],
            [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierFlightsClimbed],
            [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDistanceCycling],
            [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDistanceWalkingRunning],
            nil];
}


-(NSArray *)types {
    return @[HKQuantityTypeIdentifierStepCount,
             HKQuantityTypeIdentifierDistanceWalkingRunning,
             HKQuantityTypeIdentifierDistanceCycling,
             HKQuantityTypeIdentifierFlightsClimbed
             ];
}

- (NSDictionary *)typesAndUnits {
    return @{
             [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount]:[HKUnit countUnit],
             [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierFlightsClimbed]:[HKUnit countUnit],
             [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDistanceCycling]:[HKUnit meterUnitWithMetricPrefix:HKMetricPrefixKilo],
             [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDistanceWalkingRunning]:[HKUnit meterUnitWithMetricPrefix:HKMetricPrefixKilo],
             };
}


@end
