/**
 * Linux providers - native implementation
 */

import { Package, State } from "../core.ts";
import { BaseProvider } from "./base.ts";

// Command execution with minimal overhead
async function exec(cmd: string[], options?: { quiet?: boolean }): Promise<{ success: boolean; stdout: string; stderr: string }> {
  try {
    const process = new Deno.Command(cmd[0], {
      args: cmd.slice(1),
      stdout: "piped",
      stderr: options?.quiet ? "null" : "piped",
    });
    
    const result = await process.output();
    return {
      success: result.success,
      stdout: new TextDecoder().decode(result.stdout),
      stderr: new TextDecoder().decode(result.stderr),
    };
  } catch (error) {
    return {
      success: false,
      stdout: "",
      stderr: error instanceof Error ? error.message : String(error),
    };
  }
}

/**
 * APT provider
 */
export class AptProvider extends BaseProvider {
  readonly name = "apt";
  
  async check(pkg: Package): Promise<State> {
    const result = await exec(["dpkg", "-l", pkg.id], { quiet: true });
    return result.success && result.stdout.includes("ii ") ? State.Installed : State.Missing;
  }
  
  protected async doInstall(pkg: Package): Promise<void> {
    const result = await exec(["sudo", "apt-get", "install", "-y", pkg.id]);
    if (!result.success) {
      throw new Error(result.stderr || "APT installation failed");
    }
  }
  
  protected async doRemove(pkg: Package): Promise<void> {
    const result = await exec(["sudo", "apt-get", "remove", "-y", pkg.id]);
    if (!result.success) {
      throw new Error(result.stderr || "APT removal failed");
    }
  }
}

/**
 * Pacman provider
 */
export class PacmanProvider extends BaseProvider {
  readonly name = "pacman";
  
  async check(pkg: Package): Promise<State> {
    const result = await exec(["pacman", "-Q", pkg.id], { quiet: true });
    return result.success ? State.Installed : State.Missing;
  }
  
  protected async doInstall(pkg: Package): Promise<void> {
    const result = await exec(["sudo", "pacman", "-S", "--noconfirm", pkg.id]);
    if (!result.success) {
      throw new Error(result.stderr || "Pacman installation failed");
    }
  }
  
  protected async doRemove(pkg: Package): Promise<void> {
    const result = await exec(["sudo", "pacman", "-R", "--noconfirm", pkg.id]);
    if (!result.success) {
      throw new Error(result.stderr || "Pacman removal failed");
    }
  }
}

/**
 * DNF provider
 */
export class DnfProvider extends BaseProvider {
  readonly name = "dnf";
  
  async check(pkg: Package): Promise<State> {
    const result = await exec(["rpm", "-q", pkg.id], { quiet: true });
    return result.success ? State.Installed : State.Missing;
  }
  
  protected async doInstall(pkg: Package): Promise<void> {
    const result = await exec(["sudo", "dnf", "install", "-y", pkg.id]);
    if (!result.success) {
      throw new Error(result.stderr || "DNF installation failed");
    }
  }
  
  protected async doRemove(pkg: Package): Promise<void> {
    const result = await exec(["sudo", "dnf", "remove", "-y", pkg.id]);
    if (!result.success) {
      throw new Error(result.stderr || "DNF removal failed");
    }
  }
}

/**
 * GitHub Release provider (optimized)
 */
interface GitHubReleasePackage extends Package {
  repo: string;
  file: string;
  type: "deb" | "rpm" | "tar" | "zip";
}

export class GitHubReleaseProvider extends BaseProvider {
  readonly name = "github_release";
  
  // Cache for GitHub API responses
  private static releaseCache = new Map<string, any>();
  
  async check(pkg: Package): Promise<State> {
    const ghPkg = pkg as GitHubReleasePackage;
    
    switch (ghPkg.type) {
      case "deb":
        const dpkgResult = await exec(["dpkg", "-l", ghPkg.id], { quiet: true });
        return dpkgResult.success ? State.Installed : State.Missing;
      case "rpm":
        const rpmResult = await exec(["rpm", "-q", ghPkg.id], { quiet: true });
        return rpmResult.success ? State.Installed : State.Missing;
      default:
        const whichResult = await exec(["which", ghPkg.id], { quiet: true });
        return whichResult.success ? State.Installed : State.Missing;
    }
  }
  
  protected async doInstall(pkg: Package): Promise<void> {
    const ghPkg = pkg as GitHubReleasePackage;
    
    // Check cache first
    let release = GitHubReleaseProvider.releaseCache.get(ghPkg.repo);
    if (!release) {
      const apiUrl = `https://api.github.com/repos/${ghPkg.repo}/releases/latest`;
      const response = await fetch(apiUrl);
      release = await response.json();
      GitHubReleaseProvider.releaseCache.set(ghPkg.repo, release);
    }
    
    const version = release.tag_name.replace(/^v/, "");
    const filename = ghPkg.file
      .replace("VERSION", version)
      .replace("vVERSION", `v${version}`);
    
    const asset = release.assets.find((a: any) => a.name === filename);
    if (!asset) {
      throw new Error(`Asset ${filename} not found`);
    }
    
    const tempFile = `/tmp/${filename}`;
    
    // Download with native fetch
    const downloadResponse = await fetch(asset.browser_download_url);
    const arrayBuffer = await downloadResponse.arrayBuffer();
    await Deno.writeFile(tempFile, new Uint8Array(arrayBuffer));
    
    // Install based on type
    let result;
    switch (ghPkg.type) {
      case "deb":
        result = await exec(["sudo", "dpkg", "-i", tempFile]);
        break;
      case "rpm":
        result = await exec(["sudo", "rpm", "-i", tempFile]);
        break;
      case "tar":
        await exec(["tar", "-xzf", tempFile, "-C", "/tmp"]);
        const binPath = `${Deno.env.get("HOME")}/.local/bin`;
        await Deno.mkdir(binPath, { recursive: true });
        result = await exec(["find", "/tmp", "-name", ghPkg.id, "-type", "f", "-executable", "-exec", "mv", "{}", `${binPath}/`, ";"]);
        break;
      case "zip":
        await exec(["unzip", "-o", tempFile, "-d", "/tmp"]);
        const binPath2 = `${Deno.env.get("HOME")}/.local/bin`;
        await Deno.mkdir(binPath2, { recursive: true });
        result = await exec(["find", "/tmp", "-name", ghPkg.id, "-type", "f", "-executable", "-exec", "mv", "{}", `${binPath2}/`, ";"]);
        break;
      default:
        throw new Error(`Unsupported package type: ${ghPkg.type}`);
    }
    
    // Cleanup
    try {
      await Deno.remove(tempFile);
    } catch {
      // Ignore cleanup errors
    }
    
    if (!result?.success) {
      throw new Error(result?.stderr || "Installation failed");
    }
  }
  
  protected async doRemove(pkg: Package): Promise<void> {
    const ghPkg = pkg as GitHubReleasePackage;
    
    let result;
    switch (ghPkg.type) {
      case "deb":
        result = await exec(["sudo", "apt", "remove", "-y", ghPkg.id]);
        break;
      case "rpm":
        result = await exec(["sudo", "rpm", "-e", ghPkg.id]);
        break;
      default:
        const binPath = `${Deno.env.get("HOME")}/.local/bin/${ghPkg.id}`;
        try {
          await Deno.remove(binPath);
          result = { success: true, stdout: "", stderr: "" };
        } catch {
          result = { success: false, stdout: "", stderr: "Binary not found" };
        }
    }
    
    if (!result.success) {
      throw new Error(result.stderr || "Removal failed");
    }
  }
}

/**
 * Git Clone provider
 */
interface GitClonePackage extends Package {
  repo: string;
  dest: string;
}

export class GitCloneProvider extends BaseProvider {
  readonly name = "git_clone";
  
  async check(pkg: Package): Promise<State> {
    const gitPkg = pkg as GitClonePackage;
    const dest = gitPkg.dest.replace("$HOME", Deno.env.get("HOME") || "");
    
    try {
      await Deno.stat(`${dest}/.git`);
      return State.Installed;
    } catch {
      return State.Missing;
    }
  }
  
  protected async doInstall(pkg: Package): Promise<void> {
    const gitPkg = pkg as GitClonePackage;
    const dest = gitPkg.dest.replace("$HOME", Deno.env.get("HOME") || "");
    
    // Create parent directory
    const parent = dest.substring(0, dest.lastIndexOf("/"));
    await Deno.mkdir(parent, { recursive: true });
    
    const result = await exec(["git", "clone", gitPkg.repo, dest]);
    if (!result.success) {
      throw new Error(result.stderr || "Git clone failed");
    }
  }
  
  protected async doRemove(pkg: Package): Promise<void> {
    const gitPkg = pkg as GitClonePackage;
    const dest = gitPkg.dest.replace("$HOME", Deno.env.get("HOME") || "");
    
    try {
      await Deno.remove(dest, { recursive: true });
    } catch (error) {
      const message = error instanceof Error ? error.message : String(error);
      throw new Error(`Failed to remove ${dest}: ${message}`);
    }
  }
}

/**
 * Script provider with caching
 */
interface ScriptPackage extends Package {
  script: string;
}

export class ScriptProvider extends BaseProvider {
  readonly name = "script";
  
  // Track executed scripts to avoid re-running
  private static executedScripts = new Set<string>();
  
  async check(pkg: Package): Promise<State> {
    // Check if script was already executed in this session
    if (ScriptProvider.executedScripts.has(pkg.id)) {
      return State.Installed;
    }
    
    // For scripts, we can't reliably check state
    return State.Missing;
  }
  
  protected async doInstall(pkg: Package): Promise<void> {
    const scriptPkg = pkg as ScriptPackage;
    
    // Mark as executed to avoid re-running
    ScriptProvider.executedScripts.add(pkg.id);
    
    const result = await exec(["bash", "-c", scriptPkg.script || pkg.id]);
    if (!result.success) {
      // Remove from executed set if failed
      ScriptProvider.executedScripts.delete(pkg.id);
      throw new Error(result.stderr || "Script execution failed");
    }
  }
  
  protected async doRemove(_pkg: Package): Promise<void> {
    // Scripts typically don't support removal
    console.log("Scripts cannot be automatically removed");
  }
}

/**
 * Cargo provider
 */
export class CargoProvider extends BaseProvider {
  readonly name = "cargo";
  
  async check(pkg: Package): Promise<State> {
    const result = await exec(["which", pkg.id], { quiet: true });
    return result.success ? State.Installed : State.Missing;
  }
  
  protected async doInstall(pkg: Package): Promise<void> {
    const args = ["cargo", "install", pkg.id];
    if (pkg.version) args.push("--version", pkg.version);
    
    const result = await exec(args);
    if (!result.success) {
      throw new Error(result.stderr || "Cargo installation failed");
    }
  }
  
  protected async doRemove(pkg: Package): Promise<void> {
    const result = await exec(["cargo", "uninstall", pkg.id]);
    if (!result.success) {
      throw new Error(result.stderr || "Cargo removal failed");
    }
  }
}