#include <assert.h>
#include <stdbool.h>
#include <string.h>
#include <mach/mach_time.h>
#define SBAR_MACH_TIMEOUT_MS 50
#include "mach.h"

int main(void) {
  mach_port_t task = mach_task_self(), port;
  assert(mach_port_allocate(task, MACH_PORT_RIGHT_RECEIVE, &port) == KERN_SUCCESS);
  assert(mach_port_insert_right(task, port, port, MACH_MSG_TYPE_MAKE_SEND) == KERN_SUCCESS);
  struct mach_port_limits limits = { .mpl_qlimit = 1 };
  assert(mach_port_set_attributes(task, port, MACH_PORT_LIMITS_INFO, (mach_port_info_t)&limits, MACH_PORT_LIMITS_INFO_COUNT) == KERN_SUCCESS);
  mach_msg_header_t filler = { .msgh_bits = MACH_MSGH_BITS(MACH_MSG_TYPE_COPY_SEND, 0), .msgh_remote_port = port, .msgh_size = sizeof(filler) };
  assert(mach_msg(&filler, MACH_SEND_MSG | MACH_SEND_TIMEOUT, sizeof(filler), 0, MACH_PORT_NULL, 50, MACH_PORT_NULL) == KERN_SUCCESS);
  mach_timebase_info_data_t timebase; mach_timebase_info(&timebase);
  uint64_t start = mach_absolute_time();
  for (int i = 0; i < 3; i++) assert(mach_send_message(port, "test", 5, true) == NULL);
  double elapsed = (double)(mach_absolute_time()-start)*timebase.numer/timebase.denom/1e6;
  assert(elapsed >= 100 && elapsed < 2000);
  assert(mach_port_destruct(task, port, -1, 0) == KERN_SUCCESS);
  printf("Native IPC: three saturated-queue sends returned in %.1f ms\n", elapsed);
}
