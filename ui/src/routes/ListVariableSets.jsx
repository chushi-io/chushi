import * as React from "react";
import TableContainer from "@mui/material/TableContainer";
import Paper from '@mui/material/Paper';
import TableHead from "@mui/material/TableHead";
import TableRow from "@mui/material/TableRow";
import TableCell from "@mui/material/TableCell";
import TableBody from "@mui/material/TableBody";
import {Link} from "react-router-dom";
import Table from "@mui/material/Table";
import Button from "@mui/material/Button";
import {useEffect, useState} from "react";
import {useOrganizations} from "../providers/OrganizationProvider";
import axios from "axios";

const ListVariableSets = () => {
    const orgs = useOrganizations()
    const [variableSets, setVariableSets] = useState([])

    useEffect(() => {
        if (orgs.currentOrganization === undefined) {
            return
        }
        axios.get(`/api/v1/orgs/${orgs.currentOrganization}/variable_sets`).then(res => setVariableSets(res.data.variable_sets))
    }, orgs.currentOrganization)
    return (
        <React.Fragment>
            <TableContainer component={Paper}>
                <Table sx={{ minWidth: 650 }} aria-label="simple table">
                    <TableHead>
                        <TableRow>
                            <TableCell>Name</TableCell>
                            <TableCell align="right">Auto Attach</TableCell>
                            <TableCell align="right">Priority</TableCell>
                        </TableRow>
                    </TableHead>
                    <TableBody>
                        {variableSets.map((variableSet) => (
                            <TableRow
                                key={variableSet.id}
                                sx={{ '&:last-child td, &:last-child th': { border: 0 } }}
                            >
                                <TableCell component="th" scope="row">
                                    <Link to={`/variable_sets/${variableSet.id}`}>
                                        {variableSet.name}
                                    </Link>
                                </TableCell>
                                <TableCell align="right">{variableSet.auto_attach}</TableCell>
                                <TableCell align="right">{variableSet.priority}</TableCell>
                            </TableRow>
                        ))}
                    </TableBody>
                </Table>
            </TableContainer>

            <Button variant="outlined">
                <Link to={"/variable_sets/new"}>Create Variable Set</Link>
            </Button>
        </React.Fragment>
    )
}

export default ListVariableSets;
