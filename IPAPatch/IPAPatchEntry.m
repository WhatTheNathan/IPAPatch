//
//  IPAPatchEntry.m
//  IPAPatch
//
//  Created by wutian on 2017/3/17.
//  Copyright © 2017年 Weibo. All rights reserved.
//

#import "IPAPatchEntry.h"
#import <UIKit/UIKit.h>
#import "Aspects.h"
#import "fishhook.h"
#import <objc/runtime.h>
#import <objc/objc.h>
#import "objc/message.h"

static IMP (*original_class_getMethodImplementation)(Class cls, SEL sel);

@implementation IPAPatchEntry

+ (void)load
{
    // DO YOUR WORKS...
    
    // For Example:
    [self for_example_showAlert];
    
    [UIViewController aspect_hookSelector:@selector(viewWillAppear:) withOptions:AspectPositionAfter usingBlock:^(id<AspectInfo> aspectInfo, BOOL animated) {
        NSLog(@"View Controller %@ will appear animated: %tu", aspectInfo.instance, animated);
    } error:NULL];
    
    struct rebinding my_rebinding = { "class_getMethodImplementation", new_class_getMethodImplementation, (void *)&original_class_getMethodImplementation };
    rebind_symbols((struct rebinding[1]){my_rebinding}, 1);
}


IMP new_class_getMethodImplementation(Class cls, SEL sel)
{
    NSLog(@"getMethodImp %@ %@", NSStringFromClass(cls), NSStringFromSelector(sel));
    return original_class_getMethodImplementation(cls, sel);
}

+ (void)for_example_showAlert
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UIAlertController * alertController = [UIAlertController alertControllerWithTitle:@"Hacked" message:@"Hacked with IPAPatch" preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:NULL]];
        UIViewController * controller = [UIApplication sharedApplication].keyWindow.rootViewController;
        while (controller.presentedViewController) {
            controller = controller.presentedViewController;
        }
        [controller presentViewController:alertController animated:YES completion:NULL];
    });
}

@end
