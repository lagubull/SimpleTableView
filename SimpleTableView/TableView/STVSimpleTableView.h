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

/**
 Defines methods for manging pagination and refresing of content.
 */
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

/**
 Table to show any content on a dataSource, requires cell customization.
 */
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
 The section that will be used to check if the Table View has data.
 */
@property (nonatomic, strong) NSNumber *sectionToCheckForData;

/**
 Used to connect the TableView with Core Data.
 */
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

/**
 Pagination content view to show the local user we are retrieving fresh data.
 */
@property (nonatomic, strong) STVPaginatingView *paginatingView;

/**
 Returns YES if the Data Source view has data, NO if not.
 */
@property (nonatomic, assign, readonly) BOOL hasData;

/**
 View to display when the Data Source View is empty.
 */
@property (nonatomic, strong) UIView *emptyView;

/**
 Is the loading view currently being shown.
 */
@property (nonatomic, assign, readonly) BOOL isShowingLoadingView;

/**
 View to display when the Data Source View is loading.
 */
@property (nonatomic, strong) UIView *loadingView;

/**
 Notify the tableView loading is starting
 */
- (void)willLoadContent;

/**
 Tells the tableView we are about to paginate.
 */
- (void)willPaginate;

/**
 Tells the tableView pagination has finished.
 */
- (void)didPaginate;

/**
 Removes refresh indicator from tableview.
 
 @param hasContent - YES if the table has content or NO
 */
- (void)didRefreshWithContent:(BOOL)hasContent;

/**
 Notify the tableView loading has finished
 
 @param YES if there is data in the tableView
 */
- (void)didFinishLoadingContent:(BOOL)hasData;

@end
