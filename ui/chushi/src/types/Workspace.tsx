
export interface Workspace {
  id: string;
  permissions: object;
  queueAllRuns: boolean | null;
  allowDestroyPlan: boolean;
  autoApply: boolean;
  autoApplyRunTrigger: boolean;
  description: string | null;
  environment: string | null;
  executionMode: string;
  fileTriggersEnabled: boolean;
  globalRemoteState: boolean;
  latestChangeAt: string | null;
  locked: boolean;
  name: string;
  resourceCount: number | null;
  source: string | null;
  speculativeEnabled: boolean;
  structuredRunOutputEnabled: boolean;
  terraformVersion: string | null;
  triggerPrefixes: string[]
  workingDirectory: string | null;
}