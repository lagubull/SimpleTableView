//
//  STVPaginatingView.h
//  SimpleTableView
//
//  Created by Javier Laguna on 21/02/2016.
//  Copyright © 2016 Javier Laguna. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 Height of this view.
 */
extern CGFloat const kSTVPaginatingViewHeight;

/**
 Loading view for paginating on feed.
 */
@interface STVPaginatingView : UIView

/**
 Label to show loading text.
 */
@property (nonatomic, strong, readonly) UILabel *loadingLabel;

/**
 Handles starting the animation of loading indicator.
 */
- (void)startAnimating;

/**
 Handles stopping the animation of loading indicator.
 */
- (void)stopAnimating;

@end