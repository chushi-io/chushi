import * as React from "react";
import {useEffect, useState} from "react";
import axios from "axios";

const OrganizationContext = React.createContext(undefined)

const OrganizationProvider = ({ children }) => {
    const [organizations, setOrganizations] = useState([])
    const [currentOrganization, setCurrentOrganization] = useState(undefined)

    useEffect(() => {
        axios.get("/me/orgs").then(res => {
            setOrganizations(res.data.organizations)
        })
    }, [])

    const changeOrganization = (organizationId) => {
        localStorage.setItem("organization", organizationId);
        setCurrentOrganization(organizationId)
    }

    useEffect(() => {
        const storedOrg = localStorage.getItem("organization")
        if (storedOrg !== null) {
            setCurrentOrganization(storedOrg)
        }
    }, [])

    return (
        <OrganizationContext.Provider value={{
            organizations,
            setOrganizations,
            currentOrganization,
            changeOrganization,
        }}>
            {children}
        </OrganizationContext.Provider>
    )
}

function useOrganizations() {
    const context = React.useContext(OrganizationContext)
    if (context === undefined) {
        throw new Error('currentOrganization must be used within an OrganiztionProvider')
    }
    return context
}

export default OrganizationProvider;
export {
    OrganizationContext,
    useOrganizations,
}