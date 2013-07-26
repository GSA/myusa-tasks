require 'spec_helper'

describe "api", type: :integration do
  describe "v1" do

    let(:task) { FactoryGirl.create(:task_with_task_items) }
    let(:task_item_1) { task.task_items[0] }
    let(:task_item_2) { task.task_items[1] }

    context "GET api/v1/task_items" do
      let(:url) { "api/v1/task_items" }
      let(:expected_response) {
        [
          {"task_item"=>{"id"=>task_item_1.id, "name"=>"Task 1", "task_id"=>task.id}},
          {"task_item"=>{"id"=>task_item_2.id, "name"=>"Task 2", "task_id"=>task.id}}
        ]
      }

      it "gets a list of task items" do
        task
        get url
        response.should be_success
        expect(JSON.parse(response.body).length).to eq 2
        expect(JSON.parse(response.body)).to eq expected_response
      end
    end


    context "GET api/v1/tasks_items/:id" do
      let(:url) { "api/v1/task_items/#{task_item_2.id}" }
      let(:expected_response) {
        { "task_item"=>
          {
            "id"=>task_item_2.id,
            "name"=>"Task 2",
            "task_id"=>task.id
          }
        }
      }

      it "gets information for a specific task" do
        task
        get url
        response.should be_success
        expect(JSON.parse(response.body)).to eq expected_response
      end
    end

    context "POST api/v1/task_items/" do
      let(:url) { "api/v1/task_items" }
      let(:params) { {"name"=>"My new task item", "task_id"=>1234} }
      let(:expected_response) {
        {"task_item"=>{"id"=>TaskItem.last.id, "name"=>"My new task item", "task_id"=>1234}}
      }

      context "correct attributes" do
        it "responds with the created record" do
          post url, params
          response.should be_success
          JSON.parse(response.body).should eq expected_response
        end
      end

      context "missing required attributes" do
        required_attributes = ["name","task_id"]
        required_attributes.each do |attrib|
          it "responds with an error message for missing #{attrib}" do
            params.delete(attrib)
            post url, params
            response.should_not be_success
            JSON.parse(response.body).should include(
              {"message"=>"The record was not saved due to errors","errors"=>{ attrib =>["can't be blank"]} }
            )
          end
        end

      end
    end

  end
end