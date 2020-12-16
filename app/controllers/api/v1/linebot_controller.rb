module Api
    module V1
        class LinebotController < ApplicationController
            require 'line/bot'

            protect_from_forgery :except => [:callback]

            def client
                @client ||= Line::Bot::Client.new do |config|
                    config.channel_secret =ENV["LINE_CHANNEL_SECRET"]
                    config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
                end
            end

            def callback
                body = request.body.read

                signature = request.env['HTTP_C_LINE_SIGNATURE']
                unless client.validate_signature(body, signature)
                    head :bad_request
                end

                events = client.parse_events_from(body)

                events.each do |event|
                    case event
                    when Line::Bot::Event::Message
                        case event.type
                        when Line::Bot::Event::MessageType::Text
                            case event.message['text']
                            when "一覧"
                                todos = Todo.all.map do |todo|
                                    {
                                        type: "button",
                                        style: "link",
                                        height: "sm",
                                        action: {
                                            type: "uri",
                                            label: todo.title,
                                            uri: "https://linecorp.com"
                                        }
                                    }
                                end
                                message = {
                                    type: "bubble",
                                    body: {
                                      type: "box",
                                      layout: "vertical",
                                      contents: [
                                        {
                                          type: "text",
                                          text: "Todoリスト",
                                          weight: "bold",
                                          size: "xl"
                                        },
                                        {
                                          type: "box",
                                          layout: "vertical",
                                          spacing: "sm",
                                          contents: [
                                            *todos,
                                            {
                                              type: "spacer",
                                              size: "sm"
                                            }
                                          ],
                                          flex: 0
                                        }
                                      ]
                                    }
                                  }
                            else                          
                                message = {
                                    type: 'text',
                                    text: event.message['text']
                                }
                            end
                            client.reply_message(event['replyToken'], message)
                        end
                    end
                end

                head :ok
            end
        end
    end
end