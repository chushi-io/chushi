import { Serializer } from "jsonapi-serializer"

export interface Organization {
  id: string;
  createdAt: string;
  email: string;
  name: string;
  defaultExecutionMode: string;
  type: string;
}

export const OrganizationSerializer = new Serializer('organizations', {
  attributes: ['name', 'email', 'default-execution-mode', 'type']
});
