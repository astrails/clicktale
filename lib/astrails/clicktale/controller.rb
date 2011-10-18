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
        res = yield
        if clicktale_enabled? && response.body.present?
          top_regexp = clicktale_config[:insert_after] || /(\<body\>)/
          bottom_regexp = clicktale_config[:insert_before] || /(\<\/body\>)/
          response.body.sub!(top_regexp) { |match| match + "\n" + clicktale_config[:top] }
          response.body.sub!(bottom_regexp) { |match| clicktale_bottom + "\n" + match }

          if clicktale_config[:allowed_addresses].blank?
            cache_page(nil, "/clicktale/#{clicktale_cache_token}")
          else
            cache_page(nil, "/../tmp/clicktale/#{clicktale_cache_token}")
          end
        end
        res
      end

      def clicktale_enabled?
        @clicktale_enabled ||= clicktale_config[:enabled] &&
          request.format.try(:html?) &&
          request.get? &&
          !(request.path =~ /clicktale.*\.html$/) &&
          cookie_enabled? &&
          regexp_enabled?
      end

      def clicktale_config
        @clicktale_config ||= Astrails::Clicktale::CONFIG.merge(@@clicktale_options || {}).merge(@clicktale_options || {})
      end

      protected

      def clicktale_bottom
        clicktale_config[:bottom].gsub!(/(if.*typeof.*ClickTale.*function)/, "\nvar ClickTaleFetchFrom='#{clicktale_url}';\n\\1")
      end

      def regexp_enabled?
        clicktale_config[:do_not_replace].present? ? !(response.body =~ clicktale_config[:do_not_replace]) : true
      end

      def cookie_enabled?
        if clicktale_config[:do_not_process_cookie_name].present?
          cookies[clicktale_config[:do_not_process_cookie_name]] != clicktale_config[:do_not_process_cookie_value]
        else
          true
        end
      end

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
