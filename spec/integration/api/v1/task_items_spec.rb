require 'spec_helper'

describe "api", type: :integration do
  describe "v1" do

    let(:task) { FactoryGirl.create(:task_with_task_items) }
    let(:task_item_1) { task.task_items[0] }
    let(:task_item_2) { task.task_items[1] }
    let(:link_1) { Link.create(name: "Groovy test link 1", url: "http://some/url/1", task_item_id: task_item_2.id) }
    let(:link_2) { Link.create(name: "Groovy test link 2", url: "http://some/url/2", task_item_id: task_item_2.id) }

    context "GET api/v1/task_items" do
      let(:url) { "api/v1/task_items" }
      let(:expected_response) {
        [
          {"task_item"=>{"id"=>task_item_1.id,
                         "name"=>"Task 1",
                         "task_id"=>task.id,
                         "description"=>task_item_1.description
                         }},
          {"task_item"=>{"id"=>task_item_2.id,
                         "name"=>"Task 2",
                         "task_id"=>task.id,
                         "description"=>task_item_2.description
                         }}
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
            "task_id"=>task.id,
            "description"=>task_item_2.description,
            "links"=>[
              {"link"=>{"name"=>"Groovy test link 1", "url"=>"http://some/url/1"}},
              {"link"=>{"name"=>"Groovy test link 2", "url"=>"http://some/url/2"}}
            ]
          }
        }
      }

      it "gets information for a specific task" do
        task
        link_1
        link_2

        get url
        response.should be_success
        expect(JSON.parse(response.body)).to eq expected_response
      end
    end

    context "POST api/v1/task_items/" do
      let(:url) { "api/v1/task_items" }
      let(:task_without_task_items) { FactoryGirl.create(:task) }
      let(:params) { {"name"=>"My new task item", "task_id"=>task_without_task_items.id} }
      let(:expected_response) {
        {"task_item"=>{"id"=>TaskItem.last.id, "name"=>"My new task item", "task_id"=>task_without_task_items.id, "links"=>[]}}
      }
      let(:expected_response_with_links) {
        {"task_item"=>{
                        "id"=>TaskItem.last.id,
                        "name"=>"My new task item",
                        "task_id"=>task_without_task_items.id,
                        "links"=>[
                          "link"=>{"name"=>"task link 1", "url"=>"http://some/link/1"}
                        ]
                      }
        }
      }

      context "correct task attributes" do

        before do
          TaskItem.all.map(&:destroy)
        end

        it "responds with the created record" do
          post url, params
          response.should be_success
          expect(JSON.parse(response.body)).to eq expected_response
          expect(TaskItem.count).to eq 1
        end

        it "creates associated links with correct attributes" do
          updated_params = params.merge("links"=>[
                                  {"name"=>"task link 1", "url"=>"http://some/link/1"}
                                ])
          post url, updated_params
          response.should be_success
          expect(JSON.parse(response.body)).to eq expected_response_with_links
          expect(TaskItem.count).to eq 1
          expect(Link.count).to eq 1
        end

        it "returns 500 with associated links with incorrect attributes" do
          updated_params = params.merge("links"=>[
                                  {"name"=>"task link 1", "url"=>"http://some/link/1"}
                                ])
          post url, updated_params.delete("name")
          response.should_not be_success
          expect(JSON.parse(response.body)).to include(
            {"message"=>"The record was not saved due to errors"}
          )
          expect(response.status).to eq 500
          expect(TaskItem.count).to eq 0
          expect(Link.count).to eq 0
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
              {"message"=>"The record was not saved due to errors"}
            )
          expect(TaskItem.count).to eq 0
          end
        end
      end
    end

  end
end