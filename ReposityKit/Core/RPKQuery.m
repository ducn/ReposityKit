#import "RPKQuery.h"

#define CONCAT(prefix, suffix) ([NSString stringWithFormat:@"%@%@", prefix, suffix])

#define EARTH_RADIAN_MILES 3956.6
#define EARTH_RADIAN_KM    6367.5

@interface RPKQuery () {
    int _andGroup;
    int _orGroup;
    BOOL _isOrQuery;
}

@end

@implementation RPKQuery

@synthesize requestParameters = _requestParameters;
@synthesize requestHeaders = _requestHeaders;
@synthesize schemaName = _schemaName;
@synthesize entity = _entity;

- (id)initWithEntity:(NSEntityDescription *)entity
{
    
    NSString *schemaName = [[entity name] lowercaseString];
    return [self initWithSchema:schemaName entity:entity];
    
}

- (id)initWithSchema:(NSString *)schema
{
    return [self initWithSchema:schema entity:nil];
}

- (id)initWithSchema:(NSString *)schema entity:(NSEntityDescription *)entity
{
    self = [super init];
    if (self) {
        _entity = entity;
        _schemaName = [schema lowercaseString];
        _requestParameters = [NSMutableDictionary dictionaryWithCapacity:1];
        _requestHeaders = [NSMutableDictionary dictionaryWithCapacity:1];
        _andGroup = 0;
        _orGroup = 0;
        _isOrQuery = NO;
    }
    return self;
}

- (void)where:(NSString *)field isEqualTo:(id)value
{
    NSMutableDictionary *requestParametersCopy = [self.requestParameters mutableCopy];
    if(value == nil) {
        [requestParametersCopy setObject:@"true"
                                  forKey:CONCAT(field, @"[null]")];
    } else if ([value isEqual:@""]) {
        [requestParametersCopy setObject:@"true"
                                  forKey:CONCAT(field, @"[empty]")];
    } else {
        [requestParametersCopy setObject:[self marshalValue:value] 
                                  forKey:field];
    }
    self.requestParameters = [NSDictionary dictionaryWithDictionary:requestParametersCopy];
}

- (void)where:(NSString *)field isNotEqualTo:(id)value
{
    NSMutableDictionary *requestParametersCopy = [self.requestParameters mutableCopy];
    if(value == nil) {
        [requestParametersCopy setObject:@"false"
                                  forKey:CONCAT(field, @"[null]")];
    } else if ([value isEqual:@""]) {
        [requestParametersCopy setObject:@"false"
                                  forKey:CONCAT(field, @"[empty]")];
    } else {
        [requestParametersCopy setObject:[self marshalValue:value]
                                  forKey:CONCAT(field, @"[ne]")];
    }
    self.requestParameters = [NSDictionary dictionaryWithDictionary:requestParametersCopy];
}

- (void)where:(NSString *)field isLessThan:(id)value
{
    NSMutableDictionary *requestParametersCopy = [self.requestParameters mutableCopy];
    [requestParametersCopy setObject:[self marshalValue:value]
                              forKey:CONCAT(field, @"[lt]")];
    self.requestParameters = [NSDictionary dictionaryWithDictionary:requestParametersCopy];
}

- (void)where:(NSString *)field isLessThanOrEqualTo:(id)value
{
    NSMutableDictionary *requestParametersCopy = [self.requestParameters mutableCopy];
    [requestParametersCopy setObject:[self marshalValue:value]
                              forKey:CONCAT(field, @"[lte]")];
    self.requestParameters = [NSDictionary dictionaryWithDictionary:requestParametersCopy];
}

- (void)where:(NSString *)field isGreaterThan:(id)value
{
    NSMutableDictionary *requestParametersCopy = [self.requestParameters mutableCopy];
    [requestParametersCopy setObject:[self marshalValue:value]
                              forKey:CONCAT(field, @"[gt]")];
    self.requestParameters = [NSDictionary dictionaryWithDictionary:requestParametersCopy];
}

- (void)where:(NSString *)field isGreaterThanOrEqualTo:(id)value
{
    NSMutableDictionary *requestParametersCopy = [self.requestParameters mutableCopy];
    [requestParametersCopy setObject:[self marshalValue:value]
                              forKey:CONCAT(field, @"[gte]")];
    self.requestParameters = [NSDictionary dictionaryWithDictionary:requestParametersCopy];
}

- (void)where:(NSString *)field isIn:(NSArray *)valuesArray
{
    NSMutableDictionary *requestParametersCopy = [self.requestParameters mutableCopy];
    NSString *possibleValues = [valuesArray componentsJoinedByString:@","];
    [requestParametersCopy setObject:possibleValues
                              forKey:CONCAT(field, @"[in]")];
    self.requestParameters = [NSDictionary dictionaryWithDictionary:requestParametersCopy];
}

- (void)where:(NSString *)field isNotIn:(NSArray *)valuesArray
{
    NSMutableDictionary *requestParametersCopy = [self.requestParameters mutableCopy];
    NSString *possibleValues = [valuesArray componentsJoinedByString:@","];
    [requestParametersCopy setObject:possibleValues
                              forKey:CONCAT(field, @"[nin]")];
    self.requestParameters = [NSDictionary dictionaryWithDictionary:requestParametersCopy];
}



- (void)fromIndex:(NSUInteger)start toIndex:(NSUInteger)end
{
    NSString *rangeHeader = [NSString stringWithFormat:@"objects=%i-%i", (int)start, (int)end];
    
    NSMutableDictionary *requestHeadersCopy = [self.requestHeaders mutableCopy];
    [requestHeadersCopy setObject:rangeHeader forKey:@"Range"];
    
    self.requestHeaders = [NSDictionary dictionaryWithDictionary:requestHeadersCopy];
}

// TODO: verify that asking for Range 0-N where N is > the # records doesn't explode
- (void)limit:(NSUInteger)count {
    [self fromIndex:0 toIndex:count-1];
}

- (void)orderByField:(NSString *)field ascending:(BOOL)ascending
{
    NSString *ordering = ascending ? @"asc" : @"desc";
    NSString *orderBy = [NSString stringWithFormat:@"%@:%@", field, ordering];
    
    NSString *existingOrderByHeader = [self.requestHeaders objectForKey:@"X-StackMob-OrderBy"];
    NSString *orderByHeader;
    
    if (existingOrderByHeader == nil) {
        orderByHeader = orderBy; 
    } else {
        orderByHeader = [NSString stringWithFormat:@"%@,%@", existingOrderByHeader, orderBy];
    }
    NSMutableDictionary *requestHeadersCopy = [self.requestHeaders mutableCopy];
    [requestHeadersCopy setObject:orderByHeader forKey:@"X-StackMob-OrderBy"];
    
    self.requestHeaders = [NSDictionary dictionaryWithDictionary:requestHeadersCopy];
}

- (id)marshalValue:(id)value {
    
    if ([value isKindOfClass:[NSDate class]]) {
    
        long double convertedValue = (long double)[value timeIntervalSince1970] * 1000.0000;
        
        return [NSNumber numberWithUnsignedLongLong:floorl(convertedValue)];
    }
    
    return value;
}

- (void)setKeysAndValuesFrom:(NSDictionary *)requestParameters to:(NSMutableDictionary *__autoreleasing*)newParameters
{
    BOOL shouldAddAnd = NO;
    __block NSString *keyToSet = @"";
    shouldAddAnd = [requestParameters count] > 1 ? YES : NO;
    if (shouldAddAnd) {
        _andGroup += 1;
        [requestParameters enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            keyToSet = [NSString stringWithFormat:@"[or%d].[and%d].%@", _orGroup, _andGroup, key];
            if (![[*newParameters allKeys] containsObject:keyToSet]) {
                [*newParameters setObject:obj forKey:keyToSet];
            } else {
                [NSException raise:RPKExceptionIncompatibleObject format:@"Duplicate parameter key found: %@.  This may cause unexpected query results as the key to set will override the existing key/value.  To include a condition where a key can be one of multiple values, use IN i.e. 'key IN [value1, value2]'.", keyToSet];
            }
        }];
    } else {
        [requestParameters enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            keyToSet = [NSString stringWithFormat:@"[or%d].%@", _orGroup, key];
            if (![[*newParameters allKeys] containsObject:keyToSet]) {
                [*newParameters setObject:obj forKey:keyToSet];
            } else {
                [NSException raise:RPKExceptionIncompatibleObject format:@"Duplicate parameter key found: %@.  This may cause unexpected query results as the key to set will override the existing key/value.  To include a condition where a key can be one of multiple values, use IN i.e. 'key IN [value1, value2]'.", keyToSet];
            }
        }];
    }
}

- (RPKQuery *)or:(RPKQuery *)query
{
    NSMutableDictionary *newParameters = [NSMutableDictionary dictionary];
    if (_isOrQuery) {
        NSMutableDictionary *currentParametersCopy = [self.requestParameters mutableCopy];
        [self setKeysAndValuesFrom:query.requestParameters to:&newParameters];
        
        // Enumerate through entries to be added and check for duplicate keys that would be overriden
        [newParameters enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            if (![[currentParametersCopy allKeys] containsObject:key]) {
                [currentParametersCopy setObject:obj forKey:key];
            } else {
                [NSException raise:RPKExceptionIncompatibleObject format:@"Duplicate parameter key found: '%@'.  This may cause unexpected query results as the new key/value will override the existing key/value.  To include a condition where a key can be one of multiple values, use IN i.e. 'key IN [value1, value2]'.", key];
            }
        }];
        self.requestParameters = [NSDictionary dictionaryWithDictionary:currentParametersCopy];
        
    } else {
        _isOrQuery = YES;
        _orGroup += 1;
        
        [self setKeysAndValuesFrom:self.requestParameters to:&newParameters];
        [self setKeysAndValuesFrom:query.requestParameters to:&newParameters];
        
        self.requestParameters = [NSDictionary dictionaryWithDictionary:newParameters];
    }
    
    return self;
}

- (RPKQuery *)and:(RPKQuery *)query
{
    NSMutableDictionary *requestParametersCopy = [self.requestParameters mutableCopy];
    [requestParametersCopy addEntriesFromDictionary:query.requestParameters];
    self.requestParameters = [NSDictionary dictionaryWithDictionary:requestParametersCopy];
    
    return self;
}

@end
