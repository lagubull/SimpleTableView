[![Build Status](https://travis-ci.org/lagubull/SimpleTableView.svg)](https://travis-ci.org/lagubull/SimpleTableView)
[![Version](https://img.shields.io/cocoapods/v/SimpleTableView.svg?style=flat)](http://cocoapods.org/pods/SimpleTableView)
[![License](https://img.shields.io/cocoapods/l/SimpleTableView.svg?style=flat)](http://cocoapods.org/pods/SimpleTableView)
[![Platform](https://img.shields.io/cocoapods/p/SimpleTableView.svg?style=flat)](http://cocoapods.org/pods/SimpleTableView)
[![CocoaPods](https://img.shields.io/cocoapods/metrics/doc-percent/SimpleTableView.svg)](http://cocoapods.org/pods/SimpleTableView)
[![Readme Score](http://readme-score-api.herokuapp.com/score.svg?url=https://github.com/lagubull/simpletableview)](http://clayallsopp.github.io/readme-score?url=https://github.com/lagubull/simpletableview)

SimpleTableView is an easy way of using a tableView connected to CoreData via a NSFetchedResultsController with pagination capabilities.

##Installation via [Cocoapods](https://cocoapods.org/)

To integrate SimpleTableView into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '8.0'

pod 'SimpleTableView'
```

Then, run the following command:

```bash
$ pod install
```

> CocoaPods 0.39.0+ is required to build SimpleTableView.

##Usage

SimpleTableView inherits from UITableView. It is composed of tableView a PaginationView and NSFetchedResultsController.

Pagination is a way of retrieving content from an external source in a controlled manner. When scrolling near the end of the tableView a call to the pagination mechanism is invoked. This is controlled by the property
paginationOffset, by default this property contains 5 based on an ideal page content size of 10 items.

The patinationView can be extended by your own custom class. It contains an UIActivityIndicatorView that will spin in while not hidden along side a UILabel which text and appearance you can and must configure.
kSTVPaginatingViewHeight contains the size of this view.

The fetchedResultsController needs to be configured and then injected but it is not mandatory.

In order to refresh the content in the table pull to refresh is enabled showing a UIRefreshControl at the top. This is connected to the Refresh delegate method so that you can choose the right behaviour.

When connected to Coredata via NSFetchedResultsController, you can take advantage of the delegate didUpdateItemAtIndexPath, this will let you know the index of the cell that needs updating but it is up to the developer to implement this update.

###STVTableView

####Creation

```objc
#import "STVSimpleTableView.h>
....

@property (nonatomic, strong) STVSimpleTableView *tableView;
....

- (STVSimpleTableView *)tableView
{
    if (!_tableView)
    {
        _tableView = [[STVSimpleTableView alloc] initWithFrame:CGRectMake(0.0f,
                                                                    	  kNavigationBarHeight,
                                                                    	  self.view.bounds.size.width,
                                                                   	   	  self.view.bounds.size.height - kNavigationBarHeight)];
        
        _tableView.backgroundColor = [UIColor lightGrayColor];
        
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.allowsSelection = NO;
        _tableView.paginatingView = self.paginatingView;
        _tableView.emptyView = self.emptyView;
        _tableView.loadingView = self.loadingView;
        _tableView.paginationOffset = @(5);
		_tableView.sectionToCheckForData = @(0);
                
        _tableView.dataSource = self;
   	    _tableView.delegate = self;
    	_tableView.dataRetrievalDelegate = self;
    	_tableView.fetchedResultsController = self.fetchedResultsController;
    }
    
    return _tableView;
}
                                                
```

####Refresh

```objc
- (void)refresh
{
	//This method is called after pull to refresh so it would be good implementing logic to
	//populated the datasource.
	
	//An animation has been triggered for the UIRefreshControl.

	 [JSCFeedAPIManager retrieveFeedWithMode:JSCDataRetrievalOperationModeFirstPage
                                    Success:^(id result)
     {
         BOOL hasContent = weakSelf.fetchedResultsController.fetchedObjects.count > 0;
         
         [weakSelf.tableView didRefreshWithContent:hasContent];
         [weakSelf.tableView reloadData];
     }
                                    failure:^(NSError *error)
     {
         BOOL hasContent = weakSelf.fetchedResultsController.fetchedObjects.count > 0;
         
         [weakSelf.tableView didRefreshWithContent:hasContent];
     }];
}

- (void)didUpdateItemAtIndexPath:(NSIndexPath *)indexPath
{
	//A specific item has changed in Coredata, you might update the cell containing this item.
}
```

###STVPaginationView

####Creation

```objc
#import <STVPaginatingView.h>
....

@property (nonatomic, strong) STVPaginatingView *paginatingView;
....

- (STVPaginatingView *)paginatingView
{
    if (!_paginatingView)
    {
        _paginatingView = [[STVPaginatingView alloc] initWithFrame:CGRectMake(0.0f,
                                                                              0.0f,
                                                                              self.view.bounds.size.width,
                                                                              kSTVPaginatingViewHeight)];
        
        _paginatingView.loadingLabel.text = NSLocalizedString(@"Loading", nil);
    }
    
    return _paginatingView;
}                                                       
```

####Pagination

```objc
- (void)paginate
{
	[self.tableView willPaginate]; // Will trigger a pagination animation.
	
	//This method is called when the table view is near to present the last few cells it would good implementing logic to
	//populated the datasource.
	
	[self.tableView didPaginate] // Will finish the pagination animation and prepare the tableView for a new pagination if needed.
}

```

###EmptyView

Optional view to show automatically when there is no data. The only requirement is that is built on top of UIView.

####Usage

```
- (STVSimpleTableView *)tableView
{
    if (!_tableView)
    {
...
 		_tableView.emptyView = self.emptyView;
...
```

####Example

#####Creation

```objc
#import "JSCEmptyView.h"

/**
 View to show when no data is available.
 */
@property (nonatomic, strong) JSCEmptyView *emptyView;

...
- (JSCEmptyView *)emptyView
{
    if (!_emptyView)
    {
        _emptyView = [[JSCEmptyView alloc] initWithFrame:CGRectMake(0.0f,
                                                                    0.0f,
                                                                    self.view.bounds.size.width,
                                                                    self.view.bounds.size.height)];
        
        _emptyView.messageLabel.text = NSLocalizedString(@"NoContentBody", nil);
    }
    
    return _emptyView;
}
```

###LoadingView
Optional view to show automatically while data is being retrieved. The only requirement is that is built on top of UIView.

####Usage

```
- (STVSimpleTableView *)tableView
{
    if (!_tableView)
    {
...
 		_tableView.loadingView = self.loadingViews;
...
```

####Example

#####Creation

```objc
#import "JSCLoadingView.h"

/**
 View to show while data is being loaded.
 */
@property (nonatomic, strong) JSCLoadingView *loadingView;

...
- (JSCLoadingView *)loadingView
{
    if (!_loadingView)
    {
        _loadingView = [[JSCLoadingView alloc] initWithFrame:CGRectMake(0.0f,
                                                                        0.0f,
                                                                        self.view.bounds.size.width,
                                                                        self.view.bounds.size.height)];
    }
    
    return _loadingView;
}
```

####sectionToCheckForData

We can use this optional value if you are interested in the content a particular section. 
This comes handy in case you have fixed content in some sections and want to only check 
for the section in particular that will have real content.

#####Usage

```objc
- (STVSimpleTableView *)tableView
{
    if (!_tableView)
    {
...
		_tableView.sectionToCheckForData = @(0);
...
```

##Found an issue?

Please open a [new Issue here](https://github.com/lagubull/SimpleTableView/issues/new) if you run into a problem specific to EasyAlert, have a feature request, or want to share a comment.

Pull requests are encouraged and greatly appreciated! Please try to maintain consistency with the existing coding style. If you're considering taking on significant changes or additions to the project, please communicate in advance by opening a new Issue. This allows everyone to get onboard with upcoming changes, ensures that changes align with the project's design philosophy, and avoids duplicated work.

Thank you!
