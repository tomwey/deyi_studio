module API
  module V1
    class EarningsAPI < Grape::API
      
      helpers API::SharedParams
      
      resource :earnings, desc: '收益接口' do
        
        desc "获取收益统计数据"
        params do
          requires :uid, type: String, desc: "用户ID"
        end
        get :stat do
          user = Studio.find_by(studio_id:  params[:uid])
          
          if user.blank?
            return { today: 0, total: 0, balance: 0 }
          end
          
          { today: user.today_earnings, total: user.earnings, balance: user.balance }
        end # end get statics
        
        desc "获取今日收益"
        params do
          requires :uid, type: String, desc: "用户ID"
        end
        get :today do
          user = Studio.find_by(studio_id:  params[:uid])
          
          if user.blank?
            return { count: 0 }
          end
          
          { count: user.today_earnings }
        end # end get today
        
        desc "获取收益汇总"
        params do
          requires :uid, type: String, desc: "用户ID"
        end
        get :summary do
          user = Studio.find_by(studio_id:  params[:uid])
          
          if user.blank?
            return render_error(4004, '账户不存在')
          end
          
          @earnings = user.earning_details.order('id desc')
          if params[:page]
            @earnings = @earnings.paginate page: params[:page], per_page: page_size
          end
          
          render_json(@earnings, API::V1::Entities::EarningDetail)
          
        end # end get summary
        
      end # end resource
      
    end
  end
end