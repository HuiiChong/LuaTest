//
//  ViewController.m
//  Lua on iOS
//

#import "ViewController.h"
#import "LuaManager.h"
#import "Person.h"


// let's prefix `lua_CFunctions` with `l_` as in http://www.lua.org/pil/26.1.html
int l_sum(lua_State *L) {
    // get arguments (`int numberOfArguments = lua_gettop(L)`)
    double x = lua_tonumber(L, 1);
    double y = lua_tonumber(L, 2);

    // compute result
    double result = x + y;

    // return one result
    lua_pushnumber(L, result);
    return 1;
}


@interface ViewController ()

@end


@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // create a manager
    LuaManager *m = [[LuaManager alloc] init];

    //
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"foo"ofType:@"lua"];
    NSError *_error = nil;
    NSString *_content = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:&_error];
//    NSLog(@"lua file: %@",_content);
    
//    [m runCodeFromString:_content];
    
    // run sth simple
    [m runCodeFromString:@"print(2 + 2)"];

    // maintain state
    [m runCodeFromString:@"x = 0"];
    [m runCodeFromString:@"print(x + 1)"];

    // run file
    NSString *path = [[NSBundle mainBundle] pathForResource:@"foo" ofType:@"lua"];
//    [m runCodeFromFileWithPath:path];
    
    NSString *bundlePath = [[NSBundle mainBundle] resourcePath];
//    [m runCodeFromFileWithPath:[NSString stringWithFormat:@"'%@/?.lua'",bundlePath]];
    [m runCodeFromFileWithPath:path path:[NSString stringWithFormat:@"%@/?.lua",bundlePath]];

    // call objc function from lua
    [m registerFunction:l_sum withName:@"sum"];
    [m runCodeFromString:@"print(sum(1, 2))"];

    // create a person called Alice
    Person *person = [[Person alloc] init];
    person.name = @"Alice";
    NSLog(@"Person's name is %@.", person.name);

    // rename person to Bob
    [m registerFunction:l_set_person_name withName:@"set_person_name"];
    [m callFunctionNamed:@"set_person_name_to_bob" withObject:person];
    NSLog(@"Person's name is %@.", person.name);
}

@end
