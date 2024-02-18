import * as React from "react";
import {useState} from "react";
import FormGroup from "@mui/material/FormGroup";
import TextField from "@mui/material/TextField";
import FormControlLabel from "@mui/material/FormControlLabel";
import Switch from "@mui/material/Switch";
import Button from "@mui/material/Button";
import axios from "axios";
import {useOrganizations} from "../providers/OrganizationProvider";
import {useNavigate} from "react-router-dom";

const NewVariableSet = () => {
    const orgs = useOrganizations()
    const navigate = useNavigate()
    // 	Name           string    `json:"name"`
    // 	Description    string    `json:"description"`
    // 	AutoAttach     bool      `json:"auto_attach"`
    // 	Priority       int32     `json:"priority"`

    const [name, setName] = useState("")
    const [description, setDescription] = useState("")
    const [autoAttach, setAutoAttach] = useState(false)
    const [priority, setPriority] = useState(0)

    const onSubmit = async (event) => {
        event.preventDefault()
        console.log({name, description, autoAttach, priority})
        let payload = {
            name,
            description,
            auto_attach: autoAttach,
            priority
        }

        const res = await axios.post(`/api/v1/orgs/${orgs.currentOrganization}/variable_sets`, payload)
        console.log(res)
        navigate(`/variable_sets/${res.data.variable_set.id}`)
    }

    return (
        <React.Fragment>
            <form onSubmit={onSubmit}>
                <FormGroup>
                    <TextField
                        label={"Name"}
                        value={name}
                        onChange={e => setName(e.target.value)} />
                </FormGroup>
                <FormGroup>
                    <TextField
                        label={"Description"}
                        value={description}
                        onChange={e => setDescription(e.target.value)} />
                </FormGroup>
                <FormGroup>
                    <FormControlLabel control={
                        <Switch inputProps={{ 'aria-label': 'controlled' }} checked={autoAttach} onChange={e => setAutoAttach(e.target.checked)}/>
                    } label={"Attach to workspaces automatically"} />
                </FormGroup>
                <FormGroup>
                    <TextField
                        type={"number"}
                        label={"Priority"}
                        value={priority}
                        onChange={e => setPriority(e.target.value)} />
                </FormGroup>
                <Button type={"submit"}>
                    Create
                </Button>
            </form>
        </React.Fragment>
    )
}

export default NewVariableSet;
