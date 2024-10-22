# frozen_string_literal: true

require 'rails_helper'

describe Api::V2::StorageController do
  Sidekiq::Testing.fake!
  before do
    PlanFileUploader.storage :file
    PlanJsonFileUploader.storage :file
    PlanRedactedJsonUploader.storage :file
    PlanStructuredFileUploader.storage :file
    PlanLogUploader.storage :file
  end

  after do
    # PlanFileUploader.remove!
  end

  {
    "plan_file": {
      "file": "tfplan",
      "content": "asdasdfasdf"
    },
    "plan_json_file": {
      "file": "tfplan.json",
      "content": "{\"file\":\"tfplan.json\"}"
    },
    "plan_structured_file": {
      "file": "structured.json",
      "content": ""
    },
    "logs": {
      "file": "logs",
      "content": ""
    },
    "redacted_json": {
      "file": "redacted.json",
      "content": ""
    }
  }.each do |attr, params|

    it "uploads plan.#{attr} successfully" do
      plan = Fabricate(:plan)
      key = Base64.strict_encode64(Vault::Rails.encrypt('transit', 'chushi_storage_url', {
        class: plan.class.name,
        id: plan.id,
        file: params["file"]
      }.to_json))

      put api_v2_upload_storage_path(key), params: params["content"], headers: {
        'Content-Type': 'text/plain'
      }

      plan = Plan.find(plan.id)
      expect(plan.public_send(attr)).to_not be_nil
      contents = Vault::Rails.decrypt('transit', 'chushi_storage_contents', plan.public_send(attr).read)
      expect(contents).to eq(params["content"])
    end
  end
end