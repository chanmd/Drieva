//
//  ScoresViewController.h
//  Drivingskill
//
//  Created by Man Tung on 12/19/12.
//  Copyright (c) 2012 Man Tung. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ScoresViewController : UITableViewController <NSFetchedResultsControllerDelegate>
{
@private
    NSFetchedResultsController *fetchedResultsController;
    NSManagedObjectContext *managedObjectContext;
}

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSManagedObjectContext * managedObjectContext;

@end
