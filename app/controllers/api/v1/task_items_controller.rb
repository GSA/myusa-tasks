module Api
  module V1
    class TaskItemsController < ApplicationController
      include ActionController::ImplicitRender

      def index
        @task_items = TaskItem.all
        render 'api/v1/task_items/index'
      end

      def show
        @task_item = TaskItem.find(params[:id])
      end

      def create
        @task_item = TaskItem.new(name: params[:name], task_id: params[:task_id])

        if @task_item.save
          render 'api/v1/task_items/create'
        else
          render json: {errors: @task_item.errors, message: "The record was not saved due to errors"}, status: 500
        end
      end

      def update
        @task_item = TaskItem.find(params[:id])

        if @task_item.update(params[:task_item])
          head :no_content
        else
          render json: @task_item.errors, status: :unprocessable_entity
        end
      end

      def destroy
        @task_item = TaskItem.find(params[:id])
        @task_item.destroy

        head :no_content
      end
    end
  end
end