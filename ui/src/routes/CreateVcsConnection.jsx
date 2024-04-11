import * as React from "react";
import {useOrganizations} from "../providers/OrganizationProvider";
import {useNavigate} from "react-router-dom";
import {useState} from "react";
import axios from "axios";
import { TextInput, Button, Group, Box } from '@mantine/core';
import { useForm } from '@mantine/form';

const CreateVcsConnection = () => {
    const form = useForm({
        initialValues: {
            name: '',
            token: ''
        },
        validate: {},
    });
    const orgs = useOrganizations();
    const navigate = useNavigate();

    const submit = (values) => {
        axios.post(`/api/v1/orgs/${orgs.currentOrganization}/vcs_connections`, {
            provider: "github",
            type: "personal_access_token",
            ...values
        }).then(res => {
            navigate("/vcs_connections")
        })
    }
    return (
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
                label="Token"
                placeholder=""
                {...form.getInputProps('token')}
              />

              <Group justify="flex-end" mt="md">
                  <Button type="submit" variant={"outline"}>Submit</Button>
              </Group>
          </form>
      </Box>
    )
}

export default CreateVcsConnection;
