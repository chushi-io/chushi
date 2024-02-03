import * as React from "react";
import {Drawer, Grid} from "@mui/material";
import ListSubheader from '@mui/material/ListSubheader';
import List from '@mui/material/List';
import ListItemButton from '@mui/material/ListItemButton';
import ListItemIcon from '@mui/material/ListItemIcon';
import ListItemText from '@mui/material/ListItemText';
import Collapse from '@mui/material/Collapse';
import InboxIcon from '@mui/icons-material/MoveToInbox';
import DraftsIcon from '@mui/icons-material/Drafts';
import SendIcon from '@mui/icons-material/Send';
import ExpandLess from '@mui/icons-material/ExpandLess';
import ExpandMore from '@mui/icons-material/ExpandMore';
import StarBorder from '@mui/icons-material/StarBorder';

const DefaultLayout = (props) => {
    const [open, setOpen] = React.useState(true);

    const handleClick = () => {
        setOpen(!open);
    };
    return (
        <Grid container spacing={2}>
            <Sidebar className="app">
                <Menu>
                    <MenuItem className="menu1">
                        <h2>QUICKPAY</h2>
                    </MenuItem>
                    <MenuItem> Dashboard </MenuItem>
                    <MenuItem> Invoices </MenuItem>
                    <MenuItem> Charts </MenuItem>
                    <MenuItem> Wallets </MenuItem>
                    <MenuItem> Transactions </MenuItem>
                    <MenuItem> Settings </MenuItem>
                    <MenuItem> Logout </MenuItem>
                </Menu>
            </Sidebar>
        </Grid>
    )
}

export default DefaultLayout;
