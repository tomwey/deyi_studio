module API
  module V1
    class AppTasksAPI < Grape::API
      
      helpers API::SharedParams
      
      resource :tasks, desc: '应用任务相关接口' do
        desc '获取任务列表'
        params do
          requires :uid, type: String, desc: '工作室ID'
        end
        get :home do
                    
          u = Studio.find_by(studio_id: params[:uid])
          if u.blank?
            return render_error(4004, '不正确的账号')
          end
          
          @progress_task = AppTask.find_by(task_id: $redis.get("#{u.studio_id}:#{client_ip}"))
          puts @progress_task
          @current_tasks = AppTask.current.on_sale.sorted.recent
          if @progress_task
            @current_tasks = @current_tasks.where.not(task_id: @progress_task.task_id)
            @progress_task_log = StudioGrabTask.where(app_task_id: @progress_task.id, state: 'pending').first
            if @progress_task_log.blank?
              progress_task = []
            else
              progress_task = [API::V1::Entities::AppTaskDetail.represent(@progress_task_log.app_task, log_id: @progress_task_log.id, expire_time: @progress_task_log.expired_at.to_i)]
            end
            # progress_task = [API::V1::Entities::AppTask.represent(@progress_task)]
          else
            progress_task = []
          end
          
          @after_tasks = AppTask.after.on_sale.sorted.recent
          
          if @current_tasks.any?
            current_tasks = API::V1::Entities::AppTask.represent(@current_tasks)
          else
            current_tasks = []
          end
          
          if @after_tasks.any?
            after_tasks = API::V1::Entities::AppTask.represent(@after_tasks)
          else
            after_tasks = []
          end
          
          if u.present?
            completed_tasks = u.app_tasks.where('studio_grab_tasks.state = ?', 'completed').order('studio_grab_tasks.id desc')
          else
            completed_tasks = []
          end
          
          { code: 0, message: 'ok', data: { progress: progress_task, current: current_tasks, after: after_tasks, completed: completed_tasks } }
        end # end get home
        
        desc "获取任务详情"
        params do
          requires :uid, type: String, desc: '用户ID或者工作室ID' 
        end
        get '/:task_id' do
          u = Studio.find_by(studio_id: params[:uid])
          
          if u.blank?
            return render_error(4004, '账户不存在')
          end
          
          task = AppTask.find_by(task_id: params[:task_id])
          if task.blank?
            return render_error(4004, '任务不存在')
          end
          
          render_json(task, API::V1::Entities::AppTaskDetail)
        end
        
        desc "抢任务"
        params do
          requires :uid, type: String, desc: '用户ID或者工作室ID'
        end
        post '/:task_id/grab' do
          u = Studio.find_by(studio_id: params[:uid])
          
          if u.blank?
            return render_error(4004, '账户不存在')
          end
          
          task = AppTask.find_by(task_id: params[:task_id])
          if task.blank?
            return render_error(4004, '任务不存在')
          end
          
          ip = client_ip
          if u.has_progressed_task?(ip)
            return render_error(1006, '有进行中的任务')
          end
          
          # 是否还有库存
          if task.grab_count >= task.put_in_count
            return render_error(1007, '任务已经下架了')
          end
          
          log = StudioGrabTask.create!(ip: ip,
                                       studio: u,
                                       app_task: task,
                                       expired_at: Time.zone.now + 30.minutes,
                                       reward: task.price - task.special_price)
          render_json(log.app_task, API::V1::Entities::AppTaskDetail, log_id: log.id, expire_time: log.expired_at.to_i)
        end # end grab
        
        desc "放弃任务"
        params do
          requires :uid, type: String, desc: '用户ID或者工作室ID'
          requires :id, type: Integer, desc: '进行中的任务记录ID'
        end
        post '/:task_id/cancel' do
          
          u = Studio.find_by(studio_id: params[:uid])
          if u.blank?
            return render_error(4004, '账户不存在')
          end
          
          task = AppTask.find_by(task_id: params[:task_id])
          if task.blank?
            return render_error(4004, '任务不存在')
          end
          
          log = StudioGrabTask.find_by(id: params[:id], app_task_id: task.id)
          if log.blank?
            return render_error(4004, '您还未抢到该任务')
          end
          
          if log.expired?
            return render_error(1008, '抢到的任务已经失效，不能取消')
          end
          
          if log.can_cancel?
            log.cancel
            render_json_no_data
          else
            render_error(1009, '不能重复取消')
          end
          
        end # end post cancel
        
        desc "提交任务"
        params do
          requires :uid, type: String, desc: '用户ID或者工作室ID'
          requires :id, type: Integer, desc: '任务记录ID'
        end
        post '/:task_id/commit' do
          
          u = Studio.find_by(studio_id: params[:uid])
          if u.blank?
            return render_error(4004, '账户不存在')
          end
          
          task = AppTask.find_by(task_id: params[:task_id])
          if task.blank?
            return render_error(4004, '任务不存在')
          end
          
          log = StudioGrabTask.find_by(id: params[:id], app_task_id: task.id)
          if log.blank?
            return render_error(4004, '您还未抢到该任务')
          end
          
          if log.expired?
            return render_error(1008, '抢到的任务已经失效，不能提交')
          end
          
          if log.canceled?
            return render_error(1010, '抢到的任务已经取消，不能提交')
          end
          
          if log.can_complete?
            log.complete
            render_json_no_data
          else
            render_error(1011, '不能重复提交')
          end
          
        end # end commit
        
      end # end resource
      
    end
  end
end