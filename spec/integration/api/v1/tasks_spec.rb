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
          {"task"=>{"id"=>@task1.id,
            "name"=>"My first task",
            "description"=>"My first task description",
            "task_items"=>[]}
            },
            {"task"=>{"id"=>@task2.id,
              "name"=>"My second task with task items",
            "description"=>"My second task description",
            "task_items"=> [
              {"task_item"=>{"id"=>@task2.task_items[0].id, "name"=>@task2.task_items[0].name}},
              {"task_item"=>{"id"=>@task2.task_items[1].id, "name"=>@task2.task_items[1].name}}
              ]
            }}
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

      context "without nested task_item attributes" do
        let(:url) { "api/v1/tasks" }
        let(:params) { { "task" => {"name"=>"My new task", "description"=>"My new task description"} } }
        let(:expected_response) {
          {"task"=>{"id"=>Task.last.id, "name"=>"My new task", "description"=>"My new task description"}}
        }

        context "correct attributes" do
          it "responds with the created record" do
            post url, params
            response.should be_success
            JSON.parse(response.body).should include(expected_response)
          end
        end

        context "missing required attributes" do
          required_attributes = ["name","description"]
          required_attributes.each do |attrib|
            it "responds with an error message for missing #{attrib}" do
              params["task"].delete(attrib)
              post url, params
              response.should_not be_success
              JSON.parse(response.body).should include(
                {"message"=>"The record was not saved due to errors","errors"=>{ attrib =>["can't be blank"]} }
              )
            end
          end
        end
      end

      context "with nested task_item_attributes" do

        let(:url) { "api/v1/tasks" }
        let(:params) {
          { "task" => {
              "name"=>"My new task with task items", "description"=>"My new task description with task items",
              "task_items_attributes" => [
                "name" => "mytask",
                "description" => "My task item description",
                "links_attributes" => [
                  "name" => 'mytasklink',
                  "url" => 'my/task/url'
                ]
              ]
            }
          }
        }

        let(:expected_response) {
          {"task"=>{"id"=>Task.last.id, "name"=>"My new task", "description"=>"My new task description"}}
        }

        before do
          Task.destroy_all
          TaskItem.destroy_all
        end

        it "posts nested task items with correct attributes" do
          post url, params
          response.should be_success
          expect(Task.count).to eq 1
          expect(TaskItem.count).to eq 1
          expect(Link.count).to eq 1
        end

        it "fails when nested task items don't have the required attribute 'name'" do
          params['task']['task_items_attributes'][0]['name'] = ''
          post url, params
          expect(response.success?).to eq false
          expect(Task.count).to eq 0
          expect(TaskItem.count).to eq 0
          expect(Link.count).to eq 0
        end

        required_attributes = ["name","url"]
        required_attributes.each do |attrib|
          it "fails when nested task links don't have the required attribute '#{attrib}'" do
            params['task']['task_items_attributes'][0]['links_attributes'][0][attrib] = ''
            post url, params
            expect(response.success?).to eq false
            expect(Task.count).to eq 0
            expect(TaskItem.count).to eq 0
            expect(Link.count).to eq 0
          end
        end

      end
    end
  end
end