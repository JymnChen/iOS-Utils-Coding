//
//  ViewController.m
//  LockDemo
//
//  Created by Jymn_Chen on 15/8/19.
//  Copyright (c) 2015年 com.jymnchen. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // [self generateDeadLock];
    [self breakDeadLock];
}

- (void)generateDeadLock {
    NSLock *lock = [[NSLock alloc] init];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        static void (^RecursiveMethod)(int);
        
        RecursiveMethod = ^(int value) {
            
            [lock lock];
            if (value > 0) {
                
                NSLog(@"value = %d", value);
                sleep(2);
                RecursiveMethod(value - 1);
            }
            [lock unlock];
        };
        
        RecursiveMethod(5);
    });
}

- (void)breakDeadLock {
    NSRecursiveLock *lock = [[NSRecursiveLock alloc] init];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        static void (^RecursiveMethod)(int);
        
        RecursiveMethod = ^(int value) {
            
            [lock lock];
            if (value > 0) {
                
                NSLog(@"value = %d", value);
                sleep(2);
                RecursiveMethod(value - 1);
            }
            [lock unlock];
        };
        
        RecursiveMethod(5);
    });
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        sleep(2);
        BOOL flag = [lock lockBeforeDate:[NSDate dateWithTimeIntervalSinceNow:1]];
        if (flag) {
            NSLog(@"lock before date");
            
            [lock unlock];
        } else {
            NSLog(@"fail to lock before date");
        }
    });
}

@end
