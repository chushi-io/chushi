import * as React from "react";
import axios from "axios";
import {useOrganizations} from "../providers/OrganizationProvider";
import {useNavigate} from "react-router-dom";
import {TextInput, Button, Group, Box, Checkbox} from '@mantine/core';
import { useForm } from '@mantine/form';

const NewVariableSet = () => {
    const form = useForm({
        initialValues: {
            name: '',
            description: '',
            autoAttach: false,
            priority: 0
        },
        validate: {}
    })
    const orgs = useOrganizations()
    const navigate = useNavigate()
    // 	Name           string    `json:"name"`
    // 	Description    string    `json:"description"`
    // 	AutoAttach     bool      `json:"auto_attach"`
    // 	Priority       int32     `json:"priority"`

    const submit = async (values) => {
        let payload = {
            name: values.name,
            description: values.description,
            auto_attach: values.autoAttach,
            priority: values.priority
        }

        const res = await axios.post(`/api/v1/orgs/${orgs.currentOrganization}/variable_sets`, payload)
        console.log(res)
        navigate(`/variable_sets/${res.data.variable_set.id}`)
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
                      label="Priority"
                      placeholder=""
                      {...form.getInputProps('priority')}
                    />

                    <Checkbox
                      mt="md"
                      label="Auto Attach"
                      {...form.getInputProps('autoAttach', { type: 'checkbox' })}
                    />

                    <Group justify="flex-end" mt="md">
                        <Button type="submit" variant={"outline"}>Submit</Button>
                    </Group>
                </form>
            </Box>
        </React.Fragment>
    )
}

export default NewVariableSet;
