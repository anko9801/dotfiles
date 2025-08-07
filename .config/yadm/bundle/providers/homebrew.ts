/**
 * Homebrew provider - uses direct filesystem checks
 */

import { Package, State } from "../core.ts";
import { BaseProvider } from "./base.ts";

// Cache for Homebrew paths
let brewPrefix: string | null = null;
let cellarPath: string | null = null;
let caskroomPath: string | null = null;

async function getBrewPaths() {
  if (brewPrefix) return;
  
  try {
    // Try common paths first
    const commonPaths = [
      "/opt/homebrew",  // Apple Silicon
      "/usr/local"      // Intel Macs
    ];
    
    for (const path of commonPaths) {
      try {
        await Deno.stat(`${path}/bin/brew`);
        brewPrefix = path;
        break;
      } catch {
        continue;
      }
    }
    
    if (!brewPrefix) {
      // Fallback to brew command (slower)
      const process = new Deno.Command("brew", {
        args: ["--prefix"],
        stdout: "piped",
      });
      const result = await process.output();
      if (result.success) {
        brewPrefix = new TextDecoder().decode(result.stdout).trim();
      }
    }
    
    if (brewPrefix) {
      cellarPath = `${brewPrefix}/Cellar`;
      caskroomPath = `${brewPrefix}/Caskroom`;
    }
  } catch {
    // Homebrew not installed
    brewPrefix = "";
  }
}

// Command execution for installations only
async function brewExec(args: string[]): Promise<{ success: boolean; stderr: string }> {
  try {
    const process = new Deno.Command("brew", {
      args,
      stderr: "piped",
    });
    
    const result = await process.output();
    return {
      success: result.success,
      stderr: new TextDecoder().decode(result.stderr),
    };
  } catch (error) {
    return {
      success: false,
      stderr: error instanceof Error ? error.message : String(error),
    };
  }
}

/**
 * Homebrew provider using filesystem checks
 */
export class HomebrewProvider extends BaseProvider {
  readonly name = "homebrew";
  
  async check(pkg: Package): Promise<State> {
    await getBrewPaths();
    
    if (!cellarPath) return State.Missing;
    
    try {
      // Direct filesystem check - more efficient than `brew list`
      const packageDir = `${cellarPath}/${pkg.id}`;
      await Deno.stat(packageDir);
      return State.Installed;
    } catch {
      return State.Missing;
    }
  }
  
  protected async doInstall(pkg: Package): Promise<void> {
    const args = ["install", pkg.id];
    if (pkg.version) args.push(`@${pkg.version}`);
    
    const result = await brewExec(args);
    if (!result.success) {
      throw new Error(result.stderr || "Installation failed");
    }
  }
  
  protected async doRemove(pkg: Package): Promise<void> {
    const result = await brewExec(["uninstall", pkg.id]);
    if (!result.success) {
      throw new Error(result.stderr || "Removal failed");
    }
  }
}

/**
 * Homebrew tap provider using filesystem checks
 */
export class BrewTapProvider extends BaseProvider {
  readonly name = "homebrew_tap";
  
  async check(pkg: Package): Promise<State> {
    await getBrewPaths();
    
    if (!brewPrefix) return State.Missing;
    
    try {
      // Check tap directory directly
      const tapPath = `${brewPrefix}/Library/Taps/${pkg.id.replace("/", "/homebrew-")}`;
      await Deno.stat(tapPath);
      return State.Installed;
    } catch {
      return State.Missing;
    }
  }
  
  protected async doInstall(pkg: Package): Promise<void> {
    const result = await brewExec(["tap", pkg.id]);
    if (!result.success) {
      throw new Error(result.stderr || "Tap failed");
    }
  }
  
  protected async doRemove(pkg: Package): Promise<void> {
    const result = await brewExec(["untap", pkg.id]);
    if (!result.success) {
      throw new Error(result.stderr || "Untap failed");
    }
  }
}

/**
 * Homebrew cask provider using filesystem checks
 */
export class BrewCaskProvider extends BaseProvider {
  readonly name = "homebrew_cask";
  
  async check(pkg: Package): Promise<State> {
    await getBrewPaths();
    
    if (!caskroomPath) return State.Missing;
    
    try {
      // Direct filesystem check for casks
      const caskDir = `${caskroomPath}/${pkg.id}`;
      await Deno.stat(caskDir);
      return State.Installed;
    } catch {
      return State.Missing;
    }
  }
  
  protected async doInstall(pkg: Package): Promise<void> {
    const result = await brewExec(["install", "--cask", pkg.id]);
    if (!result.success) {
      throw new Error(result.stderr || "Cask installation failed");
    }
  }
  
  protected async doRemove(pkg: Package): Promise<void> {
    const result = await brewExec(["uninstall", "--cask", pkg.id]);
    if (!result.success) {
      throw new Error(result.stderr || "Cask removal failed");
    }
  }
}