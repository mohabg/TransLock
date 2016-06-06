//
//  APIHandler.m
//  TransLock
//
//  Created by Mohab Gabal on 5/31/16.
//  Copyright © 2016 Mohab Gabal. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "APIHandler.h"
#import "BusStop.h"

@implementation APIHandler

-(void)parseJsonWithRequest:(NSURLRequest *)request CompletionBlock:(void (^)(NSDictionary *, int))completionBlock Index:(int)index {
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * data, NSURLResponse * response, NSError * connectionError) {
        if(connectionError){
            @throw [NSException exceptionWithName:@"Cannot Connect To Server" reason:@"Please Check Your Network Connection" userInfo:nil];
        }
        NSError * error = nil;
        NSDictionary * jsonData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments  error:&error];
        if(error){
            NSLog(@"JSON ERROR: %@", [error localizedDescription]);
            return;
        }
        completionBlock(jsonData, index);
    }] resume];
}

-(NSURLRequest *)createBusStopRequestWithLatitude:(NSString *)latitude Longitude:(NSString *)longitude{
    NSString * urlString =[NSString stringWithFormat:@"https://transloc-api-1-2.p.mashape.com/stops.json?agencies=176&callback=call&geo_area=%@%%2C%@%%7C750", latitude, longitude];
    NSMutableURLRequest * busStopRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    [self setTranslocParameters:busStopRequest];
    return busStopRequest;
}

-(NSURLRequest *)createWalkTimeRequestWithLatitude:(NSString *)latitude Longitude:(NSString *)longitude BusStop:(BusStop *)busStop{
    NSString * start = [NSString stringWithFormat:@"%@,%@",latitude, longitude];
    NSString * end = [NSString stringWithFormat:@"%@,%@",busStop.latitude,busStop.longitude];
    NSURLRequest *walkTimeRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/distancematrix/json?origins=%@&destinations=%@&mode=walking&language=en&key=AIzaSyC2MS3CUnzd_oIsjZ4OjDPSgPgVZAylHlk", start, end]]];
    return walkTimeRequest;
}

-(NSURLRequest *)createRouteRequest{ 
    NSMutableURLRequest * routeRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://transloc-api-1-2.p.mashape.com/routes.json?agencies=176&callback=call"]];
    [self setTranslocParameters:routeRequest];
    return routeRequest;
}

-(NSURLRequest *)createRandomJokeRequest{
    return [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://api.icndb.com/jokes/random?firstName=Mohab&lastName=Gabal"]];
}

-(NSURLRequest *)createArrivalTimeRequestForStop:(NSString *)stop Buses:(NSArray *)buses{
    NSString * busesEncoding = [[NSString alloc] init];
    for(NSString * bus in buses){
       busesEncoding = [busesEncoding stringByAppendingString:[NSString stringWithFormat:@"%@%%2C", bus]];
    }
    busesEncoding = [busesEncoding substringToIndex:[busesEncoding length] - 3];
    NSString * urlString =  [NSString stringWithFormat:@"https://transloc-api-1-2.p.mashape.com/arrival-estimates.json?agencies=176&callback=call&routes=%@&stops=%@", busesEncoding, stop];
    NSMutableURLRequest * arrivalTimeRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    [self setTranslocParameters:arrivalTimeRequest];
    return arrivalTimeRequest;
}
-(void)setTranslocParameters:(NSMutableURLRequest *)request{
    [request setValue:@"PCG5uRLF4ZmshAIGO5Uv2Oyqbx8sp1qjiz9jsnFDMawMbwhuy8" forHTTPHeaderField:@"X-Mashape-Key"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
}
@end
