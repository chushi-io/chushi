import {Serializer} from "jsonapi-serializer";

export interface Policy {
  id: string;
  name: string;
  description: string;
  kind: string;
  query: string;
  enforcementLevel: string;
  policySetCount: number;
  updatedAt: string;
}

export const PolicySerializer = new Serializer("policies", {
  attributes: [
    "name",
    "description",
    "query",
    "enforcementLevel",
  ]
})