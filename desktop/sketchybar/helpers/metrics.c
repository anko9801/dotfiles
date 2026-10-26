#include <inttypes.h>
#include <mach/mach.h>
#include <stdio.h>
#include <stdlib.h>
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
  int logical = 0, physical = 0;
  size = sizeof(logical);
  sysctlbyname("hw.logicalcpu", &logical, &size, NULL, 0);
  size = sizeof(physical);
  sysctlbyname("hw.physicalcpu", &physical, &size, NULL, 0);
  double load[3] = {0};
  int have_load = getloadavg(load, 3) == 3;

  printf("{\"user\":%u,\"system\":%u,\"nice\":%u,\"idle\":%u,"
         "\"memory_percent\":%.1f,\"pressure\":%d,\"swap_gib\":%.2f,\"monotonic\":%.6f,",
         cpu.cpu_ticks[CPU_STATE_USER], cpu.cpu_ticks[CPU_STATE_SYSTEM],
         cpu.cpu_ticks[CPU_STATE_NICE], cpu.cpu_ticks[CPU_STATE_IDLE],
         100.0 * (double)used / (double)total_memory, pressure,
         have_swap ? (double)swap.xsu_used / (1024.0 * 1024.0 * 1024.0) : -1.0,
         (double)sampled.tv_sec + (double)sampled.tv_nsec / 1e9);
  printf("\"memory_bytes\":%" PRIu64 ",\"total_bytes\":%" PRIu64 ","
         "\"anonymous_bytes\":%" PRIu64 ",\"purgeable_bytes\":%" PRIu64 ",\"wired_bytes\":%" PRIu64 ","
         "\"compressed_bytes\":%" PRIu64 ",\"file_backed_bytes\":%" PRIu64 ","
         "\"page_size\":%" PRIu64 ",\"swapin_pages\":%" PRIu64 ",\"swapout_pages\":%" PRIu64 ","
         "\"logical_cpus\":%d,\"physical_cpus\":%d,\"swap_total_gib\":",
         used, total_memory, (uint64_t)vm.internal_page_count * page_size,
         (uint64_t)vm.purgeable_count * page_size, (uint64_t)vm.wire_count * page_size,
         (uint64_t)vm.compressor_page_count * page_size, (uint64_t)vm.external_page_count * page_size,
         (uint64_t)page_size, vm.swapins, vm.swapouts, logical, physical);
  if (have_swap) printf("%.2f", (double)swap.xsu_total / (1024.0 * 1024.0 * 1024.0));
  else fputs("null", stdout);
  fputs(",\"load_average\":", stdout);
  if (have_load) printf("[%.2f,%.2f,%.2f]", load[0], load[1], load[2]);
  else fputs("null", stdout);
  puts("}");
  return 0;
}
