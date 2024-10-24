import {Run} from "../../types";
import {apiClient} from "../../Client.tsx";
import {useLoaderData} from "react-router-dom";

const Page = () => {
  // let { organizationName, workspaceName } = useParams();
  const run = useLoaderData() as Run

  console.log(run)

  return (
    <h4>{run.id}</h4>
  )
}

const Loader = async ({params}: { params: any}): Promise<Run> => {
  const { data: run } = await apiClient.get(`/api/v2/runs/${params.runId}`)
  return run as Run;
}

export default {
  Page, Loader
}
