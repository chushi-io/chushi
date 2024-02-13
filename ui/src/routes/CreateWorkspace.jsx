import * as React from "react";
import {useState} from "react";
import TextField from "@mui/material/TextField";
import Switch from "@mui/material/Switch";
import FormGroup from "@mui/material/FormGroup";
import {FormControlLabel} from "@mui/material";

const CreateWorkspace = () => {
    const [name, setName] = useState("");
    const [allowDestroy, setAllowDestroy] = useState(false);
    const [autoApply, setAutoApply] = useState(true);
    const [executionMode, setExecutionMode] = useState("remote");
    const [driftDetectionEnabled, setDriftDetectionEnabled] = useState(false);
    const [driftDetectionScheduler, setDriftDetectionSchedule] = useState("hourly");

    const onSubmit = (event) => {
        event.preventDefault()
    }

    return (
        <React.Fragment>
            <form action="">
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
            </form>
        </React.Fragment>
    )
}

export default CreateWorkspace;

