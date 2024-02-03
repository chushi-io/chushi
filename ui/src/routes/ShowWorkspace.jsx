import * as React from "react";
import {useEffect, useState} from "react";
import axios from "axios";
import {useParams} from "react-router-dom";

const ShowWorkspace = () => {
    const [workspace, setWorkspace] = useState({})

    let { workspaceId } = useParams();

    useEffect(() => {
        axios.get(`/api/v1/orgs/my-cool-org/workspaces/${workspaceId}`).then(res => {
            setWorkspace(res.data.workspace)
        })
    }, [])

    return (
        <h4>{workspace.name}</h4>
    )
}

export default ShowWorkspace;
