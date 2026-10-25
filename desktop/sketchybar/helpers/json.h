#include <stdio.h>

static void json_text(const char *value) {
  if (!value) { fputs("null", stdout); return; }
  putchar('"');
  for (const unsigned char *p = (const unsigned char *)value; *p; ++p) {
    if (*p == '"' || *p == '\\') printf("\\%c", *p);
    else if (*p < 0x20) printf("\\u%04x", *p);
    else putchar(*p);
  }
  putchar('"');
}
