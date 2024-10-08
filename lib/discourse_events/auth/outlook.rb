# frozen_string_literal: true

module DiscourseEvents
  module Auth
    class Outlook < Base
      def base_url
        "https://login.microsoftonline.com"
      end

      def authorization_url(state)
        uri = URI.parse("#{base_url}/common/oauth2/v2.0/authorize")
        uri.query =
          URI.encode_www_form(
            client_id: provider.client_id,
            response_type: "code",
            redirect_uri: provider.redirect_uri,
            state: state,
            scope: "Calendars.ReadWrite offline_access",
          )
        uri.to_s
      end

      def request_token(code)
        body = {
          client_id: provider.client_id,
          client_secret: provider.client_secret,
          grant_type: "authorization_code",
          redirect_uri: provider.redirect_uri,
          code: code,
        }
        perform_request(body)
      end

      def refresh_token!
        body = {
          client_id: provider.client_id,
          client_secret: provider.client_secret,
          grant_type: "refresh_token",
          refresh_token: provider.refresh_token,
        }
        perform_request(body)
      end

      protected

      def perform_request(body)
        response =
          Excon.post(
            "#{base_url}/common/oauth2/v2.0/token",
            headers: {
              "Content-Type" => "application/x-www-form-urlencoded",
            },
            body: URI.encode_www_form(body),
          )

        begin
          raise StandardError unless response.status == 200
          data = JSON.parse(response.body)
        rescue JSON::ParserError, StandardError => e
          log(:error, "Failed to retrieve access token for #{provider.name}")
          return false
        end

        provider.token = data["access_token"]
        provider.token_expires_at = Time.now + data["expires_in"].seconds
        provider.refresh_token = data["refresh_token"]

        if provider.save!
          ::Jobs.cancel_scheduled_job(:discourse_events_refresh_token, provider_id: provider.id)

          refresh_at = provider.reload.token_expires_at.to_time - 10.minutes
          ::Jobs.enqueue_at(refresh_at, :discourse_events_refresh_token, provider_id: provider.id)
        else
          log(:error, "Failed to save access token for #{provider.name}")
          false
        end
      end
    end
  end
end
