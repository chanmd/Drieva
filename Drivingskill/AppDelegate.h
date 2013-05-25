//
//  AppDelegate.h
//  Drivingskill
//
//  Created by Man Tung on 12/5/12.
//  Copyright (c) 2012 Man Tung. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HomeViewController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (strong, nonatomic, readonly) CMMotionManager *sharedMotionManager;
@property (strong, nonatomic) HomeViewController *homevc;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end
