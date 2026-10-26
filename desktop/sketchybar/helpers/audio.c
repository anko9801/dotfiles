#include <CoreAudio/CoreAudio.h>
#include <AudioToolbox/AudioHardwareService.h>
#include <math.h>
#include <stdio.h>

static int read_property(AudioObjectID object, AudioObjectPropertySelector selector,
                         AudioObjectPropertyScope scope, void *value, UInt32 size) {
  AudioObjectPropertyAddress address = {selector, scope, kAudioObjectPropertyElementMain};
  return AudioObjectHasProperty(object, &address) &&
         AudioObjectGetPropertyData(object, &address, 0, NULL, &size, value) == noErr;
}

int main(void) {
  AudioDeviceID device = kAudioObjectUnknown;
  if (!read_property(kAudioObjectSystemObject, kAudioHardwarePropertyDefaultOutputDevice,
                     kAudioObjectPropertyScopeGlobal, &device, sizeof(device)) ||
      device == kAudioObjectUnknown) return 1;

  Float32 volume = 0;
  AudioObjectPropertySelector volume_property = kAudioDevicePropertyVolumeScalar;
  int have_volume = read_property(device, volume_property,
                                  kAudioObjectPropertyScopeOutput, &volume, sizeof(volume));
  if (!have_volume) {
    volume_property = kAudioHardwareServiceDeviceProperty_VirtualMainVolume;
    have_volume = read_property(device, volume_property,
                                kAudioObjectPropertyScopeOutput, &volume, sizeof(volume));
  }
  UInt32 muted = 0;
  int have_mute = read_property(device, kAudioDevicePropertyMute,
                                kAudioObjectPropertyScopeOutput, &muted, sizeof(muted));
  Boolean writable = false;
  AudioObjectPropertyAddress volume_address = {volume_property, kAudioObjectPropertyScopeOutput, kAudioObjectPropertyElementMain};
  int have_writable = have_volume && AudioObjectIsPropertySettable(device, &volume_address, &writable) == noErr;
  AudioDeviceID current = kAudioObjectUnknown;
  if (!read_property(kAudioObjectSystemObject, kAudioHardwarePropertyDefaultOutputDevice,
                     kAudioObjectPropertyScopeGlobal, &current, sizeof(current)) ||
      current != device) return 1;

  printf("{\"device\":%u,\"volume\":", device);
  if (have_volume && isfinite(volume) && volume >= 0 && volume <= 1) printf("%.3f", 100.0 * volume);
  else printf("null");
  printf(",\"muted\":");
  if (have_mute) printf("%s", muted ? "true" : "false");
  else printf("null");
  printf(",\"writable\":");
  if (have_writable) printf("%s", writable ? "true" : "false");
  else printf("null");
  puts("}");
  return 0;
}
