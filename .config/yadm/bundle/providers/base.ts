/**
 * Base provider implementation with idempotent operations
 */

import { Provider, Package, State, Result } from "../core.ts";

export abstract class BaseProvider implements Provider {
  abstract readonly name: string;
  
  /**
   * Check if package is installed
   */
  abstract check(pkg: Package): Promise<State>;
  
  /**
   * Install operation (idempotent)
   */
  async install(pkg: Package): Promise<Result> {
    try {
      const state = await this.check(pkg);
      
      if (state === State.Installed) {
        return { success: true, changed: false };
      }
      
      await this.doInstall(pkg);
      
      // Verify installation
      const newState = await this.check(pkg);
      if (newState === State.Installed) {
        return { success: true, changed: true };
      } else {
        return { success: false, changed: false, message: "Installation verification failed" };
      }
    } catch (error) {
      const message = error instanceof Error ? error.message : String(error);
      return { success: false, changed: false, message };
    }
  }
  
  /**
   * Remove operation (idempotent)
   */
  async remove(pkg: Package): Promise<Result> {
    try {
      const state = await this.check(pkg);
      
      if (state === State.Missing) {
        return { success: true, changed: false };
      }
      
      await this.doRemove(pkg);
      
      // Verify removal
      const newState = await this.check(pkg);
      if (newState === State.Missing) {
        return { success: true, changed: true };
      } else {
        return { success: false, changed: false, message: "Removal verification failed" };
      }
    } catch (error) {
      const message = error instanceof Error ? error.message : String(error);
      return { success: false, changed: false, message };
    }
  }
  
  /**
   * Actual installation implementation
   */
  protected abstract doInstall(pkg: Package): Promise<void>;
  
  /**
   * Actual removal implementation
   */
  protected abstract doRemove(pkg: Package): Promise<void>;
}