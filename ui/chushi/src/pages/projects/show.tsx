import {apiClient} from "../../Client.tsx";

const Page = () => {
  return <h2>Viewing a project</h2>
}

const Loader = async ({params}: { params: any}) => {
  const { data: project } = await apiClient.get(`/api/v2/projects/${params.projectId}`)
  return project
}

export default { Page, Loader }