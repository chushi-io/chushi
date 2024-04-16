import * as React from "react";
import {useOrganizations} from "../providers/OrganizationProvider";
import {useNavigate} from "react-router-dom";
import {useState} from "react";
import axios from "axios";
import {TextInput, Button, Group, Box, Radio, RadioGroup, Select} from '@mantine/core';
import { useForm } from '@mantine/form';

const CreateVcsConnection = () => {
    const [githubAuthType, setGithubAuthType] = useState("token")
    const form = useForm({
        initialValues: {
            name: '',
            token: '',
            github: {
                token: '',
                application_id: '',
                application_secret: '',
                oauth_application_id: '',
                oauth_application_secret: ''
            },
            gitlab: {

            },
            bitbucket: {

            }
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

    console.log(githubAuthType)

    return (
      <Box maw={340} mx="auto">
          <form onSubmit={form.onSubmit(submit)}>
              <TextInput
                withAsterisk
                label="Name"
                placeholder=""
                {...form.getInputProps('name')}
              />

              {/*<RadioGroup*/}
              {/*  label="Select your favorite framework/library"*/}
              {/*  description="This is anonymous"*/}
              {/*  value={githubAuthType}*/}
              {/*  onChange={setGithubAuthType}*/}
              {/*>*/}
              {/*    <Radio label={"Personal Access Token"} />*/}
              {/*    <Radio label={"SSH Key"} />*/}
              {/*    <Radio label={"Github Application"} />*/}
              {/*    <Radio label={"OAuth Application"} />*/}
              {/*</RadioGroup>*/}
              <Select
                data={[
                  { value: 'token', label: 'Personal Access Token' },
                  { value: 'ssh', label: 'SSH Key' },
                  { value: 'github_app', label: 'Github Application' },
                  { value: 'oauth', label: 'OAuth Application' },
                ]}
                value={githubAuthType ? githubAuthType.value : null}
                onChange={(_value, option) => setGithubAuthType(option)}
              />

              {githubAuthType.value === "token" && (
                <TextInput
                  withAsterisk
                  label="Token"
                  placeholder=""
                  {...form.getInputProps('token')}
                />
              )}

              {githubAuthType.value === "ssh" && (
                <TextInput
                    label={"SSH Key"}
                  {...form.getInputProps('github.ssh_key')}
                />
              )}

              {githubAuthType.value === "github_app" && (
                <React.Fragment>
                    <TextInput
                        label={"Application ID"}
                      {...form.getInputProps('github.application_id')}
                        />
                    <TextInput
                      label={"Application Secret"}
                      {...form.getInputProps('github.application_secret')}
                    />
                </React.Fragment>

              )}

              {githubAuthType.value === "oauth" && (
                <React.Fragment>
                    <TextInput
                      label={"OAuth Application ID"}
                      {...form.getInputProps('github.oauth_application_id')}
                    />
                    <TextInput
                      label={"OAuth Application Secret"}
                      {...form.getInputProps('github.oauth_application_secret')}
                    />
                </React.Fragment>

              )}



              <Group justify="flex-end" mt="md">
                  <Button type="submit" variant={"outline"}>Submit</Button>
              </Group>
          </form>
      </Box>
    )
}

export default CreateVcsConnection;
