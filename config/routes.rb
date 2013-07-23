MygovTasks::Application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :tasks, except: [:new, :edit]
      resources :task_items, except: [:new, :edit]
    end
  end
end
