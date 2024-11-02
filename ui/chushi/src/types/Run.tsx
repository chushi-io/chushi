import {Serializer} from "jsonapi-serializer";
import {Workspace} from "./Workspace";

export interface Run {
  id: string;
  externalId: string;
  message: string;
  planOnly: boolean;
  refreshOnly: boolean;
  workspace: Partial<Workspace>;
  taskStages: Partial<TaskStage>[];
  plan: Plan;
}

export interface TaskStage {
  id: string;
  status: string;
  stage: string;
  taskResults: Partial<TaskResult>[]
  policyEvaluations: Partial<PolicyEvaluation>[]
}

export interface TaskResult {
  id: string;
  message: string;
  status: string;
  statusTimestamps: object;
  url: string;
  taskId: string;
  taskName: string;
  taskUrl: string;
  stage: string;
  isSpeculative: boolean;
  workspaceTaskId: string;
  workspaceTaskEnforcementLevel: string;
}

export interface PolicyEvaluation {
  id: string;
  status: string;
  policyKind: string;
  policyToolVersion: string;
  resultCount: number;
  statusTimestamps: object;
}

export interface RunEvent {
  id: string;
}

export interface Plan {
  id: string;
  logReadUrl: string;
}

export const RunSerializer = new Serializer('runs', {
  attributes: [
    'message',
    'planOnly',
    'refreshOnly',
    'workspace'
  ],
  workspace: {
    ref: 'id',
    included: false
  },
});