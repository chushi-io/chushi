import * as React from "react";
import {useOrganizations} from "../providers/OrganizationProvider";

const ListOrganizations = () => {
    const orgs = useOrganizations()
    return (
        <ul>
            {orgs.organizations.map(org => {
                return <li>{org.name}</li>
            })}
        </ul>
    )
}

export default ListOrganizations;
