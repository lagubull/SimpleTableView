//
//  STVTableView.m
//  SimpleTableView
//
//  Created by Javier Laguna on 21/02/2016.
//  Copyright © 2016 Javier Laguna. All rights reserved.
//

#import "STVTableView.h"

#import <PureLayout/PureLayout.h>

#import "STVPaginatingView.h"

@interface STVTableView () <NSFetchedResultsControllerDelegate>

/**
 Indicates wether pagination is happening.
 */
@property (nonatomic, assign, getter=isPaginating) BOOL paginating;

/**
 Shown on pull to refresh.
 */
@property (nonatomic, strong) UIRefreshControl *refreshControl;

@end

@implementation STVTableView

#pragma mark - Init

- (instancetype)init
{
    self =  [super init];
    
    if (self)
    {
        [self setUp];
    }
    
    return self;
}

- (instancetype)initForAutoLayout
{
    self =  [super initForAutoLayout];
    
    if (self)
    {
        [self setUp];
    }
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self =  [super initWithCoder:aDecoder];
    
    if (self)
    {
        [self setUp];
    }
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        [self setUp];
    }
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style
{
    self = [super initWithFrame:frame
                          style:style];
    
    if (self)
    {
        [self setUp];
    }
    
    return self;
}

#pragma mark - SetUp

- (void)setUp
{
    self.paginationOffset = @(10);
    
    if (!self.refreshControl.superview)
    {
        [self addSubview:self.refreshControl];
    }
}

#pragma mark - Dequeue

- (id)dequeueReusableCellWithIdentifier:(NSString *)identifier
                           forIndexPath:(NSIndexPath *)indexPath
{
    id cell = [super dequeueReusableCellWithIdentifier:identifier
                                          forIndexPath:indexPath];
    
    if ([self.dataRetrievalDelegate respondsToSelector:@selector(paginate)])
    {
        if (!self.isPaginating)
        {
            NSUInteger numberOfRowsInSection = [self numberOfRowsInSection:indexPath.section];
            NSUInteger paginationTriggerIndex = numberOfRowsInSection - self.paginationOffset.integerValue;
            
            if (indexPath.row >= MIN(paginationTriggerIndex, numberOfRowsInSection - 1))
            {
                [self.dataRetrievalDelegate paginate];
            }
        }
    }
    
    return cell;
}

#pragma mark - RefreshControl

- (UIRefreshControl *)refreshControl
{
    if (!_refreshControl)
    {
        _refreshControl = [[UIRefreshControl alloc] init];
        
        if ([self.dataRetrievalDelegate respondsToSelector:@selector(refresh)])
        {
            [_refreshControl addTarget:self.dataRetrievalDelegate
                                action:@selector(refresh)
                      forControlEvents:UIControlEventValueChanged];
        }
    }
    
    return _refreshControl;
}

- (void)didRefresh
{
    [self.refreshControl endRefreshing];
}

#pragma mark - FetchResultController

- (void)setFetchedResultsController:(NSFetchedResultsController *)fetchedResultsController
{
    [self willChangeValueForKey:NSStringFromSelector(@selector(fetchedResultsController))];
    _fetchedResultsController = fetchedResultsController;
    [self didChangeValueForKey:NSStringFromSelector(@selector(fetchedResultsController))];
    
    self.fetchedResultsController.delegate = self;
}

#pragma mark - Pagination

- (void)willPaginate
{
    if (!self.isPaginating)
    {
        [self.paginatingView startAnimating];
        
        self.paginating = YES;

        self.tableFooterView = self.paginatingView;
    }
}

- (void)didPaginate
{
    //we don't want it to be created if it is nil
    if (_paginatingView)
    {
        self.tableFooterView = nil;
        
        [self.paginatingView stopAnimating];
    }
    
    self.paginating = NO;
}

#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    // The fetch controller is about to start sending change notifications, so prepare the table view for updates.
    [self beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
    switch(type)
    {
        case NSFetchedResultsChangeInsert:
        {
            [self insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            
            break;
        }
        case NSFetchedResultsChangeDelete:
        {
            [self deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            
            break;
        }
        case NSFetchedResultsChangeUpdate:
        {
            if ([self.dataRetrievalDelegate respondsToSelector:@selector(didUpdateItemAtIndexPath:)])
            {
                [self.dataRetrievalDelegate didUpdateItemAtIndexPath:indexPath];
            }
            
            break;
        }
        case NSFetchedResultsChangeMove:
        {
            [self deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                        withRowAnimation:UITableViewRowAnimationFade];
            
            [self insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                        withRowAnimation:UITableViewRowAnimationFade];
        }
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id )sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch(type)
    {
        case NSFetchedResultsChangeInsert:
        {
            [self insertSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                withRowAnimation:UITableViewRowAnimationFade];
            
            break;
        }
        case NSFetchedResultsChangeDelete:
        {
            [self deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                withRowAnimation:UITableViewRowAnimationFade];
            
            break;
        }
        case NSFetchedResultsChangeMove:
        {
            break;
        }
        case NSFetchedResultsChangeUpdate:
        {
            break;
        }
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    // The fetch controller has sent all current change notifications, so tell the table view to process all updates.
    [self endUpdates];
}


@end