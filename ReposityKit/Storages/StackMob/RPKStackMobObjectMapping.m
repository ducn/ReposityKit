//
//  RPKStackMobObjectMapping.m
//  ReposityKit
//
//  Created by Duc Ngo on 7/4/13.
//  Copyright (c) 2013 Duc Ngo. All rights reserved.
//

#import "RPKStackMobObjectMapping.h"
#import "RPKIncrementalStore.h"

@implementation RPKStackMobObjectMapping

- (NSString *)primaryKeyFieldForEntity:(NSEntityDescription *)entity{
    return [[[entity name] lowercaseString] stringByAppendingString:@"_id"];
}
- (void) mapJSON:(NSDictionary *)json toManagedObject:(NSManagedObject*)mo withEntityDescription:(NSEntityDescription*)entityDes{
    [[entityDes propertiesByName] enumerateKeysAndObjectsUsingBlock:^(NSString* propertyName, id propertyValue, BOOL *stop) {
        id underscorePropertyName = [propertyName underscore];
        id jsonValue;
        if ([underscorePropertyName isEqualToString:[RPKIncrementalStore primaryKeyFieldNameForLocalEntity:entityDes]]) {
            jsonValue = [json objectForKey:[self primaryKeyFieldForEntity:entityDes]];
        }
        else{
            jsonValue = [json objectForKey:underscorePropertyName];
        }
        if (jsonValue == [NSNull null]) {
            [mo setValue:nil forKey:propertyName];
        } else {
            if ([propertyValue isKindOfClass:[NSAttributeDescription class]]) {
                [mo setValue:jsonValue forKey:propertyName];
            } else if ([(NSRelationshipDescription *)propertyValue isToMany]) {
                
            }
        }
    }];
}
@end
