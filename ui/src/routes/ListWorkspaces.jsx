import * as React from "react";
import {useEffect, useState} from "react";
import axios from "axios";
import Table from '@mui/material/Table';
import TableBody from '@mui/material/TableBody';
import TableCell from '@mui/material/TableCell';
import TableContainer from '@mui/material/TableContainer';
import TableHead from '@mui/material/TableHead';
import TableRow from '@mui/material/TableRow';
import Paper from '@mui/material/Paper';
import Skeleton from '@mui/material/Skeleton';
import Button from "@mui/material/Button";
import {Link} from "react-router-dom";
import {useOrganizations} from "../providers/OrganizationProvider";

const ListWorkspaces = () => {
    const [workspaces, setWorkspaces] = useState([])
    const [loading, setLoading] = useState(true)

    const orgs = useOrganizations()

    useEffect(() => {
        console.log(orgs)
        if (orgs.currentOrganization === undefined) {
            return
        }
        axios.get(`/api/v1/orgs/${orgs.organizations[0].name}/workspaces`).then(res => {
            setLoading(false)
            setWorkspaces(res.data.workspaces)
        })
    }, [orgs.currentOrganization])

    if (loading) {
        return <Skeleton variant="text" sx={{ fontSize: '1rem' }} />
    }

    return (
        <React.Fragment>
            <TableContainer component={Paper}>
                <Table sx={{ minWidth: 650 }} aria-label="simple table">
                    <TableHead>
                        <TableRow>
                            <TableCell>Name</TableCell>
                            <TableCell align="right">Allow Destroy</TableCell>
                            <TableCell align="right">Auto Apply</TableCell>
                            <TableCell align="right">Locked</TableCell>
                        </TableRow>
                    </TableHead>
                    <TableBody>
                        {workspaces.map((workspace) => (
                            <TableRow
                                key={workspace.name}
                                sx={{ '&:last-child td, &:last-child th': { border: 0 } }}
                            >
                                <TableCell component="th" scope="row">
                                    <Link to={`/workspaces/${workspace.name}`}>
                                        {workspace.name}
                                    </Link>
                                </TableCell>
                                <TableCell align="right">{workspace.allow_destroy}</TableCell>
                                <TableCell align="right">{workspace.auto_apply}</TableCell>
                                {
                                    workspace.locked ? (
                                        <TableCell align={"right"}>Yes</TableCell>
                                    ) : (
                                        <TableCell align={"right"}>No</TableCell>
                                    )
                                }
                            </TableRow>
                        ))}
                    </TableBody>
                </Table>
            </TableContainer>

            <Button variant="outlined">
                <Link to={"/workspaces/new"}>Create Workspace</Link>
            </Button>
        </React.Fragment>
    )
}

export default ListWorkspaces;
