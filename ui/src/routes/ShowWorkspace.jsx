import * as React from "react";
import {useEffect, useState} from "react";
import axios from "axios";
import {useParams} from "react-router-dom";

const ShowWorkspace = () => {
    const [workspace, setWorkspace] = useState({})
    const [runs, setRuns] = useState([])
    let { workspaceId } = useParams();

    useEffect(() => {
        axios.get(`/api/v1/orgs/my-cool-org/workspaces/${workspaceId}`).then(res => {
            setWorkspace(res.data.workspace)
        })
        axios.get(`/api/v1/orgs/my-cool-org/workspaces/${workspaceId}/runs`).then(res => {
            setRuns(res.data.runs)
        })
    }, [])

    return (
        <React.Fragment>
            <h4>{workspace.name}</h4>
            <table>
                <thead>
                <tr>
                    <th>ID</th>
                    <th>Add</th>
                    <th>Change</th>
                    <th>Remove</th>
                    <th>Resources</th>
                </tr>
                </thead>
                <tbody>
                {runs.map(run => {
                    return (
                        <tr>
                            <td>{run.id}</td>
                            <td>{run.add}</td>
                            <td>{run.change}</td>
                            <td>{run.destroy}</td>
                            <td>{run.managed_resources}</td>
                        </tr>
                    )
                })}
                </tbody>
            </table>
        </React.Fragment>

    )
}

export default ShowWorkspace;
