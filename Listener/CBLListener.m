//
//  CBLListener.m
//  CouchbaseLiteListener
//
//  Created by Jens Alfke on 12/29/11.
//  Copyright (c) 2011 Couchbase, Inc. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file
//  except in compliance with the License. You may obtain a copy of the License at
//    http://www.apache.org/licenses/LICENSE-2.0
//  Unless required by applicable law or agreed to in writing, software distributed under the
//  License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND,
//  either express or implied. See the License for the specific language governing permissions
//  and limitations under the License.

#import "CBLListener.h"
#import "CBLHTTPServer.h"
#import "CBLHTTPConnection.h"
#import "CouchbaseLitePrivate.h"
#import "CBL_Server.h"

#import "HTTPServer.h"


@implementation CBLListener
{
    CBLHTTPServer* _httpServer;
    CBL_Server* _tdServer;
    NSString* _realm;
    BOOL _readOnly;
    BOOL _requiresAuth;
    NSDictionary* _passwords;
}


@synthesize readOnly=_readOnly, requiresAuth=_requiresAuth, realm=_realm;


- (instancetype) initWithManager: (CBLManager*)manager port: (UInt16)port {
    self = [super init];
    if (self) {
        _tdServer = manager.backgroundServer;
        _httpServer = [[CBLHTTPServer alloc] init];
        _httpServer.listener = self;
        _httpServer.tdServer = _tdServer;
        _httpServer.port = port;
        _httpServer.connectionClass = [CBLHTTPConnection class];
        self.realm = @"CouchbaseLite";
    }
    return self;
}


- (void)dealloc
{
    [self stop];
}


- (void) setBonjourName: (NSString*)name type: (NSString*)type {
    _httpServer.name = name;
    _httpServer.type = type;
}

- (NSDictionary *)TXTRecordDictionary                   {return _httpServer.TXTRecordDictionary;}
- (void)setTXTRecordDictionary:(NSDictionary *)dict     {_httpServer.TXTRecordDictionary = dict;}



- (BOOL) start {
    NSError* error;
    return [_httpServer start: &error];
}

- (void) stop {
    [_httpServer stop];
}


- (UInt16) port {
    return _httpServer.listeningPort;
}


- (void) setPasswords: (NSDictionary*)passwords {
    _passwords = [passwords copy];
    _requiresAuth = (_passwords != nil);
}

- (NSString*) passwordForUser:(NSString *)username {
    return _passwords[username];
}


@end



@implementation CBLHTTPServer

@synthesize listener=_listener, tdServer=_tdServer;

@end
