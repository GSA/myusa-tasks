module Api
  module V1
    class TasksController < ApplicationController
      include ActionController::ImplicitRender

      def index
        @tasks = Task.all
      end

      def show
        @task = Task.find(params[:id])
      end

      def create
        @task = Task.new(name: params[:name], description: params[:description])

        if @task.save
          render 'api/v1/tasks/create'
        else
          render json: {errors: @task.errors, message: "The record was not saved due to errors"}, status: 500
        end
      end

      def update
        @task = Task.find(params[:id])

        if @task.update(params[:task])
          head :no_content
        else
          render json: @task.errors, status: :unprocessable_entity
        end
      end

      def destroy
        @task = Task.find(params[:id])
        @task.destroy

        head :no_content
      end
    end
  end
end