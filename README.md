[![Build Status](https://travis-ci.org/lagubull/SimpleTableView.svg)](https://travis-ci.org/lagubull/SimpleTableView)
[![Version](https://img.shields.io/cocoapods/v/SimpleTableView.svg?style=flat)](http://cocoapods.org/pods/SimpleTableView)
[![License](https://img.shields.io/cocoapods/l/SimpleTableView.svg?style=flat)](http://cocoapods.org/pods/SimpleTableView)
[![Platform](https://img.shields.io/cocoapods/p/SimpleTableView.svg?style=flat)](http://cocoapods.org/pods/SimpleTableView)
[![CocoaPods](https://img.shields.io/cocoapods/metrics/doc-percent/SimpleTableView.svg)](http://cocoapods.org/pods/SimpleTableView)

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

> CocoaPods 0.39.0+ is required to build EasyAlert.

##Usage

SimpleTableView inherits from UITableView.It is composed of tableView a PaginationView and NSFetchedResultsController. The patinationView can be extended by your own custom class. The fetchedResultsController needs to be configured and then injected but it is not mandatory either.

#### STVTableView

####Creation

```objc
#import "STVSimpleTableView.h>
#import "STVPaginatingView.h"
....

@property (nonatomic, strong) STVSimpleTableView *tableView;

@property (nonatomic, strong) STVPaginatingView *paginatingView;
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
        _tableView.paginationOffset = @(5);
        
        _tableView.dataSource = self;
   	    _tableView.delegate = self;
    	_tableView.dataRetrievalDelegate = self;
    	_tableView.fetchedResultsController = self.fetchedResultsController;
    }
    
    return _tableView;
}

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

#### STVDataRetrievalTableViewDelegate

```objc

- (void)refresh
{
	//This method is called after pull to refresh so it would good implementing logic to
	//populated the datasource.
	
	//An animation has been triggered for the UIRefreshControl.
}

- (void)paginate
{
	//This method is called when the table view is near to present the last few cells it would good implementing logic to
	//populated the datasource.
	
	//An animation will be triggered for the paginationView if it exists.
}

- (void)didUpdateItemAtIndexPath:(NSIndexPath *)indexPath
{
	//A specific item has changed in Coredata, you might update the cell containing this item.
}
```

##Found an issue?

Please open a [new Issue here](https://github.com/lagubull/SimpleTableView/issues/new) if you run into a problem specific to EasyAlert, have a feature request, or want to share a comment.

Pull requests are encouraged and greatly appreciated! Please try to maintain consistency with the existing coding style. If you're considering taking on significant changes or additions to the project, please communicate in advance by opening a new Issue. This allows everyone to get onboard with upcoming changes, ensures that changes align with the project's design philosophy, and avoids duplicated work.

Thank you!
