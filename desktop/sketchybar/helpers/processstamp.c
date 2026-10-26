#include <libproc.h>
#include <sys/resource.h>
#include <unistd.h>
#include <mach/mach_time.h>
#include <lua.h>
#include <lauxlib.h>

static int birth(lua_State *state) {
  struct rusage_info_v2 info = {0};
  if (proc_pid_rusage(getpid(), RUSAGE_INFO_V2, (rusage_info_t *)&info) != 0)
    return luaL_error(state, "Cannot read process start time");
  lua_pushinteger(state, (lua_Integer)info.ri_proc_start_abstime);
  return 1;
}

static int now(lua_State *state) {
  lua_pushinteger(state, (lua_Integer)mach_absolute_time());
  return 1;
}

static int pid(lua_State *state) {
  lua_pushinteger(state, getpid());
  return 1;
}

int luaopen_processstamp(lua_State *state) {
  lua_newtable(state);
  lua_pushcfunction(state, birth);
  lua_setfield(state, -2, "birth");
  lua_pushcfunction(state, now);
  lua_setfield(state, -2, "now");
  lua_pushcfunction(state, pid);
  lua_setfield(state, -2, "pid");
  return 1;
}
