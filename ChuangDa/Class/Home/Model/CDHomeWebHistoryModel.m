//
//  CDHomeHistoryURL.m
//  ChuangDa
//
//  Created by 宋直兵 on 2022/10/11.
//

#import "CDHomeWebHistoryModel.h"
#import <SSHelpTools/NSString+SSHelp.h>
#import <SSHelpTools/SSHelpDefines.h>

@interface CDHomeWebHistoryModel()
@end

@implementation CDHomeWebHistoryModel

+ (CDHomeWebHistoryModel *_Nullable)modelWithJsonString:(NSString *)jsonString
{
    if (SSEqualToNotEmptyString(jsonString)) {
        NSDictionary *dict = jsonString.ss_jsonValueDecoded;
        NSString *URL  = SSEncodeStringFromDict(dict, @"url");
        NSString *code = SSEncodeStringFromDict(dict, @"code");
        NSString *name = SSEncodeStringFromDict(dict, @"name");

        if (URL.length && code.length) {
            CDHomeWebHistoryModel *model = [[CDHomeWebHistoryModel alloc] init];
            model.jsonString = jsonString;
            model.URL = URL;
            model.code = code;
            model.name = name;
            return model;
        }
    }
    return nil;
}

@end
