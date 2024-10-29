import {Serializer} from "jsonapi-serializer";

export interface AgentPool {
  id: string;
  createdAt: string;
  name: string;
  organizationScoped: boolean;
}

export const AgentSerializer = new Serializer('agent-pools', {
  attributes: ['name', 'organization-scoped']
});