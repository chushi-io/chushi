import * as React from "react";
import {useState} from "react";
import axios from "axios";
import {useOrganizations} from "../providers/OrganizationProvider";
import {useNavigate} from "react-router-dom";
import {TextInput, Button, Group, Box, Checkbox} from '@mantine/core';
import { useForm } from '@mantine/form';

const CreateWorkspace = () => {
    const form = useForm({
        initialValues: {
            name: '',
            allowDestroy: false,
            autoApply: false,
            driftDetectionEnabled: true,
            driftDetectionSchedule: '',
            executionMode: 'remote'
        },
        validate: {}
    })
    const orgs = useOrganizations()
    const navigate = useNavigate();

    const submit = async (values) => {

        let payload = {
            name: values.name,
            allow_destroy: values.allowDestroy,
            auto_apply: values.autoApply,
            drift_detection: {
                enabled: values.driftDetectionEnabled,
            }
        }
        if (values.driftDetectionEnabled) {
            payload.drift_detection.schedule = values.driftDetectionSchedule
        }
        const res = await axios.post(`/api/v1/orgs/${orgs.currentOrganization}/workspaces`, payload)
        console.log(res)
        navigate(`/workspaces/${res.data.workspace.id}`)
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

                    <Checkbox
                      mt="md"
                      label="Allow Destroy"
                      {...form.getInputProps('allowDestroy', { type: 'checkbox' })}
                    />

                    <Checkbox
                      mt="md"
                      label="Auto Apply"
                      {...form.getInputProps('autoApply', { type: 'checkbox' })}
                    />
                    {/*<TextInput*/}
                    {/*  withAsterisk*/}
                    {/*  label="Token"*/}
                    {/*  placeholder=""*/}
                    {/*  {...form.getInputProps('token')}*/}
                    {/*/>*/}

                    <Group justify="flex-end" mt="md">
                        <Button type="submit" variant={"outline"}>Submit</Button>
                    </Group>
                </form>
            </Box>

        </React.Fragment>
    )
}

export default CreateWorkspace;

