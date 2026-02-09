# Platform-aware utility functions
{
  # Create platform-specific value
  # Usage: mkPlatformValue config { default = ...; windows = ...; darwin = ...; }
  mkPlatformValue =
    config:
    {
      default,
      windows ? default,
      darwin ? default,
    }:
    if config.platform.isWindows then
      windows
    else if config.platform.isDarwin then
      darwin
    else
      default;
}
