//
//  CDQRCodeVC.h
//  SGQRCodeExample
//
//  Created by kingsic on 17/3/20.
//  Copyright © 2017年 kingsic. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CDQRCodeVC;

@protocol CDQRCodeDelegate <NSObject>

@optional
- (void)scanCodeVC:(CDQRCodeVC *)vc result:(NSString *)result;

@end

@interface CDQRCodeVC : UIViewController

@property(nonatomic, weak) id <CDQRCodeDelegate> delegate;

@end



