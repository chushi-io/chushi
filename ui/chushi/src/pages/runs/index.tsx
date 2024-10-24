import {Run} from "../../types";
import {apiClient} from "../../Client.tsx";
import {Link, useLoaderData, useParams} from "react-router-dom";
import {Anchor, Breadcrumbs, Container} from "@mantine/core";

const Page = () => {
  let {
    organizationName,
    workspaceName
  } = useParams();

  const runs = useLoaderData() as Run[]

  const items = [
    { title: 'Workspaces', href: `/${organizationName}/workspaces` },
    { title: workspaceName, href: `/${organizationName}/${workspaceName}` },
    { title: 'Runs', href: "#" },
  ].map((item, index) => (
    <Anchor to={item.href} key={index} component={Link}>
      {item.title}
    </Anchor>
  ));

  return (
    <Container>
      <Breadcrumbs separator=">" separatorMargin="md" mt="xs">
        {items}
      </Breadcrumbs>
      <ul>
        {runs.map(run => {
          return <Link to={`/${organizationName}/${workspaceName}/runs/${run.id}`}>
            {run.id}
          </Link>
        })}
      </ul>
    </Container>
  )
}
const Loader = async ({params}: { params: any}): Promise<Run[]> => {
  const { data: runs } = await apiClient.get(`/api/v2/workspaces/${params.workspaceName}/runs`)
  return runs as Run[];
}

export default {
  Page, Loader
}