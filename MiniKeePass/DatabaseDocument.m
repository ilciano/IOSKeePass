/*
 * Copyright 2011-2012 Jason Rush and John Flanagan. All rights reserved.
 * Mdified by Frank Hausmann 2020-2021
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#import "DatabaseDocument.h"
#import "AppSettings.h"


@interface DatabaseDocument ()
#ifdef USE_KDB
@property (nonatomic, strong) KdbPassword *kdbPassword;
#else
@property (nonatomic, strong) KPKCompositeKey *kpkkey;
#endif
@end

@implementation DatabaseDocument

- (id)initWithFilename:(NSString *)filename password:(NSString *)password keyFile:(NSString *)keyFile {
    self = [super init];
    if (self) {
        if (password == nil && keyFile == nil) {
            @throw [NSException exceptionWithName:@"IllegalArgument"
                                           reason:NSLocalizedString(@"No password or keyfile specified", nil)
                                         userInfo:nil];
        }

        self.filename = filename;

       
#ifdef USE_KDB
        
        NSStringEncoding passwordEncoding = [[AppSettings sharedInstance] passwordEncoding];
        self.kdbPassword = [[KdbPassword alloc] initWithPassword:password
                                                passwordEncoding:passwordEncoding
                                                         keyFile:keyFile];

        self.kdbTree = [KdbReaderFactory load:self.filename withPassword:self.kdbPassword];
#else
        self.kpkkey = [[KPKCompositeKey alloc] initWithKeys:@[[KPKKey keyWithPassword:password]]];
        
      
        NSData *data = [self _loadTestDataBase:self.filename];// extension:@"kdb"];
        if(data ==nil)
            @throw [NSException exceptionWithName:@"IllegalData"
                                           reason:NSLocalizedString(@"Wrong Databae Data", nil)
                                         userInfo:nil];
        self.kdbTree = [[KPKTree alloc] initWithData:data key:self.kpkkey error:NULL];
        
        if(self.kdbTree == nil)
            @throw [NSException exceptionWithName:@"IllegalData"
                                           reason:NSLocalizedString(@"Passwords do not match", nil)
                                         userInfo:nil];
#endif
    }
    return self;
}

- (NSData *)_loadTestDataBase:(NSString *)name{
  NSURL *url = [NSURL fileURLWithPath:name];
  return [NSData dataWithContentsOfURL:url];
}


- (NSData *)_loadTestDataBase:(NSString *)name extension:(NSString *)extension {
  NSBundle *myBundle = [NSBundle bundleForClass:self.class];
  NSURL *url = [myBundle URLForResource:name withExtension:extension];
  return [NSData dataWithContentsOfURL:url];
}

- (void)save {
#ifdef USE_KDB
    [KdbWriterFactory persist:self.kdbTree file:self.filename withPassword:self.kdbPassword];
#else
    NSError __autoreleasing *error = nil;
    NSData *data = [self.kdbTree encryptWithKey:self.kpkkey format:KPKDatabaseFormatKdbx error:&error];
    NSLog(@"%@",error);
    
    [data writeToFile:self.filename atomically:YES];
#endif
}


+ (void)searchGroup:(KPKGroup *)group searchText:(NSString *)searchText results:(NSMutableArray *)results {
    for (KPKEntry *entry in group.entries) {
        if ([self matchesEntry:entry searchText:searchText]) {
            [results addObject:entry];
        }
    }

    for (KPKGroup *g in group.groups) {
        if (![g.title isEqualToString:@"Backup"] && ![g.title isEqualToString:NSLocalizedString(@"Backup", nil)]) {
            [self searchGroup:g searchText:searchText results:results];
        }
    }
}

+ (BOOL)matchesEntry:(KPKEntry *)entry searchText:(NSString *)searchText {
    BOOL searchTitleOnly = [[AppSettings sharedInstance] searchTitleOnly];

    if ([entry.title rangeOfString:searchText options:NSCaseInsensitiveSearch].length > 0) {
        return YES;
    }
    if (!searchTitleOnly) {
        if ([entry.username rangeOfString:searchText options:NSCaseInsensitiveSearch].length > 0) {
            return YES;
        }
        if ([entry.url rangeOfString:searchText options:NSCaseInsensitiveSearch].length > 0) {
            return YES;
        }
        if ([entry.notes rangeOfString:searchText options:NSCaseInsensitiveSearch].length > 0) {
            return YES;
        }
    }
    return NO;
}

@end
