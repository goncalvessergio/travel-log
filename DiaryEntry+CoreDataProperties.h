//
//  DiaryEntry+CoreDataProperties.h
//  Travel Log
//
//  Created by CapitanBanana on 26/05/16.
//  Copyright © 2016 CapitanBanana. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "DiaryEntry.h"

NS_ASSUME_NONNULL_BEGIN

@interface DiaryEntry (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *text;
@property (nullable, nonatomic, retain) NSDate *date;
@property (nullable, nonatomic, retain) NSString *location_lat;
@property (nullable, nonatomic, retain) NSString *location_long;
@property (nullable, nonatomic, retain) Trip *trip;

@end

NS_ASSUME_NONNULL_END
