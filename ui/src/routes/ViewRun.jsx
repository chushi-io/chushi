import * as React from "react";
import {useOrganizations} from "../providers/OrganizationProvider";
import {useEffect, useState} from "react";
import {useParams} from "react-router-dom";
import axios from "axios";

const ViewRun = () => {
  const [run, setRun] = useState({})
  const orgs = useOrganizations()

  let { runId, workspaceId } = useParams()

  useEffect(() => {
    if (orgs.currentOrganization === undefined) {
      return
    }
    axios.get(`/api/v1/orgs/${orgs.currentOrganization}/workspaces/${workspaceId}/runs/${runId}`).then((res) => {
      setRun(res.data.run)
    })
  }, [orgs.currentOrganization])

  return (
    <h1>{run.id}</h1>
  )
}

export default ViewRun;
