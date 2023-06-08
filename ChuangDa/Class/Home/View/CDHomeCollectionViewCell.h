//
//  CDHomeCollectionViewCell.h
//  ChuangDa
//
//  Created by 宋直兵 on 2022/10/11.
//

#import <UIKit/UIKit.h>
#import "CDHomeWebHistoryModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface CDHomeCollectionViewCell : UICollectionViewCell

- (void)refreshWithModel:(CDHomeWebHistoryModel *)model;

@end

NS_ASSUME_NONNULL_END
