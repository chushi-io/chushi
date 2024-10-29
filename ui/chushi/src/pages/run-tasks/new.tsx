import {RunTask} from "../../types";
import {apiClient} from "../../Client.tsx";
import {Form, Link, useParams} from "react-router-dom";
import PageHeader from "../../components/PageHeader";
import {Anchor, Button, Checkbox, Group, PasswordInput, TextInput} from "@mantine/core";
import {RunTaskSerializer} from "../../types/RunTask.tsx";

const Page = () => {
  const { organizationName } = useParams()
  return (
    <>
      <PageHeader
        breadcrumbs={[
          <Anchor to={`/${organizationName}/tasks`} component={Link}>
            Run Tasks
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
        <TextInput
          label="URL"
          name={"url"}
        />
        <Checkbox defaultChecked label="Enabled" name={"enabled"} />
        <PasswordInput
          label="HMAC Key"
          name={"hmacKey"}
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
  const runTaskInput: Partial<RunTask> = {}
  for (const [key, value] of [...form.entries()]) {
    if (key == "organization") {
      organizationName = value
    } else {
      // @ts-ignore
      runTaskInput[key] = value
    }
  }

  const data = RunTaskSerializer.serialize(runTaskInput)
  const runTask = await apiClient.post(
    `/api/v2/organizations/${organizationName}/tasks`,
    data
  )
  return { runTask }
}

export default { Page, Action }