module Wechat
  # 微信内部路由规则类，用于简化配置
  class Router
    # 支持一下形式
    # Weixin::Router.new(type: "text")
    # Weixin::Router.new(type: "text", content: "Hello2BusUser")
    # Weixin::Router.new(type: "text", content: /^@/)
    # Weixin::Router.new { |xml| xml[:MsgType] == 'image' }
    # Weixin::Router.new (type: "text") { |xml| xml[:Content].starts_with? "@" }
    def initialize(options, &block)
      @type = options[:type] if options[:type]
      @content = options[:content] if options[:content]
      @constraint = block if block_given?
    end
    
    def matches?(request)
      xml = request.params[:xml]
      if xml.blank?
        return false
      end
      result = true
      result = result && (xml[:MsgType] == @type) if @type
      result = result && (xml[:Content] =~ @content) if @content.is_a? Regexp
      result = result && (xml[:Content] == @content) if @content.is_a? String
      result = result && @constraint.call(xml) if @constraint
      
      result
    end
    
  end
  
  module ActionController
    # 辅助方法，用于简化操作, 将xml数据封装成对象
    def wechat_xml
      # puts '----------------------------'
      # puts params[:xml]
      # hash = params[:xml]
      @wechat_xml ||= WechatXML.new(params[:xml])
      @wechat_xml
    end
    
    class WechatXML
      attr_accessor :content, :type, :from_user, :to_user, :pic_url, :event, :event_key
      def initialize(hash)
        @content   = hash[:Content]
        @type      = hash[:MsgType]
        @from_user = hash[:FromUserName]
        @to_user   = hash[:ToUserName]
        @pic_url   = hash[:PicUrl]
        @event     = hash[:Event]
        @event_key = hash[:EventKey]
      end
    end
  end
end

ActionController::Base.class_eval do
  include ::Wechat::ActionController
end
ActionView::Base.class_eval do
  include ::Wechat::ActionController
end