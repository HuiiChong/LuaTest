//
//  LuaManager.m
//  Lua on iOS
//

#import "LuaManager.h"

#define to_cString(s) ([s cStringUsingEncoding:[NSString defaultCStringEncoding]])

int setLuaPath(lua_State* L, const char* path) {
    
    return 0; // all done!
}

@interface LuaManager ()

@property (nonatomic) lua_State *state;

@end


@implementation LuaManager

- (lua_State *)state {
    if (!_state) {
        _state = luaL_newstate();
        luaL_openlibs(_state);
        lua_settop(_state, 0);
    }

    return _state;
}

- (void)runCodeFromString:(NSString *)code {
    // get state
    lua_State *L = self.state;

    // compile
    int error = luaL_loadstring(L, to_cString(code));
    if (error) {
        luaL_error(L, "cannot compile Lua code: %s", lua_tostring(L, -1));
        return;
    }

    // run
    error = lua_pcall(L, 0, 0, 0);
    if (error) {
        luaL_error(L, "cannot run Lua code: %s", lua_tostring(L, -1));
        return;
    }
}

- (void)runCodeFromFileWithPath:(NSString *)path path:(NSString *)filePath {
    // get state
    lua_State *L = self.state;

    lua_getglobal(L, "package");
    lua_getfield(L, -1, "path"); // get field "path" from table at top of stack (-1)
//    const char *cur_path = lua_tostring(L, -1); // grab path string from top of stack
//    NSString *cur_path = [NSString stringWithCString:lua_tostring(L, -1) encoding:NSUTF8StringEncoding];
//    cur_path = [NSString stringWithFormat:@"%@;%@",cur_path,filePath];
//    cur_path.append(";"); // do your path magic here
//    cur_path.append(path);
    lua_pop(L, 1); // get rid of the string on the stack we just pushed on line 5
    lua_pushstring(L, to_cString(filePath)); // push the new one
    lua_setfield(L, -2, "path"); // set the field "path" in table at -2 with value at top of stack
    lua_pop(L, 1); // get rid of package table from top of stack
    
//    lua_newtable(L);
//    lua_setfield(L, 0, [filePath cStringUsingEncoding:NSUTF8StringEncoding]);
//    lua_setglobal(L, "appPath");
    // compile
    int error = luaL_loadfile(L, to_cString(path));
    if (error) {
        luaL_error(L, "cannot compile Lua file: %s", lua_tostring(L, -1));
        return;
    }

    // run
    error = lua_pcall(L, 0, 0, 0);
    if (error) {
        luaL_error(L, "cannot run Lua code: %s", lua_tostring(L, -1));
        return;
    }
}

- (void)registerFunction:(lua_CFunction)function withName:(NSString *)name {
    lua_register(self.state, to_cString(name), function);
}

- (void)callFunctionNamed:(NSString *)name withObject:(NSObject *)object {
    // get state
    lua_State *L = self.state;

    // prepare for "function(object)"
    lua_getglobal(L, to_cString(name));
    lua_pushlightuserdata(L, (__bridge void *)(object));

    // run
    int error = lua_pcall(L, 1, 0, 0);
    if (error) {
        luaL_error(L, "cannot run Lua code: %s", lua_tostring(L, -1));
        return;
    }
}

@end
