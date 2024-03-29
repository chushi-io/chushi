import * as React from "react";
import {useEffect, useState} from "react";
import axios from "axios";
import {Link, useParams} from "react-router-dom";
import Table from '@mui/material/Table';
import TableBody from '@mui/material/TableBody';
import TableCell from '@mui/material/TableCell';
import TableContainer from '@mui/material/TableContainer';
import TableHead from '@mui/material/TableHead';
import TableRow from '@mui/material/TableRow';
import Paper from '@mui/material/Paper';
import {useOrganizations} from "../providers/OrganizationProvider";
import Button from "@mui/material/Button";
import {Chip} from "@mui/material";

const ShowWorkspace = () => {
    const [workspace, setWorkspace] = useState({})
    const [runs, setRuns] = useState([])
    const orgs = useOrganizations()
    let { workspaceId } = useParams();

    useEffect(() => {
        if (orgs.currentOrganization === undefined) {
            return
        }
        axios.get(`/api/v1/orgs/${orgs.currentOrganization}/workspaces/${workspaceId}`).then(res => {
            setWorkspace(res.data.workspace)
            axios.get(`/api/v1/orgs/${orgs.currentOrganization}/workspaces/${res.data.workspace.id}/runs`).then(res => {
                setRuns(res.data.runs)
            })
        })

    }, [orgs.currentOrganization])

    const triggerRun = () => {
        axios.post(`/api/v1/orgs/${orgs.currentOrganization}/workspaces/${workspace.id}/runs`, {
            operation: "plan"
        }).then(res => console.log(res.data))
    }

    return (
        <React.Fragment>
            <h4>{workspace.name}</h4>
            <TableContainer component={Paper}>
                <Table sx={{ minWidth: 650 }} aria-label="simple table">
                    <TableHead>
                        <TableRow>
                            <TableCell>ID</TableCell>
                            <TableCell align="right">Status</TableCell>
                            <TableCell align="right">Add</TableCell>
                            <TableCell align="right">Change</TableCell>
                            <TableCell align="right">Destroy</TableCell>
                            <TableCell align="right">Resources</TableCell>
                        </TableRow>
                    </TableHead>
                    <TableBody>
                        {runs.map((run) => {
                            let color = "default"
                            let variant = "filled"
                            switch (run.status) {
                                case "completed":
                                    color = "success"
                                    break;
                                case "pending":
                                    color = "primary"
                                    variant = "outlined"
                                    break;
                                case "failed":
                                    color = "warning"
                                    break;
                            }
                            return (
                                <TableRow
                                    key={run.id}
                                    sx={{'&:last-child td, &:last-child th': {border: 0}}}
                                >
                                    <TableCell component="th" scope="row">
                                        <Link to={`/runs/${run.id}`}>
                                            {run.id}
                                        </Link>
                                    </TableCell>
                                    <TableCell align="right">
                                        <Chip size={"small"} label={run.status} color={color}/>
                                    </TableCell>
                                    <TableCell align="right">{run.add}</TableCell>
                                    <TableCell align="right">{run.change}</TableCell>
                                    <TableCell align="right">{run.destroy}</TableCell>
                                    <TableCell align="right">{run.managed_resources}</TableCell>
                                </TableRow>
                            )
                        })}
                    </TableBody>
                </Table>
            </TableContainer>
            <Button variant="outlined" onClick={triggerRun}>Trigger Run</Button>
        </React.Fragment>
    )
}

export default ShowWorkspace;
