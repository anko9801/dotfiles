/**
 * Core abstractions for idempotent package management
 */

// ============================================================================
// Core Types
// ============================================================================

/**
 * Simple package representation
 */
export interface Package {
  id: string;
  version?: string;
}

/**
 * Package state for idempotency
 */
export enum State {
  Installed = "installed",
  Missing = "missing",
  Unknown = "unknown",
}

/**
 * Idempotent operation result
 */
export interface Result {
  success: boolean;
  changed: boolean;  // Key for idempotency
  message?: string;
}

// ============================================================================
// Provider Interface
// ============================================================================

/**
 * Minimal provider interface - all operations are idempotent
 */
export interface Provider {
  readonly name: string;
  
  /** Check package state (read-only, always idempotent) */
  check(pkg: Package): Promise<State>;
  
  /** Ensure package is installed (idempotent) */
  install(pkg: Package): Promise<Result>;
  
  /** Ensure package is removed (idempotent) */
  remove(pkg: Package): Promise<Result>;
}

