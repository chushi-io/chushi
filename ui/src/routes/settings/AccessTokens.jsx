import * as React from "react";
import {useEffect, useState} from "react";
import axios from "axios";
import {Alert, Anchor, Breadcrumbs, Button, Group, Modal, TextInput} from "@mantine/core";
import {Link} from "react-router-dom";
import { Table } from '@mantine/core';
import {useForm} from "@mantine/form";
import { DatePickerInput } from '@mantine/dates';
import dayjs from "dayjs";
import {IconTrash} from "@tabler/icons-react";

const AccessTokens = () => {
  const [createModalOpen, setCreateModalOpen] = useState(false)
  const [tokens, setTokens] = useState([])
  const [tokenValue, setTokenValue] = useState("")

  const form = useForm({
    initialValues: {
      name: '',
      expires_at: dayjs().add(30, 'day')
    },
    validate: {}
  })

  useEffect(() => {
    axios.get(`/settings/access_tokens`).then((res) => {
      setTokens(res.data.access_tokens)
    })
  }, [])

  const resetForm = () => { }

  const close = () => {
    setCreateModalOpen(false)
  }

  const submit = (values) => {
    axios.post('/settings/access_tokens', values).then((res) => {
      setTokens([
        ...tokens,
        res.data.access_token
      ])
      setTokenValue(res.data.access_token.token)
      close()
    })
  }

  const deleteToken = (tokenId) => {
    axios.delete(`/settings/access_tokens/${tokenId}`).then((res) => {
      setTokens(tokens.filter(token => token.id !== tokenId))
    })
  }

  return (
    <React.Fragment>
      <Breadcrumbs>
        <Anchor component={Link} to={"/settings/profile"}>Settings</Anchor>
        <Anchor component={Link} to={"/settings/access_tokens"}>Access Tokens</Anchor>
      </Breadcrumbs>
      {tokenValue !== "" && <Alert variant="light" color={"blue"}>{tokenValue}</Alert>}
      <Table withTableBorder={true}>
        <Table.Thead>
          <Table.Tr>
            <Table.Th>ID</Table.Th>
            <Table.Th>Name</Table.Th>
            <Table.Th>Created At</Table.Th>
            <Table.Th>Last Seen</Table.Th>
            <Table.Th>Expires At</Table.Th>
            <Table.Th></Table.Th>
          </Table.Tr>
        </Table.Thead>
        <Table.Tbody>
          {tokens.map((token) => (
            <Table.Tr key={token.id}>
              <Table.Td>{token.id}</Table.Td>
              <Table.Td>{token.name}</Table.Td>
              <Table.Td>{token.created_at}</Table.Td>
              <Table.Td>{token.last_seen}</Table.Td>
              <Table.Td>{token.expires_at}</Table.Td>
              <Table.Td>
                <Button onClick={() => deleteToken(token.id)} variant="outline" color="red" size={"compact-sm"}><IconTrash /></Button>
              </Table.Td>
            </Table.Tr>
          ))}
        </Table.Tbody>
      </Table>

      <Modal opened={createModalOpen} onClose={close} title="New Access Token">
        <form onSubmit={form.onSubmit(submit)}>
          <TextInput
            withAsterisk
            label="Name"
            placeholder=""
            {...form.getInputProps('name')}
          />

          <DatePickerInput
            label="Expiration"
            {...form.getInputProps('expires_at')}
          />

          <Group justify="flex-end" mt="md">
            <Button type="submit" variant={"outline"}>Submit</Button>
          </Group>
        </form>
      </Modal>

      <Button onClick={() => setCreateModalOpen(true)} variant="outline">
        Create Access Token
      </Button>
    </React.Fragment>
  )
}

export default AccessTokens;