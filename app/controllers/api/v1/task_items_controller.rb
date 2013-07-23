module Api
  module V1
    class TaskItemsController < ApplicationController
      def index
        @task_items = TaskItem.all

        render json: @task_items
      end

      def show
        @task_item = TaskItem.find(params[:id])

        render json: @task_item
      end

      def create
        @task_item = TaskItem.new(params[:task_item])

        if @task_item.save
          render json: @task_item, status: :created, location: @task_item
        else
          render json: @task_item.errors, status: :unprocessable_entity
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