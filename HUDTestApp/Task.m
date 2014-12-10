//
//  Task.m
//  HUDTestApp
//
//  Created by Hirad Motamed on 2014-12-09.
//  Copyright (c) 2014 Pendar Labs. All rights reserved.
//

#import "Task.h"

@implementation Task

-(void)doIt
{
    unsigned int duration = (arc4random() % 2000) + 2000;
    usleep(duration);
}

@end
