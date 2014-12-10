//
//  ViewController.m
//  HUDTestApp
//
//  Created by Hirad Motamed on 2014-12-09.
//  Copyright (c) 2014 Pendar Labs. All rights reserved.
//

#import "ViewController.h"
#import "Task.h"
#import <SVProgressHUD/SVProgressHUD.h>

void* kProgressContext = &kProgressContext;
NSString* const kProgressType = @"type";

@interface ViewController ()

@property (nonatomic, strong) NSArray* typeATasks;
@property (nonatomic, strong) NSArray* typeBTasks;
@property (nonatomic, strong) NSArray* typeCTasks;
@property (nonatomic, strong) NSArray* typeDTasks;
@property (nonatomic, strong) NSArray* typeETasks;

@property (nonatomic, strong) dispatch_queue_t workQ;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.typeATasks = [self generateTasks];
    self.typeBTasks = [self generateTasks];
    self.typeCTasks = [self generateTasks];
    self.typeDTasks = [self generateTasks];
    self.typeETasks = [self generateTasks];
    
    self.workQ = dispatch_queue_create("HUDTestApp_work_queue", DISPATCH_QUEUE_SERIAL);
}

-(void)viewDidAppear:(BOOL)animated
{
    dispatch_async(self.workQ, ^{
        [self doTasks:_typeATasks type:@"type A"];
        [self doTasks:_typeBTasks type:@"type B"];
        [self doTasks:_typeCTasks type:@"type C"];
        [self doTasks:_typeDTasks type:@"type D"];
        [self doTasks:_typeETasks type:@"type E"];
    });
}

-(void)doTasks:(NSArray*)tasks type:(NSString*)type
{
    NSUInteger count = [tasks count];
    NSProgress* progress = [NSProgress progressWithTotalUnitCount:count];
    [progress becomeCurrentWithPendingUnitCount:count];
    [progress setUserInfoObject:type forKey:kProgressType];
    [progress addObserver:self
               forKeyPath:@"completedUnitCount"
                  options:NSKeyValueObservingOptionNew
                  context:kProgressContext];
    NSInteger counter = 0;
    for (Task* t in tasks) {
        [t doIt];
        [progress setCompletedUnitCount:counter++];
        NSLog(@"Set Completed Unit Count: %ld", (long)counter);
    }
    [progress resignCurrent];
    [progress removeObserver:self
                  forKeyPath:@"completedUnitCount"
                     context:kProgressContext];
}

-(void)observeValueForKeyPath:(NSString *)keyPath
                     ofObject:(id)object
                       change:(NSDictionary *)change
                      context:(void *)context
{
    if (context == kProgressContext) {
        NSProgress* progress = (NSProgress*)object;
        NSUInteger completed = (NSUInteger)progress.completedUnitCount;
        NSUInteger total = (NSUInteger)progress.totalUnitCount;
        NSString* title = [NSString stringWithFormat:@"Doing %lu of %lu %@s", (unsigned long)completed, (unsigned long)total, progress.userInfo[kProgressType]];
        double fraction = ((double)completed / (double)total);
        if (fraction > 1) {
            NSLog(@"How did I get here!!!???");
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD showProgress:fraction
                                 status:title
                               maskType:SVProgressHUDMaskTypeGradient];
        });
    }
    else
    {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

-(NSArray*)generateTasks
{
    NSUInteger tasksCount = arc4random() % 500 + 500; // want between 500-1000 tasks
    NSMutableArray* tasks = [NSMutableArray arrayWithCapacity:tasksCount];
    for (NSUInteger i = 0; i < tasksCount; i++) {
        [tasks addObject:[Task new]];
    }
    return tasks;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
