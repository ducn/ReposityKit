#import <CoreData/CoreData.h>
#import <CoreLocation/CoreLocation.h>

@interface RPKQuery : NSObject

///-------------------------------
/// @name Properties
///-------------------------------

@property (nonatomic, strong) NSDictionary *requestParameters;


@property (nonatomic, strong) NSDictionary *requestHeaders;

@property (readonly) NSString *schemaName;

@property (readonly) NSEntityDescription *entity;

#pragma mark - Creating queries
- (id)initWithEntity:(NSEntityDescription *)entity;
- (id)initWithSchema:(NSString *)schema;


#pragma mark - Where clauses
- (void)where:(NSString *)field isEqualTo:(id)value;
- (void)where:(NSString *)field isNotEqualTo:(id)value;
- (void)where:(NSString *)field isLessThan:(id)value;
- (void)where:(NSString *)field isLessThanOrEqualTo:(id)value;
- (void)where:(NSString *)field isGreaterThan:(id)value;
- (void)where:(NSString *)field isGreaterThanOrEqualTo:(id)value;
- (void)where:(NSString *)field isIn:(NSArray *)valuesArray;
- (void)where:(NSString *)field isNotIn:(NSArray *)valuesArray;


#pragma mark - Pagination / Limiting
- (void)fromIndex:(NSUInteger)start toIndex:(NSUInteger)end;
- (void)limit:(NSUInteger)count;


#pragma mark - Order-by clause
- (void)orderByField:(NSString *)field ascending:(BOOL)ascending;


#pragma mark - And/Or
- (RPKQuery *)and:(RPKQuery *)query;
- (RPKQuery *)or:(RPKQuery *)query;

@end
