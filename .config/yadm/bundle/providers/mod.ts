/**
 * Provider registry - optimized with caching
 */

import { Provider } from "../core.ts";
import { HomebrewProvider, BrewTapProvider, BrewCaskProvider } from "./homebrew.ts";
import { 
  AptProvider, 
  PacmanProvider, 
  DnfProvider,
  GitHubReleaseProvider,
  GitCloneProvider,
  ScriptProvider,
  CargoProvider
} from "./linux.ts";
import { WingetProvider, ScoopProvider, PowerShellProvider } from "./windows.ts";

// Global provider cache for performance
const providerCache = new Map<string, Map<string, Provider>>();

// Detect Linux distribution (cached)
const linuxDistro = (() => {
  if (Deno.build.os !== "linux") return null;
  
  try {
    const osRelease = Deno.readTextFileSync("/etc/os-release");
    const idMatch = osRelease.match(/^ID=(.*)$/m);
    if (idMatch) {
      return idMatch[1].replace(/"/g, "").toLowerCase();
    }
  } catch {
    // Fallback detection
    try {
      Deno.statSync("/etc/debian_version");
      return "debian";
    } catch {
      try {
        Deno.statSync("/etc/arch-release");
        return "arch";
      } catch {
        try {
          Deno.statSync("/etc/fedora-release");
          return "fedora";
        } catch {
          return "unknown";
        }
      }
    }
  }
  return "unknown";
})();

/**
 * Create providers for platform (cached)
 */
export function createProviders(platform: string): Map<string, Provider> {
  const cacheKey = `${platform}-${linuxDistro}`;
  
  if (providerCache.has(cacheKey)) {
    return providerCache.get(cacheKey)!;
  }
  
  const providers = new Map<string, Provider>();
  
  // Universal providers (available on all platforms)
  providers.set("git_clone", new GitCloneProvider());
  providers.set("script", new ScriptProvider());
  providers.set("cargo", new CargoProvider());
  
  // Platform-specific providers
  switch (platform) {
    case "darwin":
      providers.set("homebrew", new HomebrewProvider());
      providers.set("homebrew_tap", new BrewTapProvider());
      providers.set("homebrew_cask", new BrewCaskProvider());
      break;
      
    case "linux":
      providers.set("github_release", new GitHubReleaseProvider());
      
      // Distribution-specific providers
      switch (linuxDistro) {
        case "debian":
        case "ubuntu":
          providers.set("apt", new AptProvider());
          // providers.set("apt_repository", new AptRepositoryProvider()); // TODO
          break;
        case "arch":
        case "manjaro":
          providers.set("pacman", new PacmanProvider());
          // providers.set("aur", new AurProvider()); // TODO
          break;
        case "fedora":
          providers.set("dnf", new DnfProvider());
          // providers.set("copr", new CoprProvider()); // TODO
          // providers.set("rpm_repository", new RpmRepositoryProvider()); // TODO
          break;
        default:
          console.warn(`Linux distribution not supported: ${linuxDistro}`);
      }
      break;
      
    case "windows":
      providers.set("winget", new WingetProvider());
      providers.set("scoop", new ScoopProvider());
      providers.set("powershell", new PowerShellProvider());
      break;
      
    default:
      console.warn(`Platform not supported: ${platform}`);
      break;
  }
  
  // Cache the result
  providerCache.set(cacheKey, providers);
  return providers;
}

/**
 * Get supported providers for current platform
 */
export function getSupportedProviders(platform: string): string[] {
  const providers = createProviders(platform);
  return Array.from(providers.keys());
}

/**
 * Check if provider is available for platform
 */
export function isProviderSupported(platform: string, providerName: string): boolean {
  const providers = createProviders(platform);
  return providers.has(providerName);
}

/**
 * Clear provider cache (for testing/debugging)
 */
export function clearProviderCache(): void {
  providerCache.clear();
}

/**
 * Preload providers for better performance
 */
export function preloadProviders(platform: string): void {
  createProviders(platform);
}