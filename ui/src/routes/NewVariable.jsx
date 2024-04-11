import * as React from "react";
import {useNavigate, useParams} from "react-router-dom";
import {useState} from "react";
import {useOrganizations} from "../providers/OrganizationProvider";
import axios from "axios";
import {TextInput, Button, Group, Box, Checkbox} from '@mantine/core';
import { useForm } from '@mantine/form';

const NewVariable = (props) => {
    const form = useForm({
        initialValues: {
            name: '',
            description: '',
            type: '',
            value: '',
            hcl: false,
            environment: true
        },
        validate: {}
    })
    const orgs = useOrganizations()
    const navigate = useNavigate()

    const { variableSetId, workspaceId } = useParams()

    const submit = async (values) => {
        let url = `/api/v1/orgs/${orgs.currentOrganization}/variable_sets/${variableSetId}/variables`
        if (workspaceId !== undefined) {
            url = `/api/v1/orgs/${orgs.currentOrganization}/variable_sets/${variableSetId}/variables`
        }

        const res = axios.post(url, {
            ...values
        })
        console.log(res)
        if (workspaceId === undefined) {
            navigate(`/variable_sets/${variableSetId}`)
        } else {

        }
    }

    return (
      <React.Fragment>
          <Box maw={340} mx="auto">
              <form onSubmit={form.onSubmit(submit)}>
                  <TextInput
                    withAsterisk
                    label="Name"
                    placeholder=""
                    {...form.getInputProps('name')}
                  />

                  <TextInput
                    withAsterisk
                    label="Description"
                    placeholder=""
                    {...form.getInputProps('description')}
                  />

                  <TextInput
                    withAsterisk
                    label="Value"
                    placeholder=""
                    {...form.getInputProps('value')}
                  />

                  <Checkbox
                    mt="md"
                    label="HCL"
                    {...form.getInputProps('hcl', { type: 'checkbox' })}
                  />

                  <Checkbox
                    mt="md"
                    label="Sensitive"
                    {...form.getInputProps('sensitive', { type: 'checkbox' })}
                  />

                  <Group justify="flex-end" mt="md">
                      <Button type="submit" variant={"outline"}>Submit</Button>
                  </Group>
              </form>
          </Box>

      </React.Fragment>
    )
}

export default NewVariable;
