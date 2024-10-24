import {useLoaderData} from "react-router-dom";
import {Workspace} from "../../types";
import {apiClient} from "../../Client.tsx";

const Page = () => {
  const workspace = useLoaderData() as Workspace
  return (
    <h4>{workspace.name}</h4>
  )
}

export const Loader = async({params}: { params: any}): Promise<Workspace> => {
  const { data: workspace } = await apiClient.get(`/api/v2/workspaces/${params.name}`)
  return workspace
}

export default {
  Page, Loader
}