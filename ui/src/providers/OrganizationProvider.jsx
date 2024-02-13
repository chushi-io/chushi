import * as React from "react";
import {useEffect, useState} from "react";
import axios from "axios";

const OrganizationContext = React.createContext(undefined)

const OrganizationProvider = ({ children }) => {
    const [organizations, setOrganizations] = useState([])
    const [currentOrganization, setCurrentOrganization] = useState({})

    useEffect(() => {
        axios.get("/me/orgs").then(res => {
            setOrganizations(res.data.organizations)
        })
    }, [])

    return (
        <OrganizationContext.Provider value={{
            organizations,
            setOrganizations,
            currentOrganization,
            setCurrentOrganization,
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