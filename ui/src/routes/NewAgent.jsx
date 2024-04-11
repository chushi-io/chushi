import * as React from "react";
import {useState} from "react";
import axios from "axios";
import {useNavigate} from "react-router-dom";
import {useOrganizations} from "../providers/OrganizationProvider";
import {TextInput, Button, Group, Box, Checkbox} from '@mantine/core';
import { useForm } from '@mantine/form';

const NewAgent = () => {
    const form = useForm({
        initialValues: {
            name: ''
        },
        validate: {}
    })
    const orgs = useOrganizations()
    const navigate = useNavigate();

    const submit = (values) => {
        axios.post(`/api/v1/orgs/${orgs.currentOrganization}/agents`, {
            name: values.name
        }).then(res => {
            let agentId = res.data.agent.id
            navigate(`/agents/${agentId}`)
        })
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

                  <Group justify="flex-end" mt="md">
                      <Button type="submit" variant={"outline"}>Submit</Button>
                  </Group>
              </form>
          </Box>

      </React.Fragment>
    )
}

export default NewAgent;