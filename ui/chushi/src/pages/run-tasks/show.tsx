import {apiClient} from "../../Client.tsx";

const Page = () => {
  return <h4>Viewing a run task</h4>
}

const Loader = async ({params}: { params: any}) => {
  const { data: runTask } = await apiClient.get(`/api/v2/tasks/${params.runTaskId}`)
  return runTask
}

export default { Page, Loader }