//
//  VideoSession.m
//  Video
//
//  Created by MacMiniA on 20/01/14.
//  Copyright (c) 2014 MacMiniA. All rights reserved.
//

#import "VideoSession.h"
#import "AVFoundation/AVFoundation.h"
#import "AssetsLibrary/ALAssetsLibrary.h"
#import "AssetsLibrary/ALAssetRepresentation.h"

@implementation NSString (URLEncoding)
-(NSString *)urlEncodeUsingEncoding:(NSStringEncoding)encoding {
	return (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                                 (CFStringRef)self,
                                                                                 NULL,
                                                                                 (CFStringRef)@"!*'\"();:@&=+$,/?%#[]% ",
                                                                                 CFStringConvertNSStringEncodingToEncoding(encoding)));
}
@end

@interface VideoSession()
    @property (strong, nonatomic) NSMutableString* cookies;

@end;

@implementation VideoSession

- (id) initWithUserName:(NSString *) username WithPassWord:(NSString *) password {
    self = [super init];
    if (!self)
        return nil;
    self.username = username;
    self.password = password;
    return self;
}

- (int) CreateSession {
    return [self AuthenticateUser:self.username WithPassWord:self.password];
}

- (int)AuthenticateUser:(NSString *)username WithPassWord:(NSString *)password  {
    
    NSURL *url = [NSURL URLWithString:@"http://mydomain.com/loginurl"];
    NSString *bodyData = [NSString stringWithFormat:@"USER=%@&PASSWORD=%@", username, password];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setValue:[NSString stringWithFormat:@"%lu", [bodyData length]] forHTTPHeaderField:@"Content-Length"];
    //[request setHTTPBody:[NSData dataWithContentsOfFile:path]];
    [request setHTTPBody:[NSData dataWithBytes:[bodyData UTF8String] length:[bodyData length]]];
    
    NSHTTPURLResponse *response = nil;
    NSError *error = nil;
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    if ( response.statusCode != 200 ) {
        self.authenticated = NO;
        NSLog(@"ERROR HTTP STATUS CODE:%lu", response.statusCode);
        return -1;
    }
    if ( responseData == nil ) {
        self.authenticated = NO;
        NSLog(@"ResponseData is nil");
        return -1;
    }
    if ( error != nil ) {
        self.authenticated = NO;
        NSLog(@"%@", [error localizedDescription]);
        return -1;
    }
    
    self.cookies = [[NSMutableString alloc] init];
    NSArray *hCookies = [NSHTTPCookie cookiesWithResponseHeaderFields:response.allHeaderFields forURL:url];
    for (NSHTTPCookie* cookie in hCookies) {
        [self.cookies appendFormat:@"%@=%@; ", cookie.name, cookie.value];
        NSLog(@"%@: %@", cookie.name, cookie.value);
        if ( ([cookie.name compare:@"SESSIONCOOKIE"] == 0) && ([cookie.value length] == 8)) {
            NSLog(@"Valid Username");
            self.authenticated = YES;
        }
    }
    if (self.authenticated) {
        [self GetContacts:@"testing"];
        return 1;
    }
    return -1;
}

- (void) GetContacts:(NSString *)searchStr {
    
    NSString *urlAsString = [NSString stringWithFormat:@"http://mydomain.com/contacturl?q=%@", searchStr];
    NSURL *url = [[NSURL alloc] initWithString:urlAsString];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request addValue:self.cookies forHTTPHeaderField:@"Cookie"];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        if ( httpResponse.statusCode != 200 ) {
            NSLog(@"ERROR HTTP STATUS CODE:%ld", httpResponse.statusCode);
            [self.acDelegate fetchingAutoCompleteFailedWithError:error];
            return;
        }
        if (error) {
            NSLog(@"%@", [error localizedDescription]);
            [self.acDelegate fetchingAutoCompleteFailedWithError:error];
            return;
        }
        
        if( data == nil) {
            NSLog(@"No data");
            [self.acDelegate fetchingAutoCompleteFailedWithError:error];
            return;
        }
        
        NSLog(@"%s", [data bytes] );
        [self.acDelegate receivedAutoCompleteJSON:data];
    
    }];
    return;
}


- (void) SendVideoMail:(NSURL *)videoUrl To:(NSString *)to WithSubject:(NSString *)subject
              WithBody:(NSString *)body {
    
    
    NSMutableString* urlString = [[NSMutableString alloc] initWithString:@"http://mydomain.com/sendurl"];
    [urlString appendFormat:@"%lli", [@(floor([[NSDate date] timeIntervalSince1970])) longLongValue]];
    
    NSString *boundary = @"---------------------------14737809831466499882746641449";
    NSMutableData *postbody = [NSMutableData data];
    [postbody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [postbody appendData:[@"Content-Disposition: form-data; name=\"Subject\"\r\n\r\n"
                          dataUsingEncoding:NSUTF8StringEncoding]];
    [postbody appendData:[subject dataUsingEncoding:NSUTF8StringEncoding]];
    [postbody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [postbody appendData:[@"Content-Disposition: form-data; name=\"To\"\r\n\r\n"
                          dataUsingEncoding:NSUTF8StringEncoding]];
    [postbody appendData:[to dataUsingEncoding:NSUTF8StringEncoding]];
    [postbody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [postbody appendData:[@"Content-Disposition: form-data; name=\"msgText\"\r\n\r\n"
                          dataUsingEncoding:NSUTF8StringEncoding]];
    [postbody appendData:[body dataUsingEncoding:NSUTF8StringEncoding]];
    [postbody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [postbody appendData:[@"Content-Disposition: form-data; name=\"userfile\"; filename=\"video.mov\"\r\n"
                          dataUsingEncoding:NSUTF8StringEncoding]];
    [postbody appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSLog(@"video url %@", videoUrl.absoluteString);
    //NSString *assetPrefix = @"assets-library:";
    NSData *data = [NSData dataWithContentsOfURL:videoUrl];
    if ([data length] != 0) {
        [postbody appendData:data];
        [postbody appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        return [self SendVideoMail:urlString WithData:postbody WithBoundary:boundary];
    }
    
    NSLog(@"asset Url");
    ALAssetsLibrary *assetLibrary=[[ALAssetsLibrary alloc] init];
    [assetLibrary assetForURL:videoUrl resultBlock:^(ALAsset *asset) {
        ALAssetRepresentation *rep = [asset defaultRepresentation];
        Byte *buffer = (Byte*)malloc(rep.size);
        NSUInteger buffered = [rep getBytes:buffer fromOffset:0.0 length:rep.size error:nil];
        NSData *asData = [NSData dataWithBytesNoCopy:buffer length:buffered freeWhenDone:YES];
        NSLog(@"data length %lu", [asData length]);
        [postbody appendData:asData];
        [postbody appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        return [self SendVideoMail:urlString WithData:postbody WithBoundary:boundary];
        
    } failureBlock:^(NSError *err) {
        NSLog(@"Error: %@",[err localizedDescription]);
        [self.svmDelegate SendVideoMailFailedWithError:err];
        return;
    }];
    return;
}

- (void) SendVideoMail:(NSString *)urlString WithData:(NSMutableData *) postBody WithBoundary:(NSString *)boundary {
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"POST"];
    [request addValue:self.cookies forHTTPHeaderField:@"Cookie"];
    NSLog(@"Cookie:%@", self.cookies);
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
    [request addValue:contentType forHTTPHeaderField: @"Content-Type"];
    [request addValue:[NSString stringWithFormat:@"%lu", [postBody length]] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:postBody];
    [self.svmDelegate SendVideoMailInProgress];
    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        if ( httpResponse.statusCode != 200 ) {
            NSLog(@"ERROR HTTP STATUS CODE:%ld", httpResponse.statusCode);
            [self.svmDelegate SendVideoMailFailedWithError:error];
            return;
        }
        if (error) {
            NSLog(@"%@", [error localizedDescription]);
            [self.svmDelegate SendVideoMailFailedWithError:error];
            return;
        }
        
        if( data == nil) {
            NSLog(@"No data");
            [self.svmDelegate SendVideoMailFailedWithError:error];
            return;
        }
        
        NSLog(@"Videomail sent");
        [self.svmDelegate SendVideoMailSuccess:data];
        
    }];
    return;
    
}

- (void) GetVideoMails:(NSString *) folder {
    
    NSString *urlAsString = [NSString stringWithFormat:@"http://mydomain.com/getvideourl"];
    NSURL *url = [[NSURL alloc] initWithString:urlAsString];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request addValue:self.cookies forHTTPHeaderField:@"Cookie"];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        if ( httpResponse.statusCode != 200 ) {
            NSLog(@"ERROR HTTP STATUS CODE:%ld", httpResponse.statusCode);
            [self.gvmDelegate fetchingVideoMailsFailedWithError:error];
            return;
        }
        if (error) {
            NSLog(@"%@", [error localizedDescription]);
            [self.gvmDelegate fetchingVideoMailsFailedWithError:error];
            return;
        }
        
        if( data == nil) {
            NSLog(@"No data");
            [self.gvmDelegate fetchingVideoMailsFailedWithError:error];
            return;
        }
        
        NSMutableString *responseStr = [[NSMutableString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSRange startRange = [responseStr rangeOfString:@"mail:"];
        NSLog(@"Response Length: %lu", responseStr.length);
        [responseStr deleteCharactersInRange:NSMakeRange(0, startRange.location+startRange.length)];
        NSLog(@"Start:%lu Length:%lu responseLength:%lu", startRange.location, startRange.length, responseStr.length);
        NSRange endRange = [responseStr rangeOfString:@"[ '' , '' , '' , '' , '' , '' , '' , '' , '' , '' , '' , '' , '' , '' , '' ]"];
        NSLog(@"Start:%lu Length:%lu responseLength:%lu", endRange.location, endRange.length, responseStr.length);
        [responseStr deleteCharactersInRange:NSMakeRange(endRange.location+endRange.length+7, responseStr.length-endRange.location-endRange.length-7)];

        //NSString *trimStr = [responseStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        NSString *replaceStr = [responseStr stringByReplacingOccurrencesOfString:@"'" withString:@"\""];
        NSLog(@"Response: %@", replaceStr);
        [self.gvmDelegate receivedVideoMails:[replaceStr dataUsingEncoding:NSUTF8StringEncoding]];
        
    }];
    return;
}

- (void)generateThumbnailAsynchronously:(VideoMail *)videoMail InFolder:(NSString *)folder completionHandler:(void (^)(void))handler {
    
    if (videoMail.token != nil) {
        handler();
        return;
    }
    NSString *urlAsString = [NSString stringWithFormat:@"http://mydomain.com/getvideotoken?key=%@", [videoMail.mhtKey urlEncodeUsingEncoding:NSUTF8StringEncoding]];
    NSLog(@"thumbnail url:%@", urlAsString);
    NSURL *url = [[NSURL alloc] initWithString:urlAsString];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request addValue:self.cookies forHTTPHeaderField:@"Cookie"];
    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        if ( httpResponse.statusCode != 200 ) {
            NSLog(@"ERROR HTTP STATUS CODE:%ld", httpResponse.statusCode);
            return;
        }
        if (error) {
            NSLog(@"%@", [error localizedDescription]);
            return;
        }
        
        if( data == nil) {
            NSLog(@"No data");
            return;
        }
        
        NSMutableString *responseStr = [[NSMutableString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"Response: %@", responseStr);
        
        NSRange startRange = [responseStr rangeOfString:@"X-Video-Token:"];
        NSRange endRange = [responseStr rangeOfString:@"Content-Type"];
        
        if (startRange.location == 0 || startRange.length == 0 || endRange.location == 0 || endRange.length == 0) {
            handler();
            return;
        }
            
        videoMail.token = [[[responseStr substringWithRange:NSMakeRange(startRange.location+startRange.length,
                                                                       endRange.location-(startRange.location+startRange.length))] urlEncodeUsingEncoding:NSUTF8StringEncoding] stringByReplacingOccurrencesOfString:@"%0A" withString:@""];
        NSLog(@"Token: %@ is here", videoMail.token);
        videoMail.thumbnailUrl = [NSURL URLWithString:[NSString stringWithFormat:@"http://mydomain.com/getthumbnail?token=%@", videoMail.token]];
        videoMail.videoUrl = [NSURL URLWithString:[NSString stringWithFormat:@"http://mydomain.com/getvideo?token=%@", videoMail.token]];
        handler();
    }];
    
    
    return;
}

- (void) getThumbnailAsynchronously:(VideoMail *) videoMail {
    
}

- (void) Logout {
    
    NSString *urlAsString = @"http://mydomain.com/logouturl";
    NSURL *url = [[NSURL alloc] initWithString:urlAsString];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request addValue:self.cookies forHTTPHeaderField:@"Cookie"];
    
    NSHTTPURLResponse *response = nil;
    NSError *error = nil;
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    if ( response.statusCode != 200 ) {
        self.authenticated = NO;
        NSLog(@"ERROR HTTP STATUS CODE:%ld", response.statusCode);
        return;
    }
    if ( responseData == nil ) {
        self.authenticated = NO;
        NSLog(@"ResponseData is nil");
        return;
    }
    if ( error != nil ) {
        self.authenticated = NO;
        NSLog(@"%@", [error localizedDescription]);
        return;
    }
    
    NSLog(@"Successfully logged out");
    self.authenticated = NO;
    return;
}


@end
