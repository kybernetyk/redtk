//
//  main.m
//  rednegro
//
//  Created by jrk on 17/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "safari.h"


void open_reg(void)
{
	NSString *theURL = @"http://www.reddit.com/login";
	NSLog(@"opening %@", theURL);
	SafariApplication* safari = [SBApplication applicationWithBundleIdentifier:@"com.apple.Safari"];
	
	
	
    NSDictionary *theProperties = [NSDictionary dictionaryWithObject:theURL forKey:@"URL"];
    SafariDocument *theDocument = [[[safari classForScriptingClass:@"document"] alloc] initWithProperties:theProperties];
    
    [safari.documents addObject:theDocument];
  //  [theDocument autorelease];
	

//	NSURL *u = [[NSURL alloc] initWithScheme: @"http" host: @"reddit.com" path: @"/register"];
//	[safari open: u];
//	return theDocument;
}

NSString *captcha_url(void)
{
//	NSLog(@"captcha_url for doc %@", doc);
	SafariApplication* safari = [SBApplication applicationWithBundleIdentifier:@"com.apple.Safari"];
	
	SBElementArray* documents = [safari documents];
	SafariDocument* frontDocument = [documents objectAtIndex: 0];
	
	// This *no longer* fails when in full-screen mode:
	id result = [safari doJavaScript: @"document.getElementsByTagName('img')[1].attributes[2].value" in: (SafariTab *) frontDocument];
//	id result = [safari doJavaScript: @"document.getElementsByTagName('img')[1].attributes[2].value" in: (SafariTab *) doc];
	//NSLog(@"captcha url: %@", result);
	if ([result isEqualToString: @"/static/kill.png"])
		return nil;
	
	return result;
}

void set_username(NSString *username)
{
	NSLog(@"setting username: %@", username);
	//do JavaScript "document.getElementById('user_reg').value = 'lol'" in document 0
	SafariApplication* safari = [SBApplication applicationWithBundleIdentifier:@"com.apple.Safari"];
	SBElementArray* documents = [safari documents];
	SafariDocument* frontDocument = [documents objectAtIndex: 0];

	NSString *js = [NSString stringWithFormat: @"document.getElementById('user_reg').value = '%@'", username];
	
	id result = [safari doJavaScript: js in: (SafariTab *) frontDocument];
}

void set_password(NSString *pwd)
{
	NSLog(@"setting password: %@", pwd);
	//do JavaScript "document.getElementById('user_reg').value = 'lol'" in document 0
	SafariApplication* safari = [SBApplication applicationWithBundleIdentifier:@"com.apple.Safari"];
	SBElementArray* documents = [safari documents];
	SafariDocument* frontDocument = [documents objectAtIndex: 0];
	
	NSString *js = [NSString stringWithFormat: @"document.getElementById('passwd_reg').value = '%@'; document.getElementById('passwd2_reg').value = '%@'; ", pwd, pwd];
	
	id result = [safari doJavaScript: js in: (SafariTab *) frontDocument];
}

void submit(void)
{
	NSLog(@"submitting ...");
	//do JavaScript "document.getElementsByTagName('button')[0].click()" in document 0

	SafariApplication* safari = [SBApplication applicationWithBundleIdentifier:@"com.apple.Safari"];
	
	SBElementArray* documents = [safari documents];
	SafariDocument* frontDocument = [documents objectAtIndex: 0];
	
	// This *no longer* fails when in full-screen mode:
	id result = [safari doJavaScript: @"document.getElementsByTagName('button')[0].click()" in: (SafariTab *) frontDocument];
	NSLog(@"submit result: %@", result);
}

int main (int argc, const char * argv[])
{
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	
	open_reg();
	NSLog(@"Getting captcha url ...");
	NSString *captcha = nil;
	for (;;) {
		captcha = captcha_url();
		if (captcha)
			break;
		printf("#");
	}
	printf("\n");
	NSLog(@"captcha url: %@", captcha);
	
	NSData *d = [NSData dataWithContentsOfURL: [NSURL URLWithString: captcha]];
	if (!d) {
		NSLog(@"couldn't load captcha image from %@ ...", captcha);
		return 2;
	}
	[d writeToFile: @"/Users/jrk/lol.png" atomically: YES];

	set_username(@"hurrenson");
	set_password(@"password");
	sleep(30);
	submit();
	[pool drain];
    return 0;
}

