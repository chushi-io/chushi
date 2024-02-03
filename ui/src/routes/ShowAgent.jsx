import * as React from "react";
import {useEffect, useState} from "react";
import {useParams} from "react-router-dom";
import axios from "axios";

const ShowAgent = () => {
    const [agent, setAgent] = useState({})

    let { agentId  } = useParams();

    useEffect(() => {
        axios.get(`/api/v1/orgs/my-cool-org/agents/${agentId}`).then(res => {
            setAgent(res.data.agent)
        })
    }, [])

    return (
        <h4>{agent.id}</h4>
    )
}

export default ShowAgent;
