module Astrails
  module Clicktale
    module Controller

      def self.included(base)
        base.class_eval do
          @@clicktale_options = {}
          around_filter :clicktaleize
          helper_method :clicktale_enabled?
          helper_method :clicktale_config
          helper_method :clicktale_path
          helper_method :clicktale_url
        end
        base.send(:extend, ClassMethods)
      end

      module ClassMethods
        def clicktale(opts = {})
          @@clicktale_options = opts
        end
      end

      def clicktale(opts = {})
        @clicktale_options = opts
      end

      def clicktaleize
        returning(yield) do
          cache_page(nil, "/clicktale/#{clicktale_cache_token}") if clicktale_enabled?
        end
      end

      def clicktale_enabled?
        @clicktale_enabled ||= clicktale_config[:enabled] && request.format.html? && request.get?
      end

      def clicktale_config
        @clicktale_config ||= Astrails::Clicktale::CONFIG.merge(@@clicktale_options || {}).merge(@clicktale_options || {})
      end


      protected

      def clicktale_cache_token(extra = "")
        @clicktale_cache_token ||= Digest::SHA1.hexdigest(Time.now.to_s.split(//).sort_by {rand}.join + extra)
      end

      def clicktale_path
        @clicktale_path ||= "/clicktale/#{clicktale_cache_token}.html"
      end

      def clicktale_url
        @clicktale_url ||= "#{request.protocol}#{request.host_with_port}#{clicktale_path}"
      end

    end
  end
end
