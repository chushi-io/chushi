import {apiClient} from "../../Client.tsx";
import {SetStateAction, useCallback, useState} from "react";
import {Form, Link, useLoaderData, useParams} from "react-router-dom";
import PageHeader from "../../components/PageHeader";
import {Anchor, Button, Group, Input, Select, TextInput, VisuallyHidden} from "@mantine/core";
import CodeMirror from "@uiw/react-codemirror";

const Page = () => {
  let { policy, policyContent } = useLoaderData() as any

  const [value, setValue] = useState(policyContent);
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
          value={policy.name}
          disabled={true}
        />
        <TextInput
          label="Description"
          name={"description"}
          value={policy.description}
        />
        <TextInput
          label="Query"
          name={"query"}
          value={policy.query}
        />
        <VisuallyHidden>
          <TextInput value={value} name={"policy"} hidden={true}/>
        </VisuallyHidden>
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
          <Button type="submit">Update</Button>
        </Group>
      </Form>
    </>
  )
}

const Loader = async ({params}: { params: any}) => {
  const { data: policy } = await apiClient.get(`/api/v2/policies/${params.policyId}`)
  const { data: policyContent } = await apiClient.get(`/api/v2/policies/${params.policyId}/download`)
  return { policy, policyContent }
}

export default { Page, Loader }