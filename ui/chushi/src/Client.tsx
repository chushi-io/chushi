import axios from "axios";
// @ts-ignore
import {deserialize} from "deserialize-json-api";

const newApiClient = () => {
  let client = axios.create({
    headers: {
      "Content-Type": "application/json",
    },
  });
  client.interceptors.response.use((response) => {
    return {
      ...response,
      ...deserialize(response.data, { transformKeys: "camelCase" }),
    };
  }, (error) => {
    return Promise.reject(error);
  });
  return client
}


export const apiClient = newApiClient();