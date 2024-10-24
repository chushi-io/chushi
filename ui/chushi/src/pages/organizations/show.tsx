import {Organization} from "../../types";
import {apiClient} from "../../Client.tsx";
import {useLoaderData} from "react-router-dom";

const Page = () => {
  const organization = useLoaderData() as Organization
  return (
    <h4>{organization.name}</h4>
  )
}

export const Loader = async ({ params }: { params: any}): Promise<Organization[]> => {
  const { data: organizations } = await apiClient.get(`/api/v2/organizations/${params.organizationName}`)
  return organizations as Organization[];
}

export default {
  Page,
  Loader
}