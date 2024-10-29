import {Breadcrumbs, Button, Grid, Menu} from "@mantine/core";

interface PageHeaderProps {
  breadcrumbs: JSX.Element[]
  content?: JSX.Element
  // Note: These are props passed to the Mantine button
  primaryAction?: any
  secondaryActions?: any[]
}

export default ({ breadcrumbs, content, primaryAction, secondaryActions }: PageHeaderProps) => {
  let primaryActionItem;
  if (primaryAction) {
    let {children, ...rest} = primaryAction
    primaryActionItem = <Button {...rest}>{children}</Button>
  }
  let secondaryActionItem;
  if (secondaryActions && secondaryActions.length > 0) {
    if (secondaryActions.length == 1) {
      let {children, ...rest} = secondaryActions[0]
      secondaryActionItem = <Button {...rest}>{children}</Button>
    } else {
      secondaryActionItem = <Menu shadow="md" width={200}>
        <Menu.Target>
          <Button variant={"default"}>Actions</Button>
        </Menu.Target>

        <Menu.Dropdown>
          {secondaryActions.map(action => {
            let {children, ...rest} = action
            return <Menu.Item {...rest}>{children}</Menu.Item>
          })}
        </Menu.Dropdown>
      </Menu>
    }
  }
  return (
    <>
      <Grid>
        <Grid.Col span={8}>
          <Breadcrumbs separator=">" separatorMargin="md" mt="xs">
            {breadcrumbs}
          </Breadcrumbs>
          {content}
        </Grid.Col>
        <Grid.Col span={4}>
          {secondaryActionItem}
          {primaryActionItem}
        </Grid.Col>
      </Grid>
    </>
  )
}