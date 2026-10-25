#include <SystemConfiguration/SystemConfiguration.h>
#include <arpa/inet.h>
#include <ifaddrs.h>
#include <inttypes.h>
#include <net/if.h>
#include <net/if_mib.h>
#include <stdio.h>
#include <string.h>
#include <sys/sysctl.h>
#include <time.h>
#include <spawn.h>
#include <signal.h>
#include "json.h"

extern char **environ;
static int notification_pending;

static void trigger_network(CFRunLoopTimerRef timer, void *context) {
  (void)timer;
  notification_pending = 0;
  char *arguments[] = {(char *)context, "--trigger", "network_change", NULL};
  pid_t pid;
  posix_spawn(&pid, arguments[0], NULL, NULL, arguments, environ);
}

static void network_changed(SCDynamicStoreRef store, CFArrayRef keys, void *context) {
  (void)store; (void)keys;
  if (notification_pending) return;
  notification_pending = 1;
  CFRunLoopTimerContext timer_context = {0, context, NULL, NULL, NULL};
  CFRunLoopTimerRef timer = CFRunLoopTimerCreate(NULL, CFAbsoluteTimeGetCurrent() + 0.1,
                                               0, 0, 0, trigger_network, &timer_context);
  if (!timer) { notification_pending = 0; return; }
  CFRunLoopAddTimer(CFRunLoopGetCurrent(), timer, kCFRunLoopCommonModes);
  CFRelease(timer);
}

static int watch_network(char *bar) {
  signal(SIGCHLD, SIG_IGN);
  SCDynamicStoreContext context = {0, bar, NULL, NULL, NULL};
  SCDynamicStoreRef store = SCDynamicStoreCreate(NULL, CFSTR("desktop-network-watch"), network_changed, &context);
  if (!store) return 1;
  const void *values[] = {CFSTR("State:/Network/Global/IPv4"), CFSTR("State:/Network/Global/IPv6"),
    CFSTR("State:/Network/Interface/.*/(IPv4|IPv6|Link)")};
  CFArrayRef keys = CFArrayCreate(NULL, values, 2, &kCFTypeArrayCallBacks);
  CFArrayRef patterns = CFArrayCreate(NULL, values + 2, 1, &kCFTypeArrayCallBacks);
  int subscribed = SCDynamicStoreSetNotificationKeys(store, keys, patterns);
  CFRelease(keys); CFRelease(patterns);
  if (!subscribed) { CFRelease(store); return 1; }
  CFRunLoopSourceRef source = SCDynamicStoreCreateRunLoopSource(NULL, store, 0);
  if (!source) { CFRelease(store); return 1; }
  CFRunLoopAddSource(CFRunLoopGetCurrent(), source, kCFRunLoopCommonModes);
  CFRunLoopRun();
  CFRelease(source); CFRelease(store);
  return 0;
}

static int copy_string(CFDictionaryRef dictionary, CFStringRef key,
                       char *buffer, size_t size) {
  if (!dictionary || CFGetTypeID(dictionary) != CFDictionaryGetTypeID()) return 0;
  CFTypeRef value = CFDictionaryGetValue(dictionary, key);
  return value && CFGetTypeID(value) == CFStringGetTypeID() &&
         CFStringGetCString(value, buffer, (CFIndex)size, kCFStringEncodingUTF8);
}

int main(int argc, char **argv) {
  if (argc == 3 && strcmp(argv[1], "--watch") == 0) return watch_network(argv[2]);
  if (argc != 1) return 2;
  SCDynamicStoreRef store = SCDynamicStoreCreate(NULL, CFSTR("desktop-network"), NULL, NULL);
  if (!store) return 1;

  char interface[IFNAMSIZ] = "";
  char gateway[128] = "Unknown";
  CFStringRef protocols[] = {kSCEntNetIPv4, kSCEntNetIPv6};
  for (size_t i = 0; i < sizeof(protocols) / sizeof(protocols[0]); ++i) {
    CFStringRef key = SCDynamicStoreKeyCreateNetworkGlobalEntity(
        NULL, kSCDynamicStoreDomainState, protocols[i]);
    if (!key) { CFRelease(store); return 1; }
    CFDictionaryRef state = SCDynamicStoreCopyValue(store, key);
    CFRelease(key);
    if (!state && SCError() != kSCStatusNoKey) { CFRelease(store); return 1; }
    int found = copy_string(state, kSCDynamicStorePropNetPrimaryInterface,
                            interface, sizeof(interface));
    if (found) {
      if (!copy_string(state, kSCPropNetIPv4Router, gateway, sizeof(gateway))) {
        strcpy(gateway, "Unknown");
      }
    } else {
      interface[0] = '\0';
    }
    if (state) CFRelease(state);
    if (found) break;
  }
  char hostname[1024] = "";
  CFStringRef computer_name = SCDynamicStoreCopyComputerName(store, NULL);
  if (computer_name) {
    if (!CFStringGetCString(computer_name, hostname, sizeof(hostname), kCFStringEncodingUTF8)) hostname[0] = '\0';
    CFRelease(computer_name);
  }
  CFRelease(store);
  if (!interface[0]) { puts("{\"status\":\"no-route\"}"); return 0; }

  char address[INET6_ADDRSTRLEN] = "Unknown";
  struct ifaddrs *addresses;
  if (getifaddrs(&addresses) != 0) return 1;
  for (struct ifaddrs *entry = addresses; entry; entry = entry->ifa_next) {
    if (!entry->ifa_addr || strcmp(entry->ifa_name, interface) != 0) continue;
    if (entry->ifa_addr->sa_family == AF_INET) {
      struct sockaddr_in *ipv4 = (struct sockaddr_in *)entry->ifa_addr;
      if (inet_ntop(AF_INET, &ipv4->sin_addr, address, sizeof(address))) break;
    } else if (entry->ifa_addr->sa_family == AF_INET6) {
      struct sockaddr_in6 *ipv6 = (struct sockaddr_in6 *)entry->ifa_addr;
      if (!IN6_IS_ADDR_LINKLOCAL(&ipv6->sin6_addr) &&
          !IN6_IS_ADDR_UNSPECIFIED(&ipv6->sin6_addr) &&
          !IN6_IS_ADDR_LOOPBACK(&ipv6->sin6_addr)) {
        inet_ntop(AF_INET6, &ipv6->sin6_addr, address, sizeof(address));
      }
    }
  }
  freeifaddrs(addresses);

  unsigned int index = if_nametoindex(interface);
  if (!index) return 1;
  int mib[] = {CTL_NET, PF_LINK, NETLINK_GENERIC, IFMIB_IFDATA, (int)index, IFDATA_GENERAL};
  struct ifmibdata data;
  size_t size = sizeof(data);
  int have_counters = sysctl(mib, 6, &data, &size, NULL, 0) == 0;
  struct timespec sampled;
  if (clock_gettime(CLOCK_MONOTONIC, &sampled) != 0) return 1;
  printf("{\"status\":\"interface\",\"interface\":"); json_text(interface);
  printf(",\"address\":"); json_text(strcmp(address, "Unknown") ? address : NULL);
  printf(",\"gateway\":"); json_text(strcmp(gateway, "Unknown") ? gateway : NULL);
  printf(",\"hostname\":"); json_text(hostname[0] ? hostname : NULL);
  if (have_counters) {
    printf(",\"rx_bytes\":%" PRIu64 ",\"tx_bytes\":%" PRIu64, data.ifmd_data.ifi_ibytes, data.ifmd_data.ifi_obytes);
  } else printf(",\"rx_bytes\":null,\"tx_bytes\":null");
  printf(",\"monotonic\":%.6f}\n", (double)sampled.tv_sec + (double)sampled.tv_nsec / 1e9);
  return 0;
}
