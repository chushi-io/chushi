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

const ShowWorkspace = () => {
    const [workspace, setWorkspace] = useState({})
    const [runs, setRuns] = useState([])
    let { workspaceId } = useParams();

    useEffect(() => {
        axios.get(`/api/v1/orgs/my-cool-org/workspaces/${workspaceId}`).then(res => {
            setWorkspace(res.data.workspace)
            axios.get(`/api/v1/orgs/my-cool-org/workspaces/${res.data.workspace.id}/runs`).then(res => {
                setRuns(res.data.runs)
            })
        })

    }, [])

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
                        {runs.map((run) => (
                            <TableRow
                                key={run.id}
                                sx={{ '&:last-child td, &:last-child th': { border: 0 } }}
                            >
                                <TableCell component="th" scope="row">
                                    <Link to={`/runs/${run.id}`}>
                                        {run.id}
                                    </Link>
                                </TableCell>
                                <TableCell align="right">{run.status}</TableCell>
                                <TableCell align="right">{run.add}</TableCell>
                                <TableCell align="right">{run.change}</TableCell>
                                <TableCell align="right">{run.destroy}</TableCell>
                                <TableCell align="right">{run.managed_resources}</TableCell>
                            </TableRow>
                        ))}
                    </TableBody>
                </Table>
            </TableContainer>
        </React.Fragment>
    )
}

export default ShowWorkspace;
