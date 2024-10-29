import {apiClient} from "../../Client.tsx";
import {Link, useLoaderData, useParams} from "react-router-dom";
import {AgentPool} from "../../types";
import {Anchor, Container} from "@mantine/core";
import PageHeader from "../../components/PageHeader";

const Page = () => {
  let { organizationName } = useParams();
  const agentPool = useLoaderData() as AgentPool
  return (
    <Container fluid>
      <PageHeader
        breadcrumbs={[
          <Anchor to={`/${organizationName}/agent-pools`} component={Link}>
            Agent Pools
          </Anchor>,
          <Anchor to={`/${organizationName}/agent-pools/${agentPool.id}`} component={Link}>
            {agentPool.name}
          </Anchor>
        ]} />
    </Container>
  )
}

const Loader = async ({params}: { params: any}) => {
  const { data: agentPool } = await apiClient.get(`/api/v2/agent-pools/${params.agentPoolId}`)
  return agentPool
}

export default { Page, Loader }