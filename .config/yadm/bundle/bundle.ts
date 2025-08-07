#!/usr/bin/env -S deno run -A

/**
 * Idempotent package manager
 */

import { Provider, Result } from "./core.ts";
import { loadConfig, loadPackages, getConfigPath, Config } from "./config.ts";
import { createProviders, preloadProviders } from "./providers/mod.ts";

// Platform detection (cached)
const PLATFORM = (() => {
  switch (Deno.build.os) {
    case "darwin": return "darwin";
    case "linux": return "linux"; 
    case "windows": return "windows";
    default: return "unknown";
  }
})();

// Preload providers for better startup performance
preloadProviders(PLATFORM);

// Parallel package operations
async function checkPackagesParallel(provider: Provider, packages: any[]): Promise<{ pkg: any, state: string }[]> {
  const promises = packages.map(async (pkg) => {
    const state = await provider.check(pkg).catch(() => "unknown");
    return { pkg, state };
  });
  
  return Promise.all(promises);
}

async function installPackagesParallel(provider: Provider, packages: any[]): Promise<{ pkg: any, result: Result }[]> {
  // Batch size to avoid overwhelming the system
  const BATCH_SIZE = 5;
  const results = [];
  
  for (let i = 0; i < packages.length; i += BATCH_SIZE) {
    const batch = packages.slice(i, i + BATCH_SIZE);
    const promises = batch.map(async (pkg) => {
      const result = await provider.install(pkg).catch((error) => ({
        success: false,
        changed: false,
        message: error.message
      }));
      return { pkg, result };
    });
    
    const batchResults = await Promise.all(promises);
    results.push(...batchResults);
    
    // Small delay between batches to avoid rate limiting
    if (i + BATCH_SIZE < packages.length) {
      await new Promise(resolve => setTimeout(resolve, 100));
    }
  }
  
  return results;
}

// Main commands (optimized)
const commands = {
  /**
   * Install - parallel processing
   */
  async install() {
    const configPath = await getConfigPath();
    
    console.log(`📦 Platform: ${PLATFORM}`);
    console.log(`📋 Loading config: ${configPath}\n`);
    
    const [config, providers] = await Promise.all([
      loadConfig(configPath),
      Promise.resolve(createProviders(PLATFORM))
    ]);
    
    const packages = loadPackages(config, PLATFORM);
    
    let totalChanged = 0;
    let totalFailed = 0;
    
    // Process all providers in parallel
    const providerPromises = Array.from(packages.entries()).map(async ([providerName, pkgs]) => {
      const provider = providers.get(providerName);
      if (!provider) {
        console.log(`⚠️  Provider not available: ${providerName}`);
        return;
      }
      
      console.log(`\n${providerName}:`);
      
      const results = await installPackagesParallel(provider, pkgs);
      let changed = 0;
      let failed = 0;
      
      for (const { pkg, result } of results) {
        if (result.success) {
          if (result.changed) {
            console.log(`  ✅ ${pkg.id} - installed`);
            changed++;
          } else {
            console.log(`  ⏭️  ${pkg.id} - already installed`);
          }
        } else {
          console.log(`  ❌ ${pkg.id} - failed: ${result.message}`);
          failed++;
        }
      }
      
      return { changed, failed };
    });
    
    const results = await Promise.all(providerPromises);
    
    // Aggregate results
    for (const result of results) {
      if (result) {
        totalChanged += result.changed;
        totalFailed += result.failed;
      }
    }
    
    console.log("\n" + "=".repeat(50));
    if (totalFailed > 0) {
      console.log(`❌ Completed with ${totalFailed} failures`);
      Deno.exit(1);
    } else if (totalChanged > 0) {
      console.log(`✅ Successfully installed ${totalChanged} packages`);
    } else {
      console.log(`✅ All packages already installed (no changes)`);
    }
  },
  
  /**
   * Check - parallel processing
   */
  async check() {
    const configPath = await getConfigPath();
    const [config, providers] = await Promise.all([
      loadConfig(configPath),
      Promise.resolve(createProviders(PLATFORM))
    ]);
    
    const packages = loadPackages(config, PLATFORM);
    
    console.log("📋 Package status:\n");
    
    // Process all providers in parallel
    const providerPromises = Array.from(packages.entries()).map(async ([providerName, pkgs]) => {
      const provider = providers.get(providerName);
      if (!provider) return null;
      
      const results = await checkPackagesParallel(provider, pkgs);
      return { providerName, results };
    });
    
    const results = await Promise.all(providerPromises);
    
    // Display results
    for (const result of results) {
      if (result) {
        const { providerName, results: pkgResults } = result;
        console.log(`${providerName}:`);
        
        for (const { pkg, state } of pkgResults) {
          const icon = state === "installed" ? "✅" : "❌";
          console.log(`  ${icon} ${pkg.id} - ${state}`);
        }
        console.log();
      }
    }
  },
  
  /**
   * Remove - parallel processing
   */
  async remove() {
    // Safety check - require explicit package names or --all flag
    const args = Deno.args.slice(1);
    if (args.length === 0) {
      console.error("❌ Error: Remove command requires package names or --all flag");
      console.error("Usage: bundle.ts remove <package-name> [package-name...]");
      console.error("       bundle.ts remove --all  (DANGEROUS: removes all packages)");
      Deno.exit(1);
    }
    
    const configPath = await getConfigPath();
    const [config, providers] = await Promise.all([
      loadConfig(configPath),
      Promise.resolve(createProviders(PLATFORM))
    ]);
    
    const packages = loadPackages(config, PLATFORM);
    
    // Filter packages if specific ones requested
    if (!args.includes("--all")) {
      const requestedPackages = new Set(args);
      for (const [providerName, pkgs] of packages.entries()) {
        const filtered = pkgs.filter(pkg => requestedPackages.has(pkg.id));
        if (filtered.length > 0) {
          packages.set(providerName, filtered);
        } else {
          packages.delete(providerName);
        }
      }
      
      if (packages.size === 0) {
        console.error(`❌ Error: No matching packages found for: ${args.join(", ")}`);
        Deno.exit(1);
      }
    } else {
      // Confirmation for --all
      console.log("⚠️  WARNING: This will remove ALL packages defined in packages.yaml!");
      console.log("Press Ctrl+C to cancel, or wait 5 seconds to continue...");
      await new Promise(resolve => setTimeout(resolve, 5000));
    }
    
    console.log("🗑️  Removing packages...\n");
    
    // Process all providers in parallel
    const providerPromises = Array.from(packages.entries()).map(async ([providerName, pkgs]) => {
      const provider = providers.get(providerName);
      if (!provider) return;
      
      console.log(`${providerName}:`);
      
      const promises = pkgs.map(async (pkg) => {
        const result = await provider.remove(pkg).catch((error) => ({
          success: false,
          changed: false,
          message: error.message
        }));
        return { pkg, result };
      });
      
      const results = await Promise.all(promises);
      
      for (const { pkg, result } of results) {
        if (result.success) {
          if (result.changed) {
            console.log(`  ✅ ${pkg.id} - removed`);
          } else {
            console.log(`  ⏭️  ${pkg.id} - not installed`);
          }
        } else {
          console.log(`  ❌ ${pkg.id} - failed: ${result.message}`);
        }
      }
    });
    
    await Promise.all(providerPromises);
  },
  
  /**
   * Help
   */
  help() {
    console.log(`
Bundle - Idempotent Package Manager

Usage:
  bundle.ts <command> [options]

Commands:
  install                    - Ensure all packages are installed
  check                      - Check package states
  remove <package> [...]     - Remove specific packages
  remove --all               - Remove ALL packages (dangerous!)
  help                       - Show this help

Examples:
  bundle.ts install          - Install all packages from packages.yaml
  bundle.ts check            - Check status of all packages
  bundle.ts remove tree jq   - Remove only tree and jq packages
  bundle.ts remove --all     - Remove all packages (requires confirmation)

Features:
  - Idempotent operations (safe to run multiple times)
  - Parallel package processing
  - Filesystem-based checks for speed
  - Cross-platform support (macOS, Linux, Windows)
`);
  }
};


// Main execution
if (import.meta.main) {
  const command = Deno.args[0] || "help";
  
  try {
    if (command in commands) {
      await commands[command as keyof typeof commands]();
    } else {
      commands.help();
    }
  } catch (error) {
    const message = error instanceof Error ? error.message : String(error);
    console.error(`\n❌ Error: ${message}`);
    Deno.exit(1);
  }
}