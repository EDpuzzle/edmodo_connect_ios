edmodo_connect_ios
==================

IOS library wrapping interactions with Edmodo

# Goal
Use this to quickly get up and running with Edmodo Connect in your iPad App.

# Background
For more on Edmodo Connect, see:
https://developers.edmodo.com/

# Overview
## Setup
You should have a working iPad App and an Edmodo Connect client ID.

Install the framework in your XCode Project (I am not going to get into details on this, see 'Caveats' below).

## Simple usage
Add this call to your code:
...
    [[EMLoginService sharedInstance] initiateLogin:parentViewController
                                      withClientID:MY_CLIENT_ID
                                         onSuccess:^() {
                                           // handle success
                                         }
                                          onCancel:^() {
                                            // handle cancel
                                          }
                                           onError: ^(NSError* error) {
                                             // handle error
                                           }];
...

If the success block is called, you're good to go.  
Call [EMObject sharedInstance] to get the EMObjects instance and from there you can get info on the current user, his group memberships, etc.  

# Caveats
I am fairly new to the world of XCode and Objective C.  I suspect it is not up to par in several ways:
* Memory management.
* Proper config for a Framework.

On that last one, after a day of misery I could not get this project to produce a Framework that compiles with all architectures, in spite of following directions here:
https://github.com/jverkoey/iOS-Framework#walkthrough

For my projects, I am just adding the files in the source to the main project and ignoring the whole 'Framework' aspect.  :(.



