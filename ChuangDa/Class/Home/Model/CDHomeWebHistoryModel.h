//
//  CDHomeHistoryURL.h
//  ChuangDa
//
//  Created by 宋直兵 on 2022/10/11.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CDHomeWebHistoryModel : NSObject

+ (CDHomeWebHistoryModel *_Nullable)modelWithJsonString:(NSString *)jsonString;

@property(nonatomic, copy) NSString *code;

@property(nonatomic, copy) NSString *name;

@property(nonatomic, copy) NSString *URL;

@property(nonatomic, copy) NSString *jsonString;

@end

NS_ASSUME_NONNULL_END
