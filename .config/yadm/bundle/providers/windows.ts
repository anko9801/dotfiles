/**
 * Windows providers - native implementation
 */

import { Package, State } from "../core.ts";
import { BaseProvider } from "./base.ts";

// Windows command execution
async function winExec(cmd: string[], options?: { quiet?: boolean }): Promise<{ success: boolean; stdout: string; stderr: string }> {
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
 * Winget provider
 */
export class WingetProvider extends BaseProvider {
  readonly name = "winget";
  
  async check(pkg: Package): Promise<State> {
    const result = await winExec(["winget", "list", "--id", pkg.id], { quiet: true });
    return result.success && result.stdout.includes(pkg.id) ? State.Installed : State.Missing;
  }
  
  protected async doInstall(pkg: Package): Promise<void> {
    const result = await winExec([
      "winget", "install", "--id", pkg.id, 
      "--silent", "--accept-package-agreements", "--accept-source-agreements"
    ]);
    if (!result.success) {
      throw new Error(result.stderr || "Winget installation failed");
    }
  }
  
  protected async doRemove(pkg: Package): Promise<void> {
    const result = await winExec(["winget", "uninstall", "--id", pkg.id, "--silent"]);
    if (!result.success) {
      throw new Error(result.stderr || "Winget removal failed");
    }
  }
}

/**
 * Scoop provider
 */
export class ScoopProvider extends BaseProvider {
  readonly name = "scoop";
  
  async check(pkg: Package): Promise<State> {
    const result = await winExec(["scoop", "list", pkg.id], { quiet: true });
    return result.success && result.stdout.includes(pkg.id) ? State.Installed : State.Missing;
  }
  
  protected async doInstall(pkg: Package): Promise<void> {
    const result = await winExec(["scoop", "install", pkg.id]);
    if (!result.success) {
      throw new Error(result.stderr || "Scoop installation failed");
    }
  }
  
  protected async doRemove(pkg: Package): Promise<void> {
    const result = await winExec(["scoop", "uninstall", pkg.id]);
    if (!result.success) {
      throw new Error(result.stderr || "Scoop removal failed");
    }
  }
}

/**
 * PowerShell provider
 */
interface PowerShellPackage extends Package {
  script: string;
}

export class PowerShellProvider extends BaseProvider {
  readonly name = "powershell";
  
  // Cache executed scripts
  private static executedScripts = new Set<string>();
  
  async check(pkg: Package): Promise<State> {
    if (PowerShellProvider.executedScripts.has(pkg.id)) {
      return State.Installed;
    }
    
    const result = await winExec(["powershell", "-Command", `Get-Command ${pkg.id}`], { quiet: true });
    return result.success ? State.Installed : State.Missing;
  }
  
  protected async doInstall(pkg: Package): Promise<void> {
    const psPkg = pkg as PowerShellPackage;
    
    PowerShellProvider.executedScripts.add(pkg.id);
    
    const result = await winExec(["powershell", "-Command", psPkg.script]);
    if (!result.success) {
      PowerShellProvider.executedScripts.delete(pkg.id);
      throw new Error(result.stderr || "PowerShell script failed");
    }
  }
  
  protected async doRemove(_pkg: Package): Promise<void> {
    throw new Error("PowerShell script removal not supported");
  }
}