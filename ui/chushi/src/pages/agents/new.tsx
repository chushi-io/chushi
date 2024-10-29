import {Form, useParams, Link} from "react-router-dom";
import {Anchor, Button, Checkbox, Group, TextInput} from "@mantine/core";
import {AgentPool} from "../../types";
import {apiClient} from "../../Client.tsx";
import {AgentSerializer} from "../../types/AgentPool.tsx";
import PageHeader from "../../components/PageHeader";

const Page = () => {
  const { organizationName } = useParams()
  return (
    <>
      <PageHeader
        breadcrumbs={[
          <Anchor to={`/${organizationName}/agent-pools`} component={Link}>
            Agent Pools
          </Anchor>
        ]}
      />
      <Form method="post">
        <TextInput
          label="Name"
          name={"name"}
        />
        <input type={"hidden"} name={"organization"} value={organizationName}/>
        <Checkbox label="Organization Scoped" name={"organizationScoped"} />
        <Checkbox label="Default" name={"default"} />
        <Group justify="flex-end" mt="md">
          <Button type="submit">Create</Button>
        </Group>
      </Form>
    </>
  )
}

const Action = async ({ request }: any) => {
  const form = await request.formData();

  let organizationName = "";

  const agentInput: Partial<AgentPool> = {};
  for (const [key, value] of [...form.entries()]) {
    if (key == "organization") {
      organizationName = value
    } else {
      // @ts-ignore
      agentInput[key] = value
    }
  }

  const data = AgentSerializer.serialize(agentInput)
  const agentPool = await apiClient.post(
    `/api/v2/organizations/${organizationName}/agent-pools`,
    data
  )
  return { agentPool }

}

export default { Page, Action }