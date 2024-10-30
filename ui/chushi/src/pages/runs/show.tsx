import {Run, TaskStage} from "../../types";
import {apiClient} from "../../Client";
import {useLoaderData} from "react-router-dom";
import {Accordion} from "@mantine/core";

const Page = () => {
  // let { organizationName, workspaceName } = useParams();
  const { run, taskStages } = useLoaderData() as {run: Run, taskStages: TaskStage[]}

  const items = []

  let prePlanTaskStage = taskStages.find(stage => stage.stage == "pre_plan")
  if (prePlanTaskStage) {
    items.push(
      <Accordion.Item value={"pre_plan"}>
        <Accordion.Control>Pre Plan</Accordion.Control>
        <Accordion.Panel>Pre-plan task stage</Accordion.Panel>
      </Accordion.Item>
    )
  }
  // if run has pre-plan task stages
  items.push(
    <Accordion.Item value={"plan"}>
      <Accordion.Control>Plan</Accordion.Control>
      <Accordion.Panel>Plan information</Accordion.Panel>
    </Accordion.Item>
  )

  let postPlanTaskStage = taskStages.find(stage => stage.stage == "post_plan")
  if (postPlanTaskStage) {
    if (postPlanTaskStage.policyEvaluations.length > 0) {
      items.push(
        <Accordion.Item value={"policy_evaluation"}>
          <Accordion.Control>Policy Evaluation</Accordion.Control>
          <Accordion.Panel>Policy evaluation information</Accordion.Panel>
        </Accordion.Item>
      )
    }
    if (postPlanTaskStage.taskResults.length > 0) {
      items.push(
        <Accordion.Item value={"post_plan"}>
          <Accordion.Control>Post Plan</Accordion.Control>
          <Accordion.Panel>Post-plan task stage</Accordion.Panel>
        </Accordion.Item>
      )
    }
  }

  if (!run.planOnly) {
    let preApplyTaskStage = taskStages.find(stage => stage.stage == "pre_apply")
    if (preApplyTaskStage) {
      items.push(
        <Accordion.Item value={"pre_apply"}>
          <Accordion.Control>Pre Apply</Accordion.Control>
          <Accordion.Panel>Pre apply task stage</Accordion.Panel>
        </Accordion.Item>
      )
    }

    items.push(
      <Accordion.Item value={"apply"}>
        <Accordion.Control>Apply</Accordion.Control>
        <Accordion.Panel>Apply information</Accordion.Panel>
      </Accordion.Item>
    )

    let postApplyTaskStage = taskStages.find(stage => stage.stage == "post_apply")
    if (postApplyTaskStage) {
      items.push(
        <Accordion.Item value={"post_apply"}>
          <Accordion.Control>Post Apply</Accordion.Control>
          <Accordion.Panel>Post apply task stage</Accordion.Panel>
        </Accordion.Item>
      )
    }
  }

  return (
    <>
      <h4>{run.id}</h4>
      <Accordion variant="separated" multiple={true}>
        {items}
      </Accordion>
    </>
  )
}

const Loader = async ({params}: { params: any}): Promise<{run: Run, taskStages: TaskStage[]}> => {
  // Unsupported includes: cost_estimate,created_by
  const { data: run } = await apiClient.get(`/api/v2/runs/${params.runId}`, {
    params: {
      include: "plan,apply,configuration_version,configuration_version.ingress_attributes"
    }
  })
  const { data: taskStages } = await apiClient.get(`/api/v2/runs/${params.runId}/task-stages`, {
    params: {
      include: "task_results,policy_evaluations"
    }
  })
  return { run, taskStages }
}

export default {
  Page, Loader
}
