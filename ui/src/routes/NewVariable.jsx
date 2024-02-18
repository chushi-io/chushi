import * as React from "react";
import {useNavigate, useParams} from "react-router-dom";
import TextField from "@mui/material/TextField";
import FormGroup from "@mui/material/FormGroup";
import FormControl from "@mui/material/FormControl";
import FormControlLabel from "@mui/material/FormControlLabel";
import Radio from "@mui/material/Radio";
import RadioGroup from "@mui/material/RadioGroup";
import FormLabel from "@mui/material/FormLabel";
import Switch from "@mui/material/Switch";

import {useState} from "react";
import {useOrganizations} from "../providers/OrganizationProvider";
import Button from "@mui/material/Button";
import axios from "axios";

const NewVariable = (props) => {
    const orgs = useOrganizations()
    const navigate = useNavigate()

    const [name, setName] = useState("")
    const [description, setDescription] = useState("")
    const [type, setType] = useState("environment")
    const [value, setValue] = useState("")
    const [hcl, setHcl] = useState(false)
    const [sensitive, setSensitive] = useState(true)

    const { variableSetId, workspaceId } = useParams()
    console.log(variableSetId)
    console.log(workspaceId)

    const onSubmit = async (event) => {
        let url = `/api/v1/orgs/${orgs.currentOrganization}/variable_sets/${variableSetId}/variables`
        if (workspaceId !== undefined) {
            let url = `/api/v1/orgs/${orgs.currentOrganization}/variable_sets/${variableSetId}/variables`
        }

        const res = axios.post(url, {
            name,
            description,
            type,
            value,
            hcl,
            sensitive
        })
        console.log(res)
        if (workspaceId === undefined) {
            navigate(`/variable_sets/${variableSetId}`)
        } else {

        }
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
                    <TextField
                        type={sensitive ? "password" : "text"}
                        label={"Value"}
                        value={value}
                        onChange={e => setValue(e.target.value)} />
                </FormGroup>
                <FormGroup>
                    <FormControlLabel control={
                        <Switch inputProps={{ 'aria-label': 'controlled' }} checked={sensitive} onChange={e => setSensitive(e.target.checked)}/>
                    } label={"Sensitive"} />
                </FormGroup>
                <FormGroup>
                    <FormControlLabel control={
                        <Switch inputProps={{ 'aria-label': 'controlled' }} checked={hcl} onChange={e => setHcl(e.target.checked)}/>
                    } label={"HCL"} />
                </FormGroup>
                <FormControl>
                    <FormLabel id="demo-radio-buttons-group-label">Type</FormLabel>
                    <RadioGroup
                        aria-labelledby="demo-controlled-radio-buttons-group"
                        name="controlled-radio-buttons-group"
                        value={type}
                        onChange={e => setType(e.target.value)}
                    >
                        <FormControlLabel value="environment" control={<Radio />} label="Environment"/>
                        <FormControlLabel value="opentofu" control={<Radio />} label="OpenTofu" />
                    </RadioGroup>
                </FormControl>
                <Button type={"submit"}>
                    Create
                </Button>
            </form>
        </React.Fragment>
    )
}

export default NewVariable;
