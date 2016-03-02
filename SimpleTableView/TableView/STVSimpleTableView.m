//
//  STVSimpleTableView.m
//  SimpleTableView
//
//  Created by Javier Laguna on 21/02/2016.
//  Copyright © 2016 Javier Laguna. All rights reserved.
//

#import "STVSimpleTableView.h"

#import <PureLayout/PureLayout.h>

#import "STVPaginatingView.h"

/**
 Duration of emptyview animations.
 */
static CGFloat const kSTVTableViewEmptyViewAnimationDuration = 0.75;

@interface STVSimpleTableView () <NSFetchedResultsControllerDelegate>

/**
 Indicates wether pagination is happening.
 */
@property (nonatomic, assign, getter=isPaginating) BOOL paginating;

/**
 Shown on pull to refresh.
 */
@property (nonatomic, strong) UIRefreshControl *refreshControl;

/**
 Indicates that loading actions have finished
 */
@property (nonatomic, assign) BOOL didFinishLoadingContentActions;

/**
 A bit to tell the tableview that data is being loaded despite the datasource may not have been notified
 */
@property (nonatomic, assign, getter=isDataLoaded) BOOL dataLoaded;

/**
 Is the loading view currently being shown.
 */
@property (nonatomic, assign, readwrite) BOOL isShowingLoadingView;

/**
 Updates the empty view to show or hide based on the current hasData value.
 */
- (void)updateEmptyView;

/**
 Updates the loading view to show or hide based on the current hasData value.
 */
- (void)updateLoadingView;

@end

@implementation STVSimpleTableView

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

#pragma mark - EmptyView

- (void)updateEmptyView
{
    if (self.emptyView)
    {
        if ([self hasData])
        {
            [UIView animateWithDuration:kSTVTableViewEmptyViewAnimationDuration
                             animations:^
             {
                 self.emptyView.alpha = 0.0f;
             }
                             completion:^(BOOL finished)
             {
                 [self.emptyView removeFromSuperview];
             }];
        }
        else
        {
            self.emptyView.alpha = 0.0f;
            [self addSubview:self.emptyView];
            [self.emptyView updateConstraints];
            
            [UIView animateWithDuration:kSTVTableViewEmptyViewAnimationDuration
                             animations:^
             {
                 self.emptyView.alpha = 1.0f;
             }];
        }
    }
}

#pragma mark - LoadingView

- (void)updateLoadingView
{
    if (self.loadingView)
    {
        if (self.didFinishLoadingContentActions ||
            [self hasData])
        {
            self.isShowingLoadingView = NO;
            
            [UIView animateWithDuration:kSTVTableViewEmptyViewAnimationDuration
                             animations:^
             {
                 self.loadingView.alpha = 0.0f;
             }
                             completion:^(BOOL finished)
             {
                 [self.loadingView removeFromSuperview];
             }];
        }
        else
        {
            self.isShowingLoadingView = YES;
            
            self.loadingView.alpha = 0.0f;
            [self addSubview:self.loadingView];
            [self.loadingView updateConstraints];
            
            [UIView animateWithDuration:kSTVTableViewEmptyViewAnimationDuration
                             animations:^
             {
                 self.loadingView.alpha = 1.0f;
             }];
        }
    }
}

#pragma mark - Data

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (self.loadingView)
    {
        if (!self.loadingView.superview)
        {
            [self updateLoadingView];
        }
        
        [self bringSubviewToFront:self.loadingView];
    }
    else
    {
        if (!self.emptyView.superview)
        {
            [self updateEmptyView];
        }
        
        [self bringSubviewToFront:self.emptyView];
    }
}

- (void)endUpdates
{
    [super endUpdates];
    
    if (self.loadingView)
    {
        [self updateLoadingView];
    }
    
    [self updateEmptyView];
}

- (void)reloadData
{
    [super reloadData];
    
    self.dataLoaded = NO;
    
    if (self.loadingView)
    {
        [self updateLoadingView];
    }
    else
    {
        [self updateEmptyView];
    }
}

- (BOOL)hasData
{
    BOOL hasData = self.isDataLoaded;
    
    if (!hasData)
    {
        NSNumber *sectionToCheckForData = self.sectionToCheckForData;
        NSInteger numberOfRowsInSection = 0;
        
        for (NSInteger rowNumber = 0; rowNumber < [self numberOfSections]; rowNumber++)
        {
            if (sectionToCheckForData)
            {
                numberOfRowsInSection = [self numberOfRowsInSection:self.sectionToCheckForData.integerValue];
            }
            else
            {
                numberOfRowsInSection = [self numberOfRowsInSection:self.sectionToCheckForData.integerValue];
            }
            
            if (numberOfRowsInSection > 0)
            {
                hasData = YES;
                
                rowNumber = [self numberOfSections];
            }
        }
    }
    
    return hasData;
}

#pragma mark - DidFinishLoadingContent

- (void)didFinishLoadingContent:(BOOL)hasData
{
    self.dataLoaded = hasData;
    
    if (self.loadingView.superview)
    {
        [UIView animateWithDuration:kSTVTableViewEmptyViewAnimationDuration
                         animations:^
         {
             self.loadingView.alpha = 0.0f;
         }
                         completion:^(BOOL finished)
         {
             [self.loadingView removeFromSuperview];
         }];
    }
    
    [self updateEmptyView];
    
    self.didFinishLoadingContentActions = YES;
}

#pragma mark - WillLoadContent

- (void)willLoadContent
{
    self.didFinishLoadingContentActions = NO;
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

- (void)didRefreshWithContent:(BOOL)hasContent
{
    [self.refreshControl endRefreshing];
    [self didFinishLoadingContent:hasContent];
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