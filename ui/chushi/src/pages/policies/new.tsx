import {Policy} from "../../types";
import {apiClient} from "../../Client.tsx";
import {PolicySerializer} from "../../types/Policy.tsx";
import {Form, Link, useParams} from "react-router-dom";
import PageHeader from "../../components/PageHeader";
import {Anchor, Button, Group, Input, Select, TextInput} from "@mantine/core";
import CodeMirror from '@uiw/react-codemirror';
import {SetStateAction, useCallback, useState} from "react";

const Page = () => {
  const [value, setValue] = useState("");
  const onChange = useCallback((val: SetStateAction<string>, _viewUpdate: any) => {
    setValue(val);
  }, []);
  const { organizationName } = useParams()
  return (
    <>
      <PageHeader
        breadcrumbs={[
          <Anchor to={`/${organizationName}/policies`} component={Link}>
            Policies
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
          label="Query"
          name={"query"}
        />
        <TextInput value={value} name={"policy"} hidden/>
        <Select
          label="Enforcement Level"
          name={"enforcementLevel"}
          data={['advisory', 'mandatory']}
        />

        <Input.Wrapper>
          <label>Policy</label>
          <CodeMirror value={value} height="200px" onChange={onChange}/>
        </Input.Wrapper>

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
  const policyInput: Partial<Policy> = {}

  let policyContent = "";

  for (const [key, value] of [...form.entries()]) {
    if (key == "organization") {
      organizationName = value
    } else if (key == "policy") {
        policyContent = value
    } else {
      // @ts-ignore
      policyInput[key] = value
    }
  }

  const data = PolicySerializer.serialize(policyInput)
  const {data: policy} = await apiClient.post(
    `/api/v2/organizations/${organizationName}/policies`,
    data
  )

  await apiClient.put(`/api/v2/policies/${policy.id}/upload`, policyContent, { headers: { "Content-Type": "text/plain" } })

  return { policy }
}

export default { Page, Action }
