//
//  STVSimpleTableView.h
//  SimpleTableView
//
//  Created by Javier Laguna on 21/02/2016.
//  Copyright © 2016 Javier Laguna. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@class STVSimpleTableView;
@class STVPaginatingView;

@protocol STVDataRetrievalTableViewDelegate <NSObject>

@optional

/**
 Request for delegate to begin requesting new data.
 */
- (void)refresh;

/**
 Called after FSNDataRetrievalTableView instance has asked for data refresh;
 */
- (void)dataRetrievalTableViewDidRequestRefresh:(STVSimpleTableView *)tableView;

/**
 Called when we have past the half of the items in the last page loaded.
 */
- (void)paginate;

/**
 Call when there is an update.
 
 @param indexPath - index path of the updated row.
 */
- (void)didUpdateItemAtIndexPath:(NSIndexPath *)indexPath;

@end

@interface STVSimpleTableView : UITableView

/**
 Delegate of the class.
 */
@property (nonatomic, weak) id <STVDataRetrievalTableViewDelegate> dataRetrievalDelegate;

/**
 Lets the tableView know when pagination should be triggered,
 
 Ideally this value should be at least half of the page.
 */
@property (nonatomic, strong) NSNumber *paginationOffset;

/**
 Used to connect the TableView with Core Data.
 */
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

/**
 Pagination content view to show the local user we are retrieving fresh data.
 */
@property (nonatomic, strong) STVPaginatingView *paginatingView;

/**
 Tells the tableView we are about to paginate.
 */
- (void)willPaginate;

/**
 Tells the tableView pagination has finished.
 */
- (void)didPaginate;

/**
 Tells the tableView that data has finished refreshing.
 */
- (void)didRefresh;

@end