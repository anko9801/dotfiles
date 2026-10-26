#include <assert.h>
#include <string.h>
#include <lua.h>
#include <lauxlib.h>
#include <lualib.h>
#include "mach.h"

static int sends;
static const char *reply = "{}";
static char *test_send(mach_port_t port, char *message, uint32_t length, bool response) {
  (void)port; (void)message; (void)length; (void)response;
  sends++;
  return strdup(reply);
}
#define mach_send_message test_send
#include "sketchybar.c"

static int called;
static int success(lua_State *state) { (void)state; called++; return 0; }
static int fail(lua_State *state) { return luaL_error(state, "expected test error"); }
static int reference(lua_State *state, lua_CFunction function) {
  lua_pushcfunction(state, function);
  return luaL_ref(state, LUA_REGISTRYINDEX);
}
static void released(lua_State *state, int ref) {
  lua_rawgeti(state, LUA_REGISTRYINDEX, ref);
  assert(!lua_isfunction(state, -1)); lua_pop(state, 1);
}
int main(void) {
  lua_State *state = luaL_newstate(); luaL_openlibs(state); g_state = state; g_port = 1;
  transaction_create(state); transaction_commit(state); assert(sends == 0);
  lua_pushcfunction(state, set); lua_setglobal(state, "set");
  assert(luaL_dostring(state, "set('test', {})") == LUA_OK); assert(sends == 0);
  transaction_create(state); transaction_create(state);
  assert(luaL_dostring(state, "set('test', {label='value'})") == LUA_OK);
  transaction_commit(state); assert(sends == 0);
  transaction_commit(state); assert(sends == 1 && g_transaction_depth == 0);
  for (int i = 0; i < 100; i++) {
    int ref = reference(state, success);
    delay_callback(NULL, (void *)(intptr_t)ref); released(state, ref);
    assert(lua_gettop(state) == 0);
  }
  assert(called == 100 && sends == 1);
  int ref = reference(state, fail);
  delay_callback(NULL, (void *)(intptr_t)ref); released(state, ref);
  assert(lua_gettop(state) == 0);
  ref = reference(state, success);
  char message[2 + 2*sizeof(int)] = { '\x07' }; int code = 0;
  memcpy(message + 1, &ref, sizeof(ref)); memcpy(message + 1 + sizeof(ref), &code, sizeof(code));
  callback_function(message, sizeof(message)); released(state, ref); assert(called == 101);
  ref = reference(state, success);
  struct callback persistent = { ref, "item", "forced" };
  struct callback *entries[] = { &persistent }; g_callbacks.callbacks = entries; g_callbacks.num_callbacks = 1;
  char event[] = "NAME\0item\0SENDER\0forced\0\0";
  callback_function(event, sizeof(event)); callback_function(event, sizeof(event));
  lua_rawgeti(state, LUA_REGISTRYINDEX, ref); assert(lua_isfunction(state, -1)); lua_pop(state, 1);
  assert(called == 103);
  lua_pushcfunction(state, query); lua_setglobal(state, "query"); reply = "malformed";
  transaction_create(state); transaction_create(state);
  assert(luaL_dostring(state, "assert(query('test') == nil)") == LUA_OK);
  assert(g_transaction_depth == 2); transaction_commit(state); transaction_commit(state);
  assert(lua_gettop(state) == 0);
  lua_close(state);
  puts("Native client: empty/nested transactions, timer/exec cleanup, persistent subscriptions, query and error stack passed");
}
