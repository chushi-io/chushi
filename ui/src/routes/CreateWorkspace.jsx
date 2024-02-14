import * as React from "react";
import {useState} from "react";
import TextField from "@mui/material/TextField";
import Switch from "@mui/material/Switch";
import FormGroup from "@mui/material/FormGroup";
import {FormControlLabel} from "@mui/material";
import Button from "@mui/material/Button";
import axios from "axios";
import {useOrganizations} from "../providers/OrganizationProvider";
import {useNavigate} from "react-router-dom";

const CreateWorkspace = () => {
    const orgs = useOrganizations()
    const navigate = useNavigate();

    const [name, setName] = useState("");
    const [allowDestroy, setAllowDestroy] = useState(false);
    const [autoApply, setAutoApply] = useState(true);
    const [executionMode, setExecutionMode] = useState("remote");
    const [driftDetectionEnabled, setDriftDetectionEnabled] = useState(false);
    const [driftDetectionSchedule, setDriftDetectionSchedule] = useState("hourly");

    const onSubmit = async (event) => {
        event.preventDefault()
        console.log({
            name,
            allowDestroy,
            autoApply,
            driftDetectionEnabled,
        })
        let payload = {
            name,
            allow_destroy: allowDestroy,
            auto_apply: autoApply,
            drift_detection: {
                enabled: driftDetectionEnabled,
            }
        }
        if (driftDetectionEnabled) {
            payload.drift_detection.schedule = driftDetectionSchedule
        }
        const res = await axios.post(`/api/v1/orgs/${orgs.currentOrganization}/workspaces`, payload)
        console.log(res)
        navigate(`/workspaces/${res.data.workspace.id}`)
    }

    return (
        <React.Fragment>
            <form onSubmit={onSubmit}>
                <FormGroup>
                    <TextField label={"Name"} value={name} onChange={e => setName(e.target.value)} />
                </FormGroup>
                <FormGroup>
                    <FormControlLabel control={
                        <Switch inputProps={{ 'aria-label': 'controlled' }} checked={allowDestroy} onChange={e => setAllowDestroy(e.target.checked)}/>
                    } label={"Allow Destroy"} />
                </FormGroup>
                <FormGroup>
                    <FormControlLabel control={
                        <Switch inputProps={{ 'aria-label': 'controlled' }} checked={autoApply} onChange={e => setAutoApply(e.target.checked)}/>
                    } label={"Auto Apply"} />
                </FormGroup>
                <FormGroup>
                    <FormControlLabel control={
                        <Switch inputProps={{ 'aria-label': 'controlled' }} checked={driftDetectionEnabled} onChange={e => setDriftDetectionEnabled(e.target.checked)}/>
                    } label={"Drift Detection"} />
                </FormGroup>
                <Button type={"submit"}>
                    Create
                </Button>
            </form>
        </React.Fragment>
    )
}

export default CreateWorkspace;

