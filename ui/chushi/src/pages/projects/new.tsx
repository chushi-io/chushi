import {Project} from "../../types";
import {apiClient} from "../../Client.tsx";
import {ProjectSerializer} from "../../types/Project.tsx";
import {Form, Link, useParams} from "react-router-dom";
import PageHeader from "../../components/PageHeader";
import {Anchor, Button, Group, TextInput} from "@mantine/core";

const Page = () => {
  const { organizationName } = useParams()
  return (
    <>
      <PageHeader
        breadcrumbs={[
          <Anchor to={`/${organizationName}/projects`} component={Link}>
            Projects
          </Anchor>
        ]}
      />
      <Form method="post">
        <TextInput
          label="Name"
          name={"name"}
        />
        <TextInput
          label="Description"
          name={"description"}
        />
        <input type={"hidden"} name={"organization"} value={organizationName}/>
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
  const projectInput: Partial<Project> = {}
  for (const [key, value] of [...form.entries()]) {
    if (key == "organization") {
      organizationName = value
    } else {
      // @ts-ignore
      projectInput[key] = value
    }
  }

  const data = ProjectSerializer.serialize(projectInput)
  const project = await apiClient.post(
    `/api/v2/organizations/${organizationName}/projects`,
    data
  )
  return { project }
}

export default { Page, Action }