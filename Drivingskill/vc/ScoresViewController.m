//
//  ScoresViewController.m
//  Drivingskill
//
//  Created by Man Tung on 12/19/12.
//  Copyright (c) 2012 Man Tung. All rights reserved.
//

#import "ScoresViewController.h"
#import "AppDelegate.h"
#import "Scores.h"
#import "BaseCell.h"

@interface ScoresViewController ()

@end

@implementation ScoresViewController
@synthesize managedObjectContext, fetchedResultsController;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        if (!managedObjectContext) {
            managedObjectContext = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
        }
    }
    return self;
}


#pragma mark
#pragma mark - fetch data

- (void)fetch
{
    NSError *error = nil;
	if (![[self fetchedResultsController] performFetch:&error]) {
		/*
		 Replace this implementation with code to handle the error appropriately.
		 
		 abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
		 */
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		abort();
	}
}


- (void)viewDidLoad
{
    [super viewDidLoad];

    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.title = NSLocalizedString(@"scorestitle", @"");
//    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"cancelbutton", @"") style:UIBarButtonItemStyleBordered target:self action:@selector(back)];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [self fetch];
}

- (void)back
{
    [self dismissModalViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger count = [[fetchedResultsController sections] count];
	if (count == 0) {
		count = 1;
	}
    return count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger numberOfRows = 0;
	
    if ([[fetchedResultsController sections] count] > 0) {
        id <NSFetchedResultsSectionInfo> sectionInfo = [[fetchedResultsController sections] objectAtIndex:section];
        numberOfRows = [sectionInfo numberOfObjects];
    }
    return numberOfRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // Dequeue or if necessary create a RecipeTableViewCell, then set its recipe to the recipe for the current row.
    static NSString *NoteCellIdentifier = @"RecipeCellIdentifier";
    
    BaseCell *noteCell = (BaseCell *)[self.tableView dequeueReusableCellWithIdentifier:NoteCellIdentifier];
    if (noteCell == nil) {
        noteCell = [[[BaseCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NoteCellIdentifier] autorelease];
		//noteCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    [self configureCell:noteCell atIndexPath:indexPath];
    
    return noteCell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
//        [tableView deleteRowsAtIndexPaths:indexPath withRowAnimation:UITableViewRowAnimationFade];
//        [tableView beginUpdates];
//        [tableView endUpdates];
        NSManagedObjectContext *context = [fetchedResultsController managedObjectContext];
        [context deleteObject:[fetchedResultsController objectAtIndexPath:indexPath]];
        NSError *error;
		if (![context save:&error]) {
			NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
			abort();
		}
//        [tableView reloadData];

    }
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}

//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return 40;
//}

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

/*
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}
 */

- (void)configureCell:(BaseCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    if ([fetchedResultsController.fetchedObjects count] > indexPath.row) {
        Scores * score = (Scores *)[fetchedResultsController objectAtIndexPath:indexPath];
        cell.scores = score;
        [cell layoutSubviews];
    }
}


#pragma mark - FetchController
- (NSFetchedResultsController *)fetchedResultsController {
    // Set up the fetched results controller if needed.
    if (fetchedResultsController == nil) {
        // Create the fetch request for the entity.
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        // Edit the entity name as appropriate.
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Scores" inManagedObjectContext:managedObjectContext];
        [fetchRequest setEntity:entity];
//        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"(op_log != %d)", 3];
//        [fetchRequest setPredicate:predicate];
        // Edit the sort key as appropriate.
        
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"score" ascending:NO];
        NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
        
        [fetchRequest setSortDescriptors:sortDescriptors];
        
        // Edit the section name key path and cache name if appropriate.
        // nil for section name key path means "no sections".
        NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:managedObjectContext sectionNameKeyPath:nil cacheName:@"Root"];
        aFetchedResultsController.delegate = self;
        self.fetchedResultsController = aFetchedResultsController;
        
        //[self queryLocalCount];
        
        [aFetchedResultsController release];
        [fetchRequest release];
        [sortDescriptor release];
        [sortDescriptors release];
    }
	
	return fetchedResultsController;
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
	// The fetch controller is about to start sending change notifications, so prepare the table view for updates.
	[self.tableView beginUpdates];
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
	UITableView *tv = self.tableView;
	
	switch(type) {
		case NSFetchedResultsChangeInsert:
			[tv insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
			break;
			
		case NSFetchedResultsChangeDelete:
			[tv deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
			break;
			
		case NSFetchedResultsChangeUpdate:
			[self configureCell:((BaseCell *)[tv cellForRowAtIndexPath:indexPath]) atIndexPath:indexPath];
            break;
			
		case NSFetchedResultsChangeMove:
			[tv deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tv insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
	}
}


- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
	switch(type) {
		case NSFetchedResultsChangeInsert:
			[self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
			break;
			
		case NSFetchedResultsChangeDelete:
			[self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
			break;
	}
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
	// The fetch controller has sent all current change notifications, so tell the table view to process all updates.
	[self.tableView endUpdates];
}


- (void)dealloc
{
    [super dealloc];
    [fetchedResultsController release];
	[managedObjectContext release];
}

@end
