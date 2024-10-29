import {Serializer} from "jsonapi-serializer";

export interface Project {
  id: string;
  name: string;
  description: string;
  workspaceCount: number;
  teamCount: number;
  permissions: object;
  autoDestroyActivityDuration: string;
}

export const ProjectSerializer = new Serializer('projects', {
  attributes: [
    'name', 'description'
  ]
});