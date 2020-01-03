//
//  AccountDetailViewController.h
//  uraInsta
//
//  Created by phantomSTo on 2019/12/24.
//  Copyright © 2019 mac12. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AccountDetailViewController : UIViewController
@property (strong, nonatomic) IBOutlet UIBarButtonItem *btnEditAccountDetail;
@property (strong, nonatomic) IBOutlet UILabel *labelAccountEmail;
@property (strong, nonatomic) IBOutlet UILabel *labelAccountTopName;
@property (strong, nonatomic) IBOutlet UILabel *labelAccountBottomName;
@property (strong, nonatomic) IBOutlet UITextView *labelAccountDetail;

@end

NS_ASSUME_NONNULL_END
