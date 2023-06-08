//
//  CDStorageManager.h
//  ChuangDa
//
//  Created by 宋直兵 on 2022/10/11.
//

#import <Foundation/Foundation.h>
#import "CDHomeWebHistoryModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface CDStorageManager : NSObject

+ (instancetype)sharedManager;

#pragma mark - motion Model Actions

/**
 Save a motion model to database.
 */
- (BOOL)saveHomeWebHistoryModel:(CDHomeWebHistoryModel *)model;

/**
 updatea motion model to database.
 */
- (BOOL)updateHomeWebHistoryModel:(CDHomeWebHistoryModel *)model;

/**
 According to the models to remove the motion models where happened in dataBase.
 If any one fails, it returns to NO, and any failure will not affect others.
 */
- (BOOL)removeHomeWebHistoryModels:(NSArray <CDHomeWebHistoryModel *>*)models;

/**
 Get all motion models in database(this time). If nothing, it will return an emtpy array.
 */
- (NSArray <CDHomeWebHistoryModel *>*)getAllHomeWebHistoryModels;

@end

NS_ASSUME_NONNULL_END
