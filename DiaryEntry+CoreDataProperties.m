//
//  DiaryEntry+CoreDataProperties.m
//  Travel Log
//
//  Created by CapitanBanana on 26/05/16.
//  Copyright © 2016 CapitanBanana. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "DiaryEntry+CoreDataProperties.h"

@implementation DiaryEntry (CoreDataProperties)

@dynamic text;
@dynamic date;
@dynamic location_lat;
@dynamic location_long;
@dynamic trip;

@end
