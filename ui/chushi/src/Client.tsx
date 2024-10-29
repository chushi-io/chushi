import axios from "axios";
import {deserialize} from "json-api-deserialize";

const newApiClient = () => {
  let client = axios.create({
    headers: {
      "Content-Type": "application/json",
    },
  });
  client.interceptors.response.use((response) => {
    return {
      ...response,
      ...deserialize(response.data),
    };
  }, (error) => {
    return Promise.reject(error);
  });
  return client
}

export const apiClient = newApiClient();