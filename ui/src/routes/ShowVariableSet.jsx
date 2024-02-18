import * as React from "react";
import {useOrganizations} from "../providers/OrganizationProvider";
import {Link, useParams} from "react-router-dom";
import {useEffect, useState} from "react";
import axios from "axios";
import Paper from "@mui/material/Paper";
import Table from "@mui/material/Table";
import TableHead from "@mui/material/TableHead";
import TableRow from "@mui/material/TableRow";
import TableCell from "@mui/material/TableCell";
import TableBody from "@mui/material/TableBody";
import TableContainer from "@mui/material/TableContainer";
import Button from "@mui/material/Button";

const ShowVariableSet = () => {
    const [variableSet, setVariableSet] = useState({});
    const orgs = useOrganizations();
    let { variableSetId } = useParams();

    useEffect(() => {
        if (orgs.currentOrganization === undefined) {
            return
        }

        axios.get(`/api/v1/orgs/${orgs.currentOrganization}/variable_sets/${variableSetId}`)
            .then(res => setVariableSet(res.data.variable_set))
    }, orgs.currentOrganization)
    return (
        <React.Fragment>
            <h1>{variableSet?.name}</h1>
            <h4>Variables</h4>
            <TableContainer component={Paper}>
                <Table sx={{ minWidth: 650 }} aria-label="simple table">
                    <TableHead>
                        <TableRow>
                            <TableCell>Name</TableCell>
                            <TableCell>Value</TableCell>
                            <TableCell align="right">Sensitive</TableCell>
                            <TableCell align="right">HCL</TableCell>
                        </TableRow>
                    </TableHead>
                    <TableBody>
                        {variableSet?.variables?.map((variable) => (
                            <TableRow
                                key={variable.id}
                                sx={{ '&:last-child td, &:last-child th': { border: 0 } }}
                            >
                                <TableCell component="th" scope="row">
                                    <Link to={`/variables/${variable.id}`}>
                                        {variable.name}
                                    </Link>
                                </TableCell>
                                <TableCell align="right">{variable.value}</TableCell>
                                <TableCell align="right">{variable.sensitive}</TableCell>
                                <TableCell align="right">{variable.hcl}</TableCell>
                            </TableRow>
                        ))}
                    </TableBody>
                </Table>
            </TableContainer>
            <Button variant="outlined">
                <Link to={`/variable_sets/${variableSetId}/variables/new`}>Add Variable</Link>
            </Button>
        </React.Fragment>

    )
}

export default ShowVariableSet;
