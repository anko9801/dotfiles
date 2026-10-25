#include <inttypes.h>
#include <mach/mach.h>
#include <stdio.h>
#include <sys/sysctl.h>
#include <time.h>

int main(void) {
  struct timespec sampled;
  if (clock_gettime(CLOCK_MONOTONIC, &sampled) != 0) return 1;
  host_cpu_load_info_data_t cpu;
  vm_statistics64_data_t vm;
  mach_msg_type_number_t cpu_count = HOST_CPU_LOAD_INFO_COUNT;
  mach_msg_type_number_t vm_count = HOST_VM_INFO64_COUNT;
  vm_size_t page_size;
  uint64_t total_memory;
  size_t size = sizeof(total_memory);
  mach_port_t host = mach_host_self();

  if (host_statistics(host, HOST_CPU_LOAD_INFO, (host_info_t)&cpu,
                      &cpu_count) != KERN_SUCCESS ||
      host_statistics64(host, HOST_VM_INFO64, (host_info64_t)&vm,
                        &vm_count) != KERN_SUCCESS ||
      host_page_size(host, &page_size) != KERN_SUCCESS ||
      sysctlbyname("hw.memsize", &total_memory, &size, NULL, 0) != 0 ||
      total_memory == 0) {
    mach_port_deallocate(mach_task_self(), host);
    return 1;
  }
  mach_port_deallocate(mach_task_self(), host);

  // File-backed cache is reclaimable; compressed pages occupy physical RAM.
  uint64_t app_pages = vm.internal_page_count;
  app_pages -= app_pages < vm.purgeable_count ? app_pages : vm.purgeable_count;
  uint64_t used = (app_pages + vm.wire_count + vm.compressor_page_count) * page_size;
  if (used > total_memory) used = total_memory;

  int pressure = 0;
  size = sizeof(pressure);
  sysctlbyname("kern.memorystatus_vm_pressure_level", &pressure, &size, NULL, 0);
  struct xsw_usage swap = {0};
  size = sizeof(swap);
  int have_swap = sysctlbyname("vm.swapusage", &swap, &size, NULL, 0) == 0;

  printf("{\"user\":%u,\"system\":%u,\"nice\":%u,\"idle\":%u,"
         "\"memory_percent\":%.1f,\"pressure\":%d,\"swap_gib\":%.2f,\"monotonic\":%.6f}\n",
         cpu.cpu_ticks[CPU_STATE_USER], cpu.cpu_ticks[CPU_STATE_SYSTEM],
         cpu.cpu_ticks[CPU_STATE_NICE], cpu.cpu_ticks[CPU_STATE_IDLE],
         100.0 * (double)used / (double)total_memory, pressure,
         have_swap ? (double)swap.xsu_used / (1024.0 * 1024.0 * 1024.0) : -1.0,
         (double)sampled.tv_sec + (double)sampled.tv_nsec / 1e9);
  return 0;
}
