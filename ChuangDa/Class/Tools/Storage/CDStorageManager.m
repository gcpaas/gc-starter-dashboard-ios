//
//  CDStorageManager.m
//  ChuangDa
//
//  Created by 宋直兵 on 2022/10/11.
//

#import "CDStorageManager.h"
#import <FMDB/FMDB.h>
#import <SSHelpTools/SSHelpTools.h>

// Table Name
static NSString *const kHomeWebHistoryTable = @"HomeWebHistoryTable";
// Column Name
static NSString *const kIdentityColumn      = @"Identity";
static NSString *const kObjectStringColumn  = @"ObjectString";
static NSString *const kObjectCodeColumn    = @"ObjectCode";

// Table SQL
static NSString *const kCreateHomeWebHistoryTableSQL = @"CREATE TABLE IF NOT EXISTS HomeWebHistoryTable(ObjectString TEXT NOT NULL, ObjectCode TEXT NOT NULL);";


@interface CDStorageManager()
@property(nonatomic, strong) FMDatabaseQueue *dbQueue;
@end


@implementation CDStorageManager

+ (instancetype)sharedManager
{
    static CDStorageManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[CDStorageManager alloc] init];
    });
    return manager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        __unused BOOL result = [self initDatabase];  // 创建数据库
        NSAssert(result, @"Init Database fail");
    }
    return self;
}

/**
 Init database.
 */
- (BOOL)initDatabase
{
    NSString *doc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    doc = [doc stringByAppendingPathComponent:@"CDStorage"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:doc]) {
        NSError *error;
        [[NSFileManager  defaultManager] createDirectoryAtPath:doc withIntermediateDirectories:YES attributes:nil error:&error];
        if (error) {
            SSLog(@"StroageManage create folder fail, error = %@",error.description);
        }
        NSAssert(!error, error.description);
    }
    NSString *filePath = [doc stringByAppendingPathComponent:@"CDFMDB.db"];
    _dbQueue = [FMDatabaseQueue databaseQueueWithPath:filePath];
    __block BOOL ret1 = NO;
    [_dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
        // ObjectData use to convert to BGLCrashModel, launchDate use as identity
        ret1 = [db executeUpdate:kCreateHomeWebHistoryTableSQL];
        if (!ret1) {
            SSLog(@"StroageManage create StudentModelTable fail");
        }
    }];
    return ret1;
}

- (BOOL)saveHomeWebHistoryModel:(CDHomeWebHistoryModel *)model
{
    if (model.jsonString.length == 0) {
        SSLog(@"StroageManage save CDHomeHistoryURL model fail, because model's jsonString is null");
        return NO;
    }
    
    NSArray *arguments = @[model.code,model.jsonString];
    __block BOOL success = NO;
    [_dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
        NSError *error;
        success = [db executeUpdate:[NSString stringWithFormat:@"INSERT INTO %@(%@,%@) VALUES (?,?);",kHomeWebHistoryTable,kObjectCodeColumn,kObjectStringColumn] values:arguments error:&error];
        if (!success) {
            SSLog(@"CSStorageManager save crash model fail,Error = %@",error.localizedDescription);
        } else {
            SSLog(@"CSStorageManager save crash success!");
        }
    }];
    return success;
}

/**
 updatea motion model to database.
 */
- (BOOL)updateHomeWebHistoryModel:(CDHomeWebHistoryModel *)model
{
    if (model.jsonString.length == 0) {
        SSLog(@"StroageManage save CDHomeHistoryURL model fail, because model's jsonString is null");
        return NO;
    }
    
    __block BOOL success = NO;
    [_dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
        NSString *sql =  [NSString stringWithFormat:@"UPDATE %@ SET '%@'='%@' WHERE '%@' = '%@' ;",kHomeWebHistoryTable,kObjectStringColumn,model.jsonString,kObjectCodeColumn,model.code];
        success = [db executeUpdate:sql];
        if (!success) {
            SSLog(@"CSStorageManager save crash model fail,Error ..");
        } else {
            SSLog(@"CSStorageManager save crash success!");
        }
    }];
    return success;
}

- (NSArray <CDHomeWebHistoryModel *> *)getAllHomeWebHistoryModels
{
    __block NSMutableArray *modelArray = [[NSMutableArray alloc] init];
    [_dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
        FMResultSet *set = [db executeQuery:[NSString stringWithFormat:@"SELECT * FROM %@",kHomeWebHistoryTable]];
        while ([set next]) {
            NSString *jsonSting = [set stringForColumn:kObjectStringColumn];
            CDHomeWebHistoryModel *model = [CDHomeWebHistoryModel modelWithJsonString:jsonSting];
            if (model) {
                [modelArray insertObject:model atIndex:0];
            }
        }
    }];
    
    return modelArray.copy;
}

- (BOOL)removeHomeWebHistoryModels:(NSArray <CDHomeWebHistoryModel *>*)models
{
    BOOL ret = YES;
    for (CDHomeWebHistoryModel *model in models) {
        ret = ret && [self _removeMotionModel:model];
    }
    return ret;
}

// 内部真正实现删除的方法操作
- (BOOL)_removeMotionModel:(CDHomeWebHistoryModel *)model
{
    __block BOOL success = NO;
    [_dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
        NSError *error;
        success = [db executeUpdate:[NSString stringWithFormat:@"DELETE FROM %@ WHERE %@ = ?",kHomeWebHistoryTable,kObjectCodeColumn] values:@[model.code] error:&error];
        if (!success) {
            SSLog(@"Delete WebHistory model fail,error = %@",error);
        } else {
            SSLog(@"Delete WebHistory model success, yeah !");
        }
    }];
    return success;
}

@end
