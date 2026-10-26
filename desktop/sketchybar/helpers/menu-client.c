#include <CoreFoundation/CoreFoundation.h>
#include <mach/mach_time.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int main(int argc, const char *argv[]) {
  int mode = 1, offset = 1;
  if (argc > 1 && strcmp(argv[1], "--ping") == 0) { mode = 0; offset++; }
  if (argc > 1 && strcmp(argv[1], "--metrics") == 0) { mode = 3; offset++; }
  if (argc > 1 && strcmp(argv[1], "--bench") == 0) { mode = 2; offset++; }
  if (argc <= offset || ((mode == 1 || mode == 2) && argc < offset + 4) || argc > offset + 33) return 64;
  CFStringRef name = CFStringCreateWithCString(NULL, argv[offset++], kCFStringEncodingUTF8);
  if (!name) return 64;
  CFMessagePortRef port = CFMessagePortCreateRemote(NULL, name);
  CFRelease(name);
  if (!port) return 69;
  CFMutableArrayRef args = CFArrayCreateMutable(NULL, 0, &kCFTypeArrayCallBacks);
  char now[32];
  snprintf(now, sizeof(now), "%llu", (unsigned long long)mach_absolute_time());
  for (int i = offset; i < argc; i++) {
    const char *value = i == offset && strcmp(argv[i], "0") == 0 ? now : argv[i];
    CFStringRef line = CFStringCreateWithCString(NULL, value, kCFStringEncodingUTF8);
    if (!line || CFStringGetLength(line) > 512) { if (line) CFRelease(line); CFRelease(args); CFRelease(port); return 64; }
    CFArrayAppendValue(args, line);
    CFRelease(line);
  }
  CFDataRef data = CFPropertyListCreateData(NULL, args, kCFPropertyListBinaryFormat_v1_0, 0, NULL);
  CFDataRef response = NULL;
  SInt32 status = CFMessagePortSendRequest(port, mode, data, 0.05, mode == 2 ? 1.0 : 0.1, kCFRunLoopDefaultMode, &response);
  CFRelease(data);
  CFRelease(args);
  CFRelease(port);
  if (status != kCFMessagePortSuccess || !response) return 70;
  int result = 0;
  if (mode == 0 || mode == 3) fwrite(CFDataGetBytePtr(response), 1, CFDataGetLength(response), stdout);
  else if (CFDataGetLength(response) != 2 || memcmp(CFDataGetBytePtr(response), "ok", 2)) result = 75;
  CFRelease(response);
  return result;
}
