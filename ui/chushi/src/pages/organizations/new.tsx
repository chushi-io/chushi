import { Form } from "react-router-dom";
import {apiClient} from "../../Client.tsx";
import {Organization, OrganizationSerializer} from "../../types/Organization.tsx";
import {Button, Group, Select, TextInput} from "@mantine/core";

const Page = () => {
  return (
    <>
      <Form method="post">
        <TextInput
          label="Name"
          name={"name"}
        />
        <TextInput
          label="Email"
          name={"email"}
        />
        <Select
          label="Organization Type"
          data={['personal', 'business']}
        />
        <Group justify="flex-end" mt="md">
          <Button type="submit">Create</Button>
        </Group>
      </Form>
    </>
  )
}

export async function Action({ request }: any) {
  const form = await request.formData();

  const organizationInput: Partial<Organization> = {};
  for (const [key, value] of [...form.entries()]) {
    // @ts-ignore
    organizationInput[key] = value;
  }
  const data = OrganizationSerializer.serialize(organizationInput)
  const organization = await apiClient.post(
    '/api/v2/organizations',
    data
  )
  return { organization };
}

export default { Page, Action }