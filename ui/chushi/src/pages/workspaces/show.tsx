import {Link, useLoaderData, useParams} from "react-router-dom";
import {Workspace} from "../../types";
import {apiClient} from "../../Client.tsx";
import {Anchor, Breadcrumbs, Container} from "@mantine/core";

const Page = () => {
  let { organizationName, workspaceName } = useParams();
  const workspace = useLoaderData() as Workspace

  const items = [
    { title: 'Workspaces', href: `/${organizationName}/workspaces` },
    { title: workspaceName, href: `/${organizationName}/${workspaceName}` },
  ].map((item, index) => (
    <Anchor to={item.href} key={index} component={Link}>
      {item.title}
    </Anchor>
  ));
  console.log(workspace)
  return (
    <Container>
      <Breadcrumbs separator=">" separatorMargin="md" mt="xs">
        {items}
      </Breadcrumbs>
      <h4>{workspaceName}</h4>

      <Link to={`/${organizationName}/${workspaceName}/runs`}>
        Runs
      </Link>
    </Container>
  )
}

const Loader = async({params}: { params: any}): Promise<Workspace> => {
  const { data: workspace } = await apiClient.get(`/api/v2/organizations/${params.organizationName}/workspaces/${params.workspaceName}`)
  return workspace
}

export default {
  Page, Loader
}