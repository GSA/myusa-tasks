require 'spec_helper'

describe "api", type: :integration do
  describe "v1" do

    before(:each) do
      @task1 = FactoryGirl.create(:task, name: 'My first task', description: 'My first task description')
      @task2 = FactoryGirl.create(:task_with_task_items, name: 'My second task with task items', description: 'My second task description')
    end

    context "GET api/v1/tasks" do
      let(:url) { "api/v1/tasks" }
      let(:expected_response) {
        [
          {"task"=>{"id"=>@task1.id, "name"=>"My first task", "description"=>"My first task description"}},
          {"task"=>{"id"=>@task2.id, "name"=>"My second task with task items", "description"=>"My second task description"}}
        ]
      }

      it "gets a list of tasks" do
        get url
        response.should be_success
        JSON.parse(response.body).should == expected_response
      end
    end

    context "GET api/v1/tasks/:id" do
      let(:url) { "api/v1/tasks/#{@task2.id}" }
      let(:expected_response) {

        {"task" =>
          {"id"=>@task2.id, "name"=>"My second task with task items",
            "task_items"=>
            [
              {"task_item"=>{"id"=>@task2.task_items[0].id, "name"=>@task2.task_items[0].name}},
              {"task_item"=>{"id"=>@task2.task_items[1].id, "name"=>@task2.task_items[1].name}}
            ]
          }
        }
      }

      it "gets information for a specific task" do
        get url
        response.should be_success
        JSON.parse(response.body).should == expected_response
      end
    end

    context "POST api/v1/tasks/" do

      let(:url) { "api/v1/tasks" }
      let(:params) { {"name"=>"My new task", "description"=>"My new task description"} }
      let(:expected_response) {
        {"task"=>{"id"=>Task.last.id, "name"=>"My new task", "description"=>"My new task description"}}
      }

      context "correct attributes" do
        it "responds the created record" do
          post url, params
          response.should be_success
          JSON.parse(response.body).should include(expected_response)
        end
      end

      context "missing required attributes" do
        required_attributes = ["name","description"]
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