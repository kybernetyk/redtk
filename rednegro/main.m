//
//  main.m
//  rednegro
//
//  Created by jrk on 17/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "safari.h"
#include <getopt.h>

static int captcha_url_retrieve_timeout = 10; //seconds
static bool verbose = false;
char *username = 0;
char *password = 0;
char *captcha = 0;

void open_reg(void)
{
	NSString *theURL = @"http://www.reddit.com/login";
	SafariApplication* safari = [SBApplication applicationWithBundleIdentifier:@"com.apple.Safari"];
    NSDictionary *theProperties = [NSDictionary dictionaryWithObject:theURL forKey:@"URL"];
    SafariDocument *theDocument = [[[safari classForScriptingClass:@"document"] alloc] initWithProperties:theProperties];
    
    [safari.documents addObject:theDocument];
}

NSString *captcha_url(void)
{
	SafariApplication* safari = [SBApplication applicationWithBundleIdentifier:@"com.apple.Safari"];
	
	SBElementArray* documents = [safari documents];
	SafariDocument* frontDocument = [documents objectAtIndex: 0];
	
	id result = [safari doJavaScript: @"document.getElementsByTagName('img')[1].attributes[2].value" in: (SafariTab *) frontDocument];
	if ([result isEqualToString: @"/static/kill.png"])
		return nil;

	return result;
}

void set_username(NSString *username)
{
//	NSLog(@"setting username: %@", username);
	if (verbose)
		fprintf(stderr,"setting username: %s\n", [username cStringUsingEncoding: NSUTF8StringEncoding]);
	//do JavaScript "document.getElementById('user_reg').value = 'lol'" in document 0
	SafariApplication* safari = [SBApplication applicationWithBundleIdentifier:@"com.apple.Safari"];
	SBElementArray* documents = [safari documents];
	SafariDocument* frontDocument = [documents objectAtIndex: 0];

	NSString *js = [NSString stringWithFormat: @"document.getElementById('user_reg').value = '%@'", username];
	
	[safari doJavaScript: js in: (SafariTab *) frontDocument];
}

bool get_username(void)
{
	SafariApplication* safari = [SBApplication applicationWithBundleIdentifier:@"com.apple.Safari"];
	SBElementArray* documents = [safari documents];
	SafariDocument* frontDocument = [documents objectAtIndex: 0];
	
	NSString *js = @"document.getElementById('user_reg').value";
	NSString *s = [safari doJavaScript: js in: (SafariTab *) frontDocument];
	
	if ([s length] > 0) {
		username = strdup([s cStringUsingEncoding: NSUTF8StringEncoding]);
		if (verbose)
			fprintf(stderr, "retrieved username %s\n", username);
		return true;
	}
	
	return false;
}

void set_password(NSString *pwd)
{
//	NSLog(@"setting password: %@", pwd);
	if (verbose)
		fprintf(stderr,"setting password: %s\n", [pwd cStringUsingEncoding: NSUTF8StringEncoding]);
	//do JavaScript "document.getElementById('user_reg').value = 'lol'" in document 0
	SafariApplication* safari = [SBApplication applicationWithBundleIdentifier:@"com.apple.Safari"];
	SBElementArray* documents = [safari documents];
	SafariDocument* frontDocument = [documents objectAtIndex: 0];
	
	NSString *js = [NSString stringWithFormat: @"document.getElementById('passwd_reg').value = '%@'; document.getElementById('passwd2_reg').value = '%@'; ", pwd, pwd];
	
	[safari doJavaScript: js in: (SafariTab *) frontDocument];
}

bool get_password(void)
{
	SafariApplication* safari = [SBApplication applicationWithBundleIdentifier:@"com.apple.Safari"];
	SBElementArray* documents = [safari documents];
	SafariDocument* frontDocument = [documents objectAtIndex: 0];
	
	NSString *js = @"document.getElementById('passwd_reg').value";
	NSString *s = [safari doJavaScript: js in: (SafariTab *) frontDocument];
	if ([s length] > 0) {
		password = strdup([s cStringUsingEncoding: NSUTF8StringEncoding]);
		if (verbose)
			fprintf(stderr, "retrieved password %s\n", password);

		return true;
	}
	
	return false;
}


void set_captcha(NSString *cap)
{
	if (verbose)
		fprintf(stderr,"setting solved captcha: %s\n", [cap cStringUsingEncoding: NSUTF8StringEncoding]);
	//	NSLog(@"setting password: %@", pwd);
	//do JavaScript "document.getElementById('user_reg').value = 'lol'" in document 0
	SafariApplication* safari = [SBApplication applicationWithBundleIdentifier:@"com.apple.Safari"];
	SBElementArray* documents = [safari documents];
	SafariDocument* frontDocument = [documents objectAtIndex: 0];
	
//	NSString *js = [NSString stringWithFormat: @"document.getElementById('captcha_').value = '%@';", cap];
//	[safari doJavaScript: js in: (SafariTab *) frontDocument];
	
	//we have to focus the input field first so some bullshit fires in the javascript
	NSString *js = @"document.getElementById('captcha_').focus();";
	[safari doJavaScript: js in: (SafariTab *) frontDocument];
	sleep(1);
	js = [NSString stringWithFormat: @"document.getElementById('captcha_').value = '%@';", cap];
	[safari doJavaScript: js in: (SafariTab *) frontDocument];

}


bool get_captcha(void)
{
	SafariApplication* safari = [SBApplication applicationWithBundleIdentifier:@"com.apple.Safari"];
	SBElementArray* documents = [safari documents];
	SafariDocument* frontDocument = [documents objectAtIndex: 0];
	
	NSString *js = @"document.getElementById('captcha_').value";
	NSString *s = [safari doJavaScript: js in: (SafariTab *) frontDocument];
	
	if ([s length] > 0 && ![s isEqualToString: @"type the letters from the image above"]) {
		captcha = strdup([s cStringUsingEncoding: NSUTF8StringEncoding]);
		if (verbose)
			fprintf(stderr, "retrieved captcha %s\n", captcha);
		return true;
	}
	
	return false;
}


bool submit(void)
{
	if (verbose)
		fprintf(stderr, "submission ...\n");
	//if no username provided let's try to extract it from the reg page
	if (!username)
		get_username();
	if (!password)
		get_password();
	if (!captcha)
		get_captcha();

	//uh uh, nothing provied, nothing retrieved
	if (!username)
		fprintf(stderr, "error: please provide a username with -u!\n");
	if (!password)
		fprintf(stderr, "error: please provide a password with -p!\n");
	if (!captcha)
		fprintf(stderr, "error: please provide a captcha with -c!\n");
	
	if (!username || !password || !captcha)
		return false;
	
	if (verbose)
		fprintf(stderr,"submitting u: %s p: %s c: %s ...\n", username, password, captcha);
	SafariApplication* safari = [SBApplication applicationWithBundleIdentifier:@"com.apple.Safari"];
	
	SBElementArray* documents = [safari documents];
	SafariDocument* frontDocument = [documents objectAtIndex: 0];
	
	[safari doJavaScript: @"document.getElementsByTagName('button')[0].click()" in: (SafariTab *) frontDocument];

	int c = 0;
	for (;;) { //wait for 5 seconds before we check our submission status
		if (verbose)
			fprintf(stderr, "#");
		usleep(250000); //sleep for 1/4 seconds
		if (++c >= captcha_url_retrieve_timeout*2) {
			if (verbose)
				fprintf(stderr, "\n");
			break;
		}
	}

	NSString *loc = [safari doJavaScript: @"document.location" in: (SafariTab *) frontDocument];
	if (![loc isEqualToString: @"http://www.reddit.com/"]) {
		fprintf(stderr, "error: submission failed. check for errors in safari!\n");
		return false;
	}
	if (verbose)
		fprintf(stderr, "submission suceeded! the account should work now ...\n");
	fprintf(stdout, "%s:%s\n", username, password);
	return true;
}

void logout(void)
{
	//document.forms[0].submit()
	if (verbose)
		fprintf(stderr,"logging out ...\n");
	SafariApplication* safari = [SBApplication applicationWithBundleIdentifier:@"com.apple.Safari"];
	
	SBElementArray* documents = [safari documents];
	SafariDocument* frontDocument = [documents objectAtIndex: 0];
	
	[safari doJavaScript: @"document.forms[0].submit();" in: (SafariTab *) frontDocument];
	
	
}

void usage(const char *bin)
{
	fprintf(stdout, "\nkarmawhore v0.0.1c - your friendly reddit account creation tool\n");
	fprintf(stdout, "syntax: %s <command> [parameter] [...]\n", bin);
	fprintf(stdout, "  -o | --openreg                  opens new registartion in safari\n");
	fprintf(stdout, "  -g | --getcaptcha               prints the captcha image file's url\n");
	fprintf(stdout, "  -u | --user [username]          your new reddit username\n");
	fprintf(stdout, "  -p | --pass [password]          your new reddit password\n");
	fprintf(stdout, "  -c | --captcha [solved captcha] your solved captcha\n");
	fprintf(stdout, "  -s | --submit                   submits registration form\n");
	fprintf(stdout, "  -l | --logout                   logout\n");
	fprintf(stdout, "\n");
	fprintf(stdout, "command groups that belong together:\n");
	fprintf(stdout, "  [[-o] [-g] [-l]], [-u -p -c -s]\n");
	fprintf(stdout, "examples:\n");
	fprintf(stdout, "%s -o -g\n  open new reg, get captcha url\n", bin);
	fprintf(stdout, "%s -o -l\n  open new reg, logout\n", bin);
	fprintf(stdout, "%s -u lol -p lulz -c 1234q -s\n  create account lol with password lulz, captcha 1234q and submit\n  (for this to work the reddit registration page has to be open in safari and be visible)\n\n", bin);
	
}

bool print_captcha_url(void)
{
	int c = 0;
	NSString *captcha = nil;
	
	if (verbose)
		fprintf(stderr, "retrieving captcha url: ");
	for (;;) {
		captcha = captcha_url();
		if (captcha)
			break;
		if (verbose)
			fprintf(stderr, "#");
		usleep(250000); //sleep for 1/4 seconds
		if (++c >= captcha_url_retrieve_timeout*4) {
			fprintf(stderr, "captcha timeout. couldn't get captcha. maybe you're logged in? log out nao!\n");
			return false;
		}
	}
	if (verbose)
		fprintf(stderr, "\n");
	fprintf(stdout, "%s\n", [captcha cStringUsingEncoding: NSUTF8StringEncoding]);
	return true;
}

int main (int argc, const char * argv[])
{
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	
	if (argc == 1) {
		usage(argv[0]);
		return 3;
	}
	
	int option_index = 0;
	for (;;){
		static struct option long_options[] = {
			{"verbose",     no_argument,       0, 'v'},
			{"openreg",     no_argument,       0, 'o'},
			{"getcaptcha",  no_argument,       0, 'g'},
			
			{"user",  required_argument,       0, 'u'},
			{"pass",  required_argument,       0, 'p'},
			{"captcha",  required_argument,       0, 'c'},
			
			
			{"submit",  no_argument,       0, 's'},
			{"logout",  no_argument,       0, 'l'},
			{"help",    no_argument, 0, 'h'},
			{0, 0, 0, 0}
		};
		
		char c = getopt_long (argc, (char *const *)argv, "vogu:p:c:slh?", long_options, &option_index);
		
		/* Detect the end of the options. */
		if (c == -1)
			break;
		
		switch (c) {
			case 'v':
				verbose = true;
				break;
			case 'o':
				open_reg();
				break;
				
			case 'g':
				if (verbose)
					fprintf(stderr,"retrieving captcha image url ...\n");
				if (!print_captcha_url())
					return 43;
				return 0;
				break;

			case 'u':
				username = optarg;
				set_username([NSString stringWithFormat: @"%s", optarg]);
				break;

			case 'p':
				password = optarg;
				set_password([NSString stringWithFormat: @"%s", optarg]);
				break;
				
			case 'c':
				captcha = optarg;
				set_captcha([NSString stringWithFormat: @"%s", optarg]);
				break;
				
			case 's':
				if (!submit())
					return 95;
				return 0;
				break;
				
			case 'l':
				logout();
				return 0;
				
			case '?':
			case 'h':
				usage (argv[0]);
				break;
				
			default:
				abort ();
		}
	}
	
	
//	NSData *d = [NSData dataWithContentsOfURL: [NSURL URLWithString: captcha]];
//	if (!d) {
//		fprintf(stderr, "couldn't load captcha image from %s ...", [captcha cStringUsingEncoding: NSUTF8StringEncoding]);
//		return 2;
//	}
//	[d writeToFile: @"lol.png" atomically: YES];
//
//	set_username(@"hurrenson");
//	set_password(@"password");
	
	//submit();
	[pool drain];
    return 0;
}

