/**
 * Configuration system with caching and lazy loading
 */

import { parse } from "jsr:@std/yaml";
import { Package } from "./core.ts";

/**
 * Config interface matching packages.yaml structure
 */
export interface Config {
  packages: {
    [platform: string]: {
      [provider: string]: (string | object)[];
    };
  };
  post_install?: {
    [packageName: string]: string[];
  };
}

// Global config cache
let configCache: Config | null = null;
let lastConfigPath: string | null = null;
let lastConfigMtime: number | null = null;

/**
 * Package parsing with minimal allocation
 */
export function parsePackages(list: (string | object)[]): Package[] {
  const packages: Package[] = [];
  
  for (let i = 0; i < list.length; i++) {
    const item = list[i];
    if (typeof item === "string") {
      const atIndex = item.indexOf("@");
      if (atIndex > 0) {
        packages.push({ 
          id: item.substring(0, atIndex), 
          version: item.substring(atIndex + 1) 
        });
      } else {
        packages.push({ id: item });
      }
    } else {
      packages.push(item as Package);
    }
  }
  
  return packages;
}

/**
 *  platform mapping (cached result)
 */
const platformMap = new Map<string, string>();

function mapPlatform(platform: string): string {
  if (platformMap.has(platform)) {
    return platformMap.get(platform)!;
  }
  
  let mapped: string;
  switch (platform) {
    case "darwin": 
      mapped = "macos"; 
      break;
    case "linux": 
      // Detect Linux distribution for more specific mapping
      const distro = getLinuxDistro();
      switch (distro) {
        case "ubuntu":
        case "debian": 
          mapped = "debian"; 
          break;
        case "arch":
        case "manjaro": 
          mapped = "arch"; 
          break;  
        case "fedora": 
          mapped = "fedora"; 
          break;
        default: 
          mapped = "debian"; // fallback
      }
      break;
    case "windows": 
      mapped = "windows"; 
      break;
    default: 
      mapped = platform;
  }
  
  platformMap.set(platform, mapped);
  return mapped;
}

/**
 *  Linux distribution detection (cached)
 */
let cachedLinuxDistro: string | null = null;

function getLinuxDistro(): string {
  if (cachedLinuxDistro !== null) {
    return cachedLinuxDistro;
  }
  
  try {
    const osRelease = Deno.readTextFileSync("/etc/os-release");
    const idMatch = osRelease.match(/^ID=(.*)$/m);
    if (idMatch) {
      cachedLinuxDistro = idMatch[1].replace(/"/g, "").toLowerCase();
      return cachedLinuxDistro;
    }
  } catch {
    //  fallback detection
    const checks = [
      ["/etc/debian_version", "debian"],
      ["/etc/arch-release", "arch"],
      ["/etc/fedora-release", "fedora"]
    ] as const;
    
    for (const [file, distro] of checks) {
      try {
        Deno.statSync(file);
        cachedLinuxDistro = distro;
        return cachedLinuxDistro;
      } catch {
        continue;
      }
    }
  }
  
  cachedLinuxDistro = "unknown";
  return cachedLinuxDistro;
}

/**
 *  config loading with cache validation
 */
export async function loadConfig(path: string): Promise<Config> {
  try {
    const stat = await Deno.stat(path);
    const mtime = stat.mtime?.getTime() || 0;
    
    // Return cached config if file hasn't changed
    if (configCache && lastConfigPath === path && lastConfigMtime === mtime) {
      return configCache;
    }
    
    // Read and parse config
    const content = await Deno.readTextFile(path);
    const config = parse(content) as Config;
    
    // Update cache
    configCache = config;
    lastConfigPath = path;
    lastConfigMtime = mtime;
    
    return config;
  } catch (error) {
    const message = error instanceof Error ? error.message : String(error);
    throw new Error(`Failed to load config from ${path}: ${message}`);
  }
}

/**
 *  package loading with minimal allocations
 */
export function loadPackages(config: Config, platform: string): Map<string, Package[]> {
  const packages = new Map<string, Package[]>();
  
  // Map platform name to config key
  const configPlatform = mapPlatform(platform);
  
  // Get platform-specific packages
  const platformConfig = config.packages[configPlatform];
  if (!platformConfig) {
    return packages; // Return empty map instead of warning
  }
  
  // Load each provider's packages
  for (const [provider, list] of Object.entries(platformConfig)) {
    if (Array.isArray(list) && list.length > 0) {
      const pkgs = parsePackages(list);
      if (pkgs.length > 0) {
        packages.set(provider, pkgs);
      }
    }
  }
  
  return packages;
}

/**
 * Clear config cache (for testing)
 */
export function clearConfigCache(): void {
  configCache = null;
  lastConfigPath = null;
  lastConfigMtime = null;
  platformMap.clear();
  cachedLinuxDistro = null;
}

/**
 * Get config file path with fallback
 */
export async function getConfigPath(): Promise<string> {
  const configPath = `${Deno.env.get("HOME")}/.config/packages.yaml`;
  try {
    await Deno.stat(configPath);
    return configPath;
  } catch {
    return "../packages.yaml"; // fallback for testing
  }
}

/**
 * Preload config for better performance
 */
export async function preloadConfig(): Promise<void> {
  try {
    const configPath = await getConfigPath();
    await loadConfig(configPath);
  } catch {
    // Ignore preload errors
  }
}