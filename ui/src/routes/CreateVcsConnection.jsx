import * as React from "react";
import {useOrganizations} from "../providers/OrganizationProvider";
import {useNavigate} from "react-router-dom";
import Box from "@mui/material/Box";
import TextField from "@mui/material/TextField";
import Button from "@mui/material/Button";
import Paper from "@mui/material/Paper";
import {useState} from "react";
import axios from "axios";

const CreateVcsConnection = () => {
    const orgs = useOrganizations();
    const navigate = useNavigate();
    const [token, setToken] = useState("")
    const [name, setName] = useState("")

    const submit = (event) => {
        event.preventDefault()

        axios.post(`/api/v1/orgs/${orgs.currentOrganization}/vcs_connections`, {
            provider: "github",
            type: "personal_access_token",
            token,
            name
        }).then(res => {
            navigate("/vcs_connections")
        })
    }
    return (
        <Paper>
            <Box
                component="form"
                sx={{
                    '& > :not(style)': { m: 1, width: '25ch' },
                }}
                noValidate
                autoComplete="off"
                onSubmit={submit}
            >
                <TextField type="name" id="outlined-basic" label="Name" variant="outlined" value={name} onChange={(event) => {
                    setName(event.target.value)
                }} />
                <TextField type="password" id="outlined-basic" label="Access Token" variant="outlined" value={token} onChange={(event) => {
                    setToken(event.target.value)
                }} />
                <Button type={"submit"}>
                    Create
                </Button>
            </Box>
        </Paper>
    )
}

export default CreateVcsConnection;
