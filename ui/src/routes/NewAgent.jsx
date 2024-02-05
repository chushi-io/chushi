import * as React from "react";
import Paper from "@mui/material/Paper";
import FormGroup from '@mui/material/FormGroup';
import Box from '@mui/material/Box';
import TextField from '@mui/material/TextField';
import {useState} from "react";
import axios from "axios";
import {useNavigate} from "react-router-dom";

const NewAgent = () => {
    const navigate = useNavigate();
    const [name, setName] = useState("")

    const submit = (event) => {
        // post the agent information
        event.preventDefault()

        axios.post("/api/v1/orgs/my-cool-org/agents", {
            name
        }).then(res => {
            let agentId = res.data.agent.id
            navigate(`/agents/${agentId}`)
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
                <TextField id="outlined-basic" label="Outlined" variant="outlined" value={name} onChange={(event) => {
                    setName(event.target.value)
                }} />
            </Box>
        </Paper>

    )
}

export default NewAgent;