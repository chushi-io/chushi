import * as React from "react";
import {useEffect, useState} from "react";
import {useParams} from "react-router-dom";
import axios from "axios";
import {useOrganizations} from "../providers/OrganizationProvider";

const ShowAgent = () => {
    const orgs = useOrganizations()
    const [agent, setAgent] = useState({})

    let { agentId  } = useParams();

    useEffect(() => {
        axios.get(`/api/v1/orgs/${orgs.currentOrganization}/agents/${agentId}`).then(res => {
            setAgent(res.data.agent)
        })
    }, [])

    return (
        <h4>{agent.id}</h4>
    )
}

export default ShowAgent;
