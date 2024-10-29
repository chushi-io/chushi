import {Serializer} from "jsonapi-serializer";

export interface RunTask {
  id: string;
  category: string;
  name: string;
  url: string;
  description: string;
  enabled: boolean;
  hmacKey: string;
}

export const RunTaskSerializer = new Serializer('tasks', {
  attributes: [
    'name',
    'category',
    'url',
    'description',
    'enabled',
    'hmac-key'
  ]
});