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
import {Link} from "react-router-dom";
import {Button} from "@mui/material";

const ListAgents = () => {
    const [agents, setAgents] = useState([])

    useEffect(() => {
        axios.get("/api/v1/orgs/my-cool-org/agents").then(res => {
            setAgents(res.data.agents)
        })
    }, [])

    return (
        <React.Fragment>
            <TableContainer component={Paper}>
                <Table sx={{ minWidth: 650 }} aria-label="simple table">
                    <TableHead>
                        <TableRow>
                            <TableCell>Name</TableCell>
                            <TableCell>Client ID</TableCell>
                        </TableRow>
                    </TableHead>
                    <TableBody>
                        {agents.map((agent) => (
                            <TableRow
                                key={agent.name}
                                sx={{ '&:last-child td, &:last-child th': { border: 0 } }}
                            >
                                <TableCell>
                                    <Link to={`/agents/${agent.id}`}>
                                        {agent.name}
                                    </Link>
                                </TableCell>
                                <TableCell align={"right"}>{agent.oauth_client_id}</TableCell>

                            </TableRow>
                        ))}
                    </TableBody>
                </Table>
            </TableContainer>
            <Button href={"/agents/new"}>New Agent</Button>
        </React.Fragment>

    )
}

export default ListAgents;
